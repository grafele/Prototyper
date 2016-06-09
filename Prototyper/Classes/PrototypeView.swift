//
//  PrototypeView.swift
//  PrototypeFrameWork
//
//  Created by Stefan Kofler on 26.05.16.
//  Copyright © 2016 Stefan Kofler. All rights reserved.
//

import UIKit
import WebKit

@IBDesignable public class PrototypeView: UIView {
    @IBInspectable public var prototypeAddress: String = "" {
        didSet {
            prototypeURL = NSURL(string: prototypeAddress)
            loadContent()
        }
    }

    private var webView: WKWebView!
    private var prototypeURL: NSURL?
    
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
        super.init(frame: CGRectZero)
        createWebView()
        loadContent()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        loadContent()
    }
    
    // MARK: Startup
    
    func loadContent() {
        prototypeURL = NSURL(string: prototypeAddress)

        guard let prototypeURL = prototypeURL else {
            print("Prototype URL is not valid")
            return
        }
        
        let request = NSURLRequest(URL: prototypeURL)
        webView.loadRequest(request)
    }
    
    private func createWebView() {
        webView = WKWebView(frame: self.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(webView)
        
        let topConstaint = NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstaint = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstaint, bottomConstaint, leftConstraint, rightConstraint])
    }
}