//
//  UIFont+App.swift
//  OneOne
//
//  Created by wangjianfei on 2017/12/25.
//  Copyright © 2017年 zheli.tech. All rights reserved.
//

import UIKit

extension UIFont {
    static func pingFangSCRegular(fontSize: Float) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func pingFangSCMedium(fontSize: Float) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func pingFangSCSemibold(fontSize: Float) -> UIFont {
        return UIFont(name: "PingFangSC-Semibold", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func pingFangSCLight(fontSize: Float) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func gothamMedium(fontSize: Float) -> UIFont {
        return UIFont(name: "Gotham-Medium", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func gothamBold(fontSize: Float) -> UIFont {
        return UIFont(name: "Gotham-Bold", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func gothamBook(fontSize: Float) -> UIFont {
        return UIFont(name: "GothamBook", size: CGFloat(fontSize)) ?? UIFont.systemFont(ofSize: CGFloat(fontSize))
    }
    
    static func appleColorEmoji(fontSize: Float) -> UIFont {
        return UIFont(name: "AppleColorEmoji", size: CGFloat(fontSize))!
    }
    
    // MARK: Scalable
    static func pingFangSCRegularScalable(fontSize: Float) -> UIFont {
        return pingFangSCRegular(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func pingFangSCMediumScalable(fontSize: Float) -> UIFont {
        return pingFangSCMedium(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func pingFangSCSemiboldScalable(fontSize: Float) -> UIFont {
        return pingFangSCSemibold(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func pingFangSCLightScalable(fontSize: Float) -> UIFont {
        return pingFangSCLight(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func gothamMediumScalable(fontSize: Float) -> UIFont {
        return gothamMedium(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func gothamBoldScalable(fontSize: Float) -> UIFont {
        return gothamBold(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func gothamBookScalable(fontSize: Float) -> UIFont {
        return gothamBook(fontSize: adaptiveLayoutValue(fontSize))
    }
    
    static func appleColorEmojiScalable(fontSize: Float) -> UIFont {
        return appleColorEmoji(fontSize: adaptiveLayoutValue(fontSize))
    }
}
