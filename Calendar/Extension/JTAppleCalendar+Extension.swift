//
//  JTAppleCalendar+Extension.swift
//  Calendar
//
//  Created by ice on 2021/7/4.
//

import Foundation
import JTAppleCalendar

extension DaysOfWeek {
    var desription: String {
        switch self {
        case .monday:
            return NSLocalizedString(".monday", comment: "monday")
        case .sunday:
            return NSLocalizedString(".sunday", comment: "sunday")
        case .tuesday:
            return NSLocalizedString(".tuesday", comment: "tuesday")
        case .wednesday:
            return NSLocalizedString(".wednesday", comment: "wednesday")
        case .thursday:
            return NSLocalizedString(".thursday", comment: "thursday")
        case .friday:
            return NSLocalizedString(".friday", comment: "friday")
        case .saturday:
            return NSLocalizedString(".saturday", comment: "saturday")
        }
    }
}

extension DateSegmentInfo {
    func getDisplayDate() -> (start: Date, end: Date) {
        var startDate = monthDates.first?.date
        var endDate = monthDates.last?.date
        if let date = indates.first?.date {
            startDate = date
        }
        if let date = outdates.last?.date {
            endDate = date
        }
        return (startDate ?? Date(), endDate ?? Date())
    }
}
