//
//  studentPlaceDetailViewController.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/23/20.
//

import UIKit

class studentPlaceDetailViewController: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBOutlet weak var url: UITextView!
    @IBOutlet weak var phoneNumber: UITextView!
    
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var commentInput: UITextField!
    @IBAction func likeButton(_ sender: UIButton) {
        print("button clicked")
        print(sender.currentImage == UIImage(systemName: "heart"))
        if (sender.currentImage == UIImage(systemName: "heart")) {
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else if (sender.currentImage == UIImage(systemName: "heart.fill")) {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
    }
    var docId = "";
    var nameText = "";
    var addressText = "";
    var likeCountText = "";
    var phoneNumberText = "";
    var urlText = "";
    var displayPicture: UIImage = UIImage(named: "Default")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.name.text = nameText
        self.address.text = addressText
        self.likeCount.text = likeCountText
        self.phoneNumber.text = phoneNumberText
        self.url.text = urlText
        self.displayImage.image = displayPicture
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
