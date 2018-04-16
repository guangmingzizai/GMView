//
//  CocoaTarget.swift
//  GMView_Example
//
//  Created by wangjianfei on 2018/4/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import Foundation

/// A target that accepts action messages.
internal final class CocoaTarget<Value>: NSObject {
    private let action: (Value) -> ()
    
    internal init(_ action: @escaping (Value) -> ()) {
        self.action = action
    }
    
    @objc
    internal func sendNext(_ receiver: Any?) {
        action(receiver as! Value)
    }
}
