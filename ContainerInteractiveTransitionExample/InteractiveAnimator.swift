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
        
        self.gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        self.gesture!.maximumNumberOfTouches = 1
        targetVC.view.addGestureRecognizer(self.gesture!)
    }
    
    func unregisterDismissalPanGesture() {
        guard let g = self.gesture else { return }
        g.view?.removeGestureRecognizer(g)
        self.gesture = nil
    }
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let window = self.transitionContext.fromVC.view.window
        
        var location = recognizer.location(in: window)
        location = location.applying(recognizer.view!.transform.inverted())
        var velocity = recognizer .velocity(in: window)
        velocity = velocity.applying(recognizer.view!.transform.inverted())
        
        let bounds = self.transitionContext.fromVC.view.bounds
        
        switch recognizer.state {
        case .began:
            self.panLocationStart = location.x
        case .changed:
            if (location.x - self.panLocationStart) > self.panStartThreshold && !self.transitionContext.nowInteractive {
                self.startInteractiveTransition(self.transitionContext)
                self.panLocationStart = location.x
            }
            if self.transitionContext.nowInteractive {
                let animationRatio = (location.x - self.panLocationStart) / bounds.width
                self.update(animationRatio)
            }
        case .ended:
            if velocity.x > 0.0 && (location.x - self.panLocationStart) > self.panCompletionThreshold {
                self.finish()
            } else {
                self.cancel()
            }
        default:
            self.cancel()
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        print("startInteractiveTransition")
        
        self.transitionContext.fromVC.beginAppearanceTransition(false, animated: false)
        self.transitionContext.toVC.beginAppearanceTransition(true, animated: false)
        
        self.transitionContext.nowInteractive = true
        self.transitionContext.willAnimationTransition()
    }
    
    override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        
        self.transitionContext.updateInteractiveTransition(percentComplete)
    }
    
    override func cancel() {
        print("cancelInteractiveTransition")
        super.cancel()
        
        self.transitionContext.cancelInteractiveTransition()
    }
    
    override func finish() {
        print("finishInteractiveTransition")
        super.finish()
        
        self.transitionContext.finishInteractiveTransition()
    }
}
