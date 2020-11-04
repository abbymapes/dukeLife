//
//  guestProfileViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/26/20.
//

import UIKit
import Firebase

class guestProfileViewController: UIViewController {

    @IBOutlet weak var likedPlaces: UITableView!
    @IBOutlet weak var userName: UILabel!
    
    // Replace with currentUserId when user log in is set up
    var currentUserId = "guest"
    var currentUsername = "John Doe"
    
    // List of places the user likes
    var placesList = [Place]()
    var idList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likedPlaces.delegate = self
        likedPlaces.dataSource = self
        loadUserInfo()
        loadLikedPlaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDidLoad()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
     Loads user netId from database
     */
    func loadUserInfo() {
        let db = Firestore.firestore()
        let docRef = db.collection("guests").document(currentUserId)
        
        // Gets current user from database
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let netId = document.data()!["name"] as! String
                self.userName.text = netId
            } else {
                print("Current user not found")
            }
        }
    }
    
    /*
     Loads user's liked places from database
     */
    func loadLikedPlaces() {
        let db = Firestore.firestore()
        self.placesList.removeAll()
        self.idList.removeAll()
        var likedIds = [String]()
        
        // Retrieve all ids for places the user likes
        db.collection("savedPlaces").whereField("userId", isEqualTo: self.currentUserId).order(by: "time", descending: true).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting saved places documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        likedIds.append(document.data()["placeId"] as! String)
                    }
    
                    let totalLikes = likedIds.count
                    var i = 1
                    
                    // Go through each place the user likes and retrieve information about each place to create a Place object
                    for id in likedIds {
                        let docRef = db.collection("places").document(id)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                var id = document.documentID
                                
                                if (!self.idList.contains(id)) {
                                    let name = document.data()!["name"] as! String
                                    let address = Address.init(
                                        address1: document.data()!["address1"] as! String,
                                        address2: document.data()!["address2"] as! String,
                                        address3: document.data()!["address3"] as! String,
                                        city:document.data()!["city"]! as! String,
                                        zip_code:document.data()!["zip_code"] as! String,
                                        state:document.data()!["state"] as! String,
                                        display_address: document.data()!["display_address"] as! [String]
                                        )!
                                    let placeToDisplay = Place.init(
                                        id: document.data()!["id"] as! String,
                                        name: name,
                                        displayImg: document.data()!["displayImg"] as! String,
                                        url: document.data()!["url"] as! String,
                                        phoneNum: document.data()!["phoneNum"] as! String,
                                        address: address,
                                        coords: Coordinates.init(
                                            latitude: document.data()!["latitude"] as! NSNumber,
                                            longitude: document.data()!["longitude"] as! NSNumber)!,
                                        docId: document.documentID,
                                        likeCount: document.data()!["likeCount"] as! NSNumber)!
                                    self.idList.append(id)
                                    self.placesList.append(placeToDisplay)
                                    
                                    // If we've reached the last place in the list, reload the data to display liked places
                                    if (i == totalLikes) {
                                        if self.placesList.count > 0 {
                                            print("Reload liked places data \(self.placesList.count)")
                                            DispatchQueue.main.async {[weak self] in
                                                self?.likedPlaces.reloadData()
                                            }
                                        } else {
                                            print("Not reloading liked places data, since none was found")
                                        }
                                    }
                                    i += 1
                                }
                            } else {
                                print("Liked place does not exist for places ID")
                            }
                        }
                    }
                }
        }
    }
}

/*
 * Set up table view for list of places the user likes
 */
extension guestProfileViewController: UITableViewDataSource, UITableViewDelegate, GuestPlaceDetailViewControllerDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placesList.count;
   }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! placeTableViewCell
        
        cell.name.text = "\(self.placesList[indexPath.row].name)"
    
        cell.likeCount.text = "\(self.placesList[indexPath.row].likeCount)"
        
        // Set saved button for user
        var saved = false
        let db = Firestore.firestore()
        db.collection("savedPlaces").whereField("placeId", isEqualTo: placesList[indexPath.row].docId)
            .whereField("userId", isEqualTo: self.currentUserId).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var count = 0;
                    for _ in querySnapshot!.documents {
                        count += 1;
                    }
                    if (count > 0) {
                        saved = true
                        self.placesList[indexPath.row].setSavedStatus(saved)
                    } else {
                        saved = false
                    }
                }
        }
        return cell
    }

    // MARK: - Navigation to Place Information
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        let destVC = segue.destination as! guestPlaceDetailViewController
        let myRow = likedPlaces!.indexPathForSelectedRow
        let place = placesList[myRow!.row]
        
        // Pass the selected information to the new view controller.
        destVC.docId = place.docId
        destVC.nameText = place.name
        destVC.likeCountText = "\(place.likeCount)"
        destVC.urlText = place.url
        destVC.phoneNumberText = place.phoneNum
        destVC.currentUsername = self.currentUsername
        destVC.currentUserId = self.currentUserId
        
        // Information to write likes back to list when users like
        // a row
        destVC.delegate = self
        destVC.selectedIndex = myRow!.row
        
        // Get display information
        let url = URL(string: place.displayImg)
        if (url != nil) {
            if let data = try? Data(contentsOf: url!)
            {
                destVC.displayPicture = UIImage(data: data)!
            }
        } else {
            destVC.displayPicture = UIImage(named: "Default")!
        }
        
        // Create appropriate address
        var addr = "";
        if (place.address.display_address!.count > 0) {
            var j = 0;
            for line in place.address.display_address! {
                if (j < place.address.display_address!.count - 1) {
                    addr += line + "\n"
                } else {
                    addr += line
                }
                j += 1
            }
        } else {
            if (!place.address.address1!.isEmpty) {
                addr += place.address.address1! + "\n"
            }
            if (!place.address.address2!.isEmpty) {
                addr += place.address.address2! + "\n"
            }
            if (!place.address.address3!.isEmpty) {
                addr += place.address.address3! + "\n"
            }
            if (!place.address.city!.isEmpty) {
                addr += place.address.city! + ", "
            }
            addr += "NC"
            if (!place.address.zip_code!.isEmpty) {
                addr += "\n" + place.address.zip_code!
            }
        }
        destVC.addressText = addr
        destVC.isSaved = place.saved
    }
    
    func update(index i: Int, status saved: Bool) {
        placesList.remove(at:i)
        print("Reloading liked places in profile after user has unliked a place")
        DispatchQueue.main.async {[weak self] in
            self?.likedPlaces.reloadData()
        }
    }
}
