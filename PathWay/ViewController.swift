//
//  ViewController.swift
//  PathWay
//
//  Created by Matthew Krager on 10/12/18.
//  Copyright © 2018 Matthew Krager. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Anchorage
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let altitudeLabel = UILabel()
    let locationManager = CLLocationManager()
    @IBOutlet var addButton: UIButton!
    @IBOutlet var pathToClosest: UITextField!
    
    let waypointTypes = ["Bathroom", "Exit", "Health Office", "Fire Alarm", "Stairs", "Elevators", "Ramps"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startReceivingLocationChanges()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.altitudeLabel.text = "20"
        self.altitudeLabel.textColor = UIColor.white
        
        self.pathToClosest.delegate = self
        let inputView = UIPickerView()
        inputView.delegate = self
        inputView.dataSource = self
        self.pathToClosest.inputView = inputView
        
        self.sceneView.addSubview(self.altitudeLabel)
        
        self.setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func setupConstraints() {
        self.altitudeLabel.topAnchor == self.sceneView.topAnchor + 40
        self.altitudeLabel.leadingAnchor == self.sceneView.leadingAnchor + 40
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Location Data
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        self.altitudeLabel.text = "\(lastLocation.altitude)"
    }
    
    @IBAction func addPressed() {
        let alert = UIAlertController(title: "Add New Waypoint", message: "Type a name for this new waypoint", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Adding new Waypoint", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            print(textField.text)
            // TODO: Upload
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        return true
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.waypointTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.waypointTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pathToClosest.text = "Path to Nearest \(self.waypointTypes[row])"
        self.view.endEditing(true)
    }
}
