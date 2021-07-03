//
//  Date+Extension.swift
//  Calendar
//
//  Created by ice on 2021/7/3.
//

import Foundation

extension Date {
    // ex. format : yyyy-MM-dd
    public func stringFormat(_ format: String = "yyyy-MM-dd") -> String {
        return self.formatting(format, isUTC: false)
    }
    
    // ex. format : yyyy-MM-dd'T'HH:mm:ss.SSSZ
    public func stringUTCFormat(_ format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> String {
        return self.formatting(format, isUTC: true)
    }
    
    fileprivate func formatting(_ format: String, isUTC: Bool) -> String {
        let dateFormatter = DateFormatter()

        if isUTC {
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
        }
        
        dateFormatter.dateFormat = format
        
        let dateString = dateFormatter.string(from: self)
        
        return dateString
    }
    
    public func dateByAddSeconds(_ seconds: Int) -> Date {
        return self.dateByAdd({ comps -> Void in
            comps.second = seconds
        })
    }
    
    public func dateByAddDays(_ days: Int) -> Date {
        return self.dateByAdd({ comps -> Void in
            comps.day = days
        })
    }
    
    public mutating func nextDay() {
        self = self.dateByAddDays(1)
    }
    
    public static func dateByISO8601String(_ dateString: String, hasMillisecond: Bool) -> Date? {
        
        let dateFormatter = DateFormatter()
        if hasMillisecond {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        }
        
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.date(from: dateString)
    }
    
    fileprivate func dateByComponents(_ units: NSCalendar.Unit, processing: (_ comps: inout DateComponents) -> DateComponents) -> Date {
        
        var cal = Calendar.current
        
        cal.timeZone = TimeZone(identifier: "UTC")!
        
        var comps: DateComponents = (cal as NSCalendar).components(units, from: self)
        
        comps = processing(&comps)
        
        return cal.date(from: comps) ?? Date()
    }
    
    fileprivate func dateByAdd(_ processing:  (_ comps: inout DateComponents) -> Void) -> Date {
        
        var comps = DateComponents()
        
        processing(&comps)
        
        return (Calendar.current as NSCalendar).date(byAdding: comps, to: self, options: NSCalendar.Options(rawValue: 0)) ?? Date()

    }
    
    var weekday: String {
        let weekday = Calendar.current.component(.weekday, from: self)
        
        switch weekday {
        case 1: return "日"
        case 2: return "一"
        case 3: return "二"
        case 4: return "三"
        case 5: return "四"
        case 6: return "五"
        case 7: return "六"
        default: return ""
        }
    }
}

// MARK: Group List and Notify
extension Date {
    fileprivate func isDate(in number: Int, _ dateComponent: Calendar.Component) -> (Bool, Int) {
        let components = Calendar.current.dateComponents([dateComponent], from: self, to: Date())
        
        if components.value(for: dateComponent)! < number {
            return (true, components.value(for: dateComponent)!)
        }
        
        return (false, 0)
    }
    
    fileprivate func isThisYear() -> Bool {
        let currentComponents = Calendar.current.dateComponents([.year], from: Date())
        let dateComponents = Calendar.current.dateComponents([.year], from: self)
        
        return dateComponents.year == currentComponents.year
    }
    
    public func timeAgo_deprecated() -> String {
        if isDate(in: 5, .minute).0 {
            // 5分鐘內
            return "剛剛"
        } else if isDate(in: 60, .minute).0 {
            // 5分鐘 ~ 1小時內
            return "\(isDate(in: 60, .minute).1)分鐘前"
        } else if isDate(in: 24, .hour).0 {
            // 一天內
            return "\(isDate(in: 24, .hour).1)小時前"
        } else if Calendar.current.isDateInYesterday(self) {
            // 昨天
            return stringFormat("昨天 HH:mm")
        } else if isThisYear() {
            // 一天以上
            return stringFormat("M月d日 HH:mm")
        } else {
            // 不是今年
            return stringFormat("yyyy年M月d日 HH:mm")
        }
    }
    
    /// 顯示時間
    ///
    /// - Parameter edited: 如果有帶編輯參數，e.g. false等於初建立而未編輯過，顯示"建立於 ...“，true則是編輯過，顯示"編輯於 ..."，未帶任何值只顯示日期時間
    /// - Returns: 時間日期
    public func timeAgo(edited: Bool = false, isNeedPrefix: Bool = true) -> String {
        var dateString = ""
        
        if isNeedPrefix {
            if edited {
                dateString = "編輯於 "
            } else if edited == false {
                dateString = "建立於 "
            }
        }
        
        if isThisYear() {
            return dateString + stringFormat("M月d日 HH:mm")
        } else {
            // 不是今年
            return dateString + stringFormat("yyyy年M月d日 HH:mm")
        }
    }
    
    public func howManyDays() -> Int {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: self)
        return components.value(for: .day) ?? 0
    }
    
    public func howManyHours() -> Int {
        let components = Calendar.current.dateComponents([.hour], from: Date(), to: self)
        return components.value(for: .hour) ?? 0
    }
    
    public func daysLeft() -> String {
        if howManyDays() > 999 {
            return "剩餘999+天"
        } else if howManyDays() > 0 {
            return "剩餘\(howManyDays())天"
        } else if howManyHours() > 0 {
            return "剩餘1天"
        }
        return ""
    }
    
    // 判斷是否在幾天/月/年之前
    func isBefore(_ count: Int, _ component: Calendar.Component) -> Bool {
        let components = Calendar.current.dateComponents([component], from: self, to: Date())
        
        if components.value(for: component)! > count {
            return true
        }
        
        return false
    }
}

// 拿取得一天的開始和23:59:59
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

public extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()
}

extension Date {
    public func days(after date: Date) -> Int {
        let start = date.startOfDay
        let end = self.endOfDay
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0)
    }
}

extension Date {
    var startOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 0, to: sunday!)!
    }
    
    var endOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 6, to: sunday!)!
    }
    
    var startOfPreviousWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: -6, to: sunday!)!
    }
    
    var endOfPreviousWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 0, to: sunday!)!
    }
    
    var startDateOfMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    var endDateOfMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startDateOfMonth)!
    }
    
    func getMonth(_ offset: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: offset, to: self)!
    }
    
    func days(between date: Date) -> Int {
        var start = self.startOfDay
        var end = date.endOfDay
        if date < self {
            start = date.startOfDay
            end = self.endOfDay
        }
        
        let components = Calendar.current.dateComponents([.day], from: start, to: end)
        return (components.day ?? 0) 
    }
}

extension Date {
    
    // 比較兩時間差多久
    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let component1 = calendar.component(component, from: self)
        let component2 = calendar.component(component, from: date)
        return component1 - component2
    }
}
