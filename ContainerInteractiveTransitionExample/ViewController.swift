//
//  ViewController.swift
//  ContainerInteractiveTransitionExample
//
//  Created by xxxAIRINxxx on 2016/06/14.
//  Copyright © 2016 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ViewController: UIViewController  {
    
    @IBOutlet private weak var containerView: UIView!
    
    private var animator: Animator!
    private var interactiveAnimator: InteractiveAnimator!
  
    private var isTransitioning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.childViewControllers.last
    }
    
    func push() {
        guard let fromVC = self.childViewControllers.last else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let v = storyboard.instantiateViewControllerWithIdentifier("ContentsViewController") as! ContentsViewController
        let n = UINavigationController(rootViewController: v)
        
        let context = TransitionContext(containerView: self.containerView, fromVC: fromVC, toVC: n, isPresenting: true)
        context.completion = { [weak self] didComplete in
            self?.animator = nil
            fromVC.endAppearanceTransition()
            n.endAppearanceTransition()
            
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        
        fromVC.willMoveToParentViewController(nil)
        self.addChildViewController(n)
        n.didMoveToParentViewController(self)
        
        fromVC.beginAppearanceTransition(false, animated: false)
        n.beginAppearanceTransition(true, animated: false)
        
        self.animator = Animator()
        self.setupInteractiveAnimator()
        self.animator.animateTransition(context)
    }
    
    func pop() {
        if self.isTransitioning { return }
        if self.childViewControllers.count <= 1 { return }
        guard let fromVC = self.childViewControllers.last else { return }
        guard let toVC = self.getToVC(fromVC) else { return }
        
        self.isTransitioning = true
        
        let context = TransitionContext(containerView: self.containerView, fromVC: fromVC, toVC: toVC, isPresenting: false)
        context.completion = { [weak self] didComplete in
            self?.animator = nil
            self?.isTransitioning = false
            
            fromVC.endAppearanceTransition()
            toVC.endAppearanceTransition()
            fromVC.removeFromParentViewController()
            toVC.didMoveToParentViewController(self)
            
            self?.setupInteractiveAnimator()
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        
        fromVC.beginAppearanceTransition(false, animated: false)
        toVC.beginAppearanceTransition(true, animated: false)
        
        self.animator = Animator()
        self.animator.animateTransition(context)
    }
    
    private func getToVC(fromVC: UIViewController) -> UIViewController? {
        if self.childViewControllers.count <= 1 { return nil }
        
        var index = 0
        self.childViewControllers.enumerate().forEach() {
            if $0.element === fromVC {
                index = $0.index
            }
        }
        
        if index == 0 { return nil }
        return self.childViewControllers[index - 1]
    }
    
    private func setupInteractiveAnimator() {
        if self.childViewControllers.count <= 1 { return }
        guard let fromVC = self.childViewControllers.last else { return }
        guard let toVC = self.getToVC(fromVC) else { return }
        
        let context = TransitionContext(containerView: self.containerView, fromVC: fromVC, toVC: toVC, isPresenting: false)
        context.completion = { [weak self] didComplete in
            if didComplete {
                self?.interactiveAnimator = nil
                
                fromVC.endAppearanceTransition()
                toVC.endAppearanceTransition()
                
                fromVC.willMoveToParentViewController(nil)
                fromVC.removeFromParentViewController()
                
                self?.setNeedsStatusBarAppearanceUpdate()
                
                self?.setupInteractiveAnimator()
            }
        }
        
        self.interactiveAnimator = InteractiveAnimator(context)
        self.interactiveAnimator.registerDismissalPanGesture(fromVC)
    }
}

extension UIColor {
    
    static func rgba(red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor(
            red: (red < 0 ? 0 : red) / 255,
            green: (green < 0 ? 0 : green) / 255,
            blue: (blue < 0 ? 0 : blue) / 255,
            alpha: alpha < 0 ? 0 : alpha)
    }
}
