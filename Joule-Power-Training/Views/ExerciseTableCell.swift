//
//  ExerciseTableCell.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/23/22.
//

import UIKit

class ExerciseTableCell: UITableViewCell {

    @IBOutlet weak var exerciseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
