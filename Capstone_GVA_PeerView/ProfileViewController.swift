//
//  ProfileViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Aman on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: ViewController {

    @IBOutlet weak var settingsUIImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    var ref: DatabaseReference!
    var currentUser: User!
    var storageRef: StorageReference!
    var userData: [String:String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setTapGestures()
        currentUser = Firebase.Auth.auth().currentUser!
        ref = Database.database().reference().child("Users").child(currentUser.uid)
        storageRef = Storage.storage().reference()
        getUserData()
        setImageView()
        // Do any additional setup after loading the view.
    }

    func setTapGestures()
    {
        let settingTap = UITapGestureRecognizer(target: self, action: #selector(settingsTapped))
        settingsUIImageView.isUserInteractionEnabled = true
        settingsUIImageView.addGestureRecognizer(settingTap)
    }

    func setImageView()
    {
        profileImageView.layer.borderWidth = 1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    @objc func settingsTapped() {
      performSegue(withIdentifier: "toSettingsVC", sender: self)
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
            if let image = self.userData["image"], let imageUrl = URL(string: image)
            {
                self.downloadImage(from: imageUrl)
            }
        })
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
                self?.profileImageView.image = UIImage(data: data)
            }
        }
    }

}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        return cell
    }
}
