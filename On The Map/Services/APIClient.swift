//
//  APIClient.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation
import UIKit

class APIClient {
    
    // MARK: Types
    
    typealias DeserializedJson = [String: AnyObject]
    
    typealias RequestConfigurer = (URLRequest) -> URLRequest
    
    enum RequestError: Error {
        case connection
        case response(statusCode: Int?)
        case lackingData
        case malformedJson
        case malformedJsonBody
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: Properties
    let session = URLSession.shared
    var preHandleData: ((Data) -> Data)?
    var requiredAPIHeaders: [String: String]?
    
    // MARK: Imperatives
    
    func getConfiguredTaskForGET(
        withAbsolutePath path: String,
        parameters: [String: String],
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
    ) -> URLSessionDataTask? {
        
        return getConfiguredDataTask(
            forHTTPMethod: .get,
            path: path,
            parameters: parameters,
            jsonBody: nil,
            withCompletionHandler: handler
        )
    }
    
    func getConfiguredTaskForPOST(
        withAbsolutePath path: String,
        parameters: [String: String],
        jsonBody: Data,
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
    ) -> URLSessionDataTask? {
        
        return getConfiguredDataTask(
            forHTTPMethod: .post,
            path: path,
            parameters: parameters,
            jsonBody: jsonBody,
            withCompletionHandler: handler
        )
    }
    
    func getConfiguredTaskForPUT(
        withAbsolutePath path: String,
        parameters: [String: String],
        jsonBody: Data,
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
    ) -> URLSessionDataTask? {
        
        return getConfiguredDataTask(
            forHTTPMethod: .put,
            path: path,
            parameters: parameters,
            jsonBody: jsonBody,
            withCompletionHandler: handler
        )
    }
    
    func getConfiguredTaskForDELETE(
        withAbsolutePath path: String,
        parameters: [String: String],
        andCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void
    ) -> URLSessionDataTask? {
        
        return getConfiguredDataTask(
            forHTTPMethod: .delete,
            path: path,
            parameters: parameters,
            jsonBody: nil,
            withCompletionHandler: handler,
            andUsingRequestConfigurer: { urlRequest in
                var urlRequest = urlRequest
                
                // Add the cached token as a header to delete the session.
                if let xsrfCookie = HTTPCookieStorage.shared.cookies?.filter({ $0.name == "XSRF-TOKEN" }).first {
                    urlRequest.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
                }
                
                return urlRequest
            }
        )
    }
    
    private func getConfiguredDataTask(
        forHTTPMethod method: HTTPMethod,
        path: String,
        parameters: [String: String],
        jsonBody: Data?,
        withCompletionHandler handler: @escaping (DeserializedJson?, RequestError?) -> Void,
        andUsingRequestConfigurer requestConfigurer: RequestConfigurer? = nil
    ) -> URLSessionDataTask? {
        
        guard let url = getURL(fromPath: path, andParameters: parameters) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = requiredAPIHeaders {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let requestConfigurer = requestConfigurer {
            request = requestConfigurer(request)
        }
        
        switch method {
        case .post, .put:
            if let jsonBody = jsonBody {
                request.httpBody = jsonBody
            }
        default:
            break
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            let error = self.checkForErrors(inData: data, response: response, andError: error)
            guard error == nil else {
                handler(nil, error)
                return
            }
            
            // Pre-handle the data, if necessary.
            let data = self.preHandleData?(data!) ?? data!
            
            guard let json = self.deserializeJson(from: data) else {
                handler(nil, RequestError.malformedJson)
                return
            }
            
            handler(json, nil)
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        task.resume()
        
        return task
    }
    
    
    private func getURL(fromPath path: String, andParameters parameters: [String: String]) -> URL? {
        guard let url = URL(string: path) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            assertionFailure("The passed url isn't a valid one, fix it.")
            return nil
        }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        return components.url
    }
    
    private func checkForErrors(inData data: Data?, response: URLResponse?, andError error: Error?) -> RequestError? {
        guard error == nil else {
            return RequestError.connection
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            var status: Int?
            
            if let httpResponse = response as? HTTPURLResponse {
                status = httpResponse.statusCode
            }
            
            return RequestError.response(statusCode: status)
        }
        
        guard data != nil else {
            return RequestError.lackingData
        }
        
        return nil
    }
    
    
    private func deserializeJson(from data: Data) -> DeserializedJson? {
        var json: DeserializedJson!
        do {
            json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? DeserializedJson
        } catch {
            return nil
        }
        
        return json
    }
    
    
    func mountBaseURL(usingScheme scheme: String, host: String, andPath path: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        return components.url
    }
}

extension String {

    func byReplacingKey(_ key: String, withValue value: String) -> String {
        return replacingOccurrences(of: "{\(key)}", with: value)
    }
}

extension DateFormatter {
    static let APIFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }()
}
