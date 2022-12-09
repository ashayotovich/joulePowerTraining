//
//  AthleteTableCell.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/24/22.
//

import UIKit

class AthleteTableCell: UITableViewCell {

    @IBOutlet weak var athleteHeadshot: UIImageView!
    @IBOutlet weak var athleteNameLabel: UILabel!
    @IBOutlet weak var availableSetsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        athleteHeadshot.asCircle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
