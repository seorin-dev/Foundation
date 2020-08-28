//
//  ZoomDismissalInteractionController.swift
//  ArZoo
//
//  Created by baedy on 2019/06/11.
//  Copyright © 2019 LG U+. All rights reserved.
//

import UIKit

class ZoomDismissalInteractionController: NSObject {
    
    var transitionContext: UIViewControllerContextTransitioning?
    var animator: UIViewControllerAnimatedTransitioning?
    
    var fromReferenceImageViewFrame: CGRect?
    var toReferenceImageViewFrame: CGRect?
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let transitionContext = self.transitionContext,
            let animator = self.animator as? ZoomAnimator,
            let transitionImageView = animator.transitionImageView,
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageView = animator.fromDelegate?.referenceImageView(for: animator),
            let toReferenceImageView = animator.toDelegate?.referenceImageView(for: animator),
            let fromReferenceImageViewFrame = self.fromReferenceImageViewFrame,
            let toReferenceImageViewFrame = self.toReferenceImageViewFrame else {
                return
        }
        
//        Log.d("gestureRecognizer : \(gestureRecognizer)")
        
        fromReferenceImageView.isHidden = true
        
//        if gestureRecognizer.state == .began{
//        let anchorPoint = CGPoint(x: fromReferenceImageViewFrame.midX, y: fromReferenceImageViewFrame.midY)
        let anchorPoint = CGPoint(x: fromVC.view.center.x, y: fromVC.view.center.y)
        
//        gestureRecognizer.setTranslation(.zero, in: fromVC.view)
//        }//
        let translatedPoint = gestureRecognizer.translation(in: fromVC.view)
        
        var verticalDelta : CGFloat = 0
        
        //Check if the device is in landscape
        
//        if UIDevice.current.orientation.isLandscape {
//            verticalDelta = translatedPoint.x < 0 ? 0 : translatedPoint.x
//        }
//        //Otherwise the device is in any non-landscape orientation
//        else {
//            verticalDelta = translatedPoint.y < 0 ? 0 : translatedPoint.y
//        }
        
        verticalDelta = translatedPoint.y < 0 ? 0 : translatedPoint.y
        
        let backgroundAlpha = backgroundAlphaFor(view: fromVC.view, withPanningVerticalDelta: translatedPoint.y)
        let scale = scaleFor(view: fromVC.view, withPanningVerticalDelta: verticalDelta)
        
        fromVC.view.alpha = backgroundAlpha
        
//        print("anchorPoint.y : \(anchorPoint.y) translatedPoint.y : \(translatedPoint.y) transitionImageView.frame.height : \(transitionImageView.frame.height)")
//        print("anchorPoint.x : \(anchorPoint.x) translatedPoint.x : \(translatedPoint.x) transitionImageView.frame.height : \(transitionImageView.frame.height)")
        
        //  - transitionImageView.frame.height * (1 - scale) / 2.0
        
        
        transitionImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
//        let newCenter = CGPoint(x: fromVC.view.center.x + translatedPoint.x , y: fromVC.view.center.y + translatedPoint.y)
        let newCenter = CGPoint(x: anchorPoint.x + translatedPoint.x / 2.0, y: anchorPoint.y + translatedPoint.y / 2 )
//        let newCenter = CGPoint(x: anchorPoint.x + translatedPoint.x / 2.0, y: anchorPoint.y + translatedPoint.y - transitionImageView.frame.height / 2)

        
        
        // - transitionImageView.frame.height * (1 - scale) / 2.0
        
        transitionImageView.center = newCenter
        
//        toReferenceImageView.isHidden = true
        
        toReferenceImageView.alpha = 0.0
        
        transitionContext.updateInteractiveTransition(1 - scale)
        
        toVC.tabBarController?.tabBar.alpha = 1 - backgroundAlpha

        let velocity = gestureRecognizer.velocity(in: fromVC.view)
//        Log.d("velocity: \(velocity)")
//        Log.d("transition: \(translatedPoint)")
        
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled || gestureRecognizer.state == .failed{
            
            
//            var velocityCheck : Bool = false
//
//            if UIDevice.current.orientation.isLandscape {
//
//            }
//            else {
//                velocityCheck = velocity.y < 0 || newCenter.y < anchorPoint.y
            //            }
            
//            velocityCheck =  newCenter.x < anchorPoint.x
            
//            NSLog("velocity : \(velocity.y < 0)")
            if /* velocity.y < -100 ||*/ translatedPoint.y < 50{
                
                //cancel
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: {
                        transitionImageView.frame = fromReferenceImageViewFrame
                        fromVC.view.alpha = 1.0
                        toVC.tabBarController?.tabBar.alpha = 0
                },
                    completion: { completed in
                        
                        toReferenceImageView.isHidden = false
                        fromReferenceImageView.isHidden = false
                        transitionImageView.removeFromSuperview()
                        animator.transitionImageView = nil
                        transitionContext.cancelInteractiveTransition()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        animator.toDelegate?.transitionDidEndWith(zoomAnimator: animator)
                        animator.fromDelegate?.transitionDidEndWith(zoomAnimator: animator)
                        self.transitionContext = nil
                })
                return
            }
            
            //start animation
            let finalTransitionSize = toReferenceImageViewFrame
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            fromVC.view.alpha = 0
                            transitionImageView.frame = finalTransitionSize
                            toVC.tabBarController?.tabBar.alpha = 1
                            transitionImageView.alpha = 0.2
                            
                            toReferenceImageView.alpha = 1
            }, completion: { completed in
                
                transitionImageView.removeFromSuperview()
                toReferenceImageView.isHidden = false
                fromReferenceImageView.isHidden = false
                
                
                
                self.transitionContext?.finishInteractiveTransition()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                animator.toDelegate?.transitionDidEndWith(zoomAnimator: animator)
                animator.fromDelegate?.transitionDidEndWith(zoomAnimator: animator)
                self.transitionContext = nil
            })
        }
    }
    
    func backgroundAlphaFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingAlpha:CGFloat = 1.0
        let finalAlpha: CGFloat = 0.3
        let totalAvailableAlpha = startingAlpha - finalAlpha
        
        let maximumDelta = view.bounds.height / 2.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        
        return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha)
    }
    
    func scaleFor(view: UIView, withPanningVerticalDelta verticalDelta: CGFloat) -> CGFloat {
        let startingScale:CGFloat = 1.0
        let finalScale: CGFloat = 0.5
        let totalAvailableScale = startingScale - finalScale
        
        let maximumDelta = view.bounds.height / 2.0
        let deltaAsPercentageOfMaximun = min(abs(verticalDelta) / maximumDelta, 1.0)
        
        return startingScale - (deltaAsPercentageOfMaximun * totalAvailableScale)
    }
}

extension ZoomDismissalInteractionController: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView
        
        guard let animator = self.animator as? ZoomAnimator,
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromReferenceImageViewFrame = animator.fromDelegate?.referenceImageViewFrameInTransitioningView(for: animator),
            let toReferenceImageViewFrame = animator.toDelegate?.referenceImageViewFrameInTransitioningView(for: animator),
            let fromReferenceImageView = animator.fromDelegate?.referenceImageView(for: animator)
            else {
                return
        }
        
        animator.fromDelegate?.transitionWillStartWith(zoomAnimator: animator)
        animator.toDelegate?.transitionWillStartWith(zoomAnimator: animator)
        
        self.fromReferenceImageViewFrame = fromReferenceImageViewFrame
        self.toReferenceImageViewFrame = toReferenceImageViewFrame
        
        let referenceImage = fromReferenceImageView.image
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        if animator.transitionImageView == nil {
            let transitionImageView = UIImageView(image: referenceImage)
            transitionImageView.contentMode = .scaleAspectFill
            transitionImageView.clipsToBounds = true
            transitionImageView.frame = fromReferenceImageViewFrame
            animator.transitionImageView = transitionImageView
            containerView.addSubview(transitionImageView)
        }
    }
}
