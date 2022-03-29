//
//  ParseAPIClient.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation


class ParseAPIClient: APIClient, ParseAPIClientProtocol {

    // MARK: Properties

    var studentLocations = [StudentInformation]()


    
    private lazy var baseURL: URL = {
        guard let url = mountBaseURL(usingScheme: API.Scheme, host: API.Host, andPath: API.Path) else {
            assertionFailure("Couldn't mount the url.")
            return URL(string: "")!
        }
        return url
    }()

    // MARK: Initializers

    override init() {
        super.init()

        requiredAPIHeaders = [
            "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        ]
    }

    // MARK: Imperatives

    func fetchStudentLocations(
        withLimit limit: Int,
        skippingPages pagesToSkip: Int,
        andUsingCompletionHandler handler: @escaping ([StudentInformation]?, APIClient.RequestError?) -> Void
        ) {
        let fetchUrl = baseURL.appendingPathComponent(Methods.StudentLocation)
        let parameters = [ParameterKeys.Limit: String(limit), ParameterKeys.Page: String(pagesToSkip * limit)]
        _ = getConfiguredTaskForGET(withAbsolutePath: fetchUrl.absoluteString, parameters: parameters) { json, error in
            guard error == nil else {
                handler(nil, error!)
                return
            }

            let json = json!

            guard let results = json[JSONResponseKeys.Results] as? [[String: AnyObject]] else {
                handler(nil, RequestError.malformedJson)
                return
            }

            let locations = results.compactMap { StudentInformation(informationData: $0) }

            assert(!locations.isEmpty, "The mapped locations mustn't be empty.")

            self.studentLocations = locations
            self.sortLocations()
            handler(locations, nil)
        }
    }

    func fetchStudentLocation(
        byUsingUniqueKey key: String,
        andCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
        ) {
        let fetchUrl = baseURL.appendingPathComponent(Methods.StudentLocation)
        let parameters = [ParameterKeys.WhereQuery: "{\"\(JSONResponseKeys.InformationKey)\" : \"\(key)\"}"]
        _ = getConfiguredTaskForGET(withAbsolutePath: fetchUrl.absoluteString, parameters: parameters)  { json, error in
            guard error == nil, let json = json else {
                handler(nil, error!)
                return
            }

            guard let results = json[JSONResponseKeys.Results] as? [[String: AnyObject]], !results.isEmpty else {
                handler(nil, APIClient.RequestError.malformedJson)
                return
            }

            guard let fetchedInformation = StudentInformation(informationData: results.first!) else {
                handler(nil, APIClient.RequestError.malformedJson)
                return
            }

            handler(fetchedInformation, nil)
        }
    }

    func createStudentLocation(
        _ information: StudentInformation,
        withCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
        ) {
        manageCurrentUserStudentLocation(information, usingMethod: .post, andCompletionHandler: handler)
    }

    func updateStudentLocation(
        _ information: StudentInformation,
        withCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
        ) {
        manageCurrentUserStudentLocation(information, usingMethod: .put, andCompletionHandler: handler)
    }


    private func manageCurrentUserStudentLocation(
        _ information: StudentInformation,
        usingMethod method: APIClient.HTTPMethod,
        andCompletionHandler handler: @escaping (StudentInformation?, APIClient.RequestError?) -> Void
        ) {
        guard let jsonData = getJsonRepresentation(ofStudentInformation: information) else {
            assertionFailure("Couldn't get the student information json body data.")
            handler(nil, APIClient.RequestError.malformedJsonBody)
            return
        }

        let requestCompletionHandler: (DeserializedJson?, APIClient.RequestError?) -> Void = { json, error in
            guard error == nil, let json = json else {
                handler(nil, error!)
                return
            }

            var information = information

            switch method {
            case .post:
                guard let objectID = json[JSONResponseKeys.ObjectID] as? String else {
                    handler(nil, .malformedJson)
                    return
                }
                guard let updatedAtText = json[JSONResponseKeys.CreatedAt] as? String,
                    let updatedAt = DateFormatter.APIFormatter.date(from: updatedAtText) else {
                        handler(nil, .malformedJson)
                        return
                }

                information.objectID = objectID
                information.updatedAt = updatedAt
            case .put:
                guard let updatedAtText = json[JSONResponseKeys.UpdatedAt] as? String,
                    let updatedAt = DateFormatter.APIFormatter.date(from: updatedAtText) else {
                        handler(nil, .malformedJson)
                        return
                }

                information.updatedAt = updatedAt
            default: break
            }

            handler(information, nil)
        }

        var urlString = baseURL.appendingPathComponent(Methods.StudentLocation).absoluteString
        if method == .put {
            guard let objectID = information.objectID else {
                assertionFailure("Couldn't get the object identifier of the information.")
                handler(nil, APIClient.RequestError.lackingData)
                return
            }

            urlString += "/\(objectID)"
        }

        _ = (method == .post ? getConfiguredTaskForPOST : getConfiguredTaskForPUT)(
            urlString,
            [:],
            jsonData,
            requestCompletionHandler
        )
    }

 
    private func getJsonRepresentation(ofStudentInformation studentInformation: StudentInformation) -> Data? {
        let jsonDictionary: [String: Any] = [
            JSONResponseKeys.FirstName: studentInformation.firstName,
            JSONResponseKeys.LastName: studentInformation.lastName,
            JSONResponseKeys.MapTextReference: studentInformation.mapTextReference,
            JSONResponseKeys.Latitude: studentInformation.latitude,
            JSONResponseKeys.Longitude: studentInformation.longitude,
            JSONResponseKeys.MediaUrl: studentInformation.mediaUrl.absoluteString,
            JSONResponseKeys.InformationKey: studentInformation.userKey
        ]
        return try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
    }

    func sortLocations() {
        studentLocations = studentLocations.sorted {
            $0.updatedAt!.compare($1.updatedAt!) == .orderedDescending
        }
    }
}
