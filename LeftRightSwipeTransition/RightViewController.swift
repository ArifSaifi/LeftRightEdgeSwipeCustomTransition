//
//  RightViewController.swift
//
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

extension RightViewController: SwipeAnimatorDelegate {
    var animator: SwipeAnimator? {
        return swipeAnimatorController
    }
}

class RightViewController: UIViewController {
    
    var swipeAnimatorController = SwipeAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transitioningDelegate = SwipeTransitionController.shared
        swipeAnimatorController.isFromRightToLeft = true
        swipeAnimatorController.isForDismiss = true
        let interactiveLRSwipeContoller = SwipeInteractionController(viewController: self,
                                                                 isFromRightEdge: false,
                                                                 beganFunc: self.dismiss)
        swipeAnimatorController.interactionController = interactiveLRSwipeContoller
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
