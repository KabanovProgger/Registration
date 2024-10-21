//
//  ViewController.swift
//  LoginPass
//
//  Created by Owner on 6/24/24.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    
    var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            AppleSignIn.shared.addSignInButton(onView: self.view, frame: CGRect(x: 120, y: 700, width: 150, height: 50), completion: { appleUser, error in
                if error == nil {
                    if appleUser != nil {
                        print(appleUser?.identifier ?? "", appleUser?.fName ?? "")
                    }
                } else {
                    print("\(String(describing: error)) Please check your Apple ID in phone settings. You must be sign in to iCloud account and 2 factor authentication must be turned on.")
                }
                
            })
        } else {
            // Fallback on earlier versions
        }
        
        self.loginField.delegate = self
        self.passField.delegate = self
        
        // property of button
        
        configureGradientButton(signInButton, title: "Log in")
 
        self.passField.placeholder = "Enter password"
        self.passField.isSecureTextEntry  = true
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        updateGradientButton(signInButton)
        
    }
    
    // Hide keyboard when click on screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Настройка градиентной кнопки входа
       func configureGradientButton(_ button: UIButton, title: String) {
           button.setTitle(title, for: .normal)
           button.setTitleColor(.white, for: .normal)
           button.layer.cornerRadius =  22
           button.clipsToBounds = true
           
           gradientLayer = CAGradientLayer()
           gradientLayer?.frame = button.bounds
           gradientLayer?.colors = [UIColor.systemBlue.cgColor, UIColor.systemPink.cgColor]
           gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
           gradientLayer?.endPoint = CGPoint(x: 1, y: 0)
           button.layer.insertSublayer(gradientLayer!, at: 0)
           
       }
    
    func updateGradientButton(_ button: UIButton){
        gradientLayer?.frame = button.bounds
        
        
    }
    
    // Button enter action pressed
    @IBAction func button1Pressed(_ sender: Any) {
        guard let login = self.loginField.text, !login.isEmpty,
              let password = self.passField.text, !password.isEmpty else {
            self.alert(title: "Error", message: "Enter your login and password", style: .alert)
            return
        }
        
        // Выполняем проверку логина и пароля на сервере
        checkLoginCredentials(login: login, password: password)
    }
    
    // Security show password button
    @IBAction func showPassButton(_ sender: UIButton) {
        passField.isSecureTextEntry.toggle()
        if passField.isSecureTextEntry {
            if let image = UIImage(systemName: "eye.slash") {
                sender.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(systemName: "eye") {
                sender.setImage(image, for: .normal)
            }
        }
    }
    
    @IBAction func enterToRegistrationViewController(_ sender: Any) {
        let registrationStoryboard = UIStoryboard(name: "Registration", bundle: nil)
        let registrationVC = registrationStoryboard.instantiateViewController(withIdentifier: "RegistrationVC") as! RegistrationVC
        self.navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    // Alert control for nil login and password
    func alert(title: String, message: String, style: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Проверка логина и пароля через сервер
    func checkLoginCredentials(login: String, password: String) {
        guard let url = URL(string: "https://your-api.com/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData: [String: Any] = ["login": login, "password": password]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        } catch {
            alert(title: "Error", message: "Error while forming request.", style: .alert)
            return


}

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.alert(title: "Error",  message:"Network error or missing data.", style: .alert)
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let success = jsonResponse["success"] as? Bool, success {
                        DispatchQueue.main.async {
                          //  self.navigateToMainScreen() // Переход на главный экран
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.alert(title: "Error", message: "Incorrect login or password.", style: .alert)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alert(title: "Error",message: "Error while processing data.", style: . alert)
                }
            }
        }

        task.resume()
    }


      }
    
    // Переход на главный экран
    func navigateToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
      //  let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
          //  self.navigationController?.pushViewController(mainVC, animated: true)
        }
    
    



