//
//  Constants.swift
//  Pods
//
//  Created by Stefan Kofler on 21.07.16.
//
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum MimeType: String {
    case JSON = "application/json"
    case Multipart = "multipart/form-data"
}

enum HTTPHeaderField: String {
    case ContentType = "Content-Type"
    case Accept = "Accept"
}

struct API {
    static let BaseURL = NSURL(string: "https://prototyper-bruegge.in.tum.de/")
    
    struct EndPoints {
        static let Login = "login"
        static func feedback(appId: String, releaseId: String, title: String, text: String) -> String {
            return "apps/\(appId)/releases/\(releaseId)/feedbacks?feedback[title]=\(title)&feedback[text]=\(text)"
        }
    }
    
    struct DataTypes {
        struct Session {
            static let Session = "session"
            static let Email = "email"
            static let Password = "password"
        }
    }
}