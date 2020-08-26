//
//  ViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-13.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        if Firebase.Auth.auth().currentUser != nil
        {
            moveToDashboard()
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func signInClicked(_ sender: Any) {
        let email = emailTextField.text
        if email == nil, email == ""
        {
            return
        }
        let password = passwordTextField.text
        if password == nil, password == ""
        {
            return
        }
        signIn(email: email!, password: password!)
    }


    func signIn(email: String, password: String)
    {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }

            guard error == nil else
            {
                strongSelf.showInvalidCredentials()
                return
            }

            strongSelf.moveToDashboard()
        }
    }

    func moveToDashboard()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "dashboardNC") as! UINavigationController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }

    func showInvalidCredentials()
    {
        showAlert(title: "Invalid Credentials", message: "Entered Email or Password is incorrect")
    }

    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}
