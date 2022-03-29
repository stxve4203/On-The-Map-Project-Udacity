//
//  HideKeyboardDelegate.swift
//  OnTheMap
//
//  Created by Stefan Weiss on 28.03.22.
//

import Foundation
import UIKit

class HideKeyboardDelegate: NSObject, UITextFieldDelegate {
    var activeTextField: UITextField? = nil
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide the keyboard when user press enter
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
}
