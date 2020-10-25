//
//  studentPlaceDetailViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit
import Firebase

class studentPlaceDetailViewController: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var url: UITextView!
    @IBOutlet weak var phoneNumber: UITextView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var commentInput: UITextField!
    @IBOutlet weak var commentTableView: UITableView!
    
    var currentUserId = "test"
    var comments = [Comment]();
    var docId = "";
    var nameText = "";
    var addressText = "";
    var likeCountText = "";
    var phoneNumberText = "";
    var urlText = "";
    @IBOutlet weak var likeImage: UIButton!
    var displayPicture: UIImage = UIImage(named: "Default")!
    var isLiked = false;
    
    @IBAction func likeButton(_ sender: UIButton) {
        let oldCount = (likeCount.text as! NSString).integerValue
        if (sender.currentImage == UIImage(systemName: "heart")) {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likePlace()
            likeCountText = "\(oldCount + 1)"
            likeCount.text = "\(oldCount + 1)"
            
 
        } else if (sender.currentImage == UIImage(systemName: "heart.fill")) {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            unlikePlace()
            if (oldCount != 0) {
                likeCountText = "\(oldCount - 1)"
                likeCount.text = "\(oldCount - 1)"
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
    
    func loadComments() {
        let db = Firestore.firestore()
        db.collection("comments").whereField("placeId", isEqualTo: self.docId).order(by: "time", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting comment documents: \(err)")
                } else {
                    self.comments.removeAll()
                    for document in querySnapshot!.documents {
                        let netId = document.data()["netId"] as! String
                        let userId = document.data()["userId"] as! String
                        let comment = document.data()["comment"] as! String
                        let commentToAdd = Comment.init(text: comment, netId: netId, userId: userId, commentId: document.documentID, placeId: self.docId)!
                        self.comments.append(commentToAdd);
                        print(commentToAdd.text)
                    }
                    if self.comments.count > 0 {
                        print("reloading data")
                        DispatchQueue.main.async {[weak self] in
                            self?.commentTableView.reloadData()
                        }
                    } else {
                        print("not reloading data")
                    }
                }
        }
    }
        
    func likePlace() {
        let db = Firestore.firestore()
        
        // check if already liked
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
                    print("Error writing document: \(err)")
                } else {
                    print("Like successfully written!")
                }
            }
            
            // Increment like count
            
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

                // Note: this could be done without a transaction
                //       by updating the population using FieldValue.increment()
                transaction.updateData(["likeCount": oldLikeCount + 1], forDocument: docRef)
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error)")
                } else {
                    print("Transaction successfully committed!")
                }
            }
        }
    }
    
    func unlikePlace() {
        let db = Firestore.firestore()
        
        db.collection("likes").whereField("placeId", isEqualTo: self.docId)
            .whereField("userId", isEqualTo: self.currentUserId).getDocuments(){ (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        db.collection("likes").document(document.documentID).delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                    }
                }
            }
        
        // Decrement like count
        
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

            // Note: this could be done without a transaction
            //       by updating the population using FieldValue.increment()
            var newLikeCount = 0;
            if (oldLikeCount > 0) {
                newLikeCount = oldLikeCount - 1
            }
            transaction.updateData(["likeCount": newLikeCount], forDocument: docRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
}

extension studentPlaceDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cell count \(self.comments.count)")
        return self.comments.count;
   }
    
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! commentTableViewCell
        
        cell.comment.text = "\(comments[indexPath.row].netId): \(comments[indexPath.row].text)"
        print(cell.comment.text!);
        return cell
    }


    // MARK: - Navigation to Recipe List
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
