//
//  UIWindow+Snaphot.swift
//  FavStations
//
//  Created by Stefan Kofler on 26.05.15.
//  Copyright (c) 2015 grafcoding. All rights reserved.
//

import UIKit

extension UIWindow {
    func snaphot() -> UIImage {
        let newWidth = self.bounds.size.width - 66
        let newHeight = newWidth/self.bounds.size.width * self.bounds.size.height
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, UIScreen.main.scale);
        
        self.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newWidth, height: newHeight)), afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!;
    }
}
