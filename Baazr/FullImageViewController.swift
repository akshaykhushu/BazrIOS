//
//  FullImageViewController.swift
//  Baazr
//
//  Created by akkhushu on 7/8/19.
//  Copyright © 2019 Baazr. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fullImageViewImageView: UIImageView!
    var imageLink : URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fullImageViewImageView.isUserInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGesture))
        
        
        fullImageViewImageView.addGestureRecognizer(pinchGesture)
            
            

        fullImageViewImageView.setImage(url: imageLink!)
        // Do any additional setup after loading the view.
    }
    
    @objc func pinchGesture(sender:UIPinchGestureRecognizer){
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
    }
    
    @IBAction func backButtonPressed(_ sender: Any) { navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
