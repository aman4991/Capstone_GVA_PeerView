//
//  AddPostViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Aman on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import MapKit
import AVKit
import Firebase

class AddPostViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var videoButton: UIButton!
    var coordinates: CLLocationCoordinate2D?
    var locationTitle: String?
    var selectedImageURL: URL?
    var selectedImage: UIImage?
    
    let imagePickerController = UIImagePickerController()
    var videoURL: NSURL?
    
    var currentUser: User!
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGestures()
        
        currentUser = Firebase.Auth.auth().currentUser!
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        textView.resignFirstResponder()
    }
    
    func setTapGestures()
    {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageTap)
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
    
    @IBAction func locationTapped(_ sender: Any) {
        performSegue(withIdentifier: "addToLocation", sender: self)
    }
    
    @IBAction func videoTapped(_ sender: Any) {
        if videoURL == nil
        {
            selectVideo()
        }
        else
        {
            playVideo()
        }
    }
    
    func selectVideo()
    {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func playVideo()
    {
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL as URL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    @IBAction func postTapped(_ sender: Any) {
        if textView.text != "" || selectedImageURL != nil || coordinates != nil
        {
            var data: [String: String] = [:]
            if textView.text != ""
            {
                data["text"] = textView.text
            }
            if let c = coordinates
            {
                data["lat"] = String(c.latitude)
                data["lng"] = String(c.longitude)
                data["ltitle"] = locationTitle!
            }
            
            let ref = self.ref.child("Posts").child(currentUser.uid).childByAutoId()
            if data.isEmpty
            {
                if self.selectedImageURL != nil
                {
                    self.uploadImageToCloud(ref: nil)
                }
            }
            else
            {
                data["key"] = ref.key
                data["user"] = FirebaseAuth.Auth.auth().currentUser?.uid
                ref.setValue(data){ (error, DatabaseReference) in
                    guard error == nil else
                    {
                        print(error!)
                        return
                    }
                    if self.selectedImageURL != nil
                    {
                        self.uploadImageToCloud(ref: ref)
                    }
                    self.goToDashboard()
                }
            }
            
        }
    }
    
    
    func uploadImageToCloud(ref reference: DatabaseReference?)
    {
        print(7)
        if let ref = reference
        {
            ref.observeSingleEvent(of: .value, with: { snapshot in
                for task in snapshot.children {
                    print(8)
                    let id = (task as? DataSnapshot)?.key
                    print(id)
                    let data = self.selectedImage!.jpegData(compressionQuality: 0.5)! as NSData
                    let photoRef = self.storageRef.child("post_images").child("\(id).png")
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
                            var data: [String: String] = [:]
                            data["image"] = urlString
                            ref.updateChildValues(data)
                        })
                    }
                    // do other things
                }
            })
        }
        else
        {
            let data = self.selectedImage!.jpegData(compressionQuality: 0.5)! as NSData
            let photoRef = self.storageRef.child("post_images").child("\(UUID().uuidString).png")
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
                    var data: [String: String] = [:]
                    data["image"] = urlString
                    let ref = self.ref.child("Posts").child(self.currentUser.uid).childByAutoId()
                    data["key"] = ref.key
                    data["user"] = FirebaseAuth.Auth.auth().currentUser?.uid
                    ref.setValue(data)
                    self.goToDashboard()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController
        {
            mvc.delegate = self
            mvc.coorindates = self.coordinates
            mvc.locationTitle = self.locationTitle
        }
    }
    
    func goToDashboard()
    {
        tabBarController?.selectedIndex = 0
    }
    
}

extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            
            if mediaType  == "public.image" {
                selectedImageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
                let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
                selectedImage = image
                imageView.image = image
                picker.dismiss(animated: true, completion: nil)
            }
            
            if mediaType == "public.movie" {
                videoURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerReferenceURL")] as? NSURL
                print("videoURL: \(videoURL)")
                imagePickerController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddPostViewController: Callbacks
{
    func setCoordinates(coordinates: CLLocationCoordinate2D, title: String) {
        self.coordinates = coordinates
        self.locationTitle = title
    }
}
