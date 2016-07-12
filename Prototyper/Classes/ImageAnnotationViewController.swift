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
    func imageAnnotated(image: UIImage)
}

class ImageAnnotationViewController: UIViewController {
    
    var image: UIImage!
    var delegate: ImageAnnotationViewControllerDelegate?
    
    private var jotViewController: JotViewController!
    
    private var imageView: UIImageView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.backgroundColor = UIColor.whiteColor()
        title = "Annotate image"
        
        addImageView()
        addJotViewController()
        addBarButtonItems()
    }
    
    private func addImageView() {
        guard imageView == nil else { return }
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.blackColor()
        imageView.image = image
        view.addSubview(imageView)
        
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "bottomGuide": bottomLayoutGuide, "imageView": imageView]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-[imageView]-|", options: [], metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-[imageView]-[bottomGuide]", options: [], metrics: nil, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    private func addJotViewController() {
        guard jotViewController == nil else { return }
        
        jotViewController = JotViewController()
        
        addChildViewController(jotViewController)
        view.addSubview(jotViewController.view)
        jotViewController.didMoveToParentViewController(self)
        jotViewController.view.frame = imageView.frame
        
        jotViewController.state = JotViewState.Drawing
        jotViewController.drawingColor = UIColor.cyanColor();
    }
    
    private func addBarButtonItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(saveButtonPressed(_:)))
    }
    
    // MARK: Actions
    
    func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        delegate?.imageAnnotated(jotViewController.drawOnImage(image))
    }    
}
