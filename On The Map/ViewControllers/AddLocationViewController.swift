//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBOutlet weak var findButton: UIButton!
    
    //MARK: Variables
    var searchedPlacemark: MKPlacemark?
    var userLocation: MKUserLocation?
    var studentInformation: StudentInformation?
    var loggedUser: User!
    var parseClient: ParseAPIClientProtocol!
    

    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userInformation = studentInformation {
            locationTextField.text = userInformation.mapTextReference
            websiteTextField.text = userInformation.mediaUrl.absoluteString
        }
        
        locationTextField.delegate = self
        websiteTextField.delegate = self
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return searchedPlacemark != nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the informations to the next controller.
        let locationText = locationTextField.text!
        let linkText = websiteTextField.text!

        if let detailsController = segue.destination as? FinishAddLocationViewController {
            detailsController.loggedUser = loggedUser
            detailsController.parseClient = parseClient
            detailsController.locationText = locationText
            detailsController.linkText = linkText
            detailsController.placemark = searchedPlacemark
            detailsController.studentInformations = studentInformation
        }
    }
  
    @IBAction func findButtonPressed(_ sender: Any) {
        guard let locationText = locationTextField.text, !locationText.isEmpty,
            let websiteText = websiteTextField.text, !websiteText.isEmpty else {
            return
        }

        let mapSearchRequest = MKLocalSearch.Request()
        mapSearchRequest.naturalLanguageQuery = locationText
        if let userLocation = userLocation {
            let userRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
            )
            mapSearchRequest.region = userRegion
        }

        findButton.isEnabled = false
        [locationTextField, websiteTextField].forEach { $0?.resignFirstResponder() }

        let localSearch = MKLocalSearch(request: mapSearchRequest)
        localSearch.start { response, error in
            self.findButton.isEnabled = true

            guard error == nil, let response = response, !response.mapItems.isEmpty else {
                // Display error
                self.displayError(.lackingData, withMessage: "Couldn´t find the entered location.")
                return
            }

            self.searchedPlacemark = response.mapItems.first!.placemark
            self.performSegue(withIdentifier: "ShowLocationOnMap", sender: self)
        }
    }
    
}
