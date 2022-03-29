//
//  StudentInformation.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

struct StudentInformation: Hashable {

    // MARK: Properties
    let lastName: String
    let firstName: String
    let latitude: Double
    let longitude: Double
    let mapTextReference: String
    let mediaUrl: URL
    let userKey: String
    var objectID: String?
    var updatedAt: Date?

    // MARK: Initializers

    init(firstName: String,
         lastName: String,
         latitude: Double,
         longitude: Double,
         mapTextReference: String,
         mediaUrl: URL,
         userKey: String
        ) {
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapTextReference = mapTextReference
        self.mediaUrl = mediaUrl
        self.userKey = userKey
    }

    init?(informationData: [String: AnyObject]) {
        guard let lastName = informationData[ParseAPIClient.JSONResponseKeys.LastName] as? String else {
            return nil
        }
        
        guard let firstName = informationData[ParseAPIClient.JSONResponseKeys.FirstName] as? String else {
            return nil
        }

        guard let latitude = informationData[ParseAPIClient.JSONResponseKeys.Latitude] as? Double else {
            return nil
        }

        guard let longitude = informationData[ParseAPIClient.JSONResponseKeys.Longitude] as? Double else {
            return nil
        }

        guard let mapTextReference = informationData[ParseAPIClient.JSONResponseKeys.MapTextReference] as? String  else {
            return nil
        }

        guard let mediaUrlText = informationData[ParseAPIClient.JSONResponseKeys.MediaUrl] as? String,
            let mediaUrl = URL(string: mediaUrlText) else {
            return nil
        }

        guard let userKey = informationData[ParseAPIClient.JSONResponseKeys.InformationKey] as? String else {
            return nil
        }

        guard let objectID = informationData[ParseAPIClient.JSONResponseKeys.ObjectID] as? String else {
            return nil
        }

        guard let updatedAtText = informationData[ParseAPIClient.JSONResponseKeys.UpdatedAt] as? String,
            let updatedAt = DateFormatter.APIFormatter.date(from: updatedAtText) else {
                return nil
        }
        
        self.lastName = lastName
        self.firstName = firstName
        self.latitude = latitude
        self.longitude = longitude
        self.mapTextReference = mapTextReference
        self.mediaUrl = mediaUrl
        self.userKey = userKey
        self.objectID = objectID
        self.updatedAt = updatedAt
    }
}
