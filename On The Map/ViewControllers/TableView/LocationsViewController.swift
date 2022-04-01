//
//  LocationsViewController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit
import MapKit

class LocationsViewController: UITableViewController {
    
    var parseClient: ParseAPIClientProtocol!
    var mapView: MKMapView!
    var loggedUser: User!
    var parseAPIClient = ParseAPIClient()
    var studentLocations = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // ViewWillAppear is better for reloading tableView
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func displayLocation() {
        tableView.reloadData()
    }
    
    
    
    
    // Open URL by clicking on row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentLocation = parseClient.studentLocations[indexPath.row]
        UIApplication.shared.openDefaultBrowser(accessingAddress: currentLocation.mediaUrl.absoluteString)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationsTableViewCell
        
        let currentLocation = parseClient.studentLocations[indexPath.row]
        
        cell?.titleLabel.text = "\(currentLocation.firstName) \(currentLocation.lastName)"
        cell?.subTitleLabel?.text = currentLocation.mediaUrl.absoluteString
        
        return cell!
    }
}
