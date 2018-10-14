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
    var waypoints = [Waypoint]()
    
    var sceneLocationView = SceneLocationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WaypointStore.shared.getWaypointsForLocation(coordinate: CLLocationCoordinate2D(latitude: 32.8855781716564785, longitude: -117.23935240809809), altitude: 123.15) { (waypoints) in
            self.waypoints = waypoints
            DispatchQueue.main.async {
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
        }

        self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        
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
        
        self.pathToClosest.delegate = self
        self.pathToClosest.borderStyle = .none
        self.pathToClosest.font = UIFont(name: "HelveticaNeue-Light", size: 19.0)
        self.pathToClosest.text = "Tap Here for a Path"
        let inputView = UIPickerView()
        inputView.delegate = self
        inputView.dataSource = self
        self.pathToClosest.inputView = inputView
            
        self.topView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        
        self.topView.addSubview(self.pathToClosest)
        self.topView.addSubview(self.addButton)
        self.topView.addSubview(self.markButton)
        
        self.locationLabel.textColor = .white
        self.locationLabel.numberOfLines = 0
        self.view.addSubview(self.locationLabel)
        self.view.addSubview(self.topView)
        self.setupConstraints()
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
        self.markButton.widthAnchor == 20
        
        self.addButton.trailingAnchor == self.topView.trailingAnchor - 80
        self.addButton.centerYAnchor == self.topView.centerYAnchor
        self.addButton.widthAnchor == 20
        
        self.pathToClosest.topAnchor == self.topView.topAnchor
        self.pathToClosest.leadingAnchor == self.topView.leadingAnchor + 20
        self.pathToClosest.bottomAnchor == self.topView.bottomAnchor
        self.pathToClosest.trailingAnchor == self.addButton.leadingAnchor
    }

    @objc func mark() {
        guard let currentLocation = self.sceneLocationView.currentLocation() else {
            return
        }
        self.lastLocation = currentLocation
        self.marked = currentLocation
        
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
        guard let currentLocation = self.sceneLocationView.currentLocation() else {
            return
        }
        self.lastLocation = currentLocation
        let alert = UIAlertController(title: "Add New Waypoint", message: "Type a name for this new waypoint", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Adding new Waypoint", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            DispatchQueue.main.async {
                
                let coordinate = CLLocationCoordinate2D(latitude: self.lastLocation.coordinate.latitude, longitude: self.lastLocation.coordinate.longitude)
                print(coordinate)
                let location = CLLocation(coordinate: coordinate, altitude: 123.15)
                guard let image = UIImage(named: textField.text ?? "") else {
                    return
                }
                let annotationNode = LocationAnnotationNode(location: location, image: image)
            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                WaypointStore.shared.createWaypoint(name: textField.text ?? "", coordinate: coordinate, altitude: location.altitude, callback: { (waypoint) in
                    self.waypoints.append(waypoint)
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
        guard let currentLocation = self.sceneLocationView.currentLocation() else {
            return
        }
        self.lastLocation = currentLocation
        let metersAway = lastLocation.distance(from: marked)
        self.locationLabel.text = "lat: \(currentLocation.coordinate.latitude)\n long: \(currentLocation.coordinate.longitude)\n alt: \(currentLocation.altitude)\n dist: \(metersAway)"
        
        guard let heading = self.sceneLocationView.locationManager.heading?.degreesToRadians else {
            return
        }
        
        let radians = self.lastLocation.bearingToLocationRadian(self.marked)
        
        self.rotate(x: self.pyramidNode, rotateTo: -(radians - CGFloat(heading)))
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
        self.pathToClosest.text = "Showing Path to Nearest \(self.waypointTypes[row])"
        let viableWaypoints = self.waypoints.filter { (waypoint) -> Bool in
            return waypoint.name == self.waypointTypes[row]
        }
        guard let first = viableWaypoints.first else {
            return
        }
        
        var shortestDistance = sqrt( pow(first.latitude - self.lastLocation.coordinate.latitude, 2) + pow(first.longitude - self.lastLocation.coordinate.longitude, 2))
        var shortestWaypoint = first
        for waypoint in viableWaypoints {
            let distance = sqrt( pow(waypoint.longitude - self.lastLocation.coordinate.latitude, 2) + pow(waypoint.longitude - self.lastLocation.coordinate.longitude, 2))
            if distance < shortestDistance {
                shortestWaypoint = waypoint
                shortestDistance = distance
            }
        }
        self.marked = CLLocation(coordinate: CLLocationCoordinate2D(latitude: shortestWaypoint.latitude, longitude: shortestWaypoint.longitude), altitude: shortestWaypoint.altitude)
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
