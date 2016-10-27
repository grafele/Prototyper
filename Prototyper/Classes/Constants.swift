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
    static let BaseURL = URL(string: "https://prototyper-bruegge.in.tum.de/")
    
    struct EndPoints {
        static let Login = "login"
        static func fetchReleaseInfo(bundleId: String, bundleVersion: String) -> String {
            return "apps/find_release?bundle_id=\(bundleId)&bundle_version=\(bundleVersion)"
        }

        static func feedback(_ appId: String, releaseId: String, title: String, text: String) -> String {
            return "apps/\(appId)/releases/\(releaseId)/feedbacks?feedback[title]=\(title)&feedback[text]=\(text)"
        }
        static func share(_ appId: String, releaseId: String, sharedEmail: String, explanation: String) -> String {
            return "apps/\(appId)/releases/\(releaseId)/share_app?share_email=\(sharedEmail)&explanation=\(explanation)"
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

struct Texts {
    struct FeedbackActionSheet {
        static let Title: String? = nil
        static let Text: String? = nil
        static let WriteFeedback = "Give feedback"
        static let ShareApp = "Share app"
        static let HideFeedbackBubble = "Remove feedback icon"
        static let Cancel = "Cancel"
    }
    
    struct LoginAlertSheet {
        static let Title = "Do you want to log in?"
        static let Yes = "Yes"
        static let No = "No"
    }
    
    struct FeedbackHideAlertSheet {
        static let Title = "You can still give feedback by using a long press to show the feedback dialog."
        static let OK = "OK"
    }
}

struct UserDefaultKeys {
    static let AppId = "AppId"
    static let ReleaseId = "ReleaseId"
}
