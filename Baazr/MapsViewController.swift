//
//  ViewController.swift
//  Baazr
//
//  Created by akkhushu on 5/3/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import AVFoundation
import Firebase
import Lightbox

class MapsViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextViewDelegate, GMUClusterManagerDelegate, UINavigationControllerDelegate, GMUClusterRendererDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
   
    
    
    //***************************
    
    @IBOutlet weak var transparentButton: UIButton!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var listViewButton: UIButton!
    @IBOutlet var menuBar: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var markerViewMap: UIView!
    
    @IBOutlet weak var mainSearchButton: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var costTextView: UITextView!
    
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var addMoreImagesButton: UIButton!
    @IBOutlet weak var saveBtnNewMarkerView: UIButton!
    @IBOutlet var newMarker: UIView!
    //***************************
    
    @IBOutlet weak var listBtn: UIButton!
    var storageRef: StorageReference?
    var ref : DatabaseReference?
    var user : User?
    var databaseHandle: DatabaseHandle?
    var postData = [String]()
    public static var markerList = [Marker]()
    @IBOutlet weak var takepictureBtn: UIButton!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var markerClicked: GMSMarker!
    var name : String!
    var costName : Bool = false
    var markerClickedName: String!
    var cost : String!
    public static var latitude = 0.0
    public static var longitude = 0.0
    var imagePicker: UIImagePickerController!
    public static var imageData : UIImage!
    var descList = [String]()
    var costList = [String]()
    var titleMarker : String!
    var noOfImages : Int = 0
    var currencyUsed : String = "$"
    var imageList = [String]()
    var uploadDict: [String: String] = [:]
    var idTitleMap : [String: Marker] = [:]

    @IBOutlet weak var takePictureBtn: UIButton!
    
    let currency = ["$", "₹", "€", "¥", "£"]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currency[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currencyUsed = currency[row]
    }
    
    
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        signout()
    }
    
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "SearchListView", sender: self)
    }
    
    func signout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        self.performSegue(withIdentifier: "SignOut", sender: self)
    }
    @IBAction func newPictureButtonPressed(_ sender: Any) {
        self.newpicturebtn()
        
    }
    func newpicturebtn(){
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func morePicturesBtnPressed(_ sender: Any) {
        saveBtnPressed()
        noOfImages += 1
        
        self.titleTextView.text = ""
        self.costTextView.text = ""
        self.descTextView.text = ""

        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func saveBtnPressed() {
        if (self.titleTextView.text! == nil || self.titleTextView.text! == "") {
            self.costName = true
            Toast.show(message: "Please enter title", controller: self)
            return
        }
        if (self.costTextView.text! == nil || self.costTextView.text! == "") {
            self.costName = true
            Toast.show(message: "Please enter cost", controller: self)
            return
        }
        else if (self.costTextView.text! != nil ) {
            let letters = NSCharacterSet.letters
            let range = costTextView.text!.rangeOfCharacter(from: letters)
            
            // range will be nil if no letters is found
            if range != nil {
                self.costName = true
                Toast.show(message: "Invalid cost value", controller: self)
                return
            }
        }
        
        if (self.descTextView.text! == nil || self.descTextView.text! == "") {
            Toast.show(message: "Please enter description", controller: self)
            return
        }
        costList.append(self.currencyUsed + costTextView.text!)
        titleMarker = titleTextView.text!
        descList.append(descTextView.text!)
    }
    
    @IBAction func uploadBtnPressed(_ sender: Any) {
        saveBtnPressed()
        var ref: DatabaseReference!
        ref = Database.database().reference().child(user!.uid)
        
        if (self.costName){
            return
        }
       for i in stride(from: 0, to: self.imageList.count, by: 1) {
            uploadDict["Bitmap\(i)"] = self.imageList[i]
            uploadDict["Cost\(i)"] = self.costList[i]
            uploadDict["Description\(i)"] = self.descList[i]
        }
        uploadDict["Id"] = self.user!.uid
        uploadDict["LocationLati"] = String(MapsViewController.latitude)
        uploadDict["LocationLong"] = String(MapsViewController.longitude)
        uploadDict["Title"] = self.titleMarker
        uploadDict["TotalImages"] = String(self.imageList.count)
        
        ref.setValue(uploadDict)
        
        self.imageList.removeAll()
        self.costList.removeAll()
        self.descList.removeAll()
            newMarker.removeFromSuperview()
        
    }
    
    @IBAction func saveMarkerBtn(_ sender: Any) {
        saveBtnPressed()
    }
    
    let blackView = UIView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    
    let cellId = "cellId"
    
    let settings: [Setting] = {
        return [Setting(name: "Take a new image"), Setting(name: "List View"), Setting(name: "Help"), Setting(name: "Terms and Conditions"), Setting(name: "Log Out")]
    }()
    
    @IBAction func MoreButtonPressed(_ sender: Any) {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white:0, alpha:0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(blackView)
            window.addSubview(collectionView)
            let height: CGFloat = CGFloat(settings.count * 50)
            let y = window.frame.height - height
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(settings: Setting) {
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
            }
        }
    
    
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell
        let setting = settings[indexPath.item]
        cell.setting = setting
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = self.settings[indexPath.item]
//        print("\n\n\n\n\n\n\n\(setting.name)")
        handleDismiss(settings: setting)
        
        if setting.name == "Log Out" {
            self.signout()
        }
        else if setting.name == "List View" {
            self.listviewbtn()
        }
        else if setting.name == "Take a new image" {
            self.newpicturebtn()
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.view.addSubview(newMarker)

        imagePicker.dismiss(animated: true, completion: nil)

        imageView.image = info[.originalImage] as? UIImage
        
        var data = imageView.image!.jpeg(.lowest)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageRef = storageRef!.child("Image\(noOfImages)")
        
        let uploadTask = imageRef.putData(data!, metadata: metadata ) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let size = metadata.size
            imageRef.downloadURL(completion: { (url, error) in
                if let downloadURL = url {
                self.imageList.append(downloadURL.absoluteString)
                    print("\n\n\n\n\n")
                    print(downloadURL.absoluteString)
                }
                else {
                    return
                }
            })
            
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "MarkerClicked" ){
            var vc = segue.destination  as! MarkerClickedViewController
            for i in stride(from: 0, to: MapsViewController.markerList.count, by: 1) {
//            print(self.name)
                if (self.name == MapsViewController.markerList[i].id) {
                    vc.imageLink = MapsViewController.markerList[i].bitmaps
//                print("Hello" + vc.nameLabel)
                    vc.costLabel = MapsViewController.markerList[i].costs
                    vc.id = MapsViewController.markerList[i].id
                    vc.nameLabel = MapsViewController.markerList[i].title
                    vc.descLabel = MapsViewController.markerList[i].description
                    vc.totalImages = MapsViewController.markerList[i].totalImages
                    vc.longitude = Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees
                    vc.latitude = Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees
                }
            }
        }
        
        if (segue.identifier == "SearchListView" ) {
            var vc = segue.destination as! ListViewController
            vc.isSearchFirstResponder = true
        }
        
        
    }
    
    @IBAction func listViewButtonPressed(_ sender: Any) {
        self.listviewbtn()
    }
    
    func listviewbtn(){
        self.performSegue(withIdentifier: "ListView", sender: self)
    }
    
    
    func drawText(text:String, inImage:UIImage) -> UIImageView {
        
        
//        let font = UIFont(name: "KohinoorTelugu-Regular", size: 18)!
        let font = UIFont(name: "KohinoorDevanagari-Regular", size: 18)!
        let size = inImage.size
        
        UIGraphicsBeginImageContext(size)
        
        let text2 = "\t\(text)\t"
        print("n\n\n\n\n\n\n\(text2)\n\n\n\n\n\n\n")
    
        
//        inImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .center
        let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.backgroundColor:UIColor.orange]
        let textSize = text2.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
        
        
        let rect = CGRect(x: 0, y: 0, width: inImage.size.width+5, height: inImage.size.height+5)
        let textRect = CGRect(x: (rect.size.width/4), y: (rect.size.height - textSize.height)/2 - 2, width: inImage.size.width+5, height: inImage.size.height+5)
        text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        let resultImageView = UIImageView(image: resultImage)
        UIGraphicsEndImageContext()
        
        return resultImageView
    
        
    }
    private func setUpMenuBar(){
        self.view.addSubview(menuBar)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = Database.database().reference()
        
        self.user = Auth.auth().currentUser
        
        print("\n\n\nUserId")
            print(user!.uid)
        
        
        let screenSize = UIScreen.main.bounds
        
        self.menuBar.frame.size.width = screenSize.width
        
        self.menuBar.removeFromSuperview()
        
        self.markerViewMap.frame.size.width = screenSize.width
        self.markerViewMap.frame.size.height = screenSize.height
        
        
        self.newMarker.frame.size.width = screenSize.width
        self.newMarker.frame.size.height = screenSize.height
        
        
        MapsViewController.markerList.removeAll()
        
        titleTextView.textContainer.maximumNumberOfLines = 1
        costTextView.textContainer.maximumNumberOfLines = 1
        titleTextView.delegate = self
        costTextView.delegate = self
        descTextView.delegate = self
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        
        titleTextView.text = "Title"
        titleTextView.textColor = UIColor.lightGray
        
        costTextView.text = "Cost"
        costTextView.textColor = UIColor.lightGray
        
        descTextView.text = "Description"
        descTextView.textColor = UIColor.lightGray
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        //        locationManager.requestLocation()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
        
        MapsViewController.longitude = self.locationManager.location!.coordinate.longitude as! Double
        MapsViewController.latitude = self.locationManager.location!.coordinate.latitude as! Double
        
        let camera = GMSCameraPosition.camera(withLatitude: self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude, zoom: 17)
        
        self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
//        self.mapView.delegate = self
        view = self.mapView
        
        let iconGenerator = GMUDefaultClusterIconGenerator()
//        let algo = GMUGridBasedClusterAlgorithm()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView,
//                                                 clusterIconGenerator: iconGenerator)
        
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm,
                                           renderer: renderer)
        
        self.clusterManager.setDelegate(self, mapDelegate: self)
        self.view.addSubview(takePictureBtn)
//        self.takePictureBtn.bottomAnchor.constraint(equalTo: self.transparentButton.topAnchor, constant: 30.0).isActive = true
        
        
        setUpMenuBar()
        
        placesClient = GMSPlacesClient.shared()
        
        let storage = Storage.storage()
        self.storageRef = storage.reference().child(user!.uid)
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                print("Not Connected")
            }
        })
        
        
        databaseHandle = ref?.observe(.value, with:{ (snapshot) in
            print("Hello World!")
            for markers in snapshot.children.allObjects as! [DataSnapshot] {
                var marker =  Marker()
                let markerObject = markers.value as? [String: AnyObject]
                let markerTitle = markerObject?["Title"]
                let markerId = markerObject?["Id"]
                let markerLati = markerObject?["LocationLati"]
                let markerLong = markerObject?["LocationLong"]
                
                let markerTotalImages = markerObject?["TotalImages"]
                let totalImages = Int(markerTotalImages as! String)!
                marker.totalImages  = markerTotalImages as! String
                marker.title = markerTitle as! String
                marker.id = markerId as! String
                marker.longitude = markerLong as! String
                marker.latitide = markerLati as! String
                var bitmapList = [String]()
                var costList = [String]()
                var descList = [String]()
                for i in stride(from: 0, to: totalImages, by: 1) {
                    bitmapList.append(markerObject?["Bitmap\(i)"] as! String)
                    costList.append(markerObject?["Cost\(i)"] as! String)
                    descList.append(markerObject?["Description\(i)"] as! String)
                }
                marker.bitmaps = bitmapList
                marker.costs = costList
                marker.description = descList
                
                let co0 = CLLocation(latitude: MapsViewController.latitude, longitude: MapsViewController.longitude)
                let co1 = CLLocation(latitude: Double(marker.latitide) as! CLLocationDegrees, longitude: Double(marker.longitude) as! CLLocationDegrees)
                var distanceInMeters = co0.distance(from: co1) / 1609.344
                distanceInMeters = round(distanceInMeters/0.01)*0.01
                
                marker.distance = distanceInMeters
                
                
                MapsViewController.markerList.append(marker)
                self.idTitleMap[marker.id] = marker
            }
            
            MapsViewController.markerList = MapsViewController.markerList.sorted(by: {$0.distance < $1.distance})
            
            print("\n\n\n\n \(self.idTitleMap)")
            
            for i in stride(from: 0, to: MapsViewController.markerList.count, by: 1) {
                let markerMap = GMSMarker()
                let item =
                    POIItem(position: CLLocationCoordinate2DMake(Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees, Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees), title: MapsViewController.markerList[i].id)
                self.clusterManager.add(item)
//                var chat = UIImage(named: "8onTc")
//                markerMap.icon = self.drawText(text:MapsViewController.markerList[i].title, inImage: chat!)
                markerMap.position = CLLocationCoordinate2D(latitude: Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees, longitude: Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees)
                markerMap.title = MapsViewController.markerList[i].id
//                markerMap.map = self.mapView
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("GPS allowed")
        }
        else {
            print("GPS not allowed") 
            return
        }
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        let gmsMarker = clusterItem as! POIItem
        self.name = gmsMarker.title
        self.markerClickedName = gmsMarker.title
//        print(gmsMarker.title)
        self.performSegue(withIdentifier: "MarkerClicked", sender: self)
        clusterManager.clearItems()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let userData = marker.userData {
            print(userData)
        }
        guard let poi = marker.userData as? POIItem else { return }
        
        let markerImage = UIImage(named: "marker50")!.withRenderingMode(.alwaysOriginal)
        
        var text : String = self.idTitleMap[poi.title]!.title
        var modtext : String = ""
        if (text.count > 10) {
            modtext = String(text.prefix(8)) + "..."
        }
        else {
            modtext = text
        }
        
        
        let markerImage2 = textToImage(drawText: "\(modtext) | \(self.idTitleMap[poi.title]!.costs[0])" as NSString, inImage: markerImage, atPoint: CGPoint(x: 80, y: 75))
        
//
        let markerView = UIImageView(image: markerImage2)
////
//        let markerUIView = UIImageView(image: imageWithView(view: markerView))
//
        
        
//        marker.iconView = self.drawText(text: "\(self.idTitleMap[poi.title]!.title) | \(self.idTitleMap[poi.title]!.costs[0])", inImage: markerImage)
//
//        markerUIView.tintColor = UIColor.green
//
        marker.iconView = markerView

        
//        let url = URL(string: "https://vectr.com/tmp/f7UTM8MVGs/aTlLLOPJY.svg?width=640&height=640&select=aTlLLOPJYpage0&source=page")
//
//        let anSVGImage: SVGKImage = SVGKImage(contentsOf: url)
        
//        if let image = UIImage(named: "marker50")!.withRenderingMode(.alwaysTemplate) {
////            image.scale=0.1
//            marker.iconView = self.drawText(text: "\(self.idTitleMap[poi.title]!.title) | \(self.idTitleMap[poi.title]!.costs[0])", inImage: image)
//        }
        
        
    }
    
    func imageWithView(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
//    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
//        let textColor = UIColor.black
//        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
//
//        let scale = UIScreen.main.scale
//        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
//
//        let textFontAttributes = [
//            NSAttributedString.Key.font: textFont,
//            NSAttributedString.Key.foregroundColor: textColor,
//            ] as [NSAttributedString.Key : Any]
//        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
//
//        let rect = CGRect(origin: point, size: image.size)
//        text.draw(in: rect, withAttributes: textFontAttributes)
//
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        
        
        let attrs = [NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size:12)!,NSAttributedString.Key.foregroundColor : UIColor.white , NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        
        text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    

}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

