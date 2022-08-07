//
//  GroupTableCell.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/22/22.
//

import UIKit

class GroupTableCell: UITableViewCell {

    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var groupCountLabel: UILabel!
    @IBOutlet weak var groupIconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
