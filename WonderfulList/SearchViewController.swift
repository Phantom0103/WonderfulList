//
//  SearchViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/25.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        let cancelButton = searchBar.value(forKey: "cancelButton") as! UIButton
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.isEnabled = true
    }

}
