//
//  Session.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

struct Session {

    // MARK: Properties

    // Session identifier
    let identifier: String
    let expiration: Date
    // MARK: Initializers

    init?(data: [String: AnyObject]) {
        guard let identifier = data[UdacityAPIClient.JSONResponseKeys.SessionID] as? String else {
            return nil
        }
        
        guard let expirationString = data[UdacityAPIClient.JSONResponseKeys.SessionExpiration] as? String,
            let expiration = DateFormatter.APIFormatter.date(from: expirationString) else {
            return nil
        }
        
        self.expiration = expiration
        self.identifier = identifier
    }
}
