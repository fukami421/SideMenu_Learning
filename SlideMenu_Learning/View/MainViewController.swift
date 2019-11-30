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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNav()
    }
    
    func setUpNav()
    {
        self.title = "Main"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Side", style: UIBarButtonItem.Style.plain, target: self, action:#selector(self.move))
    }
    
    @objc func move(){
        let homeVC = SlideMenuViewController.init(nibName: nil, bundle: nil)
        homeVC.modalPresentationStyle = .overCurrentContext
        
        present(homeVC, animated: false)
    }
}
