//
//  MainViewController.swift
//  SlideMenu_Learning
//
//  Created by 深見龍一 on 2019/11/30.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    let contentVC = UINavigationController(rootViewController: UIViewController())
    let sidemenuVC = SlideMenuViewController.init(nibName: nil, bundle: nil)
    private var isShownSidemenu: Bool {
        return sidemenuVC.parent == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNav()
        self.contentVC.view.frame = self.view.bounds
        addChild(contentVC)
        view.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)

        sidemenuVC.delegate = self
        sidemenuVC.startPanGestureRecognizing()
    }
    
    @objc private func sidemenuBarButtonTapped(sender: Any) {
        showSidemenu(animated: true)
    }
    
    private func showSidemenu(contentAvailability: Bool = true, animated: Bool) {
        if isShownSidemenu { return }
        addChild(sidemenuVC)
        sidemenuVC.view.autoresizingMask = .flexibleHeight
        sidemenuVC.view.frame = self.view.frame
        view.insertSubview(sidemenuVC.view, aboveSubview: contentVC.view)
        sidemenuVC.didMove(toParent: self)
        if contentAvailability {
            sidemenuVC.showContentView(animated: animated)
        }
    }

    private func hideSidemenu(animated: Bool) {
        if !isShownSidemenu { return }

        sidemenuVC.hideContentView(animated: animated, completion: { (_) in
            self.sidemenuVC.willMove(toParent: nil)
            self.sidemenuVC.removeFromParent()
            self.sidemenuVC.view.removeFromSuperview()
        })
    }

    func setUpNav()
    {
        contentVC.viewControllers[0].title = "Main"
//        contentVC.viewControllers[0].navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sidemenu", style: .plain, target: self, action: #selector(sidemenuBarButtonTapped(sender:)))
    }
    
    @objc func move(){
        let homeVC = SlideMenuViewController.init(nibName: nil, bundle: nil)
        homeVC.modalPresentationStyle = .overCurrentContext
        
        present(homeVC, animated: false)
    }
}

extension MainViewController: SidemenuViewControllerDelegate {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SlideMenuViewController) -> UIViewController {
        return self
    }

    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SlideMenuViewController) -> Bool {
        /* You can specify sidemenu availability */
        return true
    }

    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SlideMenuViewController, contentAvailability: Bool, animated: Bool) {
        showSidemenu(contentAvailability: contentAvailability, animated: animated)
    }

    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SlideMenuViewController, animated: Bool) {
        hideSidemenu(animated: animated)
    }

    func sidemenuViewController(_ sidemenuViewController: SlideMenuViewController, didSelectItemAt indexPath: IndexPath) {
        hideSidemenu(animated: true)
    }
}
