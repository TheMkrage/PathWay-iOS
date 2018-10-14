//
//  TestViewController.swift
//  PathWay
//
//  Created by Matthew Krager on 10/13/18.
//  Copyright © 2018 Matthew Krager. All rights reserved.
//

import UIKit
import ARCL
import CoreLocation
import ARKit
import Anchorage

class TestViewController: UIViewController {
    
    let locationLabel = UILabel()
    var topView = UIView()
    var addButton = UIButton()
    var markButton = UIButton()
    var pathToClosest = UITextField()
    
    var timer: Timer!
    
    let pyramidGeometry = SCNPyramid(width: 0.01, height: 0.04, length: 0.01)
    lazy var pyramidNode = SCNNode(geometry: self.pyramidGeometry)
    
    var marked = CLLocation(latitude: 32.8855781716564785, longitude: -117.23935240809809)
    var lastLocation = CLLocation(latitude: 32.8855781716564785, longitude: -117.23935240809809)
    
    let waypointTypes = ["Bathroom", "Exit", "Health Office", "Fire Alarm", "Stairs", "Elevator", "Ramp", "Fire Extinguisher"]
    
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WaypointStore.shared.getWaypointsForLocation(coordinate: CLLocationCoordinate2D(latitude: 32.8855781716564785, longitude: -117.23935240809809), altitude: 123.15) { (waypoints) in
            for waypoint in waypoints {
                let coordinate = CLLocationCoordinate2D(latitude: waypoint.latitude, longitude: waypoint.longitude)
                
                print(coordinate)
                let location = CLLocation(coordinate: coordinate, altitude: 123.15)
                guard let image = UIImage(named: waypoint.name) else {
                    continue
                }
                
                let annotationNode = LocationAnnotationNode(location: location, image: image)
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
        }

        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        // ADd object
        let coordinate = CLLocationCoordinate2D(latitude: 32.8855781716564785, longitude: -117.23935240809809)
        let location = CLLocation(coordinate: coordinate, altitude: 124)
        let image = UIImage(named: "Icon-App-60x60")!
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        //sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        print(sceneLocationView.currentScenePosition())
        
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        
        //This is not working
        material.diffuse.contents = UIImage(named: "Icon.png")
        
        let node = SCNNode()
        node.geometry = box
        node.geometry?.materials = [material]
        node.position = SCNVector3(0, 0, 1)
        sceneLocationView.scene.rootNode.addChildNode(node)
        
        // Make Pyramid
        let materialPyr = SCNMaterial()
        materialPyr.diffuse.contents = UIImage.init(named: "gradient")
        pyramidGeometry.materials = [materialPyr]
        
        self.pyramidNode.position = SCNVector3Make(0, -0.1, -0.2)
        self.sceneLocationView.pointOfView?.addChildNode(pyramidNode)
        
        self.markButton.setTitle("+", for: .normal)
        self.markButton.setTitleColor(.black, for: .normal)
        self.markButton.addTarget(self, action: #selector(mark), for: .touchUpInside)
        
        self.addButton.setTitle("+", for: .normal)
        self.addButton.setTitleColor(.black, for: .normal)
        self.addButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
            
        self.topView.backgroundColor = .white
        
        self.topView.addSubview(self.addButton)
        self.topView.addSubview(self.markButton)
        
        self.locationLabel.textColor = .white
        self.locationLabel.numberOfLines = 0
        self.view.addSubview(self.locationLabel)
        self.view.addSubview(self.topView)
        self.setupConstraints()
        
        //pointTo()
    }
    
    override func viewDidLayoutSubviews() {
        sceneLocationView.frame = view.bounds
    }
    
    func setupConstraints() {
        self.sceneLocationView.bottomAnchor == self.view.bottomAnchor
        self.sceneLocationView.leadingAnchor == self.view.leadingAnchor
        self.sceneLocationView.trailingAnchor == self.view.trailingAnchor
        self.sceneLocationView.topAnchor == self.topView.bottomAnchor
        
        self.locationLabel.topAnchor == self.sceneLocationView.topAnchor + 40
        self.locationLabel.leadingAnchor == self.sceneLocationView.leadingAnchor + 40
        
        self.topView.topAnchor == self.view.safeAreaLayoutGuide.topAnchor
        self.topView.leadingAnchor == self.view.leadingAnchor
        self.topView.trailingAnchor == self.view.trailingAnchor
        self.topView.heightAnchor == 60
        
        self.markButton.trailingAnchor == self.topView.trailingAnchor - 20
        self.markButton.centerYAnchor == self.topView.centerYAnchor
        
        self.addButton.trailingAnchor == self.topView.trailingAnchor - 80
        self.addButton.centerYAnchor == self.topView.centerYAnchor
    }

    @objc func mark() {
        self.lastLocation = self.sceneLocationView.currentLocation()!
        self.marked = self.sceneLocationView.currentLocation()!
        
        DispatchQueue.main.async {
        
            let coordinate = CLLocationCoordinate2D(latitude: self.marked.coordinate.latitude, longitude: self.marked.coordinate.longitude)
            
            print(coordinate)
            let location = CLLocation(coordinate: coordinate, altitude: 123.15)
            let image = UIImage(named: "Icon-App-60x60")!
            
            let annotationNode = LocationAnnotationNode(location: location, image: image)
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        }
        
        self.locationLabel.text = "marked"
    }

    @objc func addPressed() {
        self.lastLocation = self.sceneLocationView.currentLocation()!
        let alert = UIAlertController(title: "Add New Waypoint", message: "Type a name for this new waypoint", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Adding new Waypoint", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            DispatchQueue.main.async {
                
                let coordinate = CLLocationCoordinate2D(latitude: self.lastLocation.coordinate.latitude, longitude: self.lastLocation.coordinate.longitude)
                print(coordinate)
                let location = CLLocation(coordinate: coordinate, altitude: 123.15)
                let image = UIImage(named: textField.text!)!
                let annotationNode = LocationAnnotationNode(location: location, image: image)
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                WaypointStore.shared.createWaypoint(name: textField.text ?? "", coordinate: coordinate, altitude: location.altitude, callback: { (waypoint) in
                    print("got it!")
                })
            }
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter a name"
        }
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }

    @objc func update() {
        self.lastLocation = self.sceneLocationView.currentLocation()!
        let heading = CGFloat((self.sceneLocationView.locationManager.heading?.degreesToRadians)!)
        let currentLocation = self.sceneLocationView.currentLocation()
        let metersAway = lastLocation.distance(from: marked)
        
        let radians = self.lastLocation.bearingToLocationRadian(self.marked)
        self.locationLabel.text = "lat: \(currentLocation?.coordinate.latitude)\n long: \(currentLocation?.coordinate.longitude)\n alt: \(currentLocation?.altitude)\n dist: \(metersAway)"
        self.rotate(x: self.pyramidNode, rotateTo: -(radians - heading))
    }
    
    func rotate(x: SCNNode, rotateTo: CGFloat) {
        let rot = SCNAction.rotateTo(x: 0, y: 0, z: rotateTo, duration: 0.3, usesShortestUnitArc: true)
        x.runAction(rot)
    }
}

extension TestViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        return true
    }
}

extension TestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

extension TestViewController: SceneLocationViewDelegate {
    
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
