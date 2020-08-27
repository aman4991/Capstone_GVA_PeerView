//
//  SettingsViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Aman on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: ViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var statusImageVuew: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ageTextField: UITextField!
    var currentUser: User!
    var ref: DatabaseReference!
    var userData: [String:String] = [:]
    var selectedImage: UIImage?
    var selectedImageURL: URL?
    var imagePickerController = UIImagePickerController()
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = Firebase.Auth.auth().currentUser!
        ref = Database.database().reference().child("Users").child(currentUser.uid)
        storageRef = Storage.storage().reference()
        getUserData()
        //        setUserData()
        setImageView()
        setTapGestures()
        ageTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        statusImageVuew.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }
    
    func setImageView()
    {
        userImageView.layer.borderWidth = 1.0
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = UIColor.white.cgColor
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
    }
    
    func setTapGestures()
    {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(imageTap)
    }
    
    @objc func imageTapped() {
        let image = UIImagePickerController()
        
        image.delegate = self
        
        image.allowsEditing = false
        
        let action_sheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: UIAlertController.Style.actionSheet)
        action_sheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            
            image.sourceType = UIImagePickerController.SourceType.camera
            
            self.present(image, animated: true, completion: nil)
        }))
        action_sheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            self.present(image, animated: true, completion: nil)
        }))
        action_sheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(action_sheet, animated: true, completion: nil)
    }
    
    func getUserData()
    {
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                if let value = snap.value as? String
                {
                    self.userData[key] = value
                }
            }
            self.setUserData()
        })
    }
    
    func setUserData()
    {
        nameTextField.text = userData["name"]
        statusImageVuew.text = userData["status"]
        ageTextField.text = userData["age"]
        if userData["gender"] == "Male"
        {
            genderSegmentedControl.selectedSegmentIndex = 0
        }
        else
        {
            genderSegmentedControl.selectedSegmentIndex = 1
        }
        if let image = userData["image"], let imageUrl = URL(string: image)
        {
            downloadImage(from: imageUrl)
        }
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.selectedImage = UIImage(data: data)
                self?.userImageView.image = self?.selectedImage
            }
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        let name = nameTextField.text
        let status = statusImageVuew.text
        let age = ageTextField.text
        let gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex) ?? "Male"
        if name == nil, name == ""
        {
            return
        }
        if age == nil, age == ""
        {
            return
        }
        userData["name"] = name
        userData["status"] = status
        userData["age"] = age
        userData["gender"] = gender
        self.ref.setValue(userData) { (error, DatabaseReference) in
            guard error == nil else
            {
                return
            }
            self.uploadImageToCloud()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        do
        {
            try Firebase.Auth.auth().signOut()
            moveToAuthenticationScreen()
        }
        catch
        {
            print(error)
        }
        
    }
    
    func moveToAuthenticationScreen()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "authentication") as! UINavigationController
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func uploadImageToCloud()
    {
        let data = selectedImage!.jpegData(compressionQuality: 0.8)! as NSData
        let photoRef = storageRef.child("profileImages").child("\(currentUser.uid).png")
        _ = photoRef.putData(data as Data, metadata: nil){ (metadata, err) in
            
            guard metadata != nil else
            {
                return
            }
            photoRef.downloadURL(completion: { url, error in
                guard let url = url, error == nil else
                {
                    return
                }
                
                let urlString = url.absoluteString
                self.userData["image"] = urlString
                self.ref.setValue(self.userData)
            })
        }
    }
}

extension SettingsViewController: UITextFieldDelegate
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

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        selectedImageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        selectedImage = image
        userImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
