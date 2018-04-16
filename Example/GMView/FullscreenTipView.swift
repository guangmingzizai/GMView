//
//  FullscreenTipView.swift
//  GMView_Example
//
//  Created by wangjianfei on 2018/4/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import FlexLayout
import PinLayout

class FullscreenTipView: UIView {
    
    private(set) lazy var titleLabel = UILabel(textColor: UIColor.white, font: UIFont.pingFangSCMediumScalable(fontSize: 20), numberOfLines: 0, textAlignment: .center)
    private(set) lazy var messageLabel = UILabel(textColor: UIColor.white, font: UIFont.pingFangSCLightScalable(fontSize: 17), numberOfLines: 0, textAlignment: .left)
    private(set) lazy var closeButton = UIButton(images: [.normal: #imageLiteral(resourceName: "modal_big_close")], backgroundColor: UIColor.clear)
    private let rootFlexContainer: UIView = UIView()
    
    init(title: String? = nil, message: String? = nil) {
        super.init(frame: .zero)
        
        if let title = title {
            titleLabel.text = title
        }
        if let message = message {
            messageLabel.text = message
        }
        
        rootFlexContainer.flex.alignItems(.center).define { (flex) in
            flex.addItem().alignSelf(.stretch).alignItems(.center).justifyContent(.center).paddingHorizontal(40).grow(1).define({ (flex) in
                if title != nil {
                    flex.addItem(titleLabel)
                }
                if message != nil {
                    flex.addItem(messageLabel).marginTop(title != nil ? 40 : 0)
                }
            })
            flex.addItem(closeButton).size(54).marginBottom(83)
        }
        addSubview(rootFlexContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rootFlexContainer.pin.all()
        rootFlexContainer.flex.layout()
    }
    
}
