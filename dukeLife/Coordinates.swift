//
//  Coordinates.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import Foundation

class Coordinates {
    //MARK: Properties
    var latitude: NSNumber?
    var longitude: NSNumber?
    
    //MARK: Initializer
    init?(latitude: NSNumber, longitude: NSNumber) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
