//
//  studentPlaceDetailViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase

/*
 * Delegate to pass like information back to TableView when user has liked a place
 */
protocol PlaceDetailViewControllerDelegate: AnyObject {
    func update(index i: Int, count likeNum: NSNumber)
}

class studentPlaceDetailViewController: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var url: UITextView!
    @IBOutlet weak var phoneNumber: UITextView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var commentInput: UITextField!
    @IBOutlet weak var commentTableView: UITableView!
    
    // Replace with current user id when auth is set up
    var currentUserId = "test"
    
    weak var delegate: PlaceDetailViewControllerDelegate?
    var comments = [Comment]();
    var docId = "";
    var nameText = "";
    var addressText = "";
    var likeCountText = "";
    var phoneNumberText = "";
    var urlText = "";
    var selectedIndex = 0;
    @IBOutlet weak var likeImage: UIButton!
    var displayPicture: UIImage = UIImage(named: "Default")!
    var isLiked = false;
    
    // Implement like button to add like to database and change appearance when places are liked or unliked
    // Updates information in TableView of Map Scene via delegate.update method
    @IBAction func likeButton(_ sender: UIButton) {
        let oldCount = (likeCount.text as! NSString).integerValue
        if (sender.currentImage == UIImage(systemName: "heart")) {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likePlace()
            likeCountText = "\(oldCount + 1)"
            likeCount.text = "\(oldCount + 1)"
            
            delegate?.update(index: self.selectedIndex, count: NSNumber(value: oldCount + 1))
        } else if (sender.currentImage == UIImage(systemName: "heart.fill")) {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            unlikePlace()
            
            if (oldCount != 0) {
                likeCountText = "\(oldCount - 1)"
                likeCount.text = "\(oldCount - 1)"
                delegate?.update(index: self.selectedIndex, count: NSNumber(value: oldCount - 1))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        commentTableView.delegate = self
        commentTableView.dataSource = self
        self.name.text = nameText
        self.address.text = addressText
        self.likeCount.text = likeCountText
        self.phoneNumber.text = phoneNumberText
        self.url.text = urlText
        self.displayImage.image = displayPicture
        loadComments();
        
        if (isLiked) {
            likeImage.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeImage.setImage(UIImage(systemName: "heart"), for: .normal)
        }
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
     * Loads comments for a place from the database to be displayed in comment section
     */
    func loadComments() {
        let db = Firestore.firestore()
        // Queries all comments in database for current place ID ordered by time
        db.collection("comments").whereField("placeId", isEqualTo: self.docId).order(by: "time", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting comment documents: \(err)")
                } else {
                    self.comments.removeAll()
                    for document in querySnapshot!.documents {
                        // Create comment object and add it to the list of comments to be displayed
                        let netId = document.data()["netId"] as! String
                        let userId = document.data()["userId"] as! String
                        let comment = document.data()["comment"] as! String
                        let commentToAdd = Comment.init(text: comment, netId: netId, userId: userId, commentId: document.documentID, placeId: self.docId)!
                        self.comments.append(commentToAdd);
                    }
                    // If there are comments for a post, load the comments
                    if self.comments.count > 0 {
                        print("Reloading comment table view to show comments")
                        DispatchQueue.main.async {[weak self] in
                            self?.commentTableView.reloadData()
                        }
                    } else {
                        print("No comments in database, so not reloading comment table view")
                    }
                }
        }
    }
    
    /*
     * Adds a like to the database for current user ID and current place ID if user doesn't already like the place
     */
    func likePlace() {
        let db = Firestore.firestore()
        // Double check if user has already liked the place
        var storedLikes = 0;
        db.collection("likes").whereField("placeId", isEqualTo: self.docId)
            .whereField("userId", isEqualTo: self.currentUserId).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        storedLikes += 1
                    }
                }
            }
        // If the user doesn't already like this place, add a new Like document to the database with placeID, time, and userId attributes
        if (storedLikes == 0) {
            // Get time
            let timestamp = NSDate().timeIntervalSince1970
            let myTimeInterval = TimeInterval(timestamp)
            let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
            
            db.collection("likes").document().setData([
                "placeId": self.docId,
                "time": time,
                "userId": self.currentUserId
            ]) { err in
                if let err = err {
                    print("Error writing like document: \(err)")
                } else {
                    print("Like successfully written!")
                }
            }
            
            // Increment place's like count in the database
            let docRef = db.collection("places").document(self.docId)

            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let placeDocument: DocumentSnapshot
                do {
                    try placeDocument = transaction.getDocument(docRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }

                guard let oldLikeCount = placeDocument.data()?["likeCount"] as? Int else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(placeDocument)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                transaction.updateData(["likeCount": oldLikeCount + 1], forDocument: docRef)
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Increment in likeCount failed: \(error)")
                } else {
                    print("Increment in likeCount successfully committed!")
                }
            }
        }
    }
    
    /*
     * Deletes a like to the database for current user ID and current place ID if user unlikes the place
     */
    func unlikePlace() {
        let db = Firestore.firestore()
        
        // finds like for placeId and current user in database and deltes it
        db.collection("likes").whereField("placeId", isEqualTo: self.docId)
            .whereField("userId", isEqualTo: self.currentUserId).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting like documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        db.collection("likes").document(document.documentID).delete() { err in
                            if let err = err {
                                print("Error removing like document: \(err)")
                            } else {
                                print("Like was successfully removed!")
                            }
                        }
                    }
                }
            }
        
        // Decrement like count for place
        let docRef = db.collection("places").document(self.docId)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let placeDocument: DocumentSnapshot
            do {
                try placeDocument = transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard let oldLikeCount = placeDocument.data()?["likeCount"] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(placeDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            var newLikeCount = 0;
            if (oldLikeCount > 0) {
                newLikeCount = oldLikeCount - 1
            }
            transaction.updateData(["likeCount": newLikeCount], forDocument: docRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Decrementing like count for place during an unlike has failed: \(error)")
            } else {
                print("Decrementing like count during unlike successfully committed!")
            }
        }
    }
}

/*
 * Set up table view for list of comments for the place
 */
extension studentPlaceDetailViewController: UITableViewDataSource, UITableViewDelegate {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count;
   }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! commentTableViewCell
        
        cell.comment.text = "\(comments[indexPath.row].netId): \(comments[indexPath.row].text)"
        return cell
    }


    // MARK: - Navigation to User Profile
    // Directs to the user who wrote the comment's profile
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destVC = segue.destination as! userProfileViewController
        let myRow = commentTableView!.indexPathForSelectedRow
        let comment = comments[myRow!.row]
        
        let selectedNetId = comment.netId
        let selectedUser = comment.userId
        
        // Pass the selected object to the new view controller.
        destVC.name = selectedNetId
        destVC.userId = selectedUser
    }
}
