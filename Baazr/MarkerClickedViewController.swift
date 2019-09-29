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
import Firebase

class MarkerClickedViewController: UIViewController {

    @IBOutlet weak var fullScreenImageButton: UIButton!
    @IBOutlet weak var reportBtn: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var markerClickedView: UIView!
    @IBOutlet weak var MarkerClickedImageView: UIImageView!
    @IBOutlet weak var MarkerClicedTitleTextView: UILabel!
    @IBOutlet weak var MarkerClickedCostTextView: UILabel!
    @IBOutlet weak var HomeButton: UIButton!
    @IBOutlet weak var MarkerClickedDescTextView: UILabel!
    var imageLink = [String]()
    var ref : DatabaseReference?
    var costLabel = [String]()
    var descLabel = [String]()
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    var current = 0
    var nameLabel = ""
    var totalImages = ""
    var totalImagesInt = Int()
    var id = ""
    var reported = ""
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        let alert = UIAlertController(title: "This image has been reported", message: "To uncover, please press \"Uncover Picture\" to see", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
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

        print("\n\n\nReported: " + self.reported)
        
        
        if (self.reported == "True"){
            MarkerClickedImageView.image = nil
            reportBtn.setTitle("Uncover picture", for: UIControl.State.normal)
            fullScreenImageButton.isHidden = true
            prevButton.isHidden = true
            nextButton.isHidden = true
        }
        else{
            
            var imageUrl = URL(string : imageLink[current])
            MarkerClickedImageView.setImage(url: imageUrl!)
            
        }
        
        
        
        if (self.totalImagesInt == 1){
            prevButton.isHidden = true
            nextButton.isHidden = true
        }

    }
    
    
    @IBAction func reportPostClicked(_ sender: Any) {
        
        if (reportBtn.currentTitle == "Uncover picture"){
            reportedYes()
        }
        else{
            
            
            let alert = UIAlertController(title: "Report this post?", message: "Are you sure you want to report this post?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.reportedYes()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
        
        
    }
    
    func reportedYes(){
        if (reported == "True"){
            reported = "False"
            fullScreenImageButton.isHidden = false
            prevButton.isHidden = false
            nextButton.isHidden = false
            if (self.totalImagesInt == 1){
                prevButton.isHidden = true
                nextButton.isHidden = true
            }
            reportBtn.setTitle("Report this post", for: UIControl.State.normal)
        }
        else{
            reported = "True"
            fullScreenImageButton.isHidden = true
            prevButton.isHidden = true
            nextButton.isHidden = true
            reportBtn.setTitle("Uncover picture", for: UIControl.State.normal)
            Toast.show(message: "An action will be taken in 24hrs regarding the user", controller: self)
        }
        var ref: DatabaseReference!
        ref = Database.database().reference().child(id)
        ref.child("Reported").setValue(String(reported))
        
        if (reported == "True"){
            MarkerClickedImageView.image = nil
        }
        else {
            var imageUrl = URL(string : imageLink[current])
            MarkerClickedImageView.setImage(url: imageUrl!)
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
