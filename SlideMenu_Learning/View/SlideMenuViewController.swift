//
//  SlideMenuViewController.swift
//  SlideMenu_Learning
//
//  Created by 深見龍一 on 2019/11/30.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SlideMenuViewController: UIViewController {
    private let disposeBag = DisposeBag()
    var swipeGesture : UISwipeGestureRecognizer!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var imageAicon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let list = BehaviorRelay<Array>(value: ["Profile", "Topics", "Lists", "Bookmarks", "Moments", "Setting and privacy", "Help Center"])
    //デリゲートのインスタンスを宣言
    weak var delegate: SideMenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //slideMenu
        // メニューの位置を取得する
        let menuPos = self.menuView.layer.position
        // 初期位置を画面の外側にするため、メニューの幅の分だけマイナスする
        self.menuView.layer.position.x = -self.menuView.frame.width
        // 表示時のアニメーションを作成する
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.menuView.layer.position.x = menuPos.x
        },
            completion: { bool in
        })
    }
    
    // メニューエリア以外タップ時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch in touches {
            if touch.view?.tag == 1 {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    options: .curveEaseIn,
                    animations: {
                        self.menuView.layer.position.x = -self.menuView.frame.width
                },
                    completion: { bool in
                        self.dismiss(animated: false, completion: nil)
                }
                )
            }
        }
    }
    
    func setUpUI()
    {

        
        // aicon
        imageAicon.layer.masksToBounds = true
        imageAicon.layer.cornerRadius = imageAicon.bounds.width / 2
        
        // table
        self.tableView.register(UINib(nibName: "SlideMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "SlideMenuTableViewCell")
    }
    
    func bind()
    {
        self.list
          .bind(to: tableView.rx.items) { tableView, index, item in
            let cell: SlideMenuTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SlideMenuTableViewCell")! as! SlideMenuTableViewCell
            // 選択されたセルの色を変える
            cell.backgroundColor = UIColor.clear
            cell.lbl?.text = item
            if index != 4
            {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            return cell
        }
        .disposed(by: self.disposeBag)
    }    
}

protocol SideMenuDelegate: class {

    func test()
    func parentViewControllerForSidemenuViewController()
}
