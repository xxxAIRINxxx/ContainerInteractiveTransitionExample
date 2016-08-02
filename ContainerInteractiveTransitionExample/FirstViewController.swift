//
//  FirstViewController.swift
//  ContainerInteractiveTransitionExample
//
//  Created by xxxAIRINxxx on 2016/06/15.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import UIKit

final class FirstViewController: UIViewController {
    
    deinit {
        print("deinit FirstViewController")
    }
    
    @IBAction func push() {
        if let p = self.parent as? ViewController {
            p.push()
            return
        }
        if let p = self.navigationController?.parent as? ViewController {
            p.push()
        }
    }
}
