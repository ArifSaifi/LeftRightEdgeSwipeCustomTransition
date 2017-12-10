//
//  SwipeAnimator.swift
//
//  Copyright © 2017 HCL Technologies. All rights reserved.
//

import UIKit

protocol SwipeAnimatorDelegate {    
    var animator: SwipeAnimator? {get}
}

// MARK: -

class SwipeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Style {
        case transform
        case plain
    }
    
    // MARK: - Instance properties
    
    /**
     * Set the duration of transition for non-interactive transition
     */
    var transitionDuration: TimeInterval = 0.3
    
    /**
     * Set SwipeInteractionController instance with proper configuration
     * If not assigned than interactive transition won't work
     */
    var interactionController: SwipeInteractionController?
    
    /**
     * Set transform/plain for different type of transition
     */
    var transitionStyle: Style = .transform
    
    /**
     * Set isForDismiss to true for dismis/pop viewcontroller
     */
    var isForDismiss: Bool = false
    
    /**
     * By default the transition happens from left to right.
     * Set it to true to reverse the direction
     */
    var isFromRightToLeft: Bool = false
    
    // MARK: - overrides UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch transitionStyle {
        case .plain:
            animateTransitionPlain(using: transitionContext)
        case .transform:
            animateTransitionTransform(using: transitionContext)
        }
        
    }
    
    // MARK: - Transition styles
    
    private func animateTransitionTransform(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let toView: UIView = toVC.view
        let fromView: UIView = fromVC.view
        
        let toViewOriginalFrame = toView.frame
        let fromViewOriginalFrame = fromView.frame
        
        let transformScale: CGAffineTransform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        let darkness: CGFloat = 0.85
        let darkLayerView: UIView = UIView(frame: CGRect(origin: CGPoint.zero,
                                                         size: isForDismiss ? toViewOriginalFrame.size : fromViewOriginalFrame.size))
        darkLayerView.backgroundColor = UIColor.black
        darkLayerView.alpha = 0
        
        containerView.addSubview(toView)
        
        var newFrame = CGRect.zero
        if isForDismiss {
            containerView.bringSubview(toFront: fromView)
            newFrame = fromViewOriginalFrame
            newFrame.origin.x = isFromRightToLeft ? newFrame.size.width: -newFrame.size.width
            
            toView.addSubview(darkLayerView)
            darkLayerView.alpha = darkness
            toView.transform = transformScale
        } else {
            newFrame = toViewOriginalFrame
            newFrame.origin.x =  isFromRightToLeft ? newFrame.size.width : -newFrame.size.width
            toVC.view.frame = newFrame
            
            fromView.addSubview(darkLayerView)
            darkLayerView.alpha = 0
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration,
                       animations: {
                        if self.isForDismiss {
                            fromView.frame = newFrame
                            darkLayerView.alpha = 0
                            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        } else {
                            toView.frame = toViewOriginalFrame
                            darkLayerView.alpha = darkness
                            fromView.transform = transformScale
                        }
                        
        }) { (isCompleted) in
            darkLayerView.removeFromSuperview()
            toView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            fromView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toView.frame = toViewOriginalFrame
            fromView.frame = fromViewOriginalFrame
            toView.frame = transitionContext.finalFrame(for: toVC)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func animateTransitionPlain(using transitionContext: UIViewControllerContextTransitioning) {

        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                return
        }

        let containerView = transitionContext.containerView
        let toView: UIView = toVC.view
        let fromView: UIView = fromVC.view

        let toViewOriginalFrame = toView.frame
        let fromViewOriginalFrame = fromView.frame

        let darkness: CGFloat = 0.25
        let darkLayerView: UIView = UIView(frame: CGRect(origin: CGPoint.zero,
                                                         size: isForDismiss ? toViewOriginalFrame.size : fromViewOriginalFrame.size))
        darkLayerView.backgroundColor = UIColor.black
        darkLayerView.alpha = 0

        containerView.addSubview(toView)

        var newFrame = CGRect.zero
        if isForDismiss {
            containerView.bringSubview(toFront: fromView)
            newFrame = fromViewOriginalFrame
            newFrame.origin.x = isFromRightToLeft ? newFrame.size.width: -newFrame.size.width

            toView.addSubview(darkLayerView)
            darkLayerView.alpha = darkness
        } else {
            newFrame = toViewOriginalFrame
            newFrame.origin.x =  isFromRightToLeft ? newFrame.size.width : -newFrame.size.width
            toVC.view.frame = newFrame

            fromView.addSubview(darkLayerView)
            darkLayerView.alpha = 0
        }

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration,
                       animations: {
                        if self.isForDismiss {
                            fromView.frame = newFrame
                            darkLayerView.alpha = 0
                        } else {
                            toView.frame = toViewOriginalFrame
                            darkLayerView.alpha = darkness
                        }

        }) { (isCompleted) in
            darkLayerView.removeFromSuperview()
            toView.frame = toViewOriginalFrame
            fromView.frame = fromViewOriginalFrame
            toView.frame = transitionContext.finalFrame(for: toVC)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    // MARK: -
    
}

class SwipeInteractionController: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
    
    // MARK: - Private properties
    
    fileprivate var interactionInProgress = false
    private var gesture: UIScreenEdgePanGestureRecognizer!
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    private var otherGestureRecognizers: [UIGestureRecognizer: Bool] = [:]
    
    // MARK: - Instance properties
    
    var isFromRightEdge: Bool
    var beganFunc: (() -> Void)
    
    var isEnabled: Bool {
        get {
            return gesture.isEnabled
        }
        set (newValue) {
            gesture.isEnabled = newValue
        }
    }
    
    // MARK: -
    
    init(viewController: UIViewController, isFromRightEdge: Bool, beganFunc: @escaping (() -> Void)) {
        self.beganFunc = beganFunc
        self.isFromRightEdge = isFromRightEdge
        
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }
    
    // MARK: - Helper
    
    private func prepareGestureRecognizer(in view: UIView) {
        gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = isFromRightEdge ? .right : .left
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = ((isFromRightEdge ? -translation.x : translation.x) / UIScreen.main.bounds.size.width)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        switch gestureRecognizer.state {
        case .began:
            // This is to stop any other pan gestures while UIScreenEdgePanGestureRecognizer
            // is doing its job
            _ = self.otherGestureRecognizers.map { $0.key.isEnabled = false }
            interactionInProgress = true
            beganFunc()
        case .changed:
            shouldCompleteTransition = progress > 0.3
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
            // Setting the other gestures enable state back to its original state
            _ = self.otherGestureRecognizers.map { $0.key.isEnabled = true }
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // Holding the refernces to enable/disable if required
        self.otherGestureRecognizers[otherGestureRecognizer] = otherGestureRecognizer.isEnabled
        
        return true
    }
    
    // MARK: -
    
    deinit {
        if viewController != nil && gesture != nil {
            viewController.view.removeGestureRecognizer(gesture)
        }
    }
}

// MARK: -

class SwipeTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    static let shared = SwipeTransitionController()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Overrides UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromSceneAnimatorDelegate: SwipeAnimatorDelegate? = presenting as? SwipeAnimatorDelegate
        let toSceneAnimatorDelegate: SwipeAnimatorDelegate? = presented as? SwipeAnimatorDelegate
        
        return fromSceneAnimatorDelegate?.animator ?? toSceneAnimatorDelegate?.animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let fromSceneAnimatorDelegate: SwipeAnimatorDelegate? = dismissed as? SwipeAnimatorDelegate
        
        return fromSceneAnimatorDelegate?.animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        guard let animator = animator as? SwipeAnimator,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
    
    func interactionControllerForDismissal(using
        animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? SwipeAnimator,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
    
    // MARK: -
}

/**
 * For using the transition inside a UINavigationController.
 * Just assign UINavigationController's delegate to SwipeTransitionNavControllerDelgate.shared
 */
class SwipeTransitionNavControllerDelgate: NSObject, UINavigationControllerDelegate {
    
    static let shared = SwipeTransitionNavControllerDelgate()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Overrides UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let fromSceneAnimatorDelegate: SwipeAnimatorDelegate? = fromVC as? SwipeAnimatorDelegate
        let toSceneAnimatorDelegate: SwipeAnimatorDelegate? = toVC as? SwipeAnimatorDelegate
        
        return fromSceneAnimatorDelegate?.animator ?? toSceneAnimatorDelegate?.animator
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animationController as? SwipeAnimator,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
}
