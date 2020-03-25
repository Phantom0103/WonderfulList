//
//  TaskViewController.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/9.
//  Copyright © 2020 周伟. All rights reserved.
//

import UIKit

protocol TaskViewDelegate {
    func didAddTask(taskName: String, important: Bool, schedule: Bool, scheduleTime: Date)
    func didUpdateTask(taskName: String, important: Bool, schedule: Bool, scheduleTime: Date)
    func didFinishTask(taskId: Int)
    func didDeleteTask(taskId: Int)
    func didArchiveTask(taskId: Int)
}

class TaskViewController: UIViewController {

    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var scheduleTimeTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var createTime: UILabel!
    @IBOutlet weak var updateTime: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var archiveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var timeStackViewConst: NSLayoutConstraint!
    @IBOutlet weak var taskTextView: UITextView!
    
    var delegate: TaskViewDelegate?
    let placeholderLabel = UILabel()
    
    var tag: ListTag?
    var task: ListTask?
    var isUpdate = false
    var minDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTextView.delegate = self
        placeholderLabel.text = "添加任务"
        placeholderLabel.font = UIFont.systemFont(ofSize: taskTextView.font!.pointSize)
        taskTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: taskTextView.layoutMargins.top)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.sizeToFit()
        
        datePicker.layer.borderWidth = 1
        datePicker.layer.borderColor = UIColor.gray.cgColor
        // 获取下一个整十分钟
        let second = Date.init().timeIntervalSince1970
        let minute = Int(second / 600)
        minDate = Date.init(timeIntervalSince1970: TimeInterval((minute + 1) * 600))
        datePicker.minimumDate = minDate
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(chooseDate(_:)), for: .valueChanged)
        
        // 缩放并向左偏移
        let offsetX = importantSwitch.frame.width * 0.25
        var transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        transform = transform.translatedBy(x: -offsetX, y: 0)
        importantSwitch.transform = transform

        if isUpdate {
            placeholderLabel.isHidden = true
            taskTextView.text = task!.taskName
            createTime.text = CustomUtils.dateToString(date: task!.createTime, formatter: .formatter3)
            updateTime.text = CustomUtils.dateToString(date: task!.updateTime, formatter: .formatter3)
            
            importantSwitch.isOn = task!.important
            if let scheduleTime = task!.scheduleTime, task!.schedule {
                datePicker.date = scheduleTime
                scheduleTimeTextField.text = CustomUtils.dateToString(date: scheduleTime, formatter: .formatter1)
            }
            
            if tag?.tagId == 2 {
                // 重要，重要开关打开且不可修改
                importantSwitch.isOn = true
                importantSwitch.isEnabled = false
                
            } else if tag?.tagId == 3 {
                // 计划，默认提醒时间为1小时后，且不可清空
                let date = task!.scheduleTime ?? minDate!.addingTimeInterval(TimeInterval(3600))
                datePicker.date = date
                scheduleTimeTextField.text = CustomUtils.dateToString(date: date, formatter: .formatter1)
                scheduleTimeTextField.isUserInteractionEnabled = false
                scheduleTimeTextField.clearButtonMode = .never
            }
            
            if task!.finished {
                finishButton.isHidden = true
                timeStackViewConst.constant = -finishButton.frame.height
                self.view.layoutIfNeeded()
            }
        } else {
            placeholderLabel.isHidden = false
            taskTextView.becomeFirstResponder()
            footerView.isHidden = true
            
            if tag?.tagId == 2 {
                // 重要，重要开关打开且不可修改
                importantSwitch.isOn = true
                importantSwitch.isEnabled = false
            } else if tag?.tagId == 3 {
                // 计划，默认提醒时间为1小时后，且不可清空
                let date = minDate!.addingTimeInterval(TimeInterval(3600))
                datePicker.date = date
                scheduleTimeTextField.text = CustomUtils.dateToString(date: date, formatter: .formatter1)
                scheduleTimeTextField.isUserInteractionEnabled = false
            }
        }
    }
    
    @IBAction func saveListTask(_ sender: Any) {
        let legalInput = taskTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let schedule = !scheduleTimeTextField.text!.isEmpty
        if !legalInput.isEmpty {
            if isUpdate {
                if hasUpdate(taskName: legalInput) {
                    delegate?.didUpdateTask(taskName: legalInput, important: importantSwitch.isOn, schedule: schedule, scheduleTime: datePicker.date)
                }
            } else {
                delegate?.didAddTask(taskName: legalInput, important: importantSwitch.isOn, schedule: schedule, scheduleTime: datePicker.date)
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showDatePicker(_ sender: Any) {
        if datePicker.isHidden {
            if scheduleTimeTextField.text!.isEmpty {
                // 默认提醒时间为1小时后
                let date = minDate!.addingTimeInterval(TimeInterval(3600))
                datePicker.date = date
                scheduleTimeTextField.text = CustomUtils.dateToString(date: date, formatter: .formatter1)
            }
            datePicker.isHidden = false
        } else {
            datePicker.isHidden = true
        }
    }
    
    @IBAction func finishTask(_ sender: Any) {
        delegate?.didFinishTask(taskId: task!.taskId)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func archiveTask(_ sender: Any) {
        let alertController = UIAlertController(title: "注意", message: "可以在归档中恢复任务", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "好的", style: .default, handler: { (_) in
            self.delegate?.didArchiveTask(taskId: self.task!.taskId)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        let alertController = UIAlertController(title: "注意", message: "这将永久删除任务", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "好的", style: .destructive, handler: { (_) in
            self.delegate?.didDeleteTask(taskId: self.task!.taskId)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func chooseDate(_ datePicker: UIDatePicker) {
        scheduleTimeTextField.text = CustomUtils.dateToString(date: datePicker.date, formatter: .formatter1)
    }
    
    // 点击空白处收回软键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        taskTextView.resignFirstResponder()
    }
    
    // 判断是否有更新
    func hasUpdate(taskName: String) -> Bool {
        if task!.taskName != taskName {
            return true
        }
        
        if importantSwitch.isOn {
            if !task!.important {
                return true
            }
        } else {
            if task!.important {
                return true
            }
        }
        
        // 提交时datePicker的时间
        let time = datePicker.date
        let timeStr = scheduleTimeTextField.text
        if task!.schedule {
            if timeStr!.isEmpty {
                return true
            } else {
                if time.compare(task!.scheduleTime!) != ComparisonResult.orderedSame {
                    return true
                }
            }
        } else {
            if !timeStr!.isEmpty {
                return true
            }
        }
        
        return false
    }
}

extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    // 当按写键盘"Return"，不换行，结束输入
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            taskTextView.resignFirstResponder()
            return false
        }
        
        return true
    }
}
