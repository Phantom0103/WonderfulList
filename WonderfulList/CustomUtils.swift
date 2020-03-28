//
//  CustomUtils.swift
//  WonderfulList
//
//  Created by 周伟 on 2020/3/9.
//  Copyright © 2020 周伟. All rights reserved.
//

import Foundation

class CustomUtils {
    
    static let dateFormatter = DateFormatter()
    
    class func dateToString(date: Date, formatter: CustomDateFormatter) -> String {
        let result: String?
        if formatter == .formatter1 {
            let week = getWeek(date: date)
            dateFormatter.dateFormat="MM-dd HH:mm"
            result = dateFormatter.string(from: date) + " \(week)"
        } else if formatter == .formatter2 {
            let week = getWeek(date: date)
            dateFormatter.dateFormat="M月d日"
            result = dateFormatter.string(from: date) + " \(week)"
        } else if formatter == .formatter3 {
            dateFormatter.dateFormat="MM-dd HH:mm"
            result = dateFormatter.string(from: date)
        } else if formatter == .formatter4 {
            let week = getWeek(date: date)
            dateFormatter.dateFormat="yyyy-MM-dd HH:mm"
            result = dateFormatter.string(from: date) + " \(week)"
        } else {
            result = dateFormatter.string(from: date)
        }

        return result!
    }
    
    class func getWeek(date: Date) -> String {
        let week = (Int(date.timeIntervalSince1970 / 86400) - 3) % 7
        switch week {
        case 0:
            return "周日"
        case 1:
            return "周一"
        case 2:
            return "周二"
        case 3:
            return "周三"
        case 4:
            return "周四"
        case 5:
            return "周五"
        case 6:
            return "周六"
        default:
            return ""
        }
    }
    
    enum CustomDateFormatter {
        // 01-01 10:00 周一
        case formatter1
        
        // 1月1日 周一
        case formatter2
        
        // 01-01 10:00
        case formatter3
        
        // 2020-01-01 10:00 周一
        case formatter4
    }
}

