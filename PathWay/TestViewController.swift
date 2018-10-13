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

class TestViewController: UIViewController {

    var sceneLocationView = SceneLocationView()
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        let coordinate = CLLocationCoordinate2D(latitude: 32.8855781716564785, longitude: -117.23935240809809)
        let location = CLLocation(coordinate: coordinate, altitude: 124)
        let image = UIImage(named: "Icon-App-60x60")!
        LocationAnnotationNode.initialize()
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
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
    }
    
    override func viewDidLayoutSubviews() {
        sceneLocationView.frame = view.bounds
    }

    //override func 
}
