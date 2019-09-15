//
//  ViewController.swift
//  CDManagerExample
//
//  Created by Wendy Liga on 15/09/19.
//  Copyright © 2019 Wendy Liga. All rights reserved.
//

import UIKit
import CDManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let manager = CDManager<User>(container: AppDelegate.managedContext)
        
        let users = manager.fetch()
        
    }
}

