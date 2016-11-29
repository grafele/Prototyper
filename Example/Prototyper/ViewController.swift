//
//  ViewController.swift
//  Prototyper
//
//  Created by Stefan Kofler on 06/09/2016.
//  Copyright (c) 2016 Stefan Kofler. All rights reserved.
//

import UIKit
import Prototyper

class ViewController: PrototypeViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.loadPrototypeContainer("container")
        PrototypeController.sharedInstance.shouldShowFeedbackButton = true
    }
    
}
