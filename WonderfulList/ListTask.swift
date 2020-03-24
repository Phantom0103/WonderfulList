//
//  ListTask.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/9.
//  Copyright © 2020 周伟. All rights reserved.
//

import Foundation
import RealmSwift

// 清单任务
class ListTask: Object {
    @objc dynamic var taskId = 0
    @objc dynamic var tagId = 0
    
    @objc dynamic var today = false
    @objc dynamic var important = false
    @objc dynamic var schedule = false

    // 归档
    @objc dynamic var archived = false
    @objc dynamic var finished = false
    
    @objc dynamic var taskName = ""
    
    @objc dynamic var scheduleTime: Date? = nil
    @objc dynamic var createTime = Date()
    @objc dynamic var updateTime = Date()
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
}
