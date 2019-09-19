//
//  AppDelegate.swift
//  Baazr
//
//  Created by akkhushu on 5/3/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import GoogleSignIn

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, CLLocationManagerDelegate{

    var window: UIWindow?
    public static var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyDOk2yQ4zxnkEzmzlI263Hh14htvxQG5ao")
        GMSPlacesClient.provideAPIKey("AIzaSyDOk2yQ4zxnkEzmzlI263Hh14htvxQG5ao")
        FirebaseApp.configure()
        
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        AppDelegate.locationManager.requestWhenInUseAuthorization()
//        AppDelegate.locationManager.requestLocation()
//        AppDelegate.locationManager.requestAlwaysAuthorization()
//
//
//        AppDelegate.locationManager.startUpdatingLocation()
//        AppDelegate.locationManager.startMonitoringSignificantLocationChanges()
        
        Auth.auth().addStateDidChangeListener({ (auth, user) in
            if (user != nil && user!.isEmailVerified ){
                print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nAutomatic Sign In: \(user?.email)")
                MapsViewController.user = user
                MapsViewController.isGuest = false
                MapsViewController.userEmailId = user!.email!
                let storage = Storage.storage()
                MapsViewController.storageRef = storage.reference().child(user!.uid)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainAppBaazr")
                self.window!.rootViewController = initialViewController
                return
                
                // User is signed in.
                
            }
            else {
                MapsViewController.isGuest = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "NewUserBaazr")
                self.window!.rootViewController = initialViewController
                return
            }
            })
        
        var ref : DatabaseReference!
        ref = Database.database().reference()
        UINavigationBar.appearance().backgroundColor = UIColor.orange
        return true
    }
    
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
            if locations.first != nil {
                print("location:: (location)")
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
    
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation:options[UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("\n\n\n\n\n\n\(error)")
            return
        }
        
        MapsViewController.isGuest = false
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("\n\n\n\n\n\n\n\n\n\(error)")
                return
            }
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainAppBaazr")
//            self.window!.rootViewController = initialViewController
        }
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
//        Auth.auth().addStateDidChangeListener({ (auth, user) in
//            if (user != nil && user!.isEmailVerified ){
//                print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nAutomatic Sign In: \(user?.email)")
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainAppBaazr")
//                self.window!.rootViewController = initialViewController
//                return
//
//                // User is signed in.
//
//            }
//            else {
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "NewUserBaazr")
//                self.window!.rootViewController = initialViewController
//                return
//            }
//        })
        
//
//        if (CLLocationManager.locationServicesEnabled()){
//            switch CLLocationManager.authorizationStatus() {
//            case .notDetermined, .restricted, .denied:
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainAppBaazr")
//                self.window!.rootViewController = initialViewController
//                Toast.show(message: "Please turn on Location Services and restart the app to continue.", controller: initialViewController)
//                return
//
//                    MapsViewController.longitude = -121.9940569
//                    MapsViewController.latitude = 37.3919265
//
//
//            case .authorizedAlways:
//                print("Access")
//            case .authorizedWhenInUse:
//                print("Access")
//            @unknown default:
//                print("Access")
//            }
//        }
//        else{
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewController = storyboard.instantiateViewController(withIdentifier: "MainAppBaazr")
//                self.window!.rootViewController = initialViewController
//                Toast.show(message: "Please turn on Location Services and restart the app to continue.", controller: initialViewController)
//                MapsViewController.longitude = -121.9940569
//                MapsViewController.latitude = 37.3919265
//                return
//
//            }
//
//
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

