//
//  UserDefaultsKey.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/18.
//  Copyright © 2020 周伟. All rights reserved.
//

import Foundation

struct UserDefaultsKeys {
    
    static let tagSort = "tag-sort"
    static let todayTagResetTs = "today-tag-reset-ts"
    static let hasLaunch = "hasLaunch"
    
    // 主键
    struct RealmPrimaryKey {
        static let primaryKeyTag = "pk-tag"
        static let primaryKeyTask = "pk-task"
    }
    
    // 默认清单的主题
    struct TagThemeDefault {
        static let tagThemeToday = "tagTheme-today"
        static let tagThemeImportant = "tagTheme-important"
        static let tagThemeSchedule = "tagTheme-schedule"
        static let tagThemeTask = "tagTheme-task"
    }

}
