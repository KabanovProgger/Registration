


import UIKit

class RegistrationVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var repPassTF: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Установка делегатов для отслеживания ввода
        emailTF.delegate = self
        phoneTF.delegate = self
        passTF.delegate = self
        repPassTF.delegate = self
    }
    
    // Метод делегата для отслеживания изменений текста в текстовом поле
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        // Проверка email
        if textField == emailTF {
            if isValidEmail(currentText) {
                hideError(for: emailTF)
                
            } else {
                showError(for: emailTF, message: "Invalid email format.")
            }
        }
        // Проверка телефона
        else if textField == phoneTF {
            if isValidPhone(currentText) {
                hideError(for: phoneTF)
            } else {
                showError(for: phoneTF, message: "Invalid phone number format.")
            }
        }
        // Проверка пароля
        else if textField == passTF {
            if validatePassword(currentText) {
                hideError(for: passTF)
            } else {
                showError(for: passTF, message: "Password must contain at least one uppercase letter, one digit, and one special character.")
            }
        }
        // Проверка совпадения паролей
        else if textField == repPassTF {
            if currentText == passTF.text {
                hideError(for: repPassTF)
            } else {
                showError(for: repPassTF, message: "Passwords don't match.")
            }
        }
        
        return true
    }
    
    // Валидация email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    // Валидация телефона
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{7,13}$"
        return NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: phone)
    }
    
    // Валидация пароля
    func validatePassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$&*]).{8,16}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegEx).evaluate(with: password)
    }
    
    // Отображение ошибки под текстовым полем
    func showError(for textField: UITextField, message: String) {
        let errorLabelTag: Int
        switch textField {
        case emailTF:
            errorLabelTag = 101
        case phoneTF:
            errorLabelTag = 102
            
        case passTF:
            errorLabelTag = 103
        case repPassTF:
            errorLabelTag = 104
        default:
            return
        }
        if let errorLabel = textField.superview?.viewWithTag(errorLabelTag) as? UILabel {
            errorLabel.text = message
            errorLabel.isHidden = false
        } else {
            let errorLabel = UILabel()
            errorLabel.tag = errorLabelTag
            errorLabel.textColor = .red
            errorLabel.font = .systemFont(ofSize: 12)
            errorLabel.text = message
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            textField.superview?.addSubview(errorLabel)
            
            NSLayoutConstraint.activate([
                errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5),
                errorLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
                errorLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor)
            ])
        }
    }
    
    // Скрытие ошибки
    func hideError(for textField: UITextField) {
        let errorLabelTag: Int
        switch textField {
        case emailTF:
            errorLabelTag = 101
        case phoneTF:
            errorLabelTag = 102
            
        case passTF:
            errorLabelTag = 103
        case repPassTF:
            errorLabelTag = 104
        default:
            return
            
        }
            if let errorLabel = textField.superview?.viewWithTag(errorLabelTag) as? UILabel {
                errorLabel.isHidden = true
            }
        }
    
        func clearAllErrors() {
            for  view in self.view.subviews {
                if let errorLabel = view.viewWithTag(100) as? UILabel{
                    errorLabel.isHidden = true
                }
            }
            
        }
        
        // Проверка уникальности email и телефона на сервере
        func checkLoginUniqueness(completion: @escaping (Bool) -> Void) {
            guard let email = emailTF.text, let phone = phoneTF.text else {
                completion(false)
                return
            }
            
            // URL для проверки уникальности
            guard let url = URL(string: "https://your-api.com/check-login") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let loginData: [String: Any] = [
                "email": email,
                "phone": phone
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
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let isUnique = json["isUnique"] as? Bool {
                        completion(isUnique)
                    } else {
                        completion(false)
                    }
                } catch {
                    print("Ошибка обработки JSON")
                    completion(false)
                }
            }
            
            task.resume()
        }
        
        // Финальная валидация всех полей перед регистрацией
        func validateFields(completion: @escaping (Bool) -> Void) {
            guard let name = nameTF.text, !name.isEmpty else {
                showError(for: nameTF, message: "Name can't be empty.")
                completion(false)
                return
            }
            
            guard let lastname = lastnameTF.text, !lastname.isEmpty else {
                showError(for: lastnameTF, message: "Lastname can't be empty.")
                completion(false)
                return
            }
            
            guard let email = emailTF.text, isValidEmail(email) else {
                showError(for: emailTF, message: "Enter a valid email.")
                completion(false)
                return
            }
            
            guard let phone = phoneTF.text, isValidPhone(phone) else {
                showError(for: phoneTF, message: "Enter a valid phone number.")
                completion(false)
                return
            }
            
            guard let password = passTF.text, validatePassword(password) else {
                showError(for: passTF, message: "Password must contain at least one uppercase letter, one digit, and one special character.")
                completion(false)
                return
            }
            
            guard let repeatPassword = repPassTF.text, repeatPassword == password else {
                showError(for: repPassTF, message: "Passwords don't match.")
                completion(false)
                return
            }
            
            // Проверка уникальности email и телефона
            checkLoginUniqueness { isUnique in
                DispatchQueue.main.async {
                    if isUnique {
                        completion(true)
                    } else {
                        self.showError(for: self.emailTF, message: "Email or phone is already used.")
                        completion(false)
                    }
                }
            }
        }
        
        // Метод для регистрации пользователя
        func registerUser() {
            validateFields { isValid in
                if isValid {
                    guard let url = URL(string: "https://your-api.com/register") else { return }
                    
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let userData: [String: Any] = [
                        "name": self.nameTF.text ?? "",
                        "lastname": self.lastnameTF.text ?? "",
                        "email": self.emailTF.text ?? "",
                        "phone": self.phoneTF.text ?? "",
                        "password": self.passTF.text ?? ""
                    ]
                    
                    // Конвертация данных в JSON
                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: userData, options: [])
                    } catch {
                        print("Ошибка сериализации JSON")
                        return
                    }
                    
                    // Отправка данных на сервер
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print("Ошибка: \(error?.localizedDescription ?? "Нет данных")")
                            return
                        }
                        
                        // Обработка ответа сервера
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
        
        // Действие при нажатии на кнопку регистрации
@IBAction func signInButtonTapped(_ sender: Any) {
            registerUser()
           //  let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
          //  let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
           //  self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

