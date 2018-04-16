//
//  Cocoa+Extension.swift
//  GMView_Example
//
//  Created by wangjianfei on 2018/4/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

private var controlHandlerKey: Int8 = 0

extension UIControlState: Hashable {
    static let all: [UIControlState] = [.normal, .selected, .disabled, .highlighted]
    
    public var hashValue: Int {
        return Int(rawValue)
    }
}

extension UILabel {
    convenience init(textColor: UIColor = UIColor.white,
                     font: UIFont = UIFont.systemFont(ofSize: 16),
                     numberOfLines: Int = 1,
                     textAlignment: NSTextAlignment = .left,
                     text: String = "",
                     attributedText: NSAttributedString? = nil
        ) {
        self.init(frame: .zero)
        
        self.textColor = textColor
        self.font = font
        self.numberOfLines = numberOfLines
        self.textAlignment = textAlignment
        self.text = text
        if let attributedText = attributedText {
            self.attributedText = attributedText
        }
    }
}

extension UIControl {
    public func addHandler(for controlEvents: UIControlEvents, handler: @escaping (UIControl) -> ()) {
        if let oldTarget = objc_getAssociatedObject(self, &controlHandlerKey) as? CocoaTarget<UIControl> {
            self.removeTarget(oldTarget, action: #selector(oldTarget.sendNext), for: controlEvents)
        }
        
        let target = CocoaTarget<UIControl>(handler)
        objc_setAssociatedObject(self, &controlHandlerKey, target, .OBJC_ASSOCIATION_RETAIN)
        self.addTarget(target, action: #selector(target.sendNext), for: controlEvents)
    }
}

extension UIButton {
    convenience init(
        titles: [UIControlState: String] = [:],
        titleColors: [UIControlState: UIColor] = [:],
        images: [UIControlState: UIImage] = [:],
        backgroundImages: [UIControlState: UIImage] = [:],
        titleFont: UIFont = UIFont.systemFont(ofSize: 16),
        backgroundColor: UIColor = UIColor.white,
        cornerRadius: Float = 0,
        selected: Bool = false,
        enabled: Bool = true,
        handler: @escaping (UIControl) -> () = {_ in }
        ) {
        self.init()
        
        titleLabel?.font = titleFont
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.masksToBounds = (cornerRadius > 0)
        self.isSelected = selected
        self.isEnabled = enabled
        self.addHandler(for: .touchUpInside, handler: handler)
        
        for controlState in UIControlState.all {
            if let title = titles[controlState] {
                setTitle(title, for: controlState)
            }
            
            if let titleColor = titleColors[controlState] {
                setTitleColor(titleColor, for: controlState)
            }
            
            if let image = images[controlState] {
                setImage(image, for: controlState)
            }
            
            if let backgroundImage = backgroundImages[controlState] {
                setBackgroundImage(backgroundImage, for: controlState)
            }
        }
    }
    
    func setImageAndTextSpace(space: CGFloat) {
        /*
         top : 为正数的时候,是往下偏移,为负数的时候往上偏移;
         left : 为正数的时候往右偏移,为负数的时候往左偏移;
         bottom : 为正数的时候往上偏移,为负数的时候往下偏移;
         right :为正数的时候往左偏移,为负数的时候往右偏移;
         */
        imageEdgeInsets = UIEdgeInsetsMake(0, -space/2, 0, (space/2))
        titleEdgeInsets = UIEdgeInsetsMake(0, space/2, 0, -(space/2))
    }
}
