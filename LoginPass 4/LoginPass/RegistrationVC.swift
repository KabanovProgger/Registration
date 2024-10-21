
import UIKit

class RegistrationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var loginTF: UITextField! // Одно поле для email/телефона
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var repPassTF: UITextField!
   

    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Устанавливаем плейсхолдер
        loginTF.placeholder = "Enter your email or phone"
        loginTF.delegate = self
    }

    // Метод делегата для отслеживания изменений текста в текстовом поле
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string

        if isValidEmail(currentText) {
            print("Это email")
        } else if isValidPhone(currentText) {
            print("Это телефон")
        } else {
            print("Неверный формат")
        }

        return true
    }

    // Валидация для email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }

    // Валидация для телефона
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{7,13}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: phone)
    }

    // Валидация имени и фамилии
    func validateName(_ name: String) -> Bool {
        let nameRegEx = "^[a-zA-Zа-яА-Я]+$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegEx).evaluate(with: name)
    }

    // Валидация пароля
    func validatePassword(_ password: String) -> Bool {
        let passwordRegEx = "[A-Z0-9a-z._%+-]{8,16}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: password)
    }

    // Проверка уникальности логина
    func checkLoginUniqueness(completion: @escaping (Bool) -> Void) {
        guard let login = loginTF.text else {
            completion(false)
            return
        }

        // URL для проверки уникальности логина
        guard let url = URL(string: "https://your-api.com/check-login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: Any] = [
            "login": login
        ]

        // Конвертируем данные в JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        } catch {
            print("Ошибка сериализации JSON")
            completion(false)
            return
        }

        // Выполняем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка: \(error?.localizedDescription ?? "Нет данных")")
                completion(false)
                return
            }

            // Обрабатываем ответ сервера
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let isUnique = json["isUnique"] as? Bool {
                        completion(isUnique)
                    } else {
                        completion(false)
                    }
                }
            } catch {
                print("Ошибка обработки JSON")
                completion(false)
            }
        }

        task.resume()
    }

    // Финальная валидация всех полей перед регистрацией
    // Метод для финальной валидации всех полей перед регистрацией
    func validateFields(completion: @escaping (Bool) -> Void) {
        guard let name = nameTF.text, validateName(name) else {
            showAlert("Error", "Name can contain only letters.")
            completion(false)
            return
        }
        
        guard let lastname = lastnameTF.text, validateName(lastname) else {
            showAlert("Error", "Lastname can contain only letters.")
            completion(false)
            return
        }
        
        guard let login = loginTF.text else {
            showAlert("Error", "Enter email or phone.")
            completion(false)
            return
        }
        
        if isValidEmail(login) {
            print("Email валиден")
        } else if isValidPhone(login) {
            print("Телефон валиден")
        } else {
            showAlert("Error", "Enter correct email or phone.")
            completion(false)
            return
        }

        guard let password = passTF.text, validatePassword(password) else {
            showAlert("Eroor", "Password must contain between 8 and 16 characters, including upper/lower case, numbers and special characters..")
            completion(false)
            return
        }

        guard let repeatPassword = repPassTF.text, password == repeatPassword else {
            showAlert("Error", "Passwords don't match.")
            completion(false)
            return
        }
        
        // Проверка уникальности логина
        checkLoginUniqueness { isUnique in
            DispatchQueue.main.async {
                if isUnique {
                    print("Логин уникален")
                    completion(true)
                } else {
                    self.showAlert("Error", "This login is already used.")
                    completion(false)
                }
            }
        }
    }

    // Метод для показа сообщения об ошибке
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Метод для отправки данных на сервер (если все поля валидны)
    func registerUser() {
        validateFields { isValid in
            if isValid {
                // Делаем регистрацию только если валидация успешна
                guard let url = URL(string: "https://your-api.com/register") else { return }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let userData: [String: Any] = [
                    "name": self.nameTF.text ?? "",
                    "lastname": self.lastnameTF.text ?? "",
                    "login": self.loginTF.text ?? "",
                    "password": self.passTF.text ?? "",
      
                ]

                // Конвертируем данные в JSON
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
                } catch {
                    print("Ошибка сериализации JSON")
                    return
                }

                // Выполняем запрос
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Ошибка: \(error?.localizedDescription ?? "Нет данных")")
                        return
                    }

                    // Обрабатываем ответ сервера
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        print("Успешная регистрация")
                    } else {
                        print("Ошибка регистрации")
                    }
                }

                task.resume()
            }
        }
    }
    
    //func enterToViewController() {
        //let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
       // let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
       // self.navigationController?.pushViewController(viewController, animated: true)
  //  }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        registerUser()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
