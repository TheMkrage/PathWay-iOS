//
//  TextViewControllerHelper.swift
//  PathWay
//
//  Created by Matthew Krager on 10/13/18.
//  Copyright © 2018 Matthew Krager. All rights reserved.
//

import UIKit
import ARKit

extension TestViewController {
    func getBox(image: UIImage) -> SCNNode {
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        
        let node = SCNNode()
        node.geometry = box
        node.geometry?.materials = [material]
        node.position = SCNVector3(0, 1, 0)
        return node
    }
}
