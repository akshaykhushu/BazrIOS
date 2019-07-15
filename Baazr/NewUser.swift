//
//  NewUser.swift
//  Baazr
//
//  Created by akkhushu on 6/26/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class NewUser: UIViewController, GIDSignInUIDelegate {

    @IBOutlet var SignInView: UIView!
    
    @IBOutlet weak var forgotPasswordEmailID: UITextField!
    @IBOutlet var forgotPasswordView: UIView!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var emailIdTextField: UITextField!
    @IBOutlet weak var alreadyCreatedUserPassword: UITextField!
    @IBOutlet weak var alreadyCreatedUserEmailID: UITextField!
    @IBOutlet var RegisterUserView: UIView!
    
    @IBAction func googleSignInButtonPressed(_ sender: Any) {

//        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func registerViewCancelBtn(_ sender: Any) {
        RegisterUserView.removeFromSuperview()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let screenSize = UIScreen.main.bounds
        
        self.forgotPasswordView.frame.size.width = screenSize.width
        self.forgotPasswordView.frame.size.height = screenSize.height
        
        self.RegisterUserView.frame.size.width = screenSize.width
        self.RegisterUserView.frame.size.height = screenSize.height
    }
    
    @IBAction func forgotPasswordCancelBtnClicked(_ sender: Any) {
        self.forgotPasswordView.removeFromSuperview()
    }
    @IBAction func forgotPasswordBtnClicked(_ sender: Any) {
        self.view.addSubview(forgotPasswordView)
    }
    
    @IBAction func sendPasswordResetLinkBtnClicked(_ sender: Any) {
        if (forgotPasswordEmailID.text == nil || forgotPasswordEmailID.text == "" ){
            Toast.show(message: "Please enter Email ID", controller: self)
            return
        }
        var email = forgotPasswordEmailID.text!
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            Toast.show(message: "Password reset link has been sent to the email id", controller: self)
        }
        self.forgotPasswordView.removeFromSuperview()
    }
    
    @IBAction func NewUserRegister(_ sender: Any) {
        
        if ((emailIdTextField.text == nil) || (emailIdTextField.text! == "") || !(emailIdTextField.text!.contains("@")) || !(emailIdTextField.text!.contains(".com"))){
            self.view.endEditing(true)
            Toast.show(message: "Please Enter correct Email ID", controller: self)
            return
        }
        
        if (pwdTextField.text == nil || pwdTextField.text!.count <= 8) {
            self.view.endEditing(true)
            return
        }
        
        
        Auth.auth().createUser(withEmail: emailIdTextField.text!, password: pwdTextField.text!, completion: {(user, error) in
            
            Auth.auth().currentUser?.sendEmailVerification { (error) in
                print("\n\nemailVerificationSent")
            }
            
            if user != nil {
                print("Register Successful")
            }
            else {
                if let myerror = error?.localizedDescription{
                    print("\n\n\n\n ERROR")
                    print(myerror)
                }
                else{
                    print("Error")
                }
            }
            
        })
        
        
        
        RegisterUserView.removeFromSuperview()
        
        Toast.show(message: "A verification email has been sent to the email id you mentioned", controller: self)
    }
    
    
    @IBAction func AlreadyCreatedUserSignIn(_ sender: Any) {
        
        if ((alreadyCreatedUserEmailID.text == nil) || (alreadyCreatedUserEmailID.text! == "") || !(alreadyCreatedUserEmailID.text!.contains("@")) || !(alreadyCreatedUserEmailID.text!.contains(".com"))){
            self.view.endEditing(true)
            Toast.show(message: "Please Enter correct Email ID", controller: self)
            return
        }
        
        if (alreadyCreatedUserPassword.text == nil || alreadyCreatedUserPassword.text! == "") {
            self.view.endEditing(true)
            Toast.show(message: "Please Enter correct Email ID or Password", controller: self)
            return
        }
        self.view.endEditing(true)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user == nil){
                Toast.show(message: "Please Verify your email", controller: self)
                return
            }
            
            if (user!.isEmailVerified) {
                Auth.auth().signIn(withEmail: self.alreadyCreatedUserEmailID.text!, password: self.alreadyCreatedUserPassword.text!, completion: { (user, error) in
                    if (user != nil) {
                        
                        print("Sign In Successful")
                        
                        self.performSegue(withIdentifier: "OpenBaazr", sender: self)
                        return
                    }
                    else {
                        if let myerror = error?.localizedDescription{
                            print(myerror)
                        }
                        else{
                            print("Error")
                            return
                        }
                        return
                    }
                })
            }
        }
        
    }

    @IBAction func RegisterUser(_ sender: Any) {
        self.view.addSubview(RegisterUserView)
    }

}
