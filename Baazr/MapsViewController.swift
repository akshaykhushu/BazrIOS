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
import CoreLocation

class MapsViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextViewDelegate, GMUClusterManagerDelegate, UINavigationControllerDelegate, GMUClusterRendererDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
   
    
    
    //***************************
    
    @IBOutlet var helpView: UIView!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var switchTemp: UISwitch!
    @IBOutlet var buttonState: UIButton!
    @IBOutlet weak var markerViewLabel: UILabel!
    @IBOutlet var markerView: UIView!
    @IBOutlet weak var transparentButton: UIButton!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var listViewButton: UIButton!
    @IBOutlet var menuBar: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var markerViewMap: UIView!
    public static var isGuest : Bool = true
    @IBOutlet weak var mainSearchButton: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    
    public static var reportedAgree = "False"
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var costTextView: UITextView!
    
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var addMoreImagesButton: UIButton!
    @IBOutlet weak var saveBtnNewMarkerView: UIButton!
    @IBOutlet var newMarker: UIView!
    //***************************
    
    public static var settingsGuest : String = "Sign Out"
    @IBOutlet weak var listBtn: UIButton!
    public static var storageRef: StorageReference?
    var ref : DatabaseReference?
    public static var user : User?
    public static var userEmailId : String = ""
    var permission = false
    var databaseHandle: DatabaseHandle?
    var postData = [String]()
    public static var markerList = [Marker]()
//    @IBOutlet weak var takepictureBtn: UIButton!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var markerClicked: GMSMarker!
    public static var name : String!
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

    @IBOutlet var eulaAgreeView: UIView!
    @IBOutlet var takePictureBtn: UIButton!
    
    @IBOutlet weak var uelaAgreeBtn: UIButton!
    
    
    let currency = ["$", "₹", "€", "¥", "£"]
    
    let buttonStatus = UIButton(frame: CGRect(x: 100, y: 100, width: 120, height: 30))
    
    let segmentedControl = UISegmentedControl(items:["Open", "Closed"])

    
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
    
    
    @IBAction func eulaAgreeButtonPressed(_ sender: Any) {
        MapsViewController.reportedAgree = "True"
        self.eulaAgreeView.removeFromSuperview()
    }
    
    func signout() {
        
        MapsViewController.userEmailId = ""
        if(MapsViewController.isGuest){
            
            self.performSegue(withIdentifier: "SignOut", sender: self)
            return
        }
        self.buttonState.removeFromSuperview()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        self.idTitleMap.removeAll()
        MapsViewController.markerList.removeAll()
        
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
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
    }
        
        
    
    
    func checkCameraAccess() -> Int {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            return 0
        case .authorized:
            return 1
        case .notDetermined:
            return 0
        @unknown default:
            return 1
        }
        return 0
    }
    
    @objc func pressed(sender: UIButton!) {
        self.pressedfn()
    }
    
    func pressedfn(){
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func deniedPressed(sender: UIButton!) {
        self.deniedPressedfn()
    }
    
    func deniedPressedfn(){
        Toast.show(message: "Please grant camera permission to continue", controller: self)
    }
    
    
    @IBAction func morePicturesBtnPressed(_ sender: Any) {
        if (saveBtnPressed() == "Error"){
            Toast.show(message: "Please enter All the values", controller: self)
            return
        }
        noOfImages += 1
        
        self.titleTextView.text = ""
        self.costTextView.text = ""
        self.descTextView.text = ""

       
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func saveBtnPressed() -> String {
        if (self.titleTextView.text! == nil || self.titleTextView.text! == "") {
            self.costName = true
            Toast.show(message: "Please enter title", controller: self)
            return "Error"
        }
        if (self.costTextView.text! == nil || self.costTextView.text! == "") {
            self.costName = true
            Toast.show(message: "Please enter cost", controller: self)
            return "Error"
        }
        else if (self.costTextView.text! != nil ) {
            let letters = NSCharacterSet.letters
            let range = costTextView.text!.rangeOfCharacter(from: letters)
            
            // range will be nil if no letters is found
            if range != nil {
                self.costName = true
                Toast.show(message: "Invalid cost value", controller: self)
                return "Error"
            }
        }
        
        if (self.descTextView.text! == nil || self.descTextView.text! == "") {
            Toast.show(message: "Please enter description", controller: self)
            return "Error"
        }
        costList.append(self.currencyUsed + costTextView.text!)
        titleMarker = titleTextView.text!
        descList.append(descTextView.text!)
        return "All Good"
    }
    
    @IBAction func uploadBtnPressed(_ sender: Any) {
        saveBtnPressed()
        var ref: DatabaseReference!
        ref = Database.database().reference().child(MapsViewController.user!.uid)
        
        if (self.costName){
            return
        }
       for i in stride(from: 0, to: self.imageList.count, by: 1) {
            uploadDict["Bitmap\(i)"] = self.imageList[i]
            uploadDict["Cost\(i)"] = self.costList[i]
            uploadDict["Description\(i)"] = self.descList[i]
        }
        uploadDict["Id"] = MapsViewController.user!.uid
        uploadDict["LocationLati"] = String(MapsViewController.latitude)
        uploadDict["LocationLong"] = String(MapsViewController.longitude)
        uploadDict["Title"] = self.titleMarker
        uploadDict["State"] = "open"
        uploadDict["Reported"] = "False"
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
        return [Setting(name: "User: " + MapsViewController.userEmailId), Setting(name: "Take a new image"), Setting(name: "List View"), Setting(name: MapsViewController.settingsGuest)]
    }()
    
    @IBAction func MoreButtonPressed(_ sender: Any) {
        if let window = UIApplication.shared.keyWindow {
            blackView.backgroundColor = UIColor(white:0, alpha:0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            window.addSubview(blackView)
            window.addSubview(collectionView)
            let height: CGFloat = CGFloat(settings.count * 60)
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
    
    //Code for dismissing the slider view
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
    
    //Used for checking what element was pressed in the slider view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let setting = self.settings[indexPath.item]
//        print("\n\n\n\n\n\n\n\(setting.name)")
        handleDismiss(settings: setting)
        
        if setting.name == "Sign Out"{
            self.signout()
        }
        else if setting.name == "List View" {
            self.listviewbtn()
        }
        else if setting.name == "Take a new image" {
            if (MapsViewController.isGuest){
                Toast.show(message: "Please Sign In to post", controller: self)
            }
            else{
                if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                    self.pressedfn()
                    
                    self.newpicturebtn()
                } else {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                        if granted {
                            self.pressedfn()
                            
                            self.newpicturebtn()
                        } else {
                            self.deniedPressedfn()
                        }
                    })
                }
                
            }
        }
        else if setting.name == "Sign In"{
            self.signout()
        }
    }
    
    //open the help view
    func help() {
        self.view.addSubview(helpView)
    }
    
    
    
    
    
    
    //changes the state of the marker
    @IBAction func changeState(_ sender: Any) {
        
        var ref: DatabaseReference!
        ref = Database.database().reference().child(MapsViewController.user!.uid)
        print(MapsViewController.user!.uid)
        print(idTitleMap[MapsViewController.user!.uid]!)
//        print(idTitleMap[MapsViewController.user!.uid]!.latitide)
        let camera = GMSCameraPosition.camera(withLatitude: Double(idTitleMap[MapsViewController.user!.uid]!.latitide) as! CLLocationDegrees, longitude: Double(idTitleMap[MapsViewController.user!.uid]!.longitude) as! CLLocationDegrees, zoom: 17)
        
        self.mapView.animate(to: camera)
//
        
        if (self.buttonState.currentTitle! == "I am Open" ) {
            self.buttonState.setTitle("I am Closed", for: .normal)
            ref.child("State").setValue("closed")
            
        }
        else{
            self.buttonState.setTitle("I am Open", for: .normal)
            ref.child("State").setValue("open")
        }
    }
    
    @objc func stateChange() {
        
        var ref: DatabaseReference!
        ref = Database.database().reference().child(MapsViewController.user!.uid)
        print(MapsViewController.user!.uid)
        print(idTitleMap[MapsViewController.user!.uid]!)
        //        print(idTitleMap[MapsViewController.user!.uid]!.latitide)
        let camera = GMSCameraPosition.camera(withLatitude: Double(idTitleMap[MapsViewController.user!.uid]!.latitide) as! CLLocationDegrees, longitude: Double(idTitleMap[MapsViewController.user!.uid]!.longitude) as! CLLocationDegrees, zoom: 17)
        
        self.mapView.animate(to: camera)
        
        if (self.buttonStatus.currentTitle! == "Open" ) {
            self.buttonStatus.setTitle("Closed", for: .normal)
            ref.child("State").setValue("closed")

        }
        else{
            self.buttonStatus.setTitle("Open", for: .normal)
            ref.child("State").setValue("open")
        }
    }
    
    //Called as soon as the user clicks the picture and presses ok
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.view.addSubview(newMarker)

        imagePicker.dismiss(animated: true, completion: nil)

        imageView.image = info[.originalImage] as? UIImage
        
        var data = imageView.image!.jpeg(.lowest)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageRef = MapsViewController.storageRef!.child("Image\(noOfImages)")
        
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
    
    //Called when going from one view controller to another
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "MarkerClicked" ){
            var vc = segue.destination  as! MarkerClickedViewController
            for i in stride(from: 0, to: MapsViewController.markerList.count, by: 1) {
//            print(self.name)
                if (MapsViewController.name == MapsViewController.markerList[i].id) {
                    vc.imageLink = MapsViewController.markerList[i].bitmaps
//                print("Hello" + vc.nameLabel)
                    vc.costLabel = MapsViewController.markerList[i].costs
                    vc.id = MapsViewController.markerList[i].id
                    vc.nameLabel = MapsViewController.markerList[i].title
                    vc.descLabel = MapsViewController.markerList[i].description
                    vc.totalImages = MapsViewController.markerList[i].totalImages
                    vc.reported = MapsViewController.markerList[i].reported
                    print("\n\n\n\n\n function prepare " + vc.reported)
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
    
    //Used for wrtiting text on marker
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
    
    //Main function of this file. Sets up the UI of the app, downloads the marker data from firebase and display it on the map
    func restOfCode(){
        
        ref = Database.database().reference()
        
        let screenSize = UIScreen.main.bounds
        
        self.menuBar.frame.size.width = screenSize.width
        
//        print(MapsViewController.user!.uid)
        self.menuBar.removeFromSuperview()
        
        self.markerViewMap.frame.size.width = screenSize.width
        self.markerViewMap.frame.size.height = screenSize.height
        
        self.newMarker.frame.size.width = screenSize.width
        self.newMarker.frame.size.height = screenSize.height
        
        self.helpView.frame.size.width = screenSize.width
        self.helpView.frame.size.height = screenSize.height
        
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
        
        
        let camera = GMSCameraPosition.camera(withLatitude: MapsViewController.latitude, longitude: MapsViewController.longitude, zoom: 17)
        
        self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true

        self.view = self.mapView
        
//        self.view.layoutIfNeeded()
        
        self.view.frame.size.width = self.mapView.frame.size.width
        self.view.frame.size.height = self.mapView.frame.size.height
        
        
        
        
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
        
        
//                self.view.addSubview(self.takePictureBtn)
        //        self.view.addSubview(stateSwitch)
        
        mainSearchButton.layer.cornerRadius = 0
        mainSearchButton.layer.borderWidth = 0.5
        mainSearchButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        currencyPicker.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        currencyPicker.layer.borderWidth = 0.5
        
        costTextView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        costTextView.layer.borderWidth = 0.5
        
        titleTextView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        titleTextView.layer.borderWidth = 0.5
        
        descTextView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        descTextView.layer.borderWidth = 0.5
        
        uploadBtn.layer.cornerRadius = 5.0
        plusBtn.layer.cornerRadius = 5.0
        
    
        setUpMenuBar()
        
        placesClient = GMSPlacesClient.shared()
        
        
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
            self.clusterManager.clearItems()
            MapsViewController.markerList.removeAll()
            for markers in snapshot.children.allObjects as! [DataSnapshot] {
                var marker =  Marker()
                let markerObject = markers.value as? [String: AnyObject]
                let markerTitle = markerObject?["Title"]
                let markerId = markerObject?["Id"]
                let markerLati = markerObject?["LocationLati"]
                let markerLong = markerObject?["LocationLong"]
                let markerStatus = markerObject?["State"]
                let markerTotalImages = markerObject?["TotalImages"]
                let totalImages = Int(markerTotalImages as! String)!
                let reported = markerObject?["Reported"]
                marker.totalImages  = markerTotalImages as! String
                marker.title = markerTitle as! String
                marker.id = markerId as! String
                marker.longitude = markerLong as! String
                marker.latitide = markerLati as! String
                marker.state = markerStatus as! String
                marker.reported = reported as! String
                print(marker.reported)
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
                
                print(self.idTitleMap[marker.id]!.title)
            }
            
            let margins = self.view.layoutMarginsGuide
            if(!MapsViewController.isGuest) {
                print("\n\n\nisGuest : \t   \(MapsViewController.isGuest)")
            
                
                let buttonPic = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
                buttonPic.backgroundColor = UIColor.clear
                let btnImage = UIImage(named: "Circle-icons-camera")
                buttonPic.setImage(btnImage, for: UIControl.State.normal)
//                button.addTarget(self), for: .touchUpInside)
                

                self.view.addSubview(buttonPic)
                buttonPic.translatesAutoresizingMaskIntoConstraints = false
                
                let widthContraints =  NSLayoutConstraint(item: buttonPic, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
                let heightContraints = NSLayoutConstraint(item: buttonPic, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
                buttonPic.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                //
                buttonPic.centerYAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100).isActive = true
                
                
                NSLayoutConstraint.activate([heightContraints,widthContraints])
                
                if (MapsViewController.user != nil){
                    MapsViewController.userEmailId = MapsViewController.user!.email!
                    print(MapsViewController.userEmailId)
                    print("\n\n\n\nPrint User ki id : \n\n\n")
                    print(MapsViewController.user!.uid)
                    print(self.idTitleMap.keys)
                    print("\n\nBefore\n\n")
                    print(self.idTitleMap.keys)
                    if ((self.idTitleMap[MapsViewController.user!.uid]) != nil){
                        print("User has a marker")
                        print("\n\n\nyo yo \(self.idTitleMap[MapsViewController.user!.uid]!.title)")
                        
                        
                        
                        self.buttonStatus.backgroundColor = UIColor.brown
                        if (self.idTitleMap[MapsViewController.user!.uid]!.state == "open"){

//                            self.segmentedControl.selectedSegmentIndex = 0
                            self.buttonStatus.setTitle("Open", for: UIControl.State.normal)
                        }
                        else {
//                            self.segmentedControl.selectedSegmentIndex = 1
                            self.buttonStatus.setTitle("Closed", for: UIControl.State.normal)
                        }
                        self.view.addSubview(self.buttonStatus)
                        
//                        self.view.addSubview(self.segmentedControl)
                        self.buttonStatus.translatesAutoresizingMaskIntoConstraints = false
//                        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false

                        let widthContraintsStatus =  NSLayoutConstraint(item: self.buttonStatus, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 100)
                        let heightContraintsStatus = NSLayoutConstraint(item: self.buttonStatus, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 30)
                        self.buttonStatus.centerXAnchor.constraint(equalTo: self.view.rightAnchor, constant: -100).isActive = true
                        self.buttonStatus.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 150).isActive = true
                        self.buttonStatus.addTarget(self, action: #selector(self.stateChange), for: .touchUpInside)
                        self.buttonStatus.layer.cornerRadius = 10
                        self.buttonStatus.layer.borderWidth = 1
                        NSLayoutConstraint.activate([heightContraintsStatus,widthContraintsStatus])
                        print("\n\n\n\n Maps ka user \(self.idTitleMap[MapsViewController.user!.uid]!.id)")
                    }
                    else{
                        if(MapsViewController.reportedAgree == "False"){
                            
                            self.view.addSubview(self.eulaAgreeView)
                            //                        self.eulaAgreeView.center = CGPoint(x: self.view.frame.size.width / 2,
                            //                                                            y: self.view.frame.size.height / 2)
                            
                            self.eulaAgreeView.frame.size.width = screenSize.width
                            self.eulaAgreeView.frame.size.height = screenSize.height
                        }
                    }
                    
                    print("\n\nAfter\n\n")
                    print(self.idTitleMap.keys)
                }
            }
            else{
                
                MapsViewController.userEmailId = "Guest"
            }
            
            MapsViewController.markerList = MapsViewController.markerList.sorted(by: {$0.distance < $1.distance})
            
            
            for i in stride(from: 0, to: MapsViewController.markerList.count, by: 1) {
                let markerMap = GMSMarker()
                let item =
                    POIItem(position: CLLocationCoordinate2DMake(Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees, Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees), title: MapsViewController.markerList[i].id, state: MapsViewController.markerList[i].state)
                self.clusterManager.add(item)
                //                var chat = UIImage(named: "8onTc")
                //                markerMap.icon = self.drawText(text:MapsViewController.markerList[i].title, inImage: chat!)
                markerMap.position = CLLocationCoordinate2D(latitude: Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees, longitude: Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees)
                markerMap.title = MapsViewController.markerList[i].id
                //                markerMap.map = self.mapView
            }
        })
        
    }
    
    //First method called in this file. checks whether the location is enabled or not. If not sends a dummy location and executes restOfCode() function. If location is enabled, then takes the current user location and executes estOfCode() function.
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if (CLLocationManager.locationServicesEnabled()){
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let camera = GMSCameraPosition.camera(withLatitude: 23.43, longitude: 118.23, zoom: 5)
                
                self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
                view = self.mapView
                
                Toast.show(message: "Please turn on Location Services and restart the app to continue.", controller: self)
                let alert = UIAlertController(title: "Location Services", message: "Please turn on location to continue. ", preferredStyle: UIAlertController.Style.alert)
                
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {action in
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {action in
                    exit(-1)
                }))
                
                self.present(alert, animated: true)
                
                MapsViewController.longitude = -121.9940569
                MapsViewController.latitude = 37.3919265

                restOfCode()
                
            case .authorizedAlways, .authorizedWhenInUse:
                if (AppDelegate.locationManager.location?.coordinate.longitude == nil){
                    MapsViewController.longitude = -121.9940569
                }
                if (AppDelegate.locationManager.location?.coordinate.latitude == nil){
                    MapsViewController.latitude = 37.3919265
                }
                else{
                    MapsViewController.longitude = AppDelegate.locationManager.location?.coordinate.longitude as! Double
                    MapsViewController.latitude = AppDelegate.locationManager.location?.coordinate.latitude as! Double
                }
                restOfCode()
            }
        }
        else {
            let camera = GMSCameraPosition.camera(withLatitude: 23.43, longitude: 118.23, zoom: 5)
            self.mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            view = self.mapView
    
            Toast.show(message: "Please turn on Location Services and restart the app to continue.", controller: self)
            let alert = UIAlertController(title: "Location Services", message: "Please turn on location to continue. ", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {action in
                UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)

            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {action in
                exit(-1)
            }))
            
            self.present(alert, animated: true)
            
            MapsViewController.longitude = -121.9940569
            MapsViewController.latitude = 37.3919265

            restOfCode()
        }
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
        MapsViewController.name = gmsMarker.title
        self.markerClickedName = gmsMarker.title
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
        
        var text2 : String = self.idTitleMap[poi.title]!.title
        print("\n\n\n\n\n\n\n")
        print(self.idTitleMap[poi.title]!)
        print(self.idTitleMap[poi.title]!.title)
        print(self.idTitleMap[poi.title]!.costs[0])
        print("\n\n\n\n\n\n\n")
        var text3 = "   \(text2) | \(self.idTitleMap[poi.title]!.costs[0])"
 
        var newMarkerView = UIView()
        
        print("State " + self.idTitleMap[poi.title]!.state)
        if (self.idTitleMap[poi.title]!.state == "open") {
            
            newMarkerView.backgroundColor = UIColor.orange
        }
        else {
            newMarkerView.backgroundColor = UIColor.gray
        }
        newMarkerView.frame = CGRect.init(x: 0, y: 0, width: CGFloat(Double(text3.count*8)), height: 30)
        
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: newMarkerView.frame.size.width, height: newMarkerView.frame.size.height))
        
        label.text = text3
        label.textColor = UIColor.white
        label.center.x = newMarkerView.center.x
        label.center.y = newMarkerView.center.y
        newMarkerView.addSubview(label)
        
        label.frame = CGRect.init(x: 0, y: 0, width: CGFloat(Double(text3.count*8)), height: 30)
        
        newMarkerView.frame.size.width = CGFloat(Double(Double(text3.count)*8.5))
        
        print("\n\n\n\nModText = \(text2.count)")
        markerView.frame.size.width = markerViewLabel.frame.size.width
        
        marker.iconView = newMarkerView

    }
    
    func imageWithView(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    
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
