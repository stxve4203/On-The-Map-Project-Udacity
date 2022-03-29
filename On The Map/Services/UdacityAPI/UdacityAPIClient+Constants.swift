//
//  UdacityAPIClient+Constants.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation


extension UdacityAPIClient {

    // MARK: Constants

    enum API {
        static let Scheme = "https"
        static let Host = "onthemap-api.udacity.com"
        static let Path = "/v1/"
    }

    enum URLKeys {
        static let UserID = "user_id"
    }
    
    enum Methods {
        static let Session = "session"
        static let User = "users/{\(URLKeys.UserID)}"
    }

    enum JSONResponseKeys {
        static let Account = "account"
        static let AccountKey = "key"
        static let AccountRegistered = "registered"
        static let Session = "session"
        static let SessionID = "id"
        static let SessionExpiration = "expiration"
        static let User = "user"
        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
        static let UserKey = "key"
    }
}
