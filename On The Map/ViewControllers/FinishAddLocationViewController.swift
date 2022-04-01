//
//  FinishAddLocationViewController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit
import MapKit
class FinishAddLocationViewController: UIViewController {
    
    // MARK: Parameters
    private let annotationViewIdentifier = "user annotation"
    var loggedUser: User!
    var parseClient: ParseAPIClientProtocol!
    var locationText: String!
    var linkText: String!
    var placemark: MKPlacemark!
    var studentInformations: StudentInformation?
    
    private lazy var studentInformationToPost: StudentInformation = {
        var studentInformation = makeStudentInformation(
            loggedUser: loggedUser,
            locationText: locationText,
            placemark: placemark,
            linkText: linkText
        )
        
        if studentInformations != nil {
            studentInformation.objectID = studentInformations?.objectID
        }
        
        return studentInformation
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    private var selectedViewTapRecognizer: UITapGestureRecognizer?
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationViewIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Display the map annotation.
        let annotation = StudentAnnotation(
            coordinate: placemark.coordinate,
            title: locationText,
            subtitle: linkText,
            studentInformation: studentInformationToPost
        )
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
        mapView.setRegion(
            MKCoordinateRegion(
                center: annotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            ),
            animated: true
        )
    }
    
    // MARK: Actions
    
    @IBAction func finishButtonPressed(_ sender: UIButton) {
        let completionHandler: (StudentInformation?, APIClient.RequestError?) -> Void = { information, error in
            guard error == nil, let information = information else {
                // Display error
                Alert.showFailedToPost(on: self)
                return
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name.StudentInformationCreated,
                    object: self,
                    userInfo: [ParseAPIClient.UserInfoKeys.CreatedStudentInformation: information]
                )
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        // Update or create the informed location values.
        (studentInformations != nil ? parseClient.updateStudentLocation : parseClient.createStudentLocation)(
            studentInformationToPost,
            completionHandler
        )
    }
    
    @objc private func openDefaultBrowser(_ sender: UITapGestureRecognizer?) {
        
    }
    
    // MARK: Imperatives
    private func makeStudentInformation(
        loggedUser: User,
        locationText: String,
        placemark: MKPlacemark,
        linkText: String
    ) -> StudentInformation {
        guard let urlString = linkText.replacingOccurrences(
            of: " ",
            with: "+"
        ).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            preconditionFailure("Couldn't configure the provided url string.")
        }
        
        return StudentInformation(
            firstName: loggedUser.firstName,
            lastName: loggedUser.lastName,
            latitude: placemark.coordinate.latitude,
            longitude: placemark.coordinate.longitude, mapTextReference: locationText,
            mediaUrl: URL(string: urlString)!,
            userKey: loggedUser.userKey
        )
    }
}

extension FinishAddLocationViewController: MKMapViewDelegate {
    
    // MARK: Map view delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationViewIdentifier,
            for: annotation
        ) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
        }
        
        annotationView.displayPriority = .required
        annotationView.pinTintColor = UIColor.red
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        selectedViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openDefaultBrowser(_:)))
        view.addGestureRecognizer(selectedViewTapRecognizer!)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(selectedViewTapRecognizer!)
    }
}
