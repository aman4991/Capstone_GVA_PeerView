//
//  MapViewController.swift
//  Capstone_GVA_PeerView
//
//  Created by Varinder Chahal on 2020-08-26.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    var delegate: Callbacks?
    var coorindates: CLLocationCoordinate2D?
    var locationTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(addLocation))
        map.addGestureRecognizer(tap)
        if let c = coorindates
        {
            showAnnotation(coordinates: c, title: locationTitle!)
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func addTapped(_ sender: Any) {
        if let c = coorindates
        {
            delegate?.setCoordinates(coordinates: c, title: locationTitle!)
            navigationController?.popViewController(animated: true)
        }
        else
        {
            showAlert(title: "Invalid Location", message: "Please select a valid location")
        }
    }


    @objc func addLocation(gestureRecognizer:UITapGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: map)
        let newCoordinates = map.convert(touchPoint, toCoordinateFrom: map)
        let location = CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription )
                return
            }

            self.locationTitle = self.getTitle(placemarks?[0])
            self.coorindates = newCoordinates
            self.showAnnotation(coordinates: newCoordinates, title: self.locationTitle!)
        })
    }

    func showAnnotation(coordinates: CLLocationCoordinate2D, title: String)
    {
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        annotation.title = title
        print("title: \(title)")
        self.map.addAnnotation(annotation)
    }


    func getTitle( _ placemark: CLPlacemark?) -> (String)
    {
        var title = ""
        if placemark == nil
        {
            return ("Unknown")
        }
        if placemark!.subThoroughfare != nil
        {
            title.append(placemark!.subThoroughfare!)
        }
        if placemark!.thoroughfare != nil
        {
            if(title != "")
            {
                title.append(", ")
            }
            title.append(placemark!.thoroughfare!)
        }
        return (title)
    }


    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))

        self.present(alert, animated: true)
    }
}
