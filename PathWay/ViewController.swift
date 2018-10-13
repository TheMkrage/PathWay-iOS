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

import ARCL

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let locationLabel = UILabel()
    let locationManager = CLLocationManager()
    @IBOutlet var addButton: UIButton!
    @IBOutlet var pathToClosest: UITextField!
    
    var marked = CLLocation(latitude: 32.8855781716564785, longitude: -117.23935240809809)
    var lastLocation = CLLocation(latitude: 32.8855781716564785, longitude: -117.23935240809809)
    
    let waypointTypes = ["Bathroom", "Exit", "Health Office", "Fire Alarm", "Stairs", "Elevators", "Ramps"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.present(TestViewController(), animated: true, completion: nil)
        return
        self.startReceivingLocationChanges()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Add a boxs
        
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        
        //This is not working
        material.diffuse.contents = UIImage(named: "Icon.png")
        
        let node = SCNNode()
        node.geometry = box
        node.geometry?.materials = [material]
        node.position = SCNVector3(0, 0.75, 0)
        scene.rootNode.addChildNode(node)
        
        self.locationLabel.text = "20"
        self.locationLabel.textColor = UIColor.white
        self.locationLabel.numberOfLines = 0
        
        self.pathToClosest.delegate = self
        let inputView = UIPickerView()
        inputView.delegate = self
        inputView.dataSource = self
        self.pathToClosest.inputView = inputView
        
        self.sceneView.addSubview(self.locationLabel)
        
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
        self.locationLabel.topAnchor == self.sceneView.topAnchor + 40
        self.locationLabel.leadingAnchor == self.sceneView.leadingAnchor + 40
    }
    
    // Location Data
    func startReceivingLocationChanges() {
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = locations.last!
        let metersAway = lastLocation.distance(from: marked)
        print("\(lastLocation.coordinate)")
        self.locationLabel.text = "lat: \(lastLocation.coordinate.latitude)\n long: \(lastLocation.coordinate.longitude)\n alt: \(lastLocation.altitude)\n dist: \(metersAway)"
    }
    
    @IBAction func mark() {
        self.marked = self.lastLocation
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        
        //This is not working
        material.diffuse.contents = UIImage(named: "Icon.png")
        
        let node = SCNNode()
        node.geometry = box
        node.geometry?.materials = [material]
        node.position = SCNVector3(0, 0.75, 0)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        self.locationLabel.text = "marked"
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
