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
        let dateFormatter = DateFormatter()
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
    
    fileprivate func dateByAdd(_ processing:  (_ comps: inout DateComponents) -> Void) -> Date {
        var comps = DateComponents()
        
        processing(&comps)
        
        return (Calendar.current as NSCalendar).date(byAdding: comps, to: self, options: NSCalendar.Options(rawValue: 0)) ?? Date()

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
