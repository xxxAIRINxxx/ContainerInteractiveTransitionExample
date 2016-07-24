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
    
    @objc func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    @objc func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let c = transitionContext as? TransitionContext else { return }
        
        c.willAnimationTransition()
        
        c.animateTransition(self.transitionDuration(c), animations: {
            c.updateInteractiveTransition(1.0)
        }) { finished in
            c.completeTransition(finished)
        }
    }
}

