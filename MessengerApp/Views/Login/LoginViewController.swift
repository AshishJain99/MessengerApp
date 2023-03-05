//
//  LoginViewController.swift
//  MessengerApp
//
//  Created by sixpep on 21/02/23.
//

import UIKit
import FirebaseAuth
import FacebookLogin

class LoginViewController: UIViewController {

    private let scrollView:UIScrollView = {
       let scrollView=UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let emailField:UITextField={
        let field=UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .done
        field.isSecureTextEntry = true
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password.."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let LoginButton:UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let FacebookLoginButton:FBLoginButton={
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        LoginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        FacebookLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(LoginButton)
        scrollView.addSubview(FacebookLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom+10 , width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom+10, width: scrollView.width-60, height: 52)
        LoginButton.frame = CGRect(x: 30, y: passwordField.bottom+10, width: scrollView.width-60, height: 52)
        FacebookLoginButton.frame = CGRect(x: 30, y: LoginButton.bottom+10, width: scrollView.width-60, height: 52)
        FacebookLoginButton.frame.origin.y = LoginButton.bottom+20
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,let password = passwordField.text,
              !email.isEmpty, !password.isEmpty,password.count >= 6 else{
            alertUserLoginError()
            return
        }
        
        //Firebase Login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] AuthResult, error in
            
            guard let strongSelf = self else{
                return
            }
            
            guard let result = AuthResult, error == nil else{
                print("Failed to login")
                return
            }
            let user  = result.user
            print("Congrats loged in \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
            
        }
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops", message: "Please Enter all the Information", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc =  RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)

    }
    
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        
        return true
    }
    
}

extension LoginViewController:LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("User failed to Login with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil, httpMethod: .get)
        
        
        facebookRequest.start(completionHandler: {
            _,result,error in
            
            guard let result = result as? [String:Any],error == nil else{
                print("Problem in here")
                return
            }
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else{
                print("Could not get email id or username")
                return
            }
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists{
                    DatabaseManager.shared.inserUser(with: ChatAppUser(Name: userName, emailAddress: email))
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) {[weak self] authResult, error in
                
                guard let strongSelf = self else{
                    return
                }
                
                guard authResult != nil, error ==  nil else {
                    print("Facebook credentials login failed, MFA may be needed")
                    return
                }
                
                print("Successfully loged user in")
                strongSelf.navigationController?.dismiss(animated: true)
            }
            
        })
        
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    
}
