//
//  ParseAPIClientProtocol.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

protocol ParseAPIClientProtocol {

    // MARK: Properties

    var studentLocations: [StudentInformation] { get set }

    // MARK: Methods

    // - Returns: The fetched locations.
    func fetchStudentLocations(
        withLimit limit: Int,
        skippingPages pagesToSkip: Int,
        andUsingCompletionHandler handler: @escaping ([StudentInformation]?, APIClient.RequestError?) -> Void
    )

    func fetchStudentLocation(
        byUsingUniqueKey key: String,
        andCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
    )


    func createStudentLocation(
        _ information: StudentInformation,
        withCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
    )

 
    func updateStudentLocation(
        _ information: StudentInformation,
        withCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
    )

    // Sorts the locations by the updated at property.
    func sortLocations()
}
