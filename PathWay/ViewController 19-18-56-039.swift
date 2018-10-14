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

    @IBOutlet var sceneView: SceneLocationView!
    
    let locationLabel = UILabel()
    @IBOutlet var addButton: UIButton!
    @IBOutlet var pathToClosest: UITextField!
    
    var marked = CLLocation(latitude: 32.8855781716564785, longitude: -117.23935240809809)
    var lastLocation = CLLocation(latitude: 32.8855781716564785, longitude: -117.23935240809809)
    
    let waypointTypes = ["Bathroom", "Exit", "Health Office", "Fire Alarm", "Stairs", "Elevators", "Ramps"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.sceneView.run()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let coordinate = CLLocationCoordinate2D(latitude: 32.8855781716564785, longitude: -117.23935240809809)
        let location = CLLocation(coordinate: coordinate, altitude: 124)
        let image = UIImage(named: "Icon-App-60x60")!
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        print(sceneView.currentScenePosition())
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.locationDelegate = self
        
        //self.sceneView.rendersContinuously = true
        //self.sceneView.showAxesNode = true
        //self.sceneView.showFeaturePoints = true
        
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
    
    @IBAction func mark() {
        self.marked = self.sceneView.currentLocation()!
        DispatchQueue.main.async {
            let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
            
            let material = SCNMaterial()
            
            //This is not working
            material.diffuse.contents = UIImage(named: "fire.png")
            
            let node = SCNNode()
            node.geometry = box
            node.geometry?.materials = [material]
            
            /*
            
            let referenceNode = self.sceneView.pointOfView!
            let position = SCNVector3(x: 0, y: 0.75, z: 0)
            let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
            
            // Setup a translation matrix with the desired position
            var translationMatrix = matrix_identity_float4x4
            translationMatrix.columns.3.x = position.x
            translationMatrix.columns.3.y = position.y
            translationMatrix.columns.3.z = position.z
            
            // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
            let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
            print(updatedTransform)
            node.transform = SCNMatrix4(updatedTransform)
            self.sceneView.scene.rootNode.addChildNode(node)

            let frame = self.sceneView.session.currentFrame!
            let currentTransform = frame.camera.transform
            node.transform = SCNMatrix4(matrix_multiply(currentTransform, translation))
            self.sceneView.scene.rootNode.addChildNode(node) */
            let coordinate = self.marked.coordinate
            print(coordinate)
            let location = CLLocation(coordinate: coordinate, altitude: 124)
            let image = UIImage(named: "fire.png")!
            let annotationNode = LocationAnnotationNode(location: location, image: image)
            self.sceneView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        }
        
        self.locationLabel.text = "marked"
        
        let currentLocation = self.sceneView.currentLocation()
        let metersAway = lastLocation.distance(from: marked)
        print("\(lastLocation.coordinate)")
        self.locationLabel.text = "lat: \(currentLocation?.coordinate.latitude)\n long: \(currentLocation?.coordinate.longitude)\n alt: \(currentLocation?.altitude)\n dist: \(metersAway)"
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("added")
        return
    }
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        print(anchor)
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("udpdate")
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

extension ViewController: SceneLocationViewDelegate {
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
}
