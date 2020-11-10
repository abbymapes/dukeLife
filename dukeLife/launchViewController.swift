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
    
    let netIds = ["bcw27", "msg124", "lsc39", "csw21", "jka32", "dar032", "dan024", "jdb12", "fab42", "cja24", "kda024", "sdf5", "sfn1", "dab24", "jb24", "da03", "erw1", "fda2", "dg2", "kap13", "amb23", "alp21", "loz02", "clo00", "adb", "avm", "mna", "bal", "llv", "naa24", "dja12", "ksa00", "ppa2", "mca12", "aba24", "zfa12", "jda99", "cck11", "jba12", "clm13", "lcm1", "ptk00", "jtm12", "cjm44", "mjm217", "ntw11", "brw12", "lqw31", "wkw12", "mdw23", "cbw29", "rmw22", "dww2", "jsb", "dab12", "dbn02", "da21", "bp02", "ljf23", "gbp12", "dak21", "fa02"]
    
    let comments = [
    "I love their ramen.",
    "Service is great!",
    "I always go there with my friends and get their bao buns. What a great establishment!",
    "This is the best ramen in Durham hands down.",
    "I never liked ramen until I tried it here.",
    "They also have great udon noodle soup.",
    "Don’t sleep on the fried rice.",
    "Great for big parties and special occasions",
    "My favorite late night ramen spot.",
    "One of my favorite places in Downtown Durham… almost rivals M Sushi!",
    "WU has a run for their money with this ramen.",
    "I love going to Eno with a group of friends.",
    "It’s so easy to go to Eno. Only around 15 minutes from campus. Bring a bathing suit and some lunch.",
    "There’s a cliff that is super fun to jump off of. Great activity for O Week when its hot.",
    "Highly recommend. Nice way to get out of Durham.",
    "The water gets cold in the winter so I recommend going in August / September.",
    "Great spot. Grade A fun"
    ]

    let places = [
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "09HrW53ZsFtOTP3VRLPw",
    "PP26rDvtoxWMRDJKct28",
    "PP26rDvtoxWMRDJKct28",
    "PP26rDvtoxWMRDJKct28",
    "PP26rDvtoxWMRDJKct28",
    "PP26rDvtoxWMRDJKct28",
    "PP26rDvtoxWMRDJKct28"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        var i = 0
        let db = Firestore.firestore()
        for id in netIds {
            var ref: DocumentReference? = nil
            ref = db.collection("students").addDocument(data:[
                "netId": id,
                "email": "demo@test.com"
            ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        if (i < self.places.count) {
                            let placeId = self.places[i]
                            let comment = self.comments[i]
                            self.saveComment(input:comment, netId: id, userId: ref!.documentID, placeId: placeId)
                            i = i + 1
                        }
                    }
                }
        }
        
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
                        }*/
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
    func saveComment(input: String, netId: String, userId: String, placeId: String) {
        let db = Firestore.firestore()

        // Get time
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
            
        var ref: DocumentReference? = nil
        ref = db.collection("comments").addDocument(data: [
            "comment": input,
            "netId": netId,
            "placeId": placeId,
            "time": time,
            "userId": userId
        ])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Comment written with Document ID: \(ref!.documentID)")
                }
            }
        }
}
