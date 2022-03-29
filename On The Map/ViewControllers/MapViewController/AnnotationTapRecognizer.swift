//
//  AnnotationTapRecognizer.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation
import UIKit

class AnnotationLinkTapRecognizer: UITapGestureRecognizer {

    // MARK: Properties
    var link: String

    // MARK: Initializers

    init(target: Any?, action: Selector?, link: String) {
        self.link = link

        super.init(target: target, action: action)
    }

}
