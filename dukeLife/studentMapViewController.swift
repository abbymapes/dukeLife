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
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBAction func typeSelector(_ sender: UISegmentedControl) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        loadPlaces()
        resultsTableView.reloadData()
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
        db.collection("places")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
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
                                docId: document.documentID)!
                            
                            print(placeToDisplay)
                            self.namesDisplayed.append(name)
                            self.placeList.append(placeToDisplay);
                        }
                    }
                }
        }
        if self.placeList.count > 0 {
            DispatchQueue.main.async {[weak self] in
                self?.resultsTableView.reloadData()
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
        
        cell.name.text = placeList[indexPath.row].name
        cell.likeCount.text = "0"
        //cell.likeButton.image = heart.fill

        return cell
    }
}
