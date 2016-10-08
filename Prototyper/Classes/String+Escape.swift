//
//  String+Escape.swift
//  Pods
//
//  Created by Stefan Kofler on 21.07.16.
//
//

import Foundation

extension String {
    var escapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}
