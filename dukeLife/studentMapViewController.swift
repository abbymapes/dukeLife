//
//  studentMapViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase

class studentMapViewController: UIViewController {
    var placeList = [Place]()
    var namesDisplayed = [String]()
    var selectedType = ""
    var types = ["Food": "food", "Bars":"bars", "Fun": "fun", "Coffee": "coffee"]
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBAction func typeSelector(_ sender: UISegmentedControl) {
        print("\(sender.titleForSegment(at: sender.selectedSegmentIndex)!)")
        selectedType = types[sender.titleForSegment(at: sender.selectedSegmentIndex)!]!
        loadPlaces()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        if (selectedType.isEmpty) {
            selectedType = "food"
        }
        loadPlaces()
        //resultsTableView.reloadData()
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
    func loadPlaces() {
        let db = Firestore.firestore()
        db.collection("places").whereField("type", isEqualTo: selectedType).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.namesDisplayed.removeAll()
                    self.placeList.removeAll()
                    for document in querySnapshot!.documents {
                        print(document.data()["name"]!)
                        let name = document.data()["name"] as! String
                        
                        if (!self.namesDisplayed.contains(name)) {
                            let address = Address.init(
                                address1: document.data()["address1"] as! String,
                                address2: document.data()["address2"] as! String,
                                address3: document.data()["address3"] as! String,
                                city:document.data()["city"] as! String,
                                zip_code:document.data()["zip_code"] as! String,
                                state:document.data()["state"] as! String,
                                display_address: document.data()["display_address"] as! [String]
                                )!
                            let placeToDisplay = Place.init(
                                id: document.data()["id"] as! String,
                                name: name,
                                displayImg: document.data()["displayImg"] as! String,
                                url: document.data()["url"] as! String,
                                phoneNum: document.data()["phoneNum"] as! String,
                                address: address,
                                coords: Coordinates.init(
                                    latitude: document.data()["latitude"] as! NSNumber,
                                    longitude: document.data()["longitude"] as! NSNumber)!,
                                docId: document.documentID,
                                likeCount: document.data()["likeCount"] as! NSNumber)!
                            self.namesDisplayed.append(name)
                            self.placeList.append(placeToDisplay);
                        }
                    }
                    if self.placeList.count > 0 {
                        print("reloading data")
                        DispatchQueue.main.async {[weak self] in
                            self?.resultsTableView.reloadData()
                        }
                    } else {
                        print("not reloading data")
                    }
                }
        }
    }
}

extension studentMapViewController: UITableViewDataSource, UITableViewDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placeList.count;
   }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! placeTableViewCell
        
    cell.name.text = "\(indexPath.row + 1). \(placeList[indexPath.row].name)"
        cell.likeCount.text = "\(placeList[indexPath.row].likeCount)"
        //cell.likeButton.image = heart.fill

        return cell
    }
    
    // MARK: - Navigation to Recipe List
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destVC = segue.destination as! studentPlaceDetailViewController
        let myRow = resultsTableView!.indexPathForSelectedRow
        let place = placeList[myRow!.row]
        
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
    }
}
