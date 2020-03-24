//
//  ListTag.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/5.
//  Copyright © 2020 周伟. All rights reserved.
//

import Foundation
import RealmSwift

// 清单列表
class ListTag: Object {
    @objc dynamic var tagId = 0
    @objc dynamic var tagImage = ""
    @objc dynamic var tagName = ""
    @objc dynamic var tagTheme = 0
    @objc dynamic var taskCount = 0
    @objc dynamic var unfinishedTaskCount = 0
    @objc dynamic var sort = 0
    
    override static func primaryKey() -> String? {
        return "tagId"
    }
}
