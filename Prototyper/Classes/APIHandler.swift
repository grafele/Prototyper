//
//  APIHandler.swift
//  Prototype
//
//  Created by Stefan Kofler on 17.06.15.
//  Copyright (c) 2015 Stephan Rabanser. All rights reserved.
//

import Foundation
import UIKit

let sharedInstance = APIHandler()

private let defaultBoundary = "------VohpleBoundary4QuqLuM1cE5lMwCy"

class APIHandler {
    let session: URLSession
    var appId: String! {
        return Bundle.main.object(forInfoDictionaryKey: "PrototyperAppId") as? String ?? UserDefaults.standard.string(forKey: UserDefaultKeys.AppId)
    }
    var releaseId: String! {
        return Bundle.main.object(forInfoDictionaryKey: "PrototyperReleaseId") as? String ?? UserDefaults.standard.string(forKey: UserDefaultKeys.ReleaseId)
    }
    
    var isLoggedIn: Bool = false
    
    init() {
        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig)
    }
    
    class var sharedAPIHandler: APIHandler {
        return sharedInstance
    }
    
    // MARK: API Methods
    
    func fetchReleaseInformation(success: @escaping (_ appId: String, _ releaseId: String) -> Void, failure: @escaping (_ error : Error?) -> Void) {
        let bundleId = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
        let bundleVersion = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        
        let url = URL(string: API.EndPoints.fetchReleaseInfo(bundleId: bundleId, bundleVersion: bundleVersion), relativeTo: API.BaseURL)!
        
        let request = jsonRequestForHttpMethod(.GET, requestURL: url)
        executeRequest(request as URLRequest) { (data, response, error) in
            guard let data = data else {
                failure(error)
                return
            }
            
            do {
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int]
                if let dict = dict, let appId = dict["app_id"], let releaseId = dict["release_id"] {
                    success("\(appId)", "\(releaseId)")
                } else {
                    failure(error)
                }
            } catch {
                failure(error)
            }
        }
    }
    
    func login(_ email: String, password: String,  success: @escaping (Void) -> Void, failure: @escaping (_ error : Error?) -> Void) {
        let params = postParamsForLogin(email: email, password: password)
        let articlesURL = URL(string: API.EndPoints.Login, relativeTo: API.BaseURL as URL?)
        
        guard let requestURL = articlesURL else {
            failure(NSError.APIURLError())
            return
        }
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            failure(NSError.dataEncodeError())
            return
        }
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: requestURL, bodyData: bodyData)
        executeRequest(request as URLRequest) { (data, response, networkError) in
            let httpURLResponse: HTTPURLResponse! = response as? HTTPURLResponse
            let error = (data == nil || httpURLResponse.statusCode != 200) ? NSError.dataParseError() : networkError
            error != nil ? failure(error) : success()
            self.isLoggedIn = error == nil
        }
    }
    
    func sendGeneralFeedback(description: String, name: String? = nil, success: @escaping (Void) -> Void, failure: @escaping (_ error : Error?) -> Void) {
        guard let appId = appId, let releaseId = releaseId else {
            print("You need to set the app and release id first")
            return
        }
        
        let url = URL(string: API.EndPoints.feedback(appId, releaseId: releaseId, text: description.escapedString, username: name?.escapedString), relativeTo: API.BaseURL)!
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: url)
        executeRequest(request as URLRequest) { (data, response, error) in
            error != nil ? failure(error) : success()
        }
    }
    
    func sendScreenFeedback(screenshot: UIImage, description: String, name: String? = nil, success: @escaping (Void) -> Void, failure: @escaping (_ error : Error?) -> Void) {
        guard let appId = appId, let releaseId = releaseId else {
            print("You need to set the app and release id first")
            failure(nil)
            return
        }

        let contentType = "\(MimeType.Multipart.rawValue); boundary=\(defaultBoundary)"
        let bodyData = bodyDataForImage(screenshot)
        
        let url = URL(string: API.EndPoints.feedback(appId, releaseId: releaseId, text: description.escapedString, username: name?.escapedString), relativeTo: API.BaseURL)!
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: url, bodyData: bodyData, contentType: contentType)
        executeRequest(request as URLRequest) { (data, response, error) in
            error != nil ? failure(error) : success()
        }
    }
    
    func sendShareRequest(for email: String, because explanation: String, name: String? = nil, success: @escaping (Void) -> Void, failure: @escaping (_ error : Error?) -> Void) {
        guard let appId = appId, let releaseId = releaseId else {
            print("You need to set the app and release id first")
            failure(nil)
            return
        }

        let url = URL(string: API.EndPoints.share(appId, releaseId: releaseId, sharedEmail: email.escapedString, explanation: explanation.escapedString, username: name?.escapedString), relativeTo: API.BaseURL)!
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: url)
        executeRequest(request as URLRequest) { (data, response, error) in
            error != nil ? failure(error) : success()
        }
    }
    
    // TODO: Add method to check for new versions

    // MARK: Helper
    
    fileprivate func jsonRequestForHttpMethod(_ method: HTTPMethod, requestURL: URL, bodyData: Data? = nil, contentType: String = MimeType.JSON.rawValue) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: requestURL)
        
        request.httpMethod = method.rawValue
        request.setValue(contentType, forHTTPHeaderField: HTTPHeaderField.ContentType.rawValue)
        request.setValue(MimeType.JSON.rawValue, forHTTPHeaderField: HTTPHeaderField.Accept.rawValue)
        request.httpBody = bodyData
        
        return request
    }
    
    fileprivate func bodyDataForImage(_ image: UIImage, boundary: String = defaultBoundary) -> Data {
        let bodyData = NSMutableData()
        
        let imageData = UIImageJPEGRepresentation(image, 0.4)
        
        bodyData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        bodyData.append("Content-Disposition: form-data; name=\"[feedback]screenshot\"; filename=\"screenshot.jpg\"\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        bodyData.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        bodyData.append(imageData!)
        bodyData.append("\r\n--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        return bodyData as Data
    }
    
    fileprivate func executeRequest(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            OperationQueue.main.addOperation {
                completionHandler(data, response, error)
            }
            return ()
        }) 
        dataTask.resume()
    }
    
    // MARK: Post params
    
    fileprivate func postParamsForLogin(email: String, password: String) -> [String: Any] {
        typealias Session = API.DataTypes.Session
        return [Session.Session: [Session.Email: email, Session.Password: password]]
    }
}
