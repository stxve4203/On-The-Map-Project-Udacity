//
//  User.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

struct User {

// MARK: Properties

let firstName: String
let lastName: String

// The user key.
let userKey: String

// MARK: Initializers

init?(userData: [String: AnyObject]) {
    guard let firstName = userData[UdacityAPIClient.JSONResponseKeys.UserFirstName] as? String,
        let lastName = userData[UdacityAPIClient.JSONResponseKeys.UserLastName] as? String else {
            return nil
    }

    self.lastName = lastName
    self.firstName = firstName

    guard let key = userData[UdacityAPIClient.JSONResponseKeys.UserKey] as? String else {
        return nil
    }

    self.userKey = key
}
}
