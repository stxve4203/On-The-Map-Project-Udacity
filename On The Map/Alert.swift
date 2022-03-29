//
//  Alert.swift
//  On the Map
//
//  Created by Stefan Weiss on 07.03.22.
//

import UIKit

struct Alert {
    
    //  MARK: - Alert Views
    
    //  basic alert with single "OK" dismiss action
    private static func showBasicAlert(on vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    //  MARK: - Alert Types
    
    //  failed network connection
    static func showNetworkError(on vc: UIViewController) {
        showBasicAlert(on: vc, title: "Network Error", message: "Unable to connect to the interwebz.")
    }
    
    //  incorrect login credentials (email and password)
    static func showInvalidLogin(on vc: UIViewController) {
        showBasicAlert(on: vc, title: "Log In Failed", message: "Please enter a valid email and password to continue.")
    }
    
    //  invalid url
    static func showInvalidURL(on vc: UIViewController) {
        showBasicAlert(on: vc, title: "Invalid Link", message: "Cannot open URL.")
    }
    
    //  empty "link" text field
    static func showMissingURL(on vc: UIViewController) {
        showBasicAlert(on: vc, title: "Link Field Empty", message: "Please provide a valid URL in the \"Link\" text field.")
    }
    
    //  failed to forward location geocode
    static func showLocationNotFound(on vc: UIViewController, message: Error) {
        showBasicAlert(on: vc, title: "Location Not Found", message: message.localizedDescription)
    }
    
    // failed getting user details
    static func showFailedToGetUserInfo(on vc: UIViewController) {
        showBasicAlert(on: vc, title: "Getting user information failed", message: "Please try again later.")
    }
    
    //  failed to post geocode map/pin data to server
    static func showFailedToPost(on vc: UIViewController) {
        showBasicAlert(on: vc, title: "Add Location Failed", message: "Please try again later.")
    }
    
}
