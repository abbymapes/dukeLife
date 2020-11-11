//
//  userProfileViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/25/20.
//

import UIKit
import Firebase
import FirebaseAuth

/*
 Class to view other user's profiles
 */
class userProfileViewController: UIViewController {
    @IBOutlet weak var likedPlaces: UITableView!
    @IBOutlet weak var userName: UILabel!
    
    var name = ""
    var userId = ""
    
    // Replaced with current userId once we set up log in
    var currentUserId = ""
    var currentUsername = ""
    
    var placesList = [Place]()
    var idList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likedPlaces.delegate = self
        likedPlaces.dataSource = self
        userName.text = name
        loadLikedPlaces()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadLikedPlaces() {
        self.placesList.removeAll()
        self.idList.removeAll()
        let db = Firestore.firestore()
        var likedIds = [String]()
        // Get all place Ids for the user who's profile was clicked on likes
        db.collection("likes").whereField("userId", isEqualTo: self.userId).order(by: "time", descending: true).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        likedIds.append(document.data()["placeId"] as! String)
                    }
                    let totalLikes = likedIds.count
                    var i = 1
                    
                    // Go through each like ID and get information about the place to make a Place object
                    for id in likedIds {
                        let docRef = db.collection("places").document(id)
                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                let id = document.documentID
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
                                    
                                    if (i == totalLikes) {
                                        if self.placesList.count > 0 {
                                            print("Reloading liked places for user's profile \(self.placesList.count)")
                                            DispatchQueue.main.async {[weak self] in
                                                self?.likedPlaces.reloadData()
                                            }
                                        } else {
                                            print("User does not like any places")
                                        }
                                    }
                                    i += 1
                                }
                            } else {
                                print("Document with docID in likes relation does not exist")
                            }
                        }
                    }
                }
        }
    }
}

extension userProfileViewController: UITableViewDataSource, UITableViewDelegate, PlaceDetailViewControllerDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placesList.count;
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let db = Firestore.firestore()
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! placeTableViewCell
        
        cell.name.text = "\(self.placesList[indexPath.row].name)"
        cell.likeCount.text = "\(self.placesList[indexPath.row].likeCount)"
        
        // Set appropriate like icon for user based on if they like the place
        db.collection("likes").whereField("placeId", isEqualTo: self.placesList[indexPath.row].docId)
            .whereField("userId", isEqualTo: self.currentUserId).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting likes for place: \(err)")
                } else {
                    var count = 0;
                    for document in querySnapshot!.documents {
                        count += 1;
                    }
                    if (count > 0) {
                        cell.likeButton.image = UIImage(systemName: "heart.fill")
                    } else {
                        cell.likeButton.image = UIImage(systemName: "heart")
                    }
                }
        }
        return cell
    }

    // MARK: - Navigation to Place Information
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            let destVC = segue.destination as! studentPlaceDetailViewController
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
            // Set like icon for page
            let selectedCell = likedPlaces!.cellForRow(at: myRow!) as! placeTableViewCell
            var liked = true
            if (selectedCell.likeButton.image == UIImage(systemName: "heart")) {
                liked = false
            }
            destVC.isLiked = liked
    }
    
    /*
     * When a user likes a place from the page, this function is called to update the like count for the cell in the TableView
     */
    func update(index i: Int, count likeNum: NSNumber) {
        print("Liked index in detail: \(i)")
        placesList[i].likeCount = likeNum
        print("Reloading like count of table view after user has liked a place")
        DispatchQueue.main.async {[weak self] in
            self?.likedPlaces.reloadData()
        }
    }
    
    func showAlert(message:String)
    {
    let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true)
    }
}
