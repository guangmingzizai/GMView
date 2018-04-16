//
//  GMLightBox.swift
//  GMView
//
//  Created by wangjianfei on 2018/4/14.
//

import UIKit

public enum BackgroundBlur {
    case none
    case light
    case xlight
    case dark
}

public struct LightBoxParams {
    var backgroundBlur: BackgroundBlur
    var backgroundColor: UIColor?
    var shouldDismissOnBackgroundTouch: Bool = true
    var fullscreen: Bool = true
    
    public init(backgroundBlur: BackgroundBlur, shouldDismissOnBackgroundTouch: Bool = true, fullscreen: Bool = true, backgroundColor: UIColor? = nil) {
        self.backgroundBlur = backgroundBlur
        self.backgroundColor = backgroundColor
        self.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch
        self.fullscreen = fullscreen
    }
}

public class LightBoxView: UIView {
    
    var params: LightBoxParams
    private var visualEffectView: UIVisualEffectView?
    private var overlayColorView: UIView?
    private var contentView: UIView
    
    public init(frame: CGRect, contentView: UIView, params: LightBoxParams) {
        self.params = params
        self.contentView = contentView
        super.init(frame: frame)
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if params.backgroundBlur != .none {
            let visualEffectView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            visualEffectView.isUserInteractionEnabled = false
            addSubview(visualEffectView)
            
            self.visualEffectView = visualEffectView
        }
        
        if let backgroundColor = params.backgroundColor {
            let overlayColorView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
            overlayColorView.backgroundColor = backgroundColor
            overlayColorView.alpha = 0
            overlayColorView.isUserInteractionEnabled = false
            addSubview(overlayColorView)
            
            self.overlayColorView = overlayColorView
        }
        
        if params.fullscreen {
            contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            contentView.frame = CGRect(x: (frame.size.width - contentView.frame.size.width) * 0.5, y: (frame.size.height - contentView.frame.size.height) * 0.5, width: contentView.frame.size.width, height: contentView.frame.size.height)
            contentView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        }
        addSubview(contentView)
        
        if params.shouldDismissOnBackgroundTouch {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            addGestureRecognizer(tapRecognizer)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func blurEfectForCurrentStyle() -> UIBlurEffect? {
        let backgroundBlur = params.backgroundBlur
        guard backgroundBlur != .none else {
            return nil
        }
        
        var blurEffectStyle: UIBlurEffectStyle = .dark
        switch backgroundBlur {
        case .light:
            blurEffectStyle = .light
        case .xlight:
            blurEffectStyle = .extraLight
        default:
            blurEffectStyle = .dark
        }
        return UIBlurEffect(style: blurEffectStyle)
    }
    
    public func show(animated: Bool = true) {
        if visualEffectView != nil || overlayColorView != nil {
            let animations = { [unowned self] in
                if let visualEffectView = self.visualEffectView {
                    visualEffectView.effect = self.blurEfectForCurrentStyle()
                }
                if let overlayColorView = self.overlayColorView {
                    overlayColorView.alpha = 1
                }
            }
            if animated {
                UIView.animate(withDuration: 0.3, animations: animations)
            } else {
                animations()
            }
        }
        
        if animated {
            contentView.transform = CGAffineTransform(translationX: 0, y: 100)
            contentView.alpha = 0
            
            UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.65, initialSpringVelocity: 0, options: .curveEaseOut, animations: { [unowned self] in
                self.contentView.transform = .identity
                self.contentView.alpha = 1
            }, completion: nil)
        }
    }
    
    public func dismiss(animated: Bool = true) {
        if animated {
            let hasOverlayViews = (visualEffectView != nil || overlayColorView != nil)
            
            UIView.animate(withDuration: 0.2, animations: { [unowned self] in
                self.contentView.transform = CGAffineTransform(translationX: 0, y: 80)
                self.contentView.alpha = 0
            }) { [unowned self] (_) in
                if !hasOverlayViews {
                    self.removeFromSuperview()
                }
            }
            
            if hasOverlayViews {
                UIView.animate(withDuration: 0.25, delay: 0.15, options: .curveEaseOut, animations: { [unowned self] in
                    if let visualEffectView = self.visualEffectView {
                        visualEffectView.effect = nil
                    }
                    if let overlayColorView = self.overlayColorView {
                        overlayColorView.alpha = 0
                    }
                }) { [unowned self] (_) in
                    self.removeFromSuperview()
                }
            }
        } else {
            removeFromSuperview()
        }
    }
    
    @objc func dismiss() {
        dismiss(animated: true)
    }
    
}

public class LightBox {
    private static func getWindow() -> UIWindow {
        let app = UIApplication.shared
        let window = app.keyWindow ?? app.windows[0]
        return window
    }
    
    @discardableResult
    public static func show(contentView: UIView, params: LightBoxParams, animated: Bool = true) -> LightBoxView {
        let window = getWindow()
        let lightBox = LightBoxView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), contentView: contentView, params: params)
        window.addSubview(lightBox)
        lightBox.show(animated: true)
        
        return lightBox
    }
}
