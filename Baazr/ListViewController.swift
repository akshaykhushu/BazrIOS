//
//  ListViewController.swift
//  Baazr
//
//  Created by akkhushu on 6/23/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UITableViewController, UISearchBarDelegate {

    var data : [MarkerListClass] = []
    var currentData: [MarkerListClass] = []
    var selectedCellData : MarkerListClass?
    var isSearchFirstResponder: Bool = false
    
    @IBOutlet weak var searchBarListView: UISearchBar!
    @IBOutlet var homeAndSearchView: UIView!
    @IBOutlet var table: UITableView!
    
    func createArray() -> [MarkerListClass] {
        var tempData: [MarkerListClass] = []
        for i in stride(from: 0, to: MapsViewController.markerList.count, by: 1) {
            let co0 = CLLocation(latitude: MapsViewController.latitude, longitude: MapsViewController.longitude)
            let co1 = CLLocation(latitude: Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees, longitude: Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees)
            var distanceInMeters = co0.distance(from: co1) / 1609.344
            distanceInMeters = round(distanceInMeters/0.01)*0.01
            distanceInMeters = distanceInMeters.truncate(places: 2)
            var markerListClass1 = MarkerListClass(imageLink: MapsViewController.markerList[i].bitmaps, title: MapsViewController.markerList[i].title, cost: MapsViewController.markerList[i].costs, id: MapsViewController.markerList[i].id, distance: distanceInMeters, description: MapsViewController.markerList[i].description, reported: MapsViewController.markerList[i].reported )
            
            if ( MapsViewController.markerList[i].reported == "False"){
                tempData.append(markerListClass1)
            }
        }
        
        return tempData
    }
    
    func setUpSearchBar() {
        searchBarListView.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentData = data.filter({ markerListClass -> Bool in
            var val = false
            guard let text = searchBarListView.text?.lowercased() else { return false }
            for i in stride(from: 0, to: markerListClass.description.count, by: 1){
                val = val || markerListClass.description[i].lowercased().contains(text)
            }
////            return val
            return (val || markerListClass.title.lowercased().contains(text))
        })
        table.reloadData()
    }
    
    
    @IBAction func homeBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = createArray()
        currentData = data
        setUpSearchBar()
        self.table.tableHeaderView = homeAndSearchView
        print("\nStart")
        print(currentData)
        print("\nEnd")
        if (isSearchFirstResponder){
            self.searchBarListView.becomeFirstResponder()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = currentData[indexPath.row]
        
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCells") as! CustomCells
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCells", for: indexPath) as! CustomCells
        
        cell.setCells(markerListClassInstance: cellData)
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCellData = currentData[indexPath.row]
        self.performSegue(withIdentifier: "MarkerClickedListView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "MarkerClickedListView" ){
            var vc = segue.destination  as! MarkerClickedViewController
            for i in stride(from: 0, to: MapsViewController.markerList.count, by: 1) {
                //            print(self.name)
                if (MapsViewController.markerList[i].id == self.selectedCellData!.id) {
                    vc.imageLink = MapsViewController.markerList[i].bitmaps
                    //                print("Hello" + vc.nameLabel)
                    vc.costLabel = MapsViewController.markerList[i].costs
                    vc.id = MapsViewController.markerList[i].id
                    vc.nameLabel = MapsViewController.markerList[i].title
                    vc.descLabel = MapsViewController.markerList[i].description
                    vc.reported = MapsViewController.markerList[i].reported
                    vc.totalImages = MapsViewController.markerList[i].totalImages
                    vc.latitude = Double(MapsViewController.markerList[i].latitide) as! CLLocationDegrees
                    vc.longitude = Double(MapsViewController.markerList[i].longitude) as! CLLocationDegrees
                }
            }
        }
    }
    
    
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
