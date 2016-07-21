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
    let session: NSURLSession
    var appId: String!
    var releaseId: String!
    
    init() {
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: sessionConfig)
    }
    
    class var sharedAPIHandler: APIHandler {
        return sharedInstance
    }
    
    // MARK: API Methods
    
    func login(email: String, password: String,  success: (Void) -> Void, failure: (error : NSError!) -> Void) {
        let params = postParamsForLogin(email: email, password: password)
        let articlesURL = NSURL(string: API.EndPoints.Login, relativeToURL: API.BaseURL)
        
        guard let requestURL = articlesURL else {
            failure(error: NSError.APIURLError())
            return
        }
        
        guard let bodyData = try? NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted) else {
            failure(error: NSError.dataEncodeError())
            return
        }
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: requestURL, bodyData: bodyData)
        executeRequest(request) { (data, response, networkError) in
            let error = data == nil ? NSError.dataParseError() : networkError
            error != nil ? failure(error: error) : success()
        }
    }
    
    func sendGeneralFeedback(title: String, description: String, success: (Void) -> Void, failure: (error : NSError!) -> Void) {
        guard let appId = appId, releaseId = releaseId else {
            print("You need to set the app and release id first")
            return
        }
        
        let url = NSURL(string: API.EndPoints.feedback(appId, releaseId: releaseId, title: title.escapedString, text: description.escapedString), relativeToURL: API.BaseURL)!
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: url)
        executeRequest(request) { (data, response, error) in
            error != nil ? failure(error: error) : success()
        }
    }
    
    func sendScreenFeedback(title: String, screenshot: UIImage, description: String, success: (Void) -> Void, failure: (error : NSError!) -> Void) {
        guard let appId = appId, releaseId = releaseId else {
            print("You need to set the app and release id first")
            return
        }

        let contentType = "\(MimeType.Multipart.rawValue); boundary=\(defaultBoundary)"
        let bodyData = bodyDataForImage(screenshot)
        
        let url = NSURL(string: "apps/\(appId)/releases/\(releaseId)/feedbacks?feedback[title]=\(title.escapedString)&feedback[text]=\(description.escapedString)", relativeToURL: API.BaseURL)!
        
        let request = jsonRequestForHttpMethod(.POST, requestURL: url, bodyData: bodyData, contentType: contentType)
        executeRequest(request) { (data, response, error) in
            error != nil ? failure(error: error) : success()
        }
    }
    
    // TODO: Add method to check for new versions

    // MARK: Helper
    
    private func jsonRequestForHttpMethod(method: HTTPMethod, requestURL: NSURL, bodyData: NSData? = nil, contentType: String = MimeType.JSON.rawValue) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: requestURL)
        
        request.HTTPMethod = method.rawValue
        request.setValue(contentType, forHTTPHeaderField: HTTPHeaderField.ContentType.rawValue)
        request.setValue(MimeType.JSON.rawValue, forHTTPHeaderField: HTTPHeaderField.Accept.rawValue)
        request.HTTPBody = bodyData
        
        return request
    }
    
    private func bodyDataForImage(image: UIImage, boundary: String = defaultBoundary) -> NSData {
        let bodyData = NSMutableData()
        
        let imageData = UIImagePNGRepresentation(image)
        
        bodyData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        bodyData.appendData("Content-Disposition: form-data; name=\"[feedback]screenshot\"; filename=\"screenshot.png\"\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        bodyData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        bodyData.appendData(imageData!)
        bodyData.appendData("\r\n--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        
        return bodyData
    }
    
    private func executeRequest(request: NSURLRequest, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completionHandler(data, response, error)
            }
        }
        dataTask.resume()
    }
    
    // MARK: Post params
    
    private func postParamsForLogin(email email: String, password: String) -> [String: AnyObject] {
        typealias Session = API.DataTypes.Session
        return [Session.Session: [Session.Email: email, Session.Password: password]]
    }
}