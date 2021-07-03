//
//  ViewController.swift
//  Calendar
//
//  Created by ice on 2021/7/3.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var header: CalendarDateHeader! {
        didSet {
            header.forwardHandler = { [weak self] in
                guard let self = self, let visibleDates = self.visibleDates else {
                    return
                }
                
                let currect = visibleDates.getDisplayDate().start.dateByAddDays(-7)
                if currect < Date().startOfDay {
                    self.calendarView.scrollToDate(Date(), animateScroll: true)
                } else {
                    self.calendarView.scrollToDate(currect, animateScroll: true)
                }
            }
            
            header.backwardHandler = { [weak self] in
                guard let self = self, let visibleDates = self.visibleDates else {
                    return
                }
                
                let currect = visibleDates.getDisplayDate().end.dateByAddDays(1)
                self.calendarView.scrollToDate(currect, animateScroll: true)
            }
        }
    }
    
    private let startDate: Date = Date()
    private let endDate: Date = Date().dateByAddDays(365)
    private var visibleDates: DateSegmentInfo?
    private var offsetX: CGFloat = 0
    
    private var testModel = CourseAPIModel.ClassModel.test()?.expandEvents() ?? [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.scrollDirection = .horizontal
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.allowsMultipleSelection = false
    }

    private func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? CalendarDateCell else { return }
        let dateString = cellState.date.startOfDay.stringFormat("yyyy/MM/dd")
        cell.configure(with: cellState, lectures: testModel[dateString])
    }
}

// MARK: - JTACMonthViewDataSource
extension ViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       numberOfRows: 1,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfRow,
                                       firstDayOfWeek: .sunday)
    }
}

// MARK: - JTACMonthViewDelegate
extension ViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! CalendarDateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendarDidScroll(_ calendar: JTACMonthView) {
        header.forward.isEnabled = !(calendar.contentOffset.x <= 0)
        header.forward.tintColor = calendar.contentOffset.x <= 0 ? .lightGray : .darkGray
        
        header.backward.isEnabled = !(calendar.contentOffset.x >= calendar.contentSize.width - UIScreen.main.bounds.width)
        header.backward.tintColor = calendar.contentOffset.x >= calendar.contentSize.width - UIScreen.main.bounds.width ? .lightGray : .darkGray
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if visibleDates.getDisplayDate().start == self.visibleDates?.getDisplayDate().start {
            if offsetX > calendar.contentOffset.x {
                let currect = visibleDates.getDisplayDate().start.dateByAddDays(-7)
                if currect < Date().startOfDay {
                    self.calendarView.scrollToDate(Date(), animateScroll: true)
                } else {
                    self.calendarView.scrollToDate(currect, animateScroll: true)
                }
            } else {
                let currect = visibleDates.getDisplayDate().end.dateByAddDays(1)
                calendarView.scrollToDate(currect, animateScroll: true)
            }
        }
        
        offsetX = calendar.contentOffset.x
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let (start, end) = visibleDates.getDisplayDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd - "
        
        var str = formatter.string(from: start)
        formatter.dateFormat = "dd"
        str.append(formatter.string(from: end))
        
        header.timeRange.text = str
        
        self.visibleDates = visibleDates
    }
}
