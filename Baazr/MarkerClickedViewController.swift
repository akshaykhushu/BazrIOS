//
//  MarkerClickedViewController.swift
//  Baazr
//
//  Created by akkhushu on 6/19/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import UIKit
import Cache
import Imaginary
import MapKit

class MarkerClickedViewController: UIViewController {

    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var markerClickedView: UIView!
    @IBOutlet weak var MarkerClickedImageView: UIImageView!
    @IBOutlet weak var MarkerClicedTitleTextView: UILabel!
    @IBOutlet weak var MarkerClickedCostTextView: UILabel!
    @IBOutlet weak var HomeButton: UIButton!
    @IBOutlet weak var MarkerClickedDescTextView: UILabel!
    var imageLink = [String]()
    var costLabel = [String]()
    var descLabel = [String]()
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    var current = 0
    var nameLabel = ""
    var totalImages = ""
    var totalImagesInt = Int()
    var id = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        current = 0

        MarkerClickedCostTextView.text = costLabel[current]
        MarkerClicedTitleTextView.text = nameLabel
        MarkerClickedDescTextView.text = descLabel[current]
        // Do any additional setup after loading the view.\
        self.totalImagesInt = Int(totalImages)!
        print("Marker Clicked " + id)
        print("\n\n\n\nLongitude    \(self.longitude)" )
        
        var imageUrl = URL(string : imageLink[current])
        MarkerClickedImageView.setImage(url: imageUrl!)
        
        if (self.totalImagesInt == 1){
            prevButton.isHidden = true
            nextButton.isHidden = true
        }
        
        
    }
    
    
    @IBAction func directionsBtnClicked(_ sender: Any) {
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.nameLabel)"
        mapItem.openInMaps(launchOptions: options)
    }
    
    
    @IBAction func HomeButtonPressed(_ sender: Any) {
//        self.performSegue(withIdentifier: "Home", sender: self)
//        MarkerClicedTitleTextView.text = ""
        
         navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "FullImage", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "FullImage" ){
            var vc = segue.destination  as! FullImageViewController
            vc.imageLink = URL(string : imageLink[current])
            
            
        }
        
    }
    
    
    
    
    @IBAction func MarkerClickedNextButtonPressed(_ sender: Any) {
        if (self.current >= self.totalImagesInt - 1) {
            self.current = 0
            MarkerClickedCostTextView.text = costLabel[current]
            MarkerClicedTitleTextView.text = nameLabel
            MarkerClickedDescTextView.text = descLabel[current]
            var imageUrl = URL(string : imageLink[current])
            MarkerClickedImageView.setImage(url: imageUrl!)
            return
        }
        self.current += 1
        MarkerClickedCostTextView.text = costLabel[current]
        MarkerClicedTitleTextView.text = nameLabel
        MarkerClickedDescTextView.text = descLabel[current]
        var imageUrl = URL(string : imageLink[current])
        MarkerClickedImageView.setImage(url: imageUrl!)
    }
    
    
    @IBAction func MarkerClickedPrevButtonPressed(_ sender: Any) {
        if (self.current <= 0 ) {
            self.current = self.totalImagesInt - 1
            MarkerClickedCostTextView.text = costLabel[current]
            MarkerClickedDescTextView.text = descLabel[current]
            MarkerClicedTitleTextView.text = nameLabel
            var imageUrl = URL(string : imageLink[current])
            MarkerClickedImageView.setImage(url: imageUrl!)
            return
        }
        self.current -= 1
        MarkerClickedCostTextView.text = costLabel[current]
        MarkerClickedDescTextView.text = descLabel[current]
        MarkerClicedTitleTextView.text = nameLabel
        var imageUrl = URL(string : imageLink[current])
        MarkerClickedImageView.setImage(url: imageUrl!)
    }
    
    @IBAction func unwindToMarkerClicked(_ sender: UIStoryboardSegue) {}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
