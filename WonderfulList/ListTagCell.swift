//
//  ListTagCell.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/5.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

class ListTagCell: UITableViewCell {

    @IBOutlet weak var listTagImage: UIImageView!
    @IBOutlet weak var listTagLabel: UILabel!
    @IBOutlet weak var taskCountLabel: UILabel!
    
    var tagId: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
