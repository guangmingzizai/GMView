//
//  ViewController.swift
//  GMView
//
//  Created by guangmingzizai@qq.com on 02/12/2018.
//  Copyright (c) 2018 guangmingzizai@qq.com. All rights reserved.
//

import UIKit
import GMView

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let roundedCornerView = GMView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        roundedCornerView.backgroundColor = UIColor.red
        roundedCornerView.borderTopLeftRadius = 0
        roundedCornerView.borderTopRightRadius = 16
        roundedCornerView.borderBottomLeftRadius = 16
        roundedCornerView.borderBottomRightRadius = 16
        roundedCornerView.borderColor = UIColor.green
        roundedCornerView.borderWidth = 3
        view.addSubview(roundedCornerView)
    }

}

