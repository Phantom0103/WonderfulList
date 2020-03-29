//
//  ArchivedViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/28.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit
import RealmSwift

class ArchivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var archivedTasks: Results<ListTask>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        archivedTasks = realm.objects(ListTask.self).filter("archived = true")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedTasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArchivedTaskCell", for: indexPath) as! ArchivedTaskCell
        
        if let tasks = archivedTasks {
            let task = tasks[indexPath.row]
            cell.taskLabel.text = task.taskName
            
            if task.important {
                cell.taskTagLabel.text = "重要"
            } else if task.tagId < 10 {
                cell.taskTagLabel.text = "事项"
            } else {
                cell.taskTagLabel.text = "我的清单"
            }
            
            cell.taskFinishedLabel.isHidden = !task.finished
            cell.archiveTimeLabel.text = CustomUtils.dateToString(date: task.updateTime, formatter: .formatter4)
        }
        
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        archivedTasks = realm.objects(ListTask.self).filter("archived = true AND taskName CONTAINS %@", searchBar.text!)
        tableView.reloadData()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            archivedTasks = realm.objects(ListTask.self).filter("archived = true")
            tableView.reloadData()
            
            // 让用户界面主线程上执行，也就是优先执行，经常用于使UI方面的操作提前执行，让用户体验变好
            DispatchQueue.main.async {
                // searchBar失去焦点
                searchBar.resignFirstResponder()
            }
        }
    }
}
