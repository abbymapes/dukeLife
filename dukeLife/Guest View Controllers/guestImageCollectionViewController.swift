//
//  guestImageCollectionViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 11/3/20.
//

import UIKit
import Firebase

private let reuseIdentifier = "pictureCell"

class guestImageCollectionViewController: UICollectionViewController {
    var placeId = ""
    var currentUserId = ""
    var imageURLS: [String] = []
    var images : [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getImages()
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    func getImages(){
        let db = Firestore.firestore()
        db.collection("images").whereField("placeId", isEqualTo: placeId).getDocuments(){
            (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        // Add each unique place to placeList as a Place object
                        for document in querySnapshot!.documents {
                            if (document.data()["imageUrl"] != nil){
                                let urlString = document.data()["imageUrl"] as! String
                                self.imageURLS.append(urlString)
                                let url = URL(string: urlString)
                                if (url != nil) {
                                    if let data = try? Data(contentsOf: url!)
                                    {
                                        self.images.append(UIImage(data: data)!)
                                    }
                                } else {
                                    self.images.append(UIImage(named: "Default")!)
                                }
                            }
                        }
                        print("Reloading photos")
                        DispatchQueue.main.async {[weak self] in
                            self?.collectionView.reloadData()
                        }
                    }
                            
        }
    }
            
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        cell.image?.image = images[indexPath.row]
        return cell
    }
    

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            self.performSegue(withIdentifier: "singleImageSegue", sender: indexPath)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "singleImageSegue"{
            let selectedIndexPath = sender as? NSIndexPath
            let vc = segue.destination as! ScrollViewController
            vc.imgs = images
            vc.index = selectedIndexPath!.row
        }
    }
    

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
