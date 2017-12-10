//
//  LeftViewController.swift
//
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

extension LeftViewController: SwipeAnimatorDelegate {
    var animator: SwipeAnimator? {
        return swipeAnimatorController
    }
}

class LeftViewController: UIViewController {
    
    var swipeAnimatorController = SwipeAnimator()    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transitioningDelegate = SwipeTransitionController.shared
        swipeAnimatorController.isForDismiss = true
        swipeAnimatorController.transitionStyle = .plain
        let interactiveRLSwipeContoller = SwipeInteractionController(viewController: self,
                                                                 isFromRightEdge: true,
                                                                 beganFunc: self.dismiss)
        swipeAnimatorController.interactionController = interactiveRLSwipeContoller
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
