//
//  ArchiveTaskCell.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/28.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

class ArchivedTaskCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskTagLabel: UILabel!
    @IBOutlet weak var taskFinishedLabel: UILabel!
    @IBOutlet weak var archiveTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
