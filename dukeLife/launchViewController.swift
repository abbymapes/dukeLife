//
//  launchViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Foundation
import UIKit
import Firebase

class launchViewController: UIViewController {
    struct coords: Codable {
        var latitude: Decimal?
        var longitude: Decimal?
    }
    struct business: Codable {
        var id:String?
        var name: String?
        var url: String?
        var coordinates: coords?
        var image_url:String?
        var location: Address?
        var display_phone: String?
    }
    
    struct apiResponse: Codable {
        var businesses:[business]
    }
    
    struct ids: Codable {
        var yelpId: String
        var docId: String
    }
    
    struct businessResponse: Codable {
        var name: String?
        var photos: [String]?
    }
    
    var idsRead = [String]()
    var placeList = [Place]()
    var idList = [ids]()
    var photosFound = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DO NOT UNCOMMENT BELOW (DATABASE ALREADY ADDED / INITIALIZED WITH LOCATIONS
        // Set up Database with locations from YelpAPI for each category
        /*
        // Set up Duke location
        let db = Firestore.firestore()
        let latitude = 36.0014
        let longitude = -78.9382
        let radius = 16093
        let searchString = "donuts"
        
        let apikey = "Q2DSCs_0MgIdnj4RLvlehFC7McfEGtAp8JZi8AYffmqMPCcS7vlpLRNoGixr_bGRKRG3XsOmjb1rlrX_0RpzIHdZG5Mdmom3GgCWyDZn8CJXHrIeQP9S3Q2AbAeTX3Yx"
        
        let baseURL = "https://api.yelp.com/v3/businesses/search?term=\(searchString)&latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
        
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
                var i = 0;
                for place in allPlaces {
                    print(allPlaces)
                    let c = Coordinates.init(latitude: place.coordinates?.latitude as! NSNumber, longitude: place.coordinates?.longitude as! NSNumber)!
                    let placeToAdd = Place.init(id: place.id!, name: place.name!, displayImg: place.image_url!, url: place.url!, phoneNum: place.display_phone!, address: place.location!, coords: c)!
                    self.placeList.append(placeToAdd);
                    
                    // Add a new document with a generated ID
                    /*
                    var ref: DocumentReference? = nil
                    var dispAddr = [String]()
                    if (placeToAdd.coords.latitude == nil || placeToAdd.coords.latitude == nil) {
                        continue;
                    } else if (["Pure Barre - Durham", "Sky Zone Trampoline Park"].contains(placeToAdd.name)) {
                        var addr1 = ""
                        var addr2 = ""
                        var addr3 = ""
                        var city = ""
                        var state = ""
                        var zip = ""
                        var dispAddr = [String]()
                        if (placeToAdd.address.address1 != nil) {
                            addr1 = placeToAdd.address.address1!
                        }
                        if (placeToAdd.address.address2 != nil) {
                            addr2 = placeToAdd.address.address2!
                        }
                        if (placeToAdd.address.address3 != nil) {
                            addr3 = placeToAdd.address.address3!
                        }
                        if (placeToAdd.address.city != nil) {
                            city = placeToAdd.address.city!
                        }
                        if (placeToAdd.address.state != nil) {
                            state = placeToAdd.address.state!
                        }
                        if (placeToAdd.address.city != nil) {
                            zip = placeToAdd.address.zip_code!
                        }
                        if (placeToAdd.address.display_address != nil) {
                            dispAddr = placeToAdd.address.display_address!
                        }
                        ref = db.collection("places").addDocument(data: [
                                                                    "id": placeToAdd.id,
                                                                    "name": placeToAdd.name,
                                                                    "displayImg": placeToAdd.displayImg,
                                                                    "url": placeToAdd.url,
                                                                    "phoneNum": placeToAdd.phoneNum,
                                                                    "latitude": placeToAdd.coords.latitude!,
                                                                    "longitude": placeToAdd.coords.longitude!,
                                                                    "address1": addr1,
                                                                    "address2": addr2,
                                                                    "address3": addr3,
                                                                    "city": city,
                                                                    "state": state,
                                                                    "zip_code": zip,
                                                                    "display_address": dispAddr,
                                                                    "type": "fun"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(ref!.documentID)")
                                }
                        }
                    }*/
                    print(place.name!)
                    print(i);
                    i += 1
                }
            } catch {
                print("JSON Decode error")
            }
        }
        dataTask.resume()*/

    // Adding Images from YELP API to Databse
    // DO NOT UNCOMMENT BELOW (ALREADY ADDED IMAGES TO DATABASE)
    
    // Loop through all documents in database
    /*
    self.idsRead.removeAll()
    self.idList.removeAll()
    db.collection("places").getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                let docId = document.documentID
                if (!self.idsRead.contains(docId)) {
                    self.idsRead.append(docId)
                    let yelpId = document.data()["id"] as! String
                    //let yelpId = "AdV3qLfQZVi3T7O-Y6qA8Q"
                    let name = document.data()["name"] as! String
                    let idToAdd = ids(yelpId: yelpId,
                                      docId: docId)
                    self.idList.append(idToAdd)
                }
            }
            let dispatchGroup = DispatchGroup()
            let dispatchQueue = DispatchQueue(label: "taskQueue")
            let dispatchSemaphore = DispatchSemaphore(value: 0)
            
            var photosToAdd = 0;
            dispatchQueue.async {
                for id in self.idList {
                    dispatchGroup.enter()
                    let apikey = "Q2DSCs_0MgIdnj4RLvlehFC7McfEGtAp8JZi8AYffmqMPCcS7vlpLRNoGixr_bGRKRG3XsOmjb1rlrX_0RpzIHdZG5Mdmom3GgCWyDZn8CJXHrIeQP9S3Q2AbAeTX3Yx"

                    let baseURL = "https://api.yelp.com/v3/businesses/\(id.yelpId)"
                    print(baseURL)

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
                                
                            // Ensure there is data returned from this HTTP response
                            guard let content = data else {
                                print("No results found")
                                return
                            }
                            // Decode JSON response
                            let decoder = JSONDecoder()
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                                    
                                let response = try decoder.decode(businessResponse.self, from: content)
                                    
                                if (response.photos != nil) {
                                    if (response.photos!.count == 0) {
                                        print("No photos found for yelpID: \(id.yelpId)")
                                    }
                                    for image in response.photos! {
                                        photosToAdd += 1
                                        if (!self.photosFound.contains(id.yelpId)) {
                                            self.photosFound.append(id.yelpId)
                                        }
                                            var ref: DocumentReference? = nil
                                            ref = db.collection("images").addDocument(data: [
                                                "imageUrl": image,
                                                "placeId": id.docId,
                                                "yelpId": id.yelpId])
                                            { err in
                                                if let err = err {
                                                    print("Error adding document: \(err)")
                                                } else {
                                                    print("Photo added for yelpID: \(id.yelpId)")
                                                }
                                            }
                                    }
                                }
                            } catch {
                                print("JSON Decode error")
                            }
                            dispatchSemaphore.signal()
                            dispatchGroup.leave()
                        }
                        dataTask.resume()
                        dispatchSemaphore.wait()
                    }
            }
            
            dispatchGroup.notify(queue: dispatchQueue){
                DispatchQueue.main.async {
                    print("Finished all requests.")
                    print("total # places: \(self.idList.count)")
                    print("# places w photos: \(self.photosFound.count)")
                    //print("# photos already in database: \(self.urlsInDatabase.count)")
                    print("# photos added to database: \(photosToAdd)")
                }
            }
            
        }
    }*/
    
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
