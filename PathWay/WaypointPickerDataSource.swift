//
//  WaypointPickerDataSource.swift
//  PathWay
//
//  Created by Matthew Krager on 10/13/18.
//  Copyright © 2018 Matthew Krager. All rights reserved.
//

import UIKit

import CoreLocation

class WaypointPickerDataSource: NSObject {
    var waypointTypes: [String]!
    var textField: UITextField!
    
    init(waypointTypes: [String], textField: UITextField) {
        self.waypointTypes = waypointTypes
        self.textField = textField
    }
}

extension WaypointPickerDataSource: UIPickerViewDelegate, UIPickerViewDataSource {
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
        let name = self.waypointTypes[row]
        self.textField.text = name
        pickerView.endEditing(true)
    }
}

