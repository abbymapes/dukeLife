//
//  Coordinates.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import Foundation

class Coordinates: Codable {
    //MARK: Properties
    var latitude: Decimal?
    var longitude: Decimal?
    
    //MARK: Initializer
    init?(latitude: Decimal, longitude: Decimal) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
