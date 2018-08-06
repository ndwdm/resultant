//
//  SplashScreenViewController.swift
//  resultant
//
//  Created by Gennady Dmitrik on 06.08.2018.
//  Copyright © 2018 Gennady Dmitrik. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {
    @IBOutlet weak var splashScreenImageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions(), animations: {
            self.splashScreenImageView.alpha = 0.0
        }, completion: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                self.view.window?.rootViewController = initialViewController
            }
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
