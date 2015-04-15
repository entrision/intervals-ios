//
//  CustomModalTransition.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit

class CustomModalTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if self.presenting {
            self.present(transitionContext)
        }
        else {
            self.dismiss(transitionContext)
        }
    }
    
    //MARK: Private methods
    
    func present(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        transitionContext.containerView().addSubview(toViewController!.view)
        toViewController?.view.frame = CGRectMake(0, transitionContext.containerView().frame.size.height, toViewController!.view.frame.size.width, toViewController!.view.frame.size.height)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: ({
            
            fromViewController?.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
            toViewController?.view.frame = CGRectMake(0, 0, toViewController!.view.frame.size.width, toViewController!.view.frame.size.height)
            
        }), completion: { finished in
            transitionContext.completeTransition(true)
        });
    }
    
    func dismiss(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        transitionContext.containerView().addSubview(toViewController!.view)
        toViewController?.view.transform = CGAffineTransformMakeScale(0.85, 0.85);
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: ({
            
            fromViewController?.view.frame = CGRectMake(0, transitionContext.containerView().frame.size.height, fromViewController!.view.frame.size.width, fromViewController!.view.frame.size.height)
            toViewController?.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
            
        }), completion: { finished in
            fromViewController?.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        });
    }
}
