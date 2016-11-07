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
    fileprivate var colorButtons: [UIButton]!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.backgroundColor = UIColor.white
        title = "Annotate image"
        
        addImageView()
        addJotViewController()
        addColorPicker()
        addBarButtonItems()
    }
    
    fileprivate func addImageView() {
        guard imageView == nil else { return }
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.white
        imageView.contentMode = .topLeft
        imageView.image = image
        view.addSubview(imageView)
        
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "bottomGuide": bottomLayoutGuide, "imageView": imageView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-33-[imageView]-33-|", options: [], metrics: nil, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-[imageView]-45-[bottomGuide]", options: [], metrics: nil, views: views)
        
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
    
    fileprivate func addColorPicker() {
        let colorPickerView = UIView() // full width, height: 60px
        colorPickerView.backgroundColor = UIColor.white
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorPickerView)
        
        let metrics = ["topSpacing": 8, "height": 45]
        let views: [String: AnyObject] = ["bottomGuide": bottomLayoutGuide, "colorPickerView": colorPickerView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[colorPickerView]-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[colorPickerView(height)]-|", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        
        // color: red, yellow, blue, green, white, black
        
        let buttonSize: CGFloat = 35.0
        
        let redColorButton = UIButton()
        redColorButton.backgroundColor = UIColor.red
        prepareColorButton(redColorButton, buttonSize: buttonSize)
        colorPickerView.addSubview(redColorButton)
        
        let spaceView1 = createSpaceView(in: colorPickerView)
        
        let yellowColorButton = UIButton()
        yellowColorButton.backgroundColor = UIColor.yellow
        prepareColorButton(yellowColorButton, buttonSize: buttonSize)
        colorPickerView.addSubview(yellowColorButton)

        let spaceView2 = createSpaceView(in: colorPickerView)

        let cyanColorButton = UIButton()
        cyanColorButton.backgroundColor = UIColor.cyan
        prepareColorButton(cyanColorButton, buttonSize: buttonSize, selected: true)
        colorPickerView.addSubview(cyanColorButton)

        let spaceView3 = createSpaceView(in: colorPickerView)

        let greenColorButton = UIButton()
        greenColorButton.backgroundColor = UIColor.green
        prepareColorButton(greenColorButton, buttonSize: buttonSize)
        colorPickerView.addSubview(greenColorButton)

        let spaceView4 = createSpaceView(in: colorPickerView)

        let whiteColorButton = UIButton()
        whiteColorButton.backgroundColor = UIColor.white
        prepareColorButton(whiteColorButton, buttonSize: buttonSize)
        colorPickerView.addSubview(whiteColorButton)

        let spaceView5 = createSpaceView(in: colorPickerView)

        let blackColorButton = UIButton()
        blackColorButton.backgroundColor = UIColor.black
        prepareColorButton(blackColorButton, buttonSize: buttonSize)
        colorPickerView.addSubview(blackColorButton)
        
        let buttonMetrics = ["sideSpacing": 8, "size": buttonSize]
        let buttonViews: [String: AnyObject] = ["redColorButton": redColorButton, "yellowColorButton": yellowColorButton, "cyanColorButton": cyanColorButton, "greenColorButton": greenColorButton, "whiteColorButton": whiteColorButton, "blackColorButton": blackColorButton, "spaceView1": spaceView1, "spaceView2": spaceView2, "spaceView3": spaceView3, "spaceView4": spaceView4, "spaceView5": spaceView5]
        
        let horizontalButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-sideSpacing-[redColorButton(size)]-[spaceView1]-[yellowColorButton(size)]-[spaceView2(==spaceView1)]-[cyanColorButton(size)]-[spaceView3(==spaceView1)]-[greenColorButton(size)]-[spaceView4(==spaceView1)]-[whiteColorButton(size)]-[spaceView5(==spaceView1)]-[blackColorButton(size)]-sideSpacing-|", options: [], metrics: buttonMetrics, views: buttonViews)
        
        let heightConstraint1 = NSLayoutConstraint(item: redColorButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonSize)
        let heightConstraint2 = NSLayoutConstraint(item: yellowColorButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonSize)
        let heightConstraint3 = NSLayoutConstraint(item: cyanColorButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonSize)
        let heightConstraint4 = NSLayoutConstraint(item: greenColorButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonSize)
        let heightConstraint5 = NSLayoutConstraint(item: whiteColorButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonSize)
        let heightConstraint6 = NSLayoutConstraint(item: blackColorButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonSize)
        
        let centerConstraint1 = NSLayoutConstraint(item: redColorButton, attribute: .centerY, relatedBy: .equal, toItem: colorPickerView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerConstraint2 = NSLayoutConstraint(item: yellowColorButton, attribute: .centerY, relatedBy: .equal, toItem: colorPickerView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerConstraint3 = NSLayoutConstraint(item: cyanColorButton, attribute: .centerY, relatedBy: .equal, toItem: colorPickerView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerConstraint4 = NSLayoutConstraint(item: greenColorButton, attribute: .centerY, relatedBy: .equal, toItem: colorPickerView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerConstraint5 = NSLayoutConstraint(item: whiteColorButton, attribute: .centerY, relatedBy: .equal, toItem: colorPickerView, attribute: .centerY, multiplier: 1, constant: 0)
        let centerConstraint6 = NSLayoutConstraint(item: blackColorButton, attribute: .centerY, relatedBy: .equal, toItem: colorPickerView, attribute: .centerY, multiplier: 1, constant: 0)
        
        colorPickerView.addConstraints(horizontalButtonConstraints)
        colorPickerView.addConstraints([heightConstraint1, heightConstraint2, heightConstraint3, heightConstraint4, heightConstraint5, heightConstraint6])
        colorPickerView.addConstraints([centerConstraint1, centerConstraint2, centerConstraint3, centerConstraint4, centerConstraint5, centerConstraint6])
        
        colorButtons = [redColorButton, yellowColorButton, cyanColorButton, greenColorButton, whiteColorButton, blackColorButton]
    }
    
    private func prepareColorButton(_ button: UIButton, buttonSize: CGFloat, selected: Bool = false) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = buttonSize/2.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.alpha = selected ? 1.0 : 0.4
        button.addTarget(self, action: #selector(colorButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func createSpaceView(in superview: UIView) -> UIView {
        let spaceView = UIView()
        spaceView.translatesAutoresizingMaskIntoConstraints = false
        spaceView.isHidden = true
        superview.addSubview(spaceView)
        return spaceView
    }
    
    // MARK: Actions
    
    func cancelButtonPressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func saveButtonPressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        delegate?.imageAnnotated(jotViewController.draw(on: image))
    }
    
    func colorButtonPressed(_ colorButton: UIButton) {
        for button in colorButtons {
            button.alpha = 0.4
        }

        colorButton.alpha = 1.0
        jotViewController.drawingColor = colorButton.backgroundColor
    }
}
