//
//  GuideContentViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/4/3.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

class GuideContentViewController: UIViewController {

    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var guideImageView: UIImageView!
    
    var pageIndex = 0
    var guideTitle = ""
    var guideImage = ""
    var bgColor: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guideLabel.text = guideTitle
        guideImageView.image = UIImage(named: guideImage)
        self.view.backgroundColor = bgColor
    }

}
