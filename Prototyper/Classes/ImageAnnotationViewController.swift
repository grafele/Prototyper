//
//  ImageAnnotationViewController.swift
//  Prototype
//
//  Created by Stefan Kofler on 13.04.16.
//  Copyright © 2016 Stephan Rabanser. All rights reserved.
//

import UIKit
import jot

protocol ImageAnnotationViewControllerDelegate {
    func imageAnnotated(_ image: UIImage)
}

class ImageAnnotationViewController: UIViewController {
    
    var image: UIImage!
    var delegate: ImageAnnotationViewControllerDelegate?
    
    fileprivate var jotViewController: JotViewController!
    
    fileprivate var imageView: UIImageView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.backgroundColor = UIColor.white
        title = "Annotate image"
        
        addImageView()
        addJotViewController()
        addBarButtonItems()
    }
    
    fileprivate func addImageView() {
        guard imageView == nil else { return }
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.black
        imageView.image = image
        view.addSubview(imageView)
        
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "bottomGuide": bottomLayoutGuide, "imageView": imageView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[imageView]-|", options: [], metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-[imageView]-[bottomGuide]", options: [], metrics: nil, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    fileprivate func addJotViewController() {
        guard jotViewController == nil else { return }
        
        jotViewController = JotViewController()
        jotViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(jotViewController)
        view.addSubview(jotViewController.view)
        jotViewController.didMove(toParentViewController: self)
        
        jotViewController.state = JotViewState.drawing
        jotViewController.drawingColor = UIColor.cyan
        
        let leftConstraint = NSLayoutConstraint(item: jotViewController.view, attribute: .left, relatedBy: .equal, toItem: imageView, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: jotViewController.view, attribute: .right, relatedBy: .equal, toItem: imageView, attribute: .right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: jotViewController.view, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: jotViewController.view, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }
    
    fileprivate func addBarButtonItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed(_:)))
    }
    
    // MARK: Actions
    
    func cancelButtonPressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func saveButtonPressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        delegate?.imageAnnotated(jotViewController.draw(on: image))
    }    
}
