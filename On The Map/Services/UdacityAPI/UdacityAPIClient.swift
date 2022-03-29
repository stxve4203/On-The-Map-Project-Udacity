//
//  UdacityAPIClient.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

final class UdacityAPIClient: APIClient, UdacityAPIClientProtocol {
    
    // MARK: Parameters
    
    
    private(set) var userSession: Session?
    private(set) var userAccount: Account?
    private(set) var user: User?
    
    
    private lazy var baseURL: URL = {
        guard let url = mountBaseURL(usingScheme: API.Scheme, host: API.Host, andPath: API.Path) else {
            assertionFailure("Couldn't mount the base url.")
            return URL(string: "")!
        }
        
        return url
    }()
    
    // MARK: Initializers
    
    override init() {
        super.init()
        
        preHandleData = { $0.subdata(in: 5..<$0.count) }
    }
    
    // MARK: Imperatives
    
    func logIn(
        withUsername username: String,
        password: String,
        andCompletionHandler handler: @escaping (Account?, Session?, APIClient.RequestError?) -> Void
    ) {
        let bodyText = """
        {
            "udacity": {
                "username": "\(username)",
                "password": "\(password)"
            }
        }
"""
        guard let body = bodyText.data(using: .utf8) else {
            assertionFailure("Couldn't get the data out of the body text.")
            handler(nil, nil, APIClient.RequestError.malformedJsonBody)
            return
        }
        
        _ = getConfiguredTaskForPOST(
            withAbsolutePath: baseURL.appendingPathComponent(Methods.Session).absoluteString,
            parameters: [:],
            jsonBody: body
        ) { json, error in
            guard error == nil else {
                handler(nil, nil, error)
                return
            }
            
            let json = json!
            
            guard let accountData = json[JSONResponseKeys.Account] as? [String: AnyObject],
                  let account = Account(data: accountData) else {
                handler(nil, nil, RequestError.malformedJson)
                return
            }
            
            guard let sessionData = json[JSONResponseKeys.Session] as? [String: AnyObject],
                  let session = Session(data: sessionData) else {
                handler(nil, nil, RequestError.malformedJson)
                return
            }
            
            self.userAccount = account
            self.userSession = session
            handler(account, session, nil)
        }
    }
    
    func logOut(withCompletionHandler handler: @escaping (Bool, APIClient.RequestError?) -> Void) {
        _ = getConfiguredTaskForDELETE(
            withAbsolutePath: baseURL.appendingPathComponent(Methods.Session).absoluteString,
            parameters: [:]
        ) { json, error in
            guard error == nil else {
                handler(false, error)
                return
            }
            
            self.user = nil
            self.userSession = nil
            self.userAccount = nil
            handler(true, nil)
        }
    }
    
    func getUserInfo(
        usingUserIdentifier userID: String,
        andCompletionHandler handler: @escaping (User?, APIClient.RequestError?) -> Void
    ) {
        let url = baseURL.appendingPathComponent(Methods.User.byReplacingKey(URLKeys.UserID, withValue: userID))
        _ = getConfiguredTaskForGET(withAbsolutePath: url.absoluteString, parameters: [:]) { json, error in
            guard error == nil else {
                handler(nil, error!)
                return
            }
            
            guard let user = User(userData: json!) else {
                handler(nil, RequestError.malformedJson)
                return
            }
            
            self.user = user
            handler(user, nil)
        }
    }
}
