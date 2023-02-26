//
//  RegisterViewController.swift
//  MessengerApp
//
//  Created by sixpep on 21/02/23.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    private let scrollView:UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let userImage:UIImageView={
       let image = UIImageView()
        image.image = UIImage(systemName: "person")
        image.tintColor = .gray
        image.contentMode = .scaleAspectFit
        image.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        image.layer.masksToBounds = true
        image.layer.borderWidth = 2
        image.layer.borderColor = UIColor.lightGray.cgColor
        return image
    }()
    
    private let nameField:UITextField={
       let text = UITextField()
        text.autocorrectionType = .no
        text.placeholder = "Name.."
        text.returnKeyType = .next
        text.layer.cornerRadius = 12
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.leftViewMode = .always
        text.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return text
    }()
    
    private let userEmailField:UITextField={
        let text = UITextField()
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .next
        text.placeholder = "Email.."
        text.layer.cornerRadius = 12
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.leftViewMode = .always
        text.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return text
    }()
    

    
    private let passwordField:UITextField={
       let text = UITextField()
        text.autocorrectionType = .no
        text.autocapitalizationType = .none
        text.returnKeyType = .done
        text.placeholder = "Password"
        text.layer.cornerRadius = 12
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.leftViewMode = .always
        text.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        text.isSecureTextEntry = true
        return text
    }()
    
    private let registerButton:UIButton={
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.layer.cornerRadius = 12
        button.layer.backgroundColor = UIColor.systemGreen.cgColor
        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        view.addSubview(scrollView)
        scrollView.addSubview(userImage)
        scrollView.addSubview(nameField)
        scrollView.addSubview(userEmailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        userImage.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        nameField.delegate = self
        userEmailField.delegate = self
        passwordField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
//        gesture.numberOfTapsRequired = 1
//        gesture.numberOfTouchesRequired = 1
//
        userImage.addGestureRecognizer(gesture)
        
    }

    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        userImage.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        userImage.layer.cornerRadius = userImage.width/2
        nameField.frame = CGRect(x: 30, y: userImage.bottom+10, width: scrollView.width-60, height: 52 )
        userEmailField.frame = CGRect(x: 30, y: nameField.bottom+10, width: scrollView.width-60, height: 52)
        passwordField.frame = CGRect(x: 30, y: userEmailField.bottom+10, width: scrollView.width-60, height: 52)
        registerButton.frame = CGRect(x: 30, y: passwordField.bottom+30, width: scrollView.width-60, height: 52)
    }
    
    @objc func registerButtonTapped(){
        nameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        nameField.resignFirstResponder()
        guard let email = userEmailField.text,let name = nameField.text,let password = passwordField.text, !email.isEmpty,!name.isEmpty, !password.isEmpty, password.count>=6
        else{
            showAlert()
            return
        }
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult, error ==  nil else{
                print("Error in Creating User")
                return
            }
            let user = result.user
            print("Created User\(user)")
        }
    }
    
   
    
    @objc func didTapChangeProfilePic(){
        print("This is Cool")
        presentPhotoActionSheet()
    }
    
    //Firebase Login
    
   
    
    private func showAlert(){
        let alert = UIAlertController(title: "Detail missing", message: "Some detail is missing", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        present(alert, animated: true)
    }
    
}

extension RegisterViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField{
            userEmailField.becomeFirstResponder()
        }
        else if textField == userEmailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            registerButtonTapped()
        }
        return true
    }
}

extension RegisterViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default,handler: {[weak self] _ in
            self?.presentCamer()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default,handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamer(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        
        self.userImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
