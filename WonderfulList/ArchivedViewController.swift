//
//  ArchivedViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/28.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit
import RealmSwift

class ArchivedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: CustomTableView!
    
    let realm = try! Realm()
    var archivedTasks: Results<ListTask>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
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
}
