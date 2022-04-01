//
//  TabBarController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit
import CoreLocation
class TabBarController: UITabBarController, UITabBarControllerDelegate {

    // MARK: Properties

    var udacityClient: UdacityAPIClientProtocol!
    var parseClient: ParseAPIClientProtocol!
    var loggedUser: User!
    var loggedUserStudentInformation: StudentInformation?
    var locationManager: CLLocationManager!
    var parseAPIClient = ParseAPIClient()


    // MARK: Imperatives
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mapsViewController = viewControllers!.first as? MapViewViewController,
            let tableViewController = viewControllers!.last as? LocationsViewController else {
                preconditionFailure("Couldn't correclty get the child view controllers.")
            }

        locationManager = CLLocationManager()
        
        mapsViewController.loggedUser = loggedUser
        mapsViewController.parseClient = parseClient
        tableViewController.loggedUser = loggedUser
        tableViewController.parseClient = parseClient
        
        delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        loadLocations()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let addLocationController = segue.destination as? AddLocationViewController {
            addLocationController.loggedUser = loggedUser
            addLocationController.parseClient = parseClient
            addLocationController.studentInformation = loggedUserStudentInformation

                let mapController = viewControllers?.first as? LocationsViewController
            addLocationController.userLocation = mapController?.mapView.userLocation
        }
        }
    

    // MARK: Actions

    @IBAction func loadLocations(_ sender: UIBarButtonItem? = nil) {
        func showFetchedLocationsOnMainThread(_ locations: [StudentInformation]) {
            DispatchQueue.main.async {
                sender?.isEnabled = true
                self.displayStudentLocations(locations)
                self.parseAPIClient.sortLocations()

            }
        }

        parseClient.fetchStudentLocations(withLimit: 100, skippingPages: 0) { locations, error in
            let errorMessage = """
There was an error while downloading the students' locations, please, contact the app developer.
"""

            guard let locations = locations, error == nil else {
                self.displayError(error ?? .malformedJson, withMessage: errorMessage)
                DispatchQueue.main.async {
                    sender?.isEnabled = true
                }
                return
            }

            if self.loggedUserStudentInformation == nil {
                // Search for the student information of the logged user.Z
                if let loggedUserInformation = locations.filter({ $0.userKey == self.loggedUser.userKey }).first {
                    self.loggedUserStudentInformation = loggedUserInformation
                    showFetchedLocationsOnMainThread(locations)
                } else {
                    // Otherwise, try to fetch it, and if successful, display it.
                    _ = self.parseClient.fetchStudentLocation(byUsingUniqueKey: self.loggedUser.userKey) { information, _ in
                        if let information = information {
                            // Include the fetched information into the other locations and sort them.
                            self.loggedUserStudentInformation = information
                            self.parseClient.studentLocations.append(information)
                            self.parseAPIClient.sortLocations()
                        }

                        showFetchedLocationsOnMainThread(self.parseClient.studentLocations)
                    }
                }
            } else {
                showFetchedLocationsOnMainThread(locations)
            }
        }
    }
    
    @IBAction func logUserOut(_ sender: UIButton) {
        udacityClient.logOut { isSuccessful, error in
            guard isSuccessful, error == nil else {
              
                DispatchQueue.main.async {
                }
                return
            }

            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

        func displayStudentLocations(_ locations: [StudentInformation]) {
            guard let mapController = viewControllers?.first as? MapViewViewController,
                let tableViewController = viewControllers?.last as? LocationsViewController else {
                    assertionFailure("Couldn't get the controllers.")
                    return
                }
            tableViewController.displayLocation()
            mapController.displayLocations()
        }
    


    
    // MARK: Notifications
    @objc private func displayCreatedLocation(usingNotification notification: NSNotification) {
        guard let createdInformation =
            notification.userInfo?[ParseAPIClient.UserInfoKeys.CreatedStudentInformation] as? StudentInformation else {
                preconditionFailure("Coulnd't get the created student information from the notification.")
        }

        loggedUserStudentInformation = createdInformation

        parseClient.studentLocations.removeAll {
            $0.userKey == createdInformation.userKey && $0.objectID == createdInformation.objectID
        }
        parseClient.studentLocations.append(createdInformation)
        parseAPIClient.sortLocations()

        displayStudentLocations(parseClient.studentLocations)
}
}
