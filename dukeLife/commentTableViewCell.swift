//
//  commentTableViewCell.swift
//  dukeLife
//
//  Created by Abby Mapes on 10/25/20.
//

import UIKit

class commentTableViewCell: UITableViewCell {

    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sizeToFit()
        layoutIfNeeded()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
