//
//  Account.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

struct Account {

    // MARK: Properties
    // Is the account registered? True or false
    let registered: Bool
    let userKey: String
   
    
    // MARK: Initializers

    init?(data: [String: AnyObject]) {
        guard let registered = data[UdacityAPIClient.JSONResponseKeys.AccountRegistered] as? Bool else {
            return nil
        }

        guard let key = data[UdacityAPIClient.JSONResponseKeys.AccountKey] as? String else {
            return nil
        }
        
      

        self.registered = registered
        self.userKey = key
    }
}
