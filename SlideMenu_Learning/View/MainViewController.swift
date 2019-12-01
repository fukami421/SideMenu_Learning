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
    let contentViewController = UINavigationController(rootViewController: UIViewController())
    let sidemenuViewController = SlideMenuViewController.init(nibName: nil, bundle: nil)
    private var isShownSidemenu: Bool {
        return sidemenuViewController.parent == self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNav()
        contentViewController.viewControllers[0].navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sidemenu", style: .plain, target: self, action: #selector(sidemenuBarButtonTapped(sender:)))
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        sidemenuViewController.delegate = self
        sidemenuViewController.startPanGestureRecognizing()
    }
    
    @objc private func sidemenuBarButtonTapped(sender: Any) {
        showSidemenu(animated: true)
    }
    
    private func showSidemenu(contentAvailability: Bool = true, animated: Bool) {
        if isShownSidemenu { return }

        addChild(sidemenuViewController)
        sidemenuViewController.view.autoresizingMask = .flexibleHeight
        sidemenuViewController.view.frame = contentViewController.view.bounds
        view.insertSubview(sidemenuViewController.view, aboveSubview: contentViewController.view)
        sidemenuViewController.didMove(toParent: self)
        if contentAvailability {
            sidemenuViewController.showContentView(animated: animated)
        }
    }

    private func hideSidemenu(animated: Bool) {
        if !isShownSidemenu { return }

        sidemenuViewController.hideContentView(animated: animated, completion: { (_) in
            self.sidemenuViewController.willMove(toParent: nil)
            self.sidemenuViewController.removeFromParent()
            self.sidemenuViewController.view.removeFromSuperview()
        })
    }

    func setUpNav()
    {
        self.title = "Main"
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Side", style: UIBarButtonItem.Style.plain, target: self, action:#selector(self.move))
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
