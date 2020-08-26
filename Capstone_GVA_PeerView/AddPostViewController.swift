//
//  AddPostViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Aman on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import MapKit

class AddPostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var videoButton: UIButton!
    var coordinates: CLLocationCoordinate2D?
    var locationTitle: String?
    var selectedImageURL: URL?
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGestures()
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
    }

    @IBAction func postTapped(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mvc = segue.destination as? MapViewController
        {
            mvc.delegate = self
            mvc.coorindates = self.coordinates
            mvc.locationTitle = self.locationTitle
        }
    }

}

extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        selectedImageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        selectedImage = image
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
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
