//
//  guestMapViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/26/20.
//

import UIKit
import Firebase

class guestMapViewController: UIViewController {
    // placeList contains all places that match selected type
    // idsInList ensures that unique places are displayed from database
    var placeList = [Place]()
    var idsInList = [String]()
    
    // placesDisplayed contains the current 10 places displayed, to be mapped on the map
    var placesDisplayed = [Place]()
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    // Determines selected type of places to display
    var selectedType = ""
    var types = ["Food": "food", "Bars":"bars", "Fun": "fun", "Coffee": "coffee"]
    @IBAction func typeSelector(_ sender: UISegmentedControl) {
        selectedType = types[sender.titleForSegment(at: sender.selectedSegmentIndex)!]!
        loadPlaces()
    }
    
    // Keeps track of current places displayed on page
    var currentStartIndex = 0
    var currentEndIndex = 0
    var totalPlaces = 0
    
    // Replace with current user ID when auth is set up
    var currentUserId = "guest"
    var currentUsername = "John Doe"
    
    // Page buttons for results
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
    @IBAction func nextPageButton(_ sender: Any) {
        getNextPage()
    }
    
    @IBAction func previousPageButton(_ sender: Any) {
        getPrevPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        if (selectedType.isEmpty) {
            selectedType = "food"
        }
        loadPlaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPlaces()
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
        // Connect to database
        let db = Firestore.firestore()
        
        // Query all places for selected type
        db.collection("places").whereField("type", isEqualTo: selectedType).order(by: "likeCount", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    // Empty previous places displayed
                    self.idsInList.removeAll()
                    self.placeList.removeAll()
                    
                    // Add each unique place to placeList as a Place object
                    for document in querySnapshot!.documents {
                        let id = document.documentID
                        if (!self.idsInList.contains(id)) {
                            let name = document.data()["name"] as! String
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
                            self.idsInList.append(id)
                            self.placeList.append(placeToDisplay);
                        }
                    }
                    // If there are results, display the first 10 of them
                    // Set currentStartIndex to 0
                    // Set currentEndIndex to min(totalPlaces, 9)
                    if self.placeList.count > 0 {
                        var i = 0
                        self.currentStartIndex = 0
                        self.totalPlaces = self.placeList.count
                        // Removes previous places displayed
                        self.placesDisplayed.removeAll()
                        for place in self.placeList {
                            if (i < 10) {
                                self.placesDisplayed.append(place)
                                i += 1
                            } else {
                                self.currentEndIndex = i - 1
                                break
                            }
                        }
                        // sets page buttons if there are more or previous results
                        self.setPageButtonsDisplay()
                        
                        print("Loading initial data from start index: \(self.currentStartIndex) to end index: \(self.currentEndIndex) for \(self.selectedType) category")
                        DispatchQueue.main.async {[weak self] in
                            self?.resultsTableView.reloadData()
                            let indexPath = NSIndexPath(row: 0, section: 0)
                            self?.resultsTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
                        }
                    } else {
                        print("No initial results returned from query")
                    }
                }
        }
    }
    
    /*
     * Loads next 10 pages to be displayed from placesList
     */
    func getNextPage() {
        // Remove current displayed places
        self.placesDisplayed.removeAll()
        // Increment indices
        self.currentStartIndex = self.currentEndIndex + 1
        self.currentEndIndex = self.currentStartIndex + 9
        for i in self.currentStartIndex ..< self.currentEndIndex + 1 {
            if (i < self.totalPlaces) {
                placesDisplayed.append(placeList[i])
            } else {
                // If less than 10 results to display, set currentEndIndex appropriately
                self.currentEndIndex = i - 1
                break
            }
        }
        // Reset page buttons
        setPageButtonsDisplay()
        print("Reloading next page of data from index \(self.currentStartIndex) to index \(self.currentEndIndex)")
        DispatchQueue.main.async {[weak self] in
            self?.resultsTableView.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 0)
            self?.resultsTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
    }
    
    /*
     * Loads previous 10 pages to be displayed from placesList
     */
    func getPrevPage() {
        // Loads previous 10 places to be displayed
        self.placesDisplayed.removeAll()
        self.currentStartIndex = self.currentStartIndex - 10
        for i in self.currentStartIndex ..< self.currentStartIndex + 10 {
            if (i >= 0) {
                placesDisplayed.append(placeList[i])
            }
        }
        self.currentEndIndex = self.currentStartIndex + 9
        setPageButtonsDisplay()
        print("Reloading previous page of data from index \(self.currentStartIndex) to index \(self.currentEndIndex)")
        DispatchQueue.main.async {[weak self] in
            self?.resultsTableView.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 0)
            self?.resultsTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
    }
    
    /*
     * Sets next and previous buttons if there are more or previous results to display
     */
    func setPageButtonsDisplay() {
        if (self.currentStartIndex == 0) {
            self.prevButton.isHidden = true;
        } else {
            self.prevButton.isHidden = false;
        }
        
        if (self.currentEndIndex + 1 < self.totalPlaces) {
            self.nextButton.isHidden = false;
        } else {
            self.nextButton.isHidden = true;
        }
    }
}

/*
 * Set up table view for list of places
 */
extension guestMapViewController: UITableViewDataSource, UITableViewDelegate, GuestPlaceDetailViewControllerDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placesDisplayed.count;
   }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! placeTableViewCell
        
        // Set name and like count for cell
        cell.name.text = "\(self.currentStartIndex + indexPath.row + 1). \(placesDisplayed[indexPath.row].name)"
        cell.likeCount.text = "\(placesDisplayed[indexPath.row].likeCount)"
    
        // Set saved button for user
        var saved = false
        let db = Firestore.firestore()
        db.collection("savedPlaces").whereField("placeId", isEqualTo: placesDisplayed[indexPath.row].docId)
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
                        self.placesDisplayed[indexPath.row].setSavedStatus(saved)
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
        let myRow = resultsTableView!.indexPathForSelectedRow
        let place = placesDisplayed[myRow!.row]
        
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
        destVC.selectedIndex = self.currentStartIndex + myRow!.row
        
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
        print("Saved/unsaved index in detail: \(i)")
        placeList[i].saved = saved
        placesDisplayed[i - self.currentStartIndex].saved = saved
        
        print("Reloading like count of table view after user has saved a place")
        DispatchQueue.main.async {[weak self] in
            self?.resultsTableView.reloadData()
            let indexPath = NSIndexPath(row: 0, section: 0)
            self?.resultsTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        }
    }
}
