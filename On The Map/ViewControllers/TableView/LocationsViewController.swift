//
//  LocationsViewController.swift
//  On The Map
//
//  Created by Stefan Weiss on 29.03.22.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parseClient: ParseAPIClientProtocol!
    var mapView: MKMapView!
    var loggedUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseClient.studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as? LocationsTableViewCell
        
        let currentLocation = parseClient.studentLocations[indexPath.row]
        
        cell?.titleLabel.text = "\(currentLocation.firstName) \(currentLocation.lastName)"
        cell?.subTitleLabel?.text = currentLocation.mediaUrl.absoluteString

        return cell!
    }
}
