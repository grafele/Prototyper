//
//  NSError+DataManager.swift
//  TUMBlog
//
//  Created by Thomas Günzel on 17/03/16.
//  Copyright © 2016 Technische Universität München. All rights reserved.
//

import Foundation

extension NSError {
	static func APIURLError() -> NSError {
		return NSError(domain: "de.tum.in.www1.Prototype", code: 1010, userInfo: nil)
	}
	
	static func dataParseError() -> NSError {
		return NSError(domain: "de.tum.in.www1.Prototype", code: 1011, userInfo: nil)
	}
	
	static func dataEncodeError() -> NSError {
		return NSError(domain: "de.tum.in.www1.Prototype", code: 1012, userInfo: nil)
	}
}
