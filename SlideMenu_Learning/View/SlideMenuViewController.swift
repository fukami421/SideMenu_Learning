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
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var imageAicon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    let list = BehaviorRelay<Array>(value: ["Profile", "Topics", "Lists", "Bookmarks", "Moments", "Setting and privacy", "Help Center"])
    
    private var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!
    weak var delegate: SidemenuViewControllerDelegate?
    private var beganLocation: CGPoint = .zero
    private var beganState: Bool = false
    var isShown: Bool {
        return self.parent != nil
    }
    private var contentMaxWidth: CGFloat {
        return view.bounds.width * 0.8
    }
    private var contentRatio: CGFloat {
        get {
            return contentView.frame.maxX / contentMaxWidth
        }
        set {
            let ratio = min(max(newValue, 0), 1)
            contentView.frame.origin.x = contentMaxWidth * ratio - contentView.frame.width
            view.backgroundColor = UIColor(white: 0, alpha: 0.3 * ratio)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.bind()
        var contentRect = view.bounds
        contentRect.size.width = contentMaxWidth
        contentRect.origin.x = -contentRect.width
        contentView.frame = contentRect
        contentView.backgroundColor = .white
        contentView.autoresizingMask = .flexibleHeight
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(sender:)))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func backgroundTapped(sender: UITapGestureRecognizer) {
        if sender.view?.tag == 1
        {
            hideContentView(animated: true) { (_) in
                self.willMove(toParent: nil)
                self.removeFromParent()
                self.view.removeFromSuperview()
            }
        }
    }

    func showContentView(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.contentRatio = 1.0
            }
        } else {
            contentRatio = 1.0
        }
    }

    func hideContentView(animated: Bool, completion: ((Bool) -> Swift.Void)?) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.contentRatio = 0
            }, completion: { (finished) in
                completion?(finished)
            })
        } else {
            contentRatio = 0
            completion?(true)
        }
    }

    func startPanGestureRecognizing() {
        if let parentViewController = self.delegate?.parentViewControllerForSidemenuViewController(self) {
            screenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandled(panGestureRecognizer:)))
            screenEdgePanGestureRecognizer.edges = [.left]
            screenEdgePanGestureRecognizer.delegate = self
            parentViewController.view.addGestureRecognizer(screenEdgePanGestureRecognizer)
            
            panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandled(panGestureRecognizer:)))
            panGestureRecognizer.delegate = self
            parentViewController.view.addGestureRecognizer(panGestureRecognizer)
        }
    }

    @objc private func panGestureRecognizerHandled(panGestureRecognizer: UIPanGestureRecognizer) {
        guard let shouldPresent = self.delegate?.shouldPresentForSidemenuViewController(self), shouldPresent else {
            return
        }
        
        let translation = panGestureRecognizer.translation(in: view)
        if translation.x > 0 && contentRatio == 1.0 {
            return
        }
        
        let location = panGestureRecognizer.location(in: view)
        switch panGestureRecognizer.state {
        case .began:
            beganState = isShown
            beganLocation = location
            if translation.x  >= 0 {
                self.delegate?.sidemenuViewControllerDidRequestShowing(self, contentAvailability: false, animated: false)
            }
        case .changed:
            let distance = beganState ? beganLocation.x - location.x : location.x - beganLocation.x
            if distance >= 0 {
                let ratio = distance / (beganState ? beganLocation.x : (view.bounds.width - beganLocation.x))
                let contentRatio = beganState ? 1 - ratio : ratio
                self.contentRatio = contentRatio
            }
            
        case .ended, .cancelled, .failed:
            if contentRatio <= 1.0, contentRatio >= 0 {
                if location.x > beganLocation.x {
                    showContentView(animated: true)
                } else {
                    self.delegate?.sidemenuViewControllerDidRequestHiding(self, animated: true)
                }
            }
            beganLocation = .zero
            beganState = false
        default: break
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

extension SlideMenuViewController: UIGestureRecognizerDelegate {
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

protocol SidemenuViewControllerDelegate: class {
    func parentViewControllerForSidemenuViewController(_ sidemenuViewController: SlideMenuViewController) -> UIViewController
    func shouldPresentForSidemenuViewController(_ sidemenuViewController: SlideMenuViewController) -> Bool
    func sidemenuViewControllerDidRequestShowing(_ sidemenuViewController: SlideMenuViewController, contentAvailability: Bool, animated: Bool)
    func sidemenuViewControllerDidRequestHiding(_ sidemenuViewController: SlideMenuViewController, animated: Bool)
    func sidemenuViewController(_ sidemenuViewController: SlideMenuViewController, didSelectItemAt indexPath: IndexPath)
}
