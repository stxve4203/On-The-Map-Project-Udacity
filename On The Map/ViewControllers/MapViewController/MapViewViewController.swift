//
//  MapViewViewController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let annotationViewReuseIdentifier = "annotation view ID"

    /// The parse client used to retrieve the students locations.
    var parseClient: ParseAPIClientProtocol!

    /// The currently logged user.
    var loggedUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
  
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
      
    }

    // MARK: Imperatives

    /// Displays the locations on the map.
    func displayLocations() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(parseClient.studentLocations.compactMap {
            StudentAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                title: "\($0.firstName) \($0.lastName)",
                subtitle: $0.mediaUrl.absoluteString,
                studentInformation: $0
            )
        })
    }

    // MARK: Actions
}

extension MapViewViewController: MKMapViewDelegate {

    // MARK: MKMapView delegate methods

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let studentAnnotation = annotation as? StudentAnnotation else {
            return nil
        }

        var annotationView: MKPinAnnotationView! = mapView.dequeueReusableAnnotationView(
            withIdentifier: annotationViewReuseIdentifier
        ) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(
                annotation: studentAnnotation,
                reuseIdentifier: annotationViewReuseIdentifier
            )
        }

        if studentAnnotation.studentInformation.userKey == loggedUser.userKey {
            annotationView.pinTintColor = UIColor.red
        } else {
            annotationView.pinTintColor = .red
        }

        annotationView.canShowCallout = true
        annotationView.displayPriority = .required
        annotationView.rightCalloutAccessoryView = UIButton(type: UIButton.ButtonType.detailDisclosure)
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let studentAnnotation = view.annotation as? StudentAnnotation else {
            return
        }

        guard let link = studentAnnotation.subtitle else {
            assertionFailure("The annotation must have a valid link.")
            return
        }
    }
    
    func open(urlToOpen url: URL) {
         UIApplication.shared.open(url, options: [:], completionHandler: nil)
     }
    // Tap on pin delegate
     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
         if control == view.rightCalloutAccessoryView {
             let url = URL(string: ((view.annotation?.subtitle) ?? "")!)!
             open(urlToOpen: url)
         }
     }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let recognizer = view.gestureRecognizers?.filter({ $0 is AnnotationLinkTapRecognizer }).first {
            view.removeGestureRecognizer(recognizer)
        }
    }
}
