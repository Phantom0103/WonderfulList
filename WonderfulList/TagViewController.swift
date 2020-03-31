//
//  TagViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/6.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit
import RealmSwift

protocol TagViewDelegate {
    func didAddTag(tagName: String, themeId: Int)
    func didUpdateTagName(tagName: String)
    func didDeleteTag(tag: ListTag)
}

class TagViewController: UIViewController {

    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: CustomTableView!
    @IBOutlet weak var addButtonView: UIView!
    @IBOutlet weak var cancelChangeThemeBtn: UIButton!
    @IBOutlet weak var confirmChangeThemeBtn: UIButton!
    @IBOutlet weak var footerViewBottomConst: NSLayoutConstraint!
    
    var delegate: TagViewDelegate?
    var taskCountDelegate: TagTaskCountDelegate?
    
    var tag: ListTag?
    var selectedIndexPath: IndexPath?
    var listTasks: Results<ListTask>?
    
    var isUpdate = false
    var isDefaultTag = false
    
    // 0表示没有选择主题，也就是默认主题
    var themeId = 0
    // 用于在更换主题时记录更换之前的主题
    var themeIdTmp = 0
    let tagThemes = ["theme0", "theme1", "theme2", "theme3", "theme4", "theme5", "theme6", "theme7", "theme8", "theme11", "theme12", "theme13", "theme14", "theme15"]
    let darkTheme = [10, 11]
    
    var menuView: MenuView?
    
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        tagTextField.delegate = self
        
        tagTextField.font = UIFont.systemFont(ofSize: 28)
        
        if (isUpdate) {
            tagTextField.text = tag!.tagName
            if isDefaultTag {
                tagTextField.isUserInteractionEnabled = false
            }
            themeId = tag!.tagTheme

            tableView.separatorStyle = .none
            addButtonView.layer.cornerRadius = 5.0
            addButtonView.layer.masksToBounds = true
            footerViewBottomConst.constant = -260
            
            initData()
        } else {
            tagTextField.placeholder = "请输入清单名称"
            
            navigationItem.rightBarButtonItems?.remove(at: 0)
            cancelChangeThemeBtn.isHidden = true
            confirmChangeThemeBtn.isHidden = true
        }
        
        changeTheme(themeId: themeId)
        
        initMenuView()
    }
    
    // 准备数据
    private func initData() {
        let tagId = tag!.tagId
        var predicateFormat = "tagId = \(tagId) AND archived = false"
        if isDefaultTag {
            switch tagId {
            case 1:
                predicateFormat = "today = true AND archived = false"
            case 2:
                predicateFormat = "important = true AND archived = false"
            case 3:
                predicateFormat = "schedule = true AND archived = false"
            default:
                predicateFormat = "archived = false"
            }
        }
        
        listTasks = realm.objects(ListTask.self).filter(predicateFormat).sorted(byKeyPath: "createTime", ascending: false)
    }
    
    // 初始化下拉菜单
    private func initMenuView() {
        let menus = [
            Menu(id: 1, image: "action-archive-white-20", title: "归档已完成"),
            Menu(id: 2, image: "action-finish-white-20", title: "删除已完成"),
            Menu(id: 3, image: "action-theme-white-20", title: "更换主题"),
            Menu(id: 4, image: "action-trash-white-20", title: "删除此清单")
        ]
        let width = CGFloat(160)
        let height = CGFloat(176)
        let x = view.frame.width - width - 20
        let y = headerView.frame.origin.y
        menuView = MenuView(frame: CGRect(x: x, y: y, width: width, height: height), menus: menus)
        menuView!.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddTaskSegue" {
            let vc = segue.destination as! TaskViewController
            vc.delegate = self
            vc.tagId = tag?.tagId
            
            let backItem = UIBarButtonItem(title: tag!.tagName, style: .plain, target: self, action: nil)
            self.navigationItem.backBarButtonItem = backItem
        } else if segue.identifier == "ShowTaskSegue" {
            let vc = segue.destination as! TaskViewController
            vc.delegate = self
            
            let cell = sender as! ListTaskCell
            let indexPath = tableView.indexPath(for: cell)!
            selectedIndexPath = indexPath
            vc.task = listTasks![indexPath.row]
            vc.tagId = tag?.tagId
            vc.isUpdate = true
            
            let backItem = UIBarButtonItem(title: tag!.tagName, style: .plain, target: self, action: nil)
            self.navigationItem.backBarButtonItem = backItem
        }
    }
    
    func changeTheme(themeId: Int) {
        view.layer.contents = UIImage(named: tagThemes[themeId])?.cgImage
        // 深色背景文字变成白色
        if darkTheme.contains(themeId) {
            tagTextField.textColor = UIColor.white
            tagTextField.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        } else {
            tagTextField.textColor = UIColor.black
            tagTextField.setValue(UIColor.init(red: 199, green: 199, blue: 205, alpha: 1.0), forKeyPath: "_placeholderLabel.textColor")
        }
    }
    
    func finishTask(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ListTaskCell
        if let task = listTasks?[indexPath.row] {
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
                
                DispatchQueue.main.async {
                    self.taskCountDelegate?.updateTask(tagId: task.tagId, value: task.finished ? -1 : 1)
                }
            }
        }
    }
    
    // 归档已完成
    func archiveFinished() {
        let alertController = UIAlertController(title: "注意", message: "可以在归档中恢复任务", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "好的", style: .default, handler: { (_) in
            var success = false
            try? self.realm.write {
                let preArchiveTasks = self.listTasks!.filter("finished = true")
                if !preArchiveTasks.isEmpty {
                    preArchiveTasks.setValue(true, forKey: "archived")
                    preArchiveTasks.setValue(Date.init(), forKey: "updateTime")
                    success = true
                }
            }
            
            if success {
                self.tableView.reloadData()
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // 删除已完成
    func deleteFinished() {
        let alertController = UIAlertController(title: "注意", message: "这将永久删除任务", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "好的", style: .default, handler: { (_) in
            var success = false
            // key: tagId, value; count
            var dict = [Int : Int]()
            try? self.realm.write {
                let preDeleteTasks = self.listTasks!.filter("finished = true")
                if !preDeleteTasks.isEmpty {
                    for preDeleteTask in preDeleteTasks {
                        let tagId = preDeleteTask.tagId
                        let c = dict[tagId] ?? 0
                        dict[tagId] = c + 1
                    }
                    
                    self.realm.delete(preDeleteTasks)
                    success = true
                }
            }
            
            if success {
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.taskCountDelegate?.deleteTasks(dict: dict)
                }
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // 更换主题
    private func changeTheme() {
        if footerViewBottomConst.constant == -260 {
            showFooterViewAnimated()
            themeIdTmp = themeId
        }
    }
    
    private func dismissFooterViewAnimated() {
        UIView.animate(withDuration: 0.5) {
            self.footerViewBottomConst.constant = -260
            self.view.layoutIfNeeded()
        }
    }
    
    private func showFooterViewAnimated() {
        UIView.animate(withDuration: 0.5) {
            self.footerViewBottomConst.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // 删除此清单
    func deleteTag() {
        delegate?.didDeleteTag(tag: tag!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelChangeTheme(_ sender: Any) {
        if themeIdTmp != themeId {
            changeThemeCellStatus(unselect: IndexPath(row: themeId, section: 0), select: IndexPath(row: themeIdTmp, section: 0))
            
            themeId = themeIdTmp
            changeTheme(themeId: themeId)
        }
        dismissFooterViewAnimated()
    }
    
    @IBAction func confirmChangeTheme(_ sender: Any) {
        if themeIdTmp != themeId {
            if isDefaultTag {
                tag?.tagTheme = themeId
                
                if tag?.tagId == 1 {
                    defaults.set(themeId, forKey: UserDefaultsKeys.TagThemeDefault.tagThemeToday)
                } else if tag?.tagId == 2 {
                    defaults.set(themeId, forKey: UserDefaultsKeys.TagThemeDefault.tagThemeImportant)
                } else if tag?.tagId == 3 {
                    defaults.set(themeId, forKey: UserDefaultsKeys.TagThemeDefault.tagThemeSchedule)
                } else if tag?.tagId == 4 {
                    defaults.set(themeId, forKey: UserDefaultsKeys.TagThemeDefault.tagThemeTask)
                }
            } else {
                try? realm.write {
                    tag?.tagTheme = themeId
                }
            }
        }
        dismissFooterViewAnimated()
    }
    
    @IBAction func showMenuView(_ sender: Any) {
        if menuView!.isNowHidden {
            view.addSubview(menuView!)
            menuView!.isNowHidden = false
        } else {
            menuView!.removeMenu()
        }
    }
    
    // 修改选择不同的主题时被选中的状态
    private func changeThemeCellStatus(unselect: IndexPath, select: IndexPath) {
        let theCell = collectionView.cellForItem(at: unselect)
        theCell?.layer.borderColor = UIColor.clear.cgColor
        theCell?.layer.borderWidth = 0
        
        let cell = collectionView.cellForItem(at: select)
        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.layer.borderWidth = 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !(menuView?.isNowHidden ?? true) {
            menuView?.removeMenu()
        }
        
        if footerViewBottomConst.constant == 0 {
            dismissFooterViewAnimated()
        }
    }
}

// 添加清单输入文本框
extension TagViewController: UITextFieldDelegate {
    
    // 提交textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let legalInput = tagTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !legalInput.isEmpty {
            if isUpdate {
                if tag!.tagName != legalInput {
                    delegate?.didUpdateTagName(tagName: legalInput)
                }
            } else {
                delegate?.didAddTag(tagName: legalInput, themeId: themeId)
            }
        }
        navigationController?.popViewController(animated: true)
        
        return true
    }
}

// 主题CollectionView代理
extension TagViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagThemes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagThemeCell", for: indexPath) as! TagThemeCell
        let theme = tagThemes[indexPath.row]
        cell.theme = theme
        cell.themeImage.image = UIImage(named: "\(theme)-thumbnail")

        if indexPath.row == themeId {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 2
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 没有选中进来时默认的cell，就去掉选中状态
        if indexPath.row != themeId {
            changeThemeCellStatus(unselect: IndexPath(row: themeId, section: 0), select: indexPath)
            
            themeId = indexPath.row
            changeTheme(themeId: themeId)
        }
    }
}

// 列表任务数据源和代理
extension TagViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTaskCell", for: indexPath) as! ListTaskCell
        
        // 不同tag下的任务显示不同，参考Trello
        if let listTasks = listTasks {
            let task = listTasks[indexPath.row]
            if task.finished {
                cell.finishTaskButton.setImage(UIImage(named: "action-finish"), for: .normal)
                let attributedText = NSAttributedString(string: task.taskName, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                cell.taskLabel.attributedText = attributedText
            } else {
                cell.finishTaskButton.setImage(UIImage(named: "action-unfinish"), for: .normal)
                cell.taskLabel.text = task.taskName
            }
            
            if tag?.tagId == 2 {
                cell.taskTagLabel.text = task.today ? "新的一天" : "事项"
            } else if tag?.tagId == 4 {
                if task.today && task.important {
                    cell.taskTagLabel.text = "新的一天·重要"
                } else if task.today {
                    cell.taskTagLabel.text = "新的一天"
                } else if task.important {
                    cell.taskTagLabel.text = "重要"
                } else {
                    cell.taskTagLabel.text = "事项"
                }
            } else {
                cell.taskTagLabel.text = task.important ? "重要" : "事项"
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
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? realm.write {
                let preDelete = listTasks![indexPath.row]
                let tagId = preDelete.tagId
                let finished = preDelete.finished
                
                realm.delete(preDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                DispatchQueue.main.async {
                    self.taskCountDelegate?.deleteTask(tagId: tagId, finished: finished)
                }
            }
        }
    }

}

extension TagViewController: TaskViewDelegate {
    func didAddTask(taskName: String, important: Bool, schedule: Bool, scheduleTime: Date) {
        let taskId = defaults.integer(forKey: UserDefaultsKeys.RealmPrimaryKey.primaryKeyTask)
        defaults.set(taskId + 1, forKey: UserDefaultsKeys.RealmPrimaryKey.primaryKeyTask)
        
        let tagId = tag!.tagId
        let today = tagId == 1
        let task = ListTask(value: ["taskId": taskId, "tagId": tagId, "today": today, "important": important, "schedule": schedule, "taskName": taskName])
        
        if schedule {
            task.scheduleTime = scheduleTime
        }
        
        try? realm.write {
            realm.add(task)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        DispatchQueue.main.async {
            self.taskCountDelegate?.addTask(tagId: tagId)
        }
    }
    
    func didUpdateTask(taskName: String, important: Bool, schedule: Bool, scheduleTime: Date) {
        if let task = listTasks?[selectedIndexPath!.row] {
            try? realm.write {
                task.taskName = taskName
                task.important = important
                task.schedule = schedule
                if schedule {
                    task.scheduleTime = scheduleTime
                } else {
                    task.scheduleTime = nil
                }
                task.updateTime = Date.init()
                
                tableView.reloadRows(at: [selectedIndexPath!], with: .automatic)
            }
        }
    }
    
    func didFinishTask(taskId: Int) {
        if let task = listTasks?[selectedIndexPath!.row] {
            if task.taskId == taskId {
                try? realm.write {
                    if !task.finished {
                        task.finished = true
                        task.updateTime = Date.init()
                        
                        let cell = tableView.cellForRow(at: selectedIndexPath!) as! ListTaskCell
                        cell.finishTaskButton.setImage(UIImage(named: "action-finish"), for: .normal)
                        let attributedText = NSAttributedString(string: task.taskName, attributes: [NSAttributedString.Key.strikethroughStyle: 1])
                        cell.taskLabel.attributedText = attributedText
                        
                        DispatchQueue.main.async {
                            self.taskCountDelegate?.updateTask(tagId: task.tagId, value: -1)
                        }
                    }
                }
            }
        }
    }
    
    func didDeleteTask(taskId: Int) {
        if let task = listTasks?[selectedIndexPath!.row] {
            if task.taskId == taskId {
                try? realm.write {
                    let finished = task.finished
                    let tagId = task.tagId
                    realm.delete(task)
                    tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
                    
                    DispatchQueue.main.async {
                        self.taskCountDelegate?.deleteTask(tagId: tagId, finished: finished)
                    }
                }
            }
        }
    }
    
    func didArchiveTask(taskId: Int) {
        if let task = listTasks?[selectedIndexPath!.row] {
            if task.taskId == taskId {
                try? realm.write {
                    let finished = task.finished
                    task.archived = true
                    task.updateTime = Date.init()
                    tableView.deleteRows(at: [selectedIndexPath!], with: .fade)
                    
                    if !finished {
                        DispatchQueue.main.async {
                            self.taskCountDelegate?.updateTask(tagId: task.tagId, value: -1)
                        }
                    }
                }
            }
        }
    }
}

extension TagViewController: MenuViewDelegate {
    func didClickSelectedRow(menuId: Int, menu: MenuView) {
        switch menuId {
        case 1:
            archiveFinished()
        case 2:
            deleteFinished()
        case 3:
            changeTheme()
        case 4:
            deleteTag()
        default:
            return
        }
        
        menu.removeMenu()
    }
}

class CustomTableView: UITableView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view?.isMember(of: CustomTableView.self) ?? false {
            UIApplication.shared.keyWindow?.endEditing(true)
        }
        return view
    }
}
