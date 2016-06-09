//
//  PrototypeViewController.swift
//  PrototypeFrameWork
//
//  Created by Stefan Kofler on 28.05.16.
//  Copyright © 2016 Stefan Kofler. All rights reserved.
//

import UIKit

public class PrototypeViewController: UIViewController {
    
    public var prototypeAddress: String = "" {
        didSet {
            guard prototypeView != nil else { return }
            prototypeView.prototypeAddress = prototypeAddress
            prototypeView.loadContent()
        }
    }
    
    private var prototypeView: PrototypeView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        createPrototypeView()
        prototypeView.prototypeAddress = prototypeAddress
        prototypeView.loadContent()
    }
    
    private func createPrototypeView() {
        prototypeView = PrototypeView(frame: self.view.bounds)
        prototypeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(prototypeView)
        
        let topConstaint = NSLayoutConstraint(item: prototypeView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstaint = NSLayoutConstraint(item: prototypeView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: prototypeView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: prototypeView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0)
        
        self.view.addConstraints([topConstaint, bottomConstaint, leftConstraint, rightConstraint])
    }
}