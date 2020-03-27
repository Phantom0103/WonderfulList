//
//  SearchViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/25.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: CustomTableView!
    
    let realm = try! Realm()
    var searchResults: Results<ListTask>?
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func cancelSearch(_ sender: Any) {
        searchBar.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    func finishTask(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ListTaskCell
        if let task = searchResults?[indexPath.row] {
            try? realm.write {
                if task.finished {
                    task.finished = false
                    task.updateTime = Date.init()
                    
                    cell.finishTaskButton.setImage(UIImage(named: "action-unfinish"), for: .normal)
                    cell.taskLabel.attributedText = nil
                    cell.taskLabel.text = task.taskName
                } else {
                    task.finished = true
                    task.updateTime = Date.init()
                    
                    cell.finishTaskButton.setImage(UIImage(named: "action-finish"), for: .normal)
                    let attributedText = NSAttributedString(string: task.taskName, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                    cell.taskLabel.attributedText = attributedText
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = realm.objects(ListTask.self).filter("archived = false AND taskName CONTAINS %@", searchBar.text!)
        tableView.reloadData()
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = nil
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchTaskSegue" {
            let vc = segue.destination as! TaskViewController
            vc.delegate = self
            
            let cell = sender as! ListTaskCell
            let indexPath = tableView.indexPath(for: cell)!
            selectedIndexPath = indexPath
            vc.task = searchResults![indexPath.row]
            vc.tagId = searchResults![indexPath.row].tagId
            vc.isUpdate = true
            
            let backItem = UIBarButtonItem(title: "搜索", style: .plain, target: self, action: nil)
            self.navigationItem.backBarButtonItem = backItem
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListTaskCell", for: indexPath) as! ListTaskCell
        
        // 不同tag下的任务显示不同，参考Trello
        if let tasks = searchResults {
            let task = tasks[indexPath.row]
            if task.finished {
                cell.finishTaskButton.setImage(UIImage(named: "action-finish"), for: .normal)
                let attributedText = NSAttributedString(string: task.taskName, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                cell.taskLabel.attributedText = attributedText
            } else {
                cell.finishTaskButton.setImage(UIImage(named: "action-unfinish"), for: .normal)
                cell.taskLabel.text = task.taskName
            }
            
            if task.today && task.important {
                cell.taskTagLabel.text = "新的一天·重要"
            } else if task.today {
                cell.taskTagLabel.text = "新的一天"
            } else if task.important {
                cell.taskTagLabel.text = "重要"
            } else {
                cell.taskTagLabel.text = "事项"
            }
            
            if task.schedule {
                let scheduleTime = task.scheduleTime!
                cell.scheduleInfoLabel.text = CustomUtils.dateToString(date: scheduleTime, formatter: .formatter1)
                let expired = !task.finished && ((scheduleTime.compare(Date.init()).rawValue) < 0)
                if expired {
                    cell.scheduleImageView.image = UIImage(named: "icon-time-red-15")
                    cell.scheduleInfoLabel.textColor = UIColor.red
                } else {
                    cell.scheduleImageView.image = UIImage(named: "icon-time-15")
                }
            } else {
                cell.scheduleImageView.isHidden = true
                cell.scheduleInfoLabel.isHidden = true
            }
            
            cell.finishButtonAction = {sender in
                self.finishTask(indexPath: indexPath)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SearchViewController: TaskViewDelegate {
    
    func didAddTask(taskName: String, important: Bool, schedule: Bool, scheduleTime: Date) {
        
    }
    
    func didUpdateTask(taskName: String, important: Bool, schedule: Bool, scheduleTime: Date) {
        
    }
    
    func didFinishTask(taskId: Int) {
        
    }
    
    func didDeleteTask(taskId: Int) {
        
    }
    
    func didArchiveTask(taskId: Int) {
        
    }
    
    
}
