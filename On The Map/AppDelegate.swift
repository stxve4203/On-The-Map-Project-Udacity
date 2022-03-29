//
//  AppDelegate.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: Properties

    var window: UIWindow?

    // MARK: App Life Cycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        if let loginController = window?.rootViewController as? LoginViewController {
            loginController.udacityClient = UdacityAPIClient()
        }
        return true
    }
}

extension UIApplication {

    // MARK: Imperatives

    /// Opens the browser using the passed url text as an address or search.
    /// - Parameter addressText: The address or search to be accessed by the browser.
    func openDefaultBrowser(accessingAddress addressText: String) {
        var addressText = addressText

        // If the address text is not a valid address, embed it in a google search.
        let componentsSplitted = addressText.split(separator: ".")
        if componentsSplitted.count == 1 {
            addressText = "https://www.google.com/search?q=\(componentsSplitted.first!)"
        }

        guard var addressURL = URL(string: addressText),
            var components = URLComponents(url: addressURL, resolvingAgainstBaseURL: true) else {
            assertionFailure("Couldn't mount the url.")
            return
        }

        if components.scheme == nil {
            components.scheme = "https"
            addressURL = components.url!
        }

        if UIApplication.shared.canOpenURL(addressURL) {
            UIApplication.shared.open(addressURL, options: [:], completionHandler: nil)
        }
    }
}
