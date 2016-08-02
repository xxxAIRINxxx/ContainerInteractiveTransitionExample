//
//  Animator.swift
//  ContainerInteractiveTransitionExample
//
//  Created by xxxAIRINxxx on 2016/06/15.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    deinit {
        print("deinit Animator")
    }
    
    @objc func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    @objc func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let c = transitionContext as? TransitionContext else { return }
        
        c.willAnimationTransition()
        
        c.animateTransition(duration: self.transitionDuration(using: c), animations: {
            c.updateInteractiveTransition(1.0)
        }) { finished in
            c.completeTransition(finished)
        }
    }
}

