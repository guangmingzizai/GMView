//
//  ViewController.swift
//  GMView
//
//  Created by guangmingzizai@qq.com on 02/12/2018.
//  Copyright (c) 2018 guangmingzizai@qq.com. All rights reserved.
//

import UIKit
import GMView
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.red
        
//        addLightBoxButton()
        addGMView()
    }
    
    private func addGMView() {
        let roundedCornerView = GMView(frame: .zero)
        roundedCornerView.backgroundColor = UIColor("#F7F8FF")
        roundedCornerView.borderTopLeftRadius = 0
        roundedCornerView.borderTopRightRadius = 16
        roundedCornerView.borderBottomLeftRadius = 16
        roundedCornerView.borderBottomRightRadius = 16
        roundedCornerView.borderColor = UIColor.green
        roundedCornerView.borderWidth = 3
        view.addSubview(roundedCornerView)
        
        roundedCornerView.snp.makeConstraints { (make) in
            make.width.height.equalTo(200)
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
    }
    
    private func addLightBoxButton() {
        let button = UIButton(titles: [.normal: "LightBox"], titleColors: [.normal: UIColor.blue], titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: UIColor.white, cornerRadius: 22) { [unowned self] (_) in
            self.showLightBox()
        }
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1
        view.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(44)
            make.center.equalToSuperview()
        }
    }
    
    private func showLightBox() {
        let tipView = FullscreenTipView(title: "Matcher会", message: "· 为你写Matcher印象，带OneOne认识生活中的你\n· 邀请身边的单身，提供给你更多认识同一圈层单身的机会")
        let lightBox = LightBox.show(contentView: tipView, params: LightBoxParams(backgroundBlur: .dark))
        tipView.closeButton.addHandler(for: .touchUpInside) { [unowned lightBox] (_) in
            lightBox.dismiss(animated: true)
        }
    }

}

