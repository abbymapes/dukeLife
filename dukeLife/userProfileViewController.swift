//
//  userProfileViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/25/20.
//

import UIKit
import Firebase

class userProfileViewController: UIViewController {

    @IBOutlet weak var likedPlaces: UITableView!
    @IBOutlet weak var userName: UILabel!
    
    var name = ""
    var userId = ""
    var currentId = "tester"
    
    var placesList = [Place]()
    var namesList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        likedPlaces.delegate = self
        likedPlaces.dataSource = self
        userName.text = name
        loadLikedPlaces()
        // Do any additional setup after loading the view.
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
        self.namesList.removeAll()
        let db = Firestore.firestore()
        var likedIds = [String]()
        // Set like icon for user
        db.collection("likes").whereField("userId", isEqualTo: self.userId).order(by: "time", descending: true).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        likedIds.append(document.data()["placeId"] as! String)
                    }
                    
                    
                    let totalLikes = likedIds.count
                    var i = 1
                    
                    for id in likedIds {
                        let docRef = db.collection("places").document(id)

                        docRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                
                                let name = document.data()!["name"] as! String
                                
                                if (!self.namesList.contains(name)) {
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
                                    self.namesList.append(name)
                                    self.placesList.append(placeToDisplay)
                                    
                                    if (i == totalLikes) {
                                        if self.placesList.count > 0 {
                                            print("reloading data \(self.placesList.count)")
                                            DispatchQueue.main.async {[weak self] in
                                                self?.likedPlaces.reloadData()
                                            }
                                        } else {
                                            print("not reloading data")
                                        }
                                    }
                                    i += 1
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                }
        }
    }
}

extension userProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placesList.count;
   }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let db = Firestore.firestore()

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! placeTableViewCell
        
    cell.name.text = "\(self.placesList[indexPath.row].name)"
    
        cell.likeCount.text = "\(self.placesList[indexPath.row].likeCount)"
        
        // Set like icon for user
    db.collection("likes").whereField("placeId", isEqualTo: self.placesList[indexPath.row].docId)
            .whereField("userId", isEqualTo: self.currentId).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
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


    // MARK: - Navigation to Recipe List
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destVC = segue.destination as! studentPlaceDetailViewController
        let myRow = likedPlaces!.indexPathForSelectedRow
        let place = placesList[myRow!.row]
        
        // Pass the selected object to the new view controller.
        destVC.docId = place.docId
        destVC.nameText = place.name
        destVC.likeCountText = "\(place.likeCount)"
        destVC.urlText = place.url
        destVC.phoneNumberText = place.phoneNum

        let url = URL(string:place.displayImg)
        if (url != nil) {
            if let data = try? Data(contentsOf: url!)
            {
                destVC.displayPicture = UIImage(data: data)!
            }
        } else {
            destVC.displayPicture = UIImage(named: "Default")!
        }
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
        
        let selectedCell = likedPlaces!.cellForRow(at: myRow!) as! placeTableViewCell
        
        var liked = true
        if (selectedCell.likeButton.image == UIImage(systemName: "heart")) {
            liked = false
        }
        destVC.isLiked = liked
    }
}
