//
//  UdacityAPIClientProtocol.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import Foundation

protocol UdacityAPIClientProtocol {
    
    var userSession: Session? { get }
    var user: User? { get }
    var userAccount: Account? { get }
    
    // MARK: Imperatives
    func logIn(
        withUsername username: String,
        password: String,
        andCompletionHandler handler: @escaping (Account?, Session?, APIClient.RequestError?) -> Void
    )

    func logOut(withCompletionHandler handler: @escaping (Bool, APIClient.RequestError?) -> Void)

    func getUserInfo(
        usingUserIdentifier userID: String,
        andCompletionHandler handler: @escaping (User?, APIClient.RequestError?) -> Void
    )
}
