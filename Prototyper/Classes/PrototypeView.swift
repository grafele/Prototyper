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
    @IBInspectable open var prototypeAddress: String = "" {
        didSet {
            prototypeURL = URL(string: prototypeAddress)
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
    
    func loadContent() {
        prototypeURL = URL(string: prototypeAddress)

        guard let prototypeURL = prototypeURL else { return }
        
        let request = URLRequest(url: prototypeURL)
        webView.load(request)
    }
    
    fileprivate func createWebView() {
        webView = WKWebView(frame: self.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(webView)
        
        let topConstaint = NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstaint = NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: webView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: webView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstaint, bottomConstaint, leftConstraint, rightConstraint])
    }
}
