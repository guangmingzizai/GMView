//
//  GMUtils.swift
//  GMView
//
//  Created by wangjianfei on 2018/2/12.
//

import Foundation
import QuartzCore

func zeroIfNaN(value: CGFloat) -> CGFloat {
    return value.isNaN || value.isInfinite ? 0 : value
}

extension CALayer {
    var hasShadow: Bool {
        return CGFloat(shadowOpacity) * (shadowColor?.alpha ?? 0) > 0
    }
}
