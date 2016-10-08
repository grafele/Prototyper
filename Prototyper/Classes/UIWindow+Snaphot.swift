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
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale);
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!;
    }
}
