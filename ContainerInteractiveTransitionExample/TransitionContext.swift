//
//  TransitionContext.swift
//  ContainerInteractiveTransitionExample
//
//  Created by xxxAIRINxxx on 2016/06/15.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import Foundation
import UIKit

final class TransitionContext: NSObject, UIViewControllerContextTransitioning {
    
    private(set) weak var containerVC: UIViewController!
    private(set) weak var fromVC: UIViewController!
    private(set) weak var toVC: UIViewController!
    
    var duration: NSTimeInterval = 0.3
    var nowInteractive: Bool = false
    var completion: (Bool -> Void)?
    
    private let blackScreenView: UIView = UIView(frame: CGRect.zero)
    private let _containerView: UIView
    private let isPresenting: Bool
    private let fromVCScrollX: CGFloat = -50.0
    private var percentComplete: CGFloat = 0.0
    
    deinit {
        print("deinit TransitionContext")
    }
    
    init(containerView: UIView, fromVC: UIViewController, toVC: UIViewController, isPresenting: Bool) {
        self._containerView = containerView
        self.fromVC = fromVC
        self.toVC = toVC
        self.isPresenting = isPresenting
        
        self.blackScreenView.backgroundColor = UIColor.rgba(0, 0, 0, 0.2)
        
        super.init()
    }
    
    func containerView() -> UIView? {
        return self._containerView
    }
    
    func isAnimated() -> Bool {
        return true
    }
    
    func isInteractive() -> Bool {
        return self.nowInteractive
    }
    
    func transitionWasCancelled() -> Bool {
        return false
    }
    
    func presentationStyle() -> UIModalPresentationStyle {
        return .Custom
    }
    
    func willAnimationTransition() {
        self.fromVC.view.frame = self.initialFrameForViewController(self.fromVC)
        self.toVC.view.frame = self.initialFrameForViewController(self.toVC)
        
        if self.isPresenting {
            self.containerView()?.subviews.forEach() { $0.removeFromSuperview() }
            
            self.toVC.view.layer.shadowColor = UIColor.rgba(40, 40, 40, 1.0).CGColor
            self.toVC.view.layer.shadowOpacity = 0.8
            self.toVC.view.layer.shadowRadius = 3.0
            
            self.blackScreenView.frame = self.fromVC.view.bounds
            self.blackScreenView.alpha = 0.0
            
            self.containerView()?.addSubview(self.fromVC.view)
            self.containerView()?.addSubview(self.blackScreenView)
            self.containerView()?.addSubview(self.toVC.view)
            self.fromVC.view.layoutIfNeeded()
            self.toVC.view.layoutIfNeeded()
        } else {
            self.fromVC.view.layer.shadowColor = UIColor.rgba(40, 40, 40, 1.0).CGColor
            self.fromVC.view.layer.shadowOpacity = 0.8
            self.fromVC.view.layer.shadowRadius = 3.0
            
            self.blackScreenView.frame = self.toVC.view.bounds
            self.blackScreenView.alpha = 1.0
            
            self.containerView()?.addSubview(self.toVC.view)
            self.containerView()?.addSubview(self.blackScreenView)
            self.containerView()?.addSubview(self.fromVC.view)
            self.fromVC.view.layoutIfNeeded()
            self.toVC.view.layoutIfNeeded()
        }
    }
    
    func animateTransition(duration: NSTimeInterval, animations: (Void -> Void), completion: ((Bool) -> Void)? = nil) {
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: .CurveEaseOut,
                                   animations: animations,
                                   completion: completion)
        
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        self.percentComplete = percentComplete
        
        if self.isPresenting {
            var fromRect = self.finalFrameForViewController(self.fromVC)
            var toRect = self.finalFrameForViewController(self.toVC)
            
            fromRect.origin.x = fromRect.origin.x * percentComplete
            toRect.origin.x = toRect.origin.x * percentComplete
            
            self.fromVC.view.frame = fromRect
            self.toVC.view.frame = toRect
            self.blackScreenView.alpha = percentComplete
        } else {
            print("percentComplete \(percentComplete)")
            
            var fromRect = self.finalFrameForViewController(self.fromVC)
            let toInitRect = self.initialFrameForViewController(self.toVC)
            var toRect = self.finalFrameForViewController(self.toVC)
            
            fromRect.origin.x = fromRect.origin.x * percentComplete
            toRect.origin.x = toInitRect.origin.x * (1.0 - percentComplete)
            
            if fromRect.origin.x < 0.0 {
                fromRect.origin.x = 0.0
            }
            if isnan(fromRect.origin.x) || isinf(fromRect.origin.x) {
                fromRect.origin.x = 0.0
            }
            
            self.fromVC.view.frame = fromRect
            self.toVC.view.frame = toRect
            self.blackScreenView.alpha = 1.0 - percentComplete
        }
    }
    
    func finishInteractiveTransition() {
        let d = self.duration - (self.duration * Double.init(self.percentComplete))
        self.nowInteractive = false
        
        self.animateTransition(d, animations: {
            self.updateInteractiveTransition(1.0)
        }) { finished in
            self.completeTransition(true)
        }
    }
    
    func cancelInteractiveTransition() {
        let d = self.duration * Double.init(1.0 - self.percentComplete)
        self.nowInteractive = false
        
        self.animateTransition(d, animations: {
            self.updateInteractiveTransition(0.0)
        }) { finished in
            self.completeTransition(false)
        }
    }
    
    func completeTransition(didComplete: Bool) {
        self.nowInteractive = false
        
        if didComplete {
            self.blackScreenView.removeFromSuperview()
            self.fromVC.view.removeFromSuperview()
        }
        self.completion?(didComplete)
    }
    
    func viewControllerForKey(key: String) -> UIViewController? {
        if key == UITransitionContextFromViewControllerKey { return self.fromVC }
        if key == UITransitionContextToViewControllerKey { return self.toVC }
        return nil
    }
    
    func viewForKey(key: String) -> UIView? {
        return self.viewControllerForKey(key)?.view
    }
    
    func targetTransform() -> CGAffineTransform {
        return self._containerView.transform
    }
    
    func initialFrameForViewController(vc: UIViewController) -> CGRect {
        var f = vc.view.frame
        if vc === self.fromVC {
            f.origin.x = 0.0
        } else {
            f.origin.x = self.isPresenting ? f.width : self.fromVCScrollX
        }
        return f
    }
    
    func finalFrameForViewController(vc: UIViewController) -> CGRect {
        var f = vc.view.frame
        if vc === self.fromVC {
            f.origin.x = self.isPresenting ? self.fromVCScrollX : f.width
        } else {
            f.origin.x = 0.0
        }
        return f
    }
}
