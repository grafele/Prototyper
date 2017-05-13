//
//  PrototypeView.swift
//  PrototypeFrameWork
//
//  Created by Stefan Kofler on 26.05.16.
//  Copyright © 2016 Stefan Kofler. All rights reserved.
//

import UIKit
import WebKit

@IBDesignable open class PrototypeView: UIView {
    
    @IBInspectable open var prototypeContainerName: String = "container" {
        didSet {
            prototypeURL = URL(string: PrototypeController.sharedInstance.prototypePathForContainer(prototypeContainerName))
            loadContent()
        }
    }
    
    fileprivate var webView: WKWebView!
    fileprivate var prototypeURL: URL?
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createWebView()
        loadContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createWebView()
        loadContent()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        createWebView()
        loadContent()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        loadContent()
    }
    
    // MARK: Startup
    
    open override func prepareForInterfaceBuilder() {
        guard let image = UIImage(named: "Prototyper", in: Bundle(for: PrototypeView.self), compatibleWith: nil) else {
            return
        }
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        let textLabel = UILabel(frame: CGRect.zero)
        textLabel.text = prototypeContainerName
        textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textLabel)
        
        let imageCenterXConstaint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let imageCenterYConstaint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let labelCenterXConstaint = NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let labelCenterYConstaint = NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.addConstraints([imageCenterXConstaint, imageCenterYConstaint, labelCenterXConstaint, labelCenterYConstaint])
        
        self.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    }
    
    func loadContent() {
        #if !TARGET_INTERFACE_BUILDER
            guard let prototypeURL = prototypeURL else { return }
            
            let request = URLRequest(url: prototypeURL)
            webView.load(request)
        #endif
    }
    
    fileprivate func createWebView() {
        #if !TARGET_INTERFACE_BUILDER
            webView = WKWebView(frame: self.bounds)
            webView.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(webView)
            
            let topConstaint = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            let bottomConstaint = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: webView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            
            self.addConstraints([topConstaint, bottomConstaint, leftConstraint, rightConstraint])
        #endif
    }
}
