//
//  ListTaskCell.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/9.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

class ListTaskCell: UITableViewCell {


    @IBOutlet weak var finishTaskButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskTagLabel: UILabel!
    @IBOutlet weak var scheduleImageView: UIImageView!
    @IBOutlet weak var scheduleInfoLabel: UILabel!
    
    var finishButtonAction: ((Any) -> Void)?
    
    @IBAction func finishTask(_ sender: Any) {
        self.finishButtonAction?(sender)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
