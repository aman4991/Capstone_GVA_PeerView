//
//  PostCollectionViewCell.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import MapKit

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var delegate: ToMove!
    
    var post: Post?
    {
        didSet
        {
            do
            {
                try textView.text = post?.text
                if post?.image == nil
                {
                    imageview.image = UIImage(named: "placeholder")
                }
                else if let image = post?.image, image == ""
                {
                    imageview.image = UIImage(named: "placeholder")
                }
                else
                {
                    downloadImage(from: URL(string: post!.image!)!)
                }
            }
            catch
            {
                print(error)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dump(self.frame.width)
    }
    
    @IBAction func showLocationTapped(_ sender: Any) {
        delegate.moveToMap(coordinates: CLLocationCoordinate2D(latitude: ((post?.lat ?? "0") as NSString).doubleValue, longitude: ((post?.lng ?? "0") as NSString).doubleValue))
    }
    
    override func layoutSubviews() {
        
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.cornerRadius = 15.0
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        //Adding shadow to this UI Collection View Cell
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
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
                self?.imageview.image = UIImage(data: data)
            }
        }
    }
}
