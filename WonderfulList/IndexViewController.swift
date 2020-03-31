//
//  IndexViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/5.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit
import RealmSwift

protocol TagTaskCountDelegate {
    func addTask(tagId: Int)
    // 更新任务未完成数量，value：未完成数增加或者减少
    func updateTask(tagId: Int, value: Int)
    func deleteTask(tagId: Int, finished: Bool)
    // 批量删除
    func deleteTasks(dict: [Int : Int])
}

class IndexViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    var defaultTags: [ListTag]?
    var customTags: Results<ListTag>?
    var selectedIndexPath: IndexPath?
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    
    let defaultTagImage = "tag-list"
    var reloadSwitch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // 设置导航栏透明
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tableView.backgroundColor = UIColor.clear
        
        initData()
        print("路径：\(Realm.Configuration.defaultConfiguration.fileURL as Any)")
    }
    
    // 准备数据
    private func initData() {
        initDefaultTagData()
        // 自定义的清单
        customTags = realm.objects(ListTag.self).sorted(byKeyPath: "sort")
    }
    
    private func initDefaultTagData() {
        // 默认清单的主题
        let tagThemeToday = defaults.integer(forKey: UserDefaultsKeys.TagThemeDefault.tagThemeToday)
        let tagThemeImportant = defaults.integer(forKey: UserDefaultsKeys.TagThemeDefault.tagThemeImportant)
        let tagThemeSchedule = defaults.integer(forKey: UserDefaultsKeys.TagThemeDefault.tagThemeSchedule)
        let tagThemeTask = defaults.integer(forKey: UserDefaultsKeys.TagThemeDefault.tagThemeTask)
        
        // 查询未完成任务数量
        let tasksToday = realm.objects(ListTask.self).filter("today = true AND archived = false AND finished = false")
        let tasksImportant = realm.objects(ListTask.self).filter("important = true AND archived = false AND finished = false")
        let tasksSchedule = realm.objects(ListTask.self).filter("schedule = true AND archived = false AND finished = false")
        let tasks = realm.objects(ListTask.self).filter("archived = false AND finished = false")
        
        // 默认的清单
        defaultTags = [
            ListTag(value: ["tagId": 1, "tagImage": "tag-today", "tagName": "新的一天", "tagTheme": tagThemeToday, "unfinishedTaskCount": tasksToday.count]),
            ListTag(value: ["tagId": 2, "tagImage": "tag-important", "tagName": "重要", "tagTheme": tagThemeImportant, "unfinishedTaskCount": tasksImportant.count]),
            ListTag(value: ["tagId": 3, "tagImage": "tag-schedule", "tagName": "制定的计划", "tagTheme": tagThemeSchedule, "unfinishedTaskCount": tasksSchedule.count]),
            ListTag(value: ["tagId": 4, "tagImage": "tag-task", "tagName": "事项", "tagTheme": tagThemeTask, "unfinishedTaskCount": tasks.count])
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if reloadSwitch {
            initDefaultTagData()
            tableView.reloadData()
        } else {
            reloadSwitch = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTagSegue" {
            let vc = segue.destination as! TagViewController
            vc.delegate = self
            vc.taskCountDelegate = self
        } else if segue.identifier == "ShowTagSegue" {
            let vc = segue.destination as! TagViewController
            vc.delegate = self
            vc.taskCountDelegate = self
            vc.isUpdate = true
            
            let cell = sender as! ListTagCell
            let indexPath = tableView.indexPath(for: cell)!
            let row = indexPath.row
            if indexPath.section == 0 {
                let listTag = defaultTags![row]
                vc.tag = listTag
                vc.isDefaultTag = true
            } else {
                let listTag = customTags![row]
                vc.tag = listTag
            }
            
            selectedIndexPath = indexPath
        } else if segue.identifier == "SearchTaskSegue" {
            let vc = segue.destination as! SearchViewController
            vc.taskCountDelegate = self
        } else if segue.identifier == "ArchivedTaskSegue" {
            let vc = segue.destination as! ArchivedViewController
            vc.taskCountDelegate = self
        }
    }
    
    func deleteTag(tag: ListTag, indexPath: IndexPath) {
        var success = true
        do {
            try self.realm.write {
                // 先删除清单下的任务
                let preDeleteTasks = self.realm.objects(ListTask.self).filter("tagId = \(tag.tagId)")
                if !preDeleteTasks.isEmpty {
                    self.realm.delete(preDeleteTasks)
                }
                
                // 删除清单
                self.realm.delete(tag)
            }
        } catch {
            success = false
        }

        if success {
            initDefaultTagData()
            self.tableView.reloadData()
        }
    }
}

extension IndexViewController: TagViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return defaultTags?.count ?? 0
        } else {
            return customTags?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTagCell", for: indexPath) as! ListTagCell
        
        if indexPath.section == 0 {
            if let defaultTags = defaultTags {
                cell.tagId = defaultTags[indexPath.row].tagId
                cell.listTagImage.image = UIImage(named: defaultTags[indexPath.row].tagImage)
                cell.listTagLabel.text = defaultTags[indexPath.row].tagName
                
                let unfinishedTaskCount = defaultTags[indexPath.row].unfinishedTaskCount;
                cell.taskCountLabel.text = unfinishedTaskCount == 0 ? "" : "\(unfinishedTaskCount)"
            }
        } else {
            if let customTags = customTags {
                cell.tagId = customTags[indexPath.row].tagId
                cell.listTagImage.image = UIImage(named: defaultTagImage)
                cell.listTagLabel.text = customTags[indexPath.row].tagName
                
                let unfinishedTaskCount = customTags[indexPath.row].unfinishedTaskCount;
                cell.taskCountLabel.text = unfinishedTaskCount == 0 ? "" : "\(unfinishedTaskCount)"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.01
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 1 {
                let alertController = UIAlertController(title: "注意", message: "这将永久删除清单和清单里的任务", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "好的", style: .default, handler: { (_) in
                    self.deleteTag(tag: self.customTags![indexPath.row], indexPath: indexPath)
                }))
                
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func didAddTag(tagName: String, themeId: Int) {
        try? realm.write {
            var tagId = defaults.integer(forKey: UserDefaultsKeys.RealmPrimaryKey.primaryKeyTag)
            tagId = tagId == 0 ? 10 : tagId
            defaults.set(tagId + 1, forKey: UserDefaultsKeys.RealmPrimaryKey.primaryKeyTag)
            
            let sort = defaults.integer(forKey: UserDefaultsKeys.tagSort)
            defaults.set(sort + 1, forKey: UserDefaultsKeys.tagSort)
            
            let newTag = ListTag(value: ["tagId": tagId, "tagImage": defaultTagImage, "tagName": tagName, "tagTheme": themeId, "taskCount": 0, "unfinishedTaskCount": 0, "sort": sort])
            realm.add(newTag)
            
            let indexPath = IndexPath(row: customTags!.count - 1, section: 1)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didUpdateTagName(tagName: String) {
        if selectedIndexPath?.section == 1 {
            try? realm.write {
                customTags![selectedIndexPath!.row].tagName = tagName
                let cell = tableView.cellForRow(at: selectedIndexPath!) as! ListTagCell
                cell.listTagLabel.text = tagName
            }
        }
    }
    
    func didDeleteTag(tag: ListTag) {
        self.deleteTag(tag: tag, indexPath: selectedIndexPath!)
    }
}

extension IndexViewController: TagTaskCountDelegate {
    
    func addTask(tagId: Int) {
        // 能查出来tag，就说明这是customTags
        if let tag = realm.object(ofType: ListTag.self, forPrimaryKey: tagId) {
            try? realm.write {
                tag.taskCount += 1
                tag.unfinishedTaskCount += 1
            }
        }
    }
    
    func updateTask(tagId: Int, value: Int) {
        if let tag = realm.object(ofType: ListTag.self, forPrimaryKey: tagId) {
            try? realm.write {
                tag.unfinishedTaskCount += value
            }
        }
    }
    
    func deleteTask(tagId: Int, finished: Bool) {
        if let tag = realm.object(ofType: ListTag.self, forPrimaryKey: tagId) {
            try? realm.write {
                tag.taskCount -= 1
                if !finished {
                    tag.unfinishedTaskCount -= 1
                }
            }
        }
    }
    
    func deleteTasks(dict: [Int : Int]) {
        for (tagId, count) in dict {
            if let tag = realm.object(ofType: ListTag.self, forPrimaryKey: tagId) {
                try? realm.write {
                    tag.taskCount -= count
                }
            }
        }
    }
}
