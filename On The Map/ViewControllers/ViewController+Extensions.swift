//
//  ViewController+Extensions.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func openLink(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
