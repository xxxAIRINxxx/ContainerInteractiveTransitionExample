//
//  InteractiveAnimator.swift
//  ContainerInteractiveTransitionExample
//
//  Created by xxxAIRINxxx on 2016/06/15.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

final class InteractiveAnimator: UIPercentDrivenInteractiveTransition {
    
    private let transitionContext: TransitionContext
    
    // dismissal pan gesture support
    var panStartThreshold: CGFloat = 10.0
    var panCompletionThreshold: CGFloat = 100.0
    
    private var gesture: UIPanGestureRecognizer?
    private var panLocationStart: CGFloat = 0.0
    
    deinit {
        print("deinit InteractiveAnimator")
    }
    
    init(_ transitionContext: TransitionContext) {
        self.transitionContext = transitionContext
        
        super.init()
    }
    
    func registerDismissalPanGesture(targetVC: UIViewController) {
        self.unregisterDismissalPanGesture()
        
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        self.gesture!.maximumNumberOfTouches = 1
        targetVC.view.addGestureRecognizer(self.gesture!)
    }
    
    func unregisterDismissalPanGesture() {
        guard let g = self.gesture else { return }
        g.view?.removeGestureRecognizer(g)
        self.gesture = nil
    }
    
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let window : UIWindow? = self.transitionContext.fromVC.view.window
        
        var location = recognizer.locationInView(window)
        location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view!.transform))
        var velocity = recognizer .velocityInView(window)
        velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view!.transform))
        
        let bounds = self.transitionContext.fromVC.view.bounds
        let animationRatio: CGFloat = (location.x - self.panLocationStart) / bounds.width
        if recognizer.state == .Began {
            self.panLocationStart = location.x
        } else if recognizer.state == .Changed {
            if (location.x - self.panLocationStart) > self.panStartThreshold && !self.transitionContext.nowInteractive {
                self.startInteractiveTransition(self.transitionContext)
            }
            self.updateInteractiveTransition(animationRatio)
        } else if recognizer.state == .Ended {
            let velocityForSelectedDirection: CGFloat = velocity.x
            
            if velocityForSelectedDirection > self.panCompletionThreshold {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
        } else {
            self.cancelInteractiveTransition()
        }
    }
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        print("startInteractiveTransition")
        
        self.transitionContext.fromVC.beginAppearanceTransition(false, animated: false)
        self.transitionContext.toVC.beginAppearanceTransition(true, animated: false)
        
        self.transitionContext.nowInteractive = true
        self.transitionContext.willAnimationTransition()
    }
    
    override func updateInteractiveTransition(percentComplete: CGFloat) {
        super.updateInteractiveTransition(percentComplete)
        
        self.transitionContext.updateInteractiveTransition(percentComplete)
    }
    
    override func cancelInteractiveTransition() {
        print("cancelInteractiveTransition")
        super.cancelInteractiveTransition()
        
        self.transitionContext.cancelInteractiveTransition()
    }
    
    override func finishInteractiveTransition() {
        print("finishInteractiveTransition")
        super.finishInteractiveTransition()
        
        self.transitionContext.finishInteractiveTransition()
    }
}
