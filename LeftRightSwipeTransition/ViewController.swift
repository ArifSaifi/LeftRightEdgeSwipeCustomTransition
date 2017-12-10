//
//  ViewController.swift
//  LeftRightSwipeTransition
//
//  Created by HCLTMacBook36 on 10/12/17.
//  Copyright © 2017 Personal. All rights reserved.
//

import UIKit

extension ViewController: SwipeAnimatorDelegate {
    var animator: SwipeAnimator? {
        return swipeAnimatorController
    }
}

class ViewController: UIViewController {

    var swipeAnimatorController: SwipeAnimator?
    var interactiveLRSwipeContoller: SwipeInteractionController?
    var interactiveRLSwipeContoller: SwipeInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transitioningDelegate = SwipeTransitionController.shared
        interactiveRLSwipeContoller = SwipeInteractionController(viewController: self,
                                                                 isFromRightEdge: true,
                                                                 beganFunc: self.presentRightViewController)
        interactiveLRSwipeContoller = SwipeInteractionController(viewController: self,
                                                                 isFromRightEdge: false,
                                                                 beganFunc: self.presentLeftViewController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        swipeAnimatorController = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.destination is LeftViewController {
            self.leftSwipeConfig()
        } else if segue.destination is RightViewController {
            self.rightSwipeConfig()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentLeftViewController() {
        self.leftSwipeConfig()
        self.performSegue(withIdentifier: "LeftPush", sender: nil)
    }
    
    func presentRightViewController() {
        self.rightSwipeConfig()
        self.performSegue(withIdentifier: "RightPush", sender: nil)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private func leftSwipeConfig() {
        swipeAnimatorController = SwipeAnimator()
        swipeAnimatorController?.isFromRightToLeft = false
        swipeAnimatorController?.transitionStyle = .plain
        swipeAnimatorController?.interactionController = interactiveLRSwipeContoller
    }
    
    private func rightSwipeConfig() {
        swipeAnimatorController = SwipeAnimator()
        swipeAnimatorController?.isFromRightToLeft = true
        swipeAnimatorController?.interactionController = interactiveRLSwipeContoller
    }
    
}
