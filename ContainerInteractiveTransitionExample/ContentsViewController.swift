//
//  ContentsViewController.swift
//  ContainerInteractiveTransitionExample
//
//  Created by xxxAIRINxxx on 2016/06/14.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ContentsViewController: UIViewController {
    
    deinit {
        print("deinit ContentsViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Pop",
                                                                 style: .Plain,
                                                                 target: self,
                                                                 action: #selector(self.pop))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push",
                                                                style: .Plain,
                                                                target: self,
                                                                action: #selector(self.push))
    }
    
    func pop() {
        if let p = self.navigationController?.parentViewController as? ViewController {
            p.pop()
        }
    }
    
    func push() {
        if let p = self.navigationController?.parentViewController as? ViewController {
            p.push()
        }
    }
}

