//
//  launchViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Foundation

class launchViewController: UIViewController {
    
    struct business: Codable {
        var id:String?
        var name: String?
        var url: String?
        var coordinates: Coordinates?
        var image_url:String?
        var location: Address?
        var display_phone: String?
    }
    
    struct apiResponse: Codable {
        var businesses:[business]
    }
    
    var placeList = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Duke location
        let latitude = 36.0014
        let longitude = -78.9382
        let radius = 16093
        let category = "bars"
        
        let apikey = "Q2DSCs_0MgIdnj4RLvlehFC7McfEGtAp8JZi8AYffmqMPCcS7vlpLRNoGixr_bGRKRG3XsOmjb1rlrX_0RpzIHdZG5Mdmom3GgCWyDZn8CJXHrIeQP9S3Q2AbAeTX3Yx"
        
        let baseURL = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&categories=\(category)"
        
        let url = URL(string: baseURL)
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if (error != nil) {
                print("Error = \(error!)")
                return
            }
            let response = response as! HTTPURLResponse
            print(response)
            
            // Ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No results found")
                return
            }
            // Decode JSON response
            print(content)
            let decoder = JSONDecoder()
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                                print(">>>>>", json, #line, "<<<<<<<<<")
                
                let apiResult = try decoder.decode(apiResponse.self, from: content)
                let allPlaces = apiResult.businesses
                
                // Parse through recipes to retrieve information
                self.placeList.removeAll()
                for place in allPlaces {
                    let placeToAdd = Place.init(id: place.id!, name: place.name!, displayImg: place.image_url!, url: place.url!, phoneNum: place.display_phone!, address: place.location!, coords: place.coordinates!)!
                    self.placeList.append(placeToAdd);
                    print(place)
                }
            } catch {
                print("JSON Decode error")
            }
        }
        dataTask.resume()
         
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
