//
//  SignupController.swift
//  CatFacts
//
//  Created by Игорь on 04/01/2019.
//  Copyright © 2019 Igor Podosonov. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView

class SignupController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        confirmPasswordTextField.setBottomBorder()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround() 
    }
    
    @IBAction func backToLoginScreen(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {

        var errors = [String]()
        
        //Check if email is valid
        if !isValidEmail(testStr: emailTextField.text!) {
            errors.append("Please enter a valid email")
        }
        
        //Check if email is uniqe
        let request: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "mail MATCHES %@", emailTextField.text!)
        
        if !fetchRequest(request, predicate: predicate).isEmpty {
            errors.append("This email has already been taken")
        }
        
        //Check password
        if passwordTextField.text! != confirmPasswordTextField.text! {
            errors.append("Passwords do not match")
        } else if !isValidPassword(testStr: passwordTextField.text!) {
            if passwordTextField.text!.count < 6 {
                errors.append("Your password should be at least 6 symbols long")
            }
            
            errors.append("Password should have at least one letter and one number")
        }
        
        //Create new user or show error
        if errors.isEmpty {
            let newUser = User(context: context)
            newUser.mail = emailTextField.text!
            newUser.password = passwordTextField.text!
            
            saveContext()
            
            //Set user as logged in
            UserDefaults.standard.set(true, forKey: "userlogin")
            //Go to main view
            performSegue(withIdentifier: "registerSegue", sender: self)

        } else {
            //Display error
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
