//
//  SignUpViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    var ref: DatabaseReference!
    var name: String?
    var email: String?
    var password: String?
    var age: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ageTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        self.name = nameTextField.text
        if name == nil, name == ""
        {
            return
        }
        self.email = emailTextField.text
        if email == nil, email == ""
        {
            return
        }
        self.password = passwordTextField.text
        if password == nil, password == ""
        {
            return
        }
        self.age = ageTextField.text
        if age == nil, age == ""
        {
            return
        }
        signUp(name: name!, email: email!, password: password!)
    }
    
    func signUp(name: String, email: String, password: String!)
    {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            //            guard let strongSelf = self else
            //            {
            //                return
            //            }
            
            guard error == nil else
            {
                self.showAlert(title: "Registeration Failed!", message: "There was some problem in creating your account")
                return
            }
            
            self.addUserData()
        }
    }
    
    func addUserData()
    {
        let gender: String = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex) ?? "Male"
        let user = Firebase.Auth.auth().currentUser
        
        var map: [String: String] = [:]
        map["email"] = email
        map["name"] = name
        map["image"] = ""
        map["status"] = ""
        map["age"] = age
        map["gender"] = gender
        
        self.ref.child("Users").child(user!.uid).setValue(map) { (error, DatabaseReference) in
            guard error == nil else
            {
                return
            }
            self.moveToDashboard()
        }
    }
    
    func moveToDashboard()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "dashboardNC") as! UINavigationController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

extension SignUpViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField.keyboardType == .numberPad
        {
            let maxLength = 2
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
