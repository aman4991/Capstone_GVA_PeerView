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
import MobileCoreServices

class AddPostViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var videoButton: UIButton!
    var coordinates: CLLocationCoordinate2D?
    var locationTitle: String?
    var selectedImageURL: URL?
    var selectedImage: UIImage?
    
    let imagePickerController = UIImagePickerController()
    var videoData: Data?
    
    var currentUser: User!
    var ref: DatabaseReference!
    var storageRef: StorageReference!
    var hasImage = false
    var hasVideo = false
    
    
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
        if videoData == nil
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
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("dummy.mp4")
        
        do {
            try self.videoData!.write(to: cacheURL, options: .atomicWrite)
        } catch {
            print("Failed with error:", error.localizedDescription)
        }
        let player = AVPlayer(url: cacheURL)
        let vcPlayer = AVPlayerViewController()
        vcPlayer.player = player
        vcPlayer.player?.play()
        present(vcPlayer, animated: true, completion: nil)
    }
    
    func uploadImageToCloud(ref reference: DatabaseReference?)
    {
        print("called uploadImageToCloud")
        if self.hasImage
        {
            if let ref = reference
            {
                let data = self.selectedImage!.jpegData(compressionQuality: 0.5)! as NSData
                let photoRef = self.storageRef.child("post_images").child("\(ref.key!).png")
                photoRef.putData(data as Data, metadata: nil){ (metadata, err) in
                    guard metadata != nil else
                    {
                        print("error in image upload: \(err)")
                        return
                    }
                    photoRef.downloadURL(completion: { url, error in
                        guard let url = url, error == nil else
                        {
                            print("error in image upload: \(err)")
                            return
                        }
                        
                        let urlString = url.absoluteString
                        var data: [String: String] = [:]
                        data["image"] = urlString
                        ref.updateChildValues(data)
                        self.hasImage = false
                        self.imageView.image = UIImage(named: "placeholder")
                        if self.hasVideo
                        {
                            print("has video")
                            self.uploadVideoToCloud(ref: ref)
                        }
                        else
                        {
                            self.goToDashboard()
                        }
                    })
                }
            }
            else
            {
                let data = self.selectedImage!.jpegData(compressionQuality: 0.5)! as NSData
                let photoRef = self.storageRef.child("post_images").child("\(UUID().uuidString).png")
                print("photoRef: \(photoRef)")
                photoRef.putData(data as Data, metadata: nil){ (metadata, err) in
                    guard metadata != nil else
                    {
                        print("error in image upload: \(err)")
                        return
                    }
                    photoRef.downloadURL(completion: { url, error in
                        guard let url = url, error == nil else
                        {
                            print("error in image upload: \(err)")
                            return
                        }
                        
                        let urlString = url.absoluteString
                        var data: [String: String] = [:]
                        data["image"] = urlString
                        let ref = self.ref.child("Posts").child(self.currentUser.uid).childByAutoId()
                        data["key"] = ref.key
                        data["user"] = FirebaseAuth.Auth.auth().currentUser?.uid
                        ref.setValue(data)
                        self.hasImage = false
                        self.imageView.image = UIImage(named: "placeholder")
                        if self.hasVideo
                        {
                            print("has video")
                            self.uploadVideoToCloud(ref: ref)
                        }
                        else
                        {
                            self.goToDashboard()
                        }
                    })
                }
            }
        }
        else if self.hasVideo
        {
            print("has video")
            self.uploadVideoToCloud(ref: reference)
        }
        
    }
    
    func uploadVideoToCloud(ref reference: DatabaseReference?)
    {
        print("got to uploadVideoToCloud")
        if let ref = reference
        {
            print("reference is not nil: \(ref)")
            let videoRef = self.storageRef.child("post_videos").child("\(ref.key!).mp4")
            print("videoRef: \(videoRef)")
            videoRef.putData(self.videoData!, metadata: nil){ (metadata, err) in
                guard metadata != nil else
                {
                    print("error in video upload: \(err?.localizedDescription)")
                    return
                }
                videoRef.downloadURL(completion: { url, error in
                    guard let url = url, error == nil else
                    {
                        print("error in video upload: \(err?.localizedDescription)")
                        return
                    }
                    
                    let urlString = url.absoluteString
                    var data: [String: String] = [:]
                    data["video"] = urlString
                    ref.updateChildValues(data)
                    self.hasVideo = false
                    self.videoButton.setBackgroundImage(UIImage(systemName: "video"), for: .normal)
                    self.goToDashboard()
                })
            }
            // do other things
        }
        else
        {
            print("reference is nil")
            let file_name = "\(UUID().uuidString.replacingOccurrences(of: "-", with: "_", options: .caseInsensitive, range: nil)).mp4"
            print("file name: \(file_name)")
            let videoRef = self.storageRef.child("post_videos").child(file_name)
            print("videoRef: \(videoRef)")
            videoRef.putData(self.videoData! , metadata: nil){ (metadata, err) in
                guard metadata != nil else
                {
                    print("error in video upload: \(err?.localizedDescription)")
                    return
                }
                videoRef.downloadURL(completion: { url, error in
                    guard let url = url, error == nil else
                    {
                        print("error in video upload: \(err?.localizedDescription)")
                        return
                    }
                    
                    let urlString = url.absoluteString
                    var data: [String: String] = [:]
                    data["video"] = urlString
                    let ref = self.ref.child("Posts").child(self.currentUser.uid).childByAutoId()
                    data["key"] = ref.key
                    data["user"] = FirebaseAuth.Auth.auth().currentUser?.uid
                    ref.setValue(data)
                    self.hasVideo = false
                    self.videoButton.setBackgroundImage(UIImage(systemName: "video"), for: .normal)
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
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
                //                print("videoURL: \(videoURL)")
                self.videoData = NSData(contentsOf: videoURL! as URL) as Data?
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
