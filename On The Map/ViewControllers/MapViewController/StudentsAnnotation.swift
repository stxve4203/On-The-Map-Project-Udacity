//
//  StudentsAnnotation.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation
import UIKit
import MapKit

class StudentAnnotation: NSObject, MKAnnotation {

    // MARK: Properties

    var studentInformation: StudentInformation
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    // MARK: Initializers

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, studentInformation: StudentInformation) {
        self.coordinate = coordinate
        self.studentInformation = studentInformation

        super.init()

        self.title = title
        self.subtitle = subtitle
    }
}
