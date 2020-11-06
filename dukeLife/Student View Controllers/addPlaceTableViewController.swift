//
//  addPlaceTableViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 11/5/20.
//

import UIKit
import Firebase

class addPlaceTableViewController: UITableViewController, UISearchBarDelegate {
    
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
    
    struct businessResponse: Codable {
        var name: String?
        var photos: [String]?
    }
    
    var placeList = [Place]()
    var idsInDatabase = [String]()
    
    var searchString = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadExisitingPlaces()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.placeList.count
    }
    
    func loadExisitingPlaces() {
        let db = Firestore.firestore()
        self.idsInDatabase.removeAll()
        db.collection("places").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let yelpId = document.data()["id"] as! String
                    self.idsInDatabase.append(yelpId)
                }
            }
        }
    }
    
    func loadResults(_ searchString:String) {
        let db = Firestore.firestore()
        let latitude = 36.0014
        let longitude = -78.9382
        let radius = 16093
        let search = searchString.split(separator: " ").joined(separator: "+")
        let apikey = "Q2DSCs_0MgIdnj4RLvlehFC7McfEGtAp8JZi8AYffmqMPCcS7vlpLRNoGixr_bGRKRG3XsOmjb1rlrX_0RpzIHdZG5Mdmom3GgCWyDZn8CJXHrIeQP9S3Q2AbAeTX3Yx"
        let baseURL = "https://api.yelp.com/v3/businesses/search?term=\(search)&latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)"
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
                let apiResult = try decoder.decode(apiResponse.self, from: content)
                let allPlaces = apiResult.businesses
                
                // Parse through recipes to retrieve information
                self.placeList.removeAll()
                for place in allPlaces {
                    if (!self.idsInDatabase.contains(place.id!)){
                        let c = Coordinates.init(latitude: place.coordinates?.latitude as! NSNumber, longitude: place.coordinates?.longitude as! NSNumber)!
                        let placeToAdd = Place.init(id: place.id!, name: place.name!, displayImg: place.image_url!, url: place.url!, phoneNum: place.display_phone!, address: place.location!, coords: c)!
                        self.placeList.append(placeToAdd);
                        print("added \(placeToAdd.name)")
                    }
                    if self.placeList.count > 0 {
                        DispatchQueue.main.async {[weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }
            } catch {
                print("JSON Decode error")
            }
        }
        dataTask.resume()
    }
    
    // Search Bar function
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (!searchBar.text!.isEmpty) {
            self.searchString = searchBar.text!.split(separator: " ").joined(separator: "+")
            loadResults(searchString)
        }
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let db = Firestore.firestore()

        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as! addPlaceTableViewCell
        
        // Set name and like count for cell
        cell.name.text = "\(indexPath.row + 1). \(placeList[indexPath.row].name)"
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destVC = segue.destination as! addDetailViewController
        let myRow = tableView.indexPathForSelectedRow
        let place = placeList[myRow!.row]
        
        // Pass the selected information to the new view controller.
        destVC.place = place
        destVC.nameText = place.name
        destVC.urlText = place.url
        destVC.phoneNumberText = place.phoneNum
        
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
    }
}
