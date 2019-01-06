//
//  LoginController.swift
//  CatFacts
//
//  Created by Игорь on 04/01/2019.
//  Copyright © 2019 Igor Podosonov. All rights reserved.
//

import UIKit
import SCLAlertView
import CoreData

class LoginController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        
        mailTextField.delegate = self
        passwordTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround() 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isLoggedIn : Bool = UserDefaults.standard.bool(forKey: "userlogin")
        
        if isLoggedIn {
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        var errors = [String]()
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "mail MATCHES %@", mailTextField.text!)
        
        let user = fetchRequest(request, predicate: predicate)
        
        //Check email
        if !isValidEmail(testStr: mailTextField.text!) {
            errors.append("Please enter a valid email")
        }
        
        //Check password
        if !isValidPassword(testStr: passwordTextField.text!) {
            if passwordTextField.text!.count < 6 {
                errors.append("Password should be at least 6 symbols long")
            }
            
            errors.append("Password should have at least one letter and one number")
        }
        
        if errors.isEmpty {
            if !user.isEmpty {
                if passwordTextField.text! == user[0].password {
                    //Auth true
                    UserDefaults.standard.set(true, forKey: "userlogin")
                    performSegue(withIdentifier: "loginSegue", sender: self)
                } else {
                    SCLAlertView().showError("Ooops...", subTitle: "Wrong password, please try again", closeButtonTitle: "Ok")
                }
            } else {
                SCLAlertView().showError("Ooops...", subTitle: "Looks like there is no user with this email", closeButtonTitle: "Ok")
            }
        } else {
            //Display an error
            SCLAlertView().showError("Ooops...", subTitle: "\(errors[0])", closeButtonTitle: "Ok")
        }
    }
    
    //MARK: - TextField Delegate Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    //MARK: - Validation functions
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(testStr:String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //MARK: - Core data functions
    
    func saveContext(){
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func fetchRequest(_ request: NSFetchRequest<User>, predicate: NSPredicate? = nil) -> [User] {
        
        if let currentPredicate = predicate {
            request.predicate = currentPredicate
        }
        
        var usersArray = [User]()
        
        do {
            usersArray = try context.fetch(request)
        } catch {
            print("Error fetching request \(error)")
        }
        
        return usersArray
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        //self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
