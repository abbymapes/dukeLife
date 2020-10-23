//
//  Place.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import Foundation

class Place:Codable {
    //MARK: Properties
    var id: String
    var name: String
    var displayImg: String
    var url: String
    var phoneNum: String
    var displayAddr: [String]
    var address: Address
    var coords: Coordinates
    
    //MARK: Initializer
    init?(id: String, name: String, displayImg: String, url: String, phoneNum: String, address: Address, coords: Coordinates) {
        if (name.isEmpty) {
            return nil;
        }
        self.id = id
        self.name = name
        self.displayImg = displayImg
        self.url = url
        self.phoneNum = phoneNum
        self.address = address
        self.displayAddr = address.display_address!
        self.coords = coords
    }
}
