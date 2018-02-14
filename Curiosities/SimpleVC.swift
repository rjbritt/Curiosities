//
//  SimpleVC.swift
//  RyanBritt
//
//  Created by Ryan Britt on 4/28/16.
//  Copyright © 2016 2016 WWDC Scholarship. All rights reserved.
//

import UIKit

class SimpleVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToLevelSelect(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
