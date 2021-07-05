//
//  ViewController.swift
//  Calendar
//
//  Created by ice on 2021/7/3.
//

import UIKit
import JTAppleCalendar

struct Lecture {
    var start: Date
    var booked: Bool
}

class ViewController: UIViewController {
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var header: CalendarDateHeader! {
        didSet {
            header.forwardHandler = { [weak self] in
                guard let self = self, let visibleDates = self.visibleDates else {
                    return
                }
                
                self.doForward(visibleDates)
            }
            
            header.backwardHandler = { [weak self] in
                guard let self = self, let visibleDates = self.visibleDates else {
                    return
                }
                
                self.doBackward(visibleDates)
            }
        }
    }
    
    private var visibleDates: DateSegmentInfo?
    private var offsetX: CGFloat = 0
    
    var course: [String: [Lecture]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalendar()
        callAPI()
    }
    
    private func callAPI() {
        let session = NetworkSessionMock()
        let manager = NetworkManager(session: session)
        
        let data = testJson.data(using: .utf8)
        session.data = data
        
        let url = URL(fileURLWithPath: "url")
        manager.loadData(from: url) { [weak self] result in
            DispatchQueue.main.async {
                self?.course = result?.expandSchedule()
                self?.calendarView.reloadData()
            }
        }
    }
}

// MARK: - JTACMonthViewDataSource
extension ViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let startDate: Date = Date()
        let endDate: Date = Date().dateByAddDays(365)
        
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
        header.setupHeaderButton(calendar)
    }
    
    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if isRepeatWeek(visibleDates) {
            if isForwardDirect(calendar.contentOffset.x) {
                doForward(visibleDates)
            } else {
                doBackward(visibleDates)
            }
        }
        
        offsetX = calendar.contentOffset.x
    }
    
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        header.configure(calendar, and: visibleDates)
        self.visibleDates = visibleDates
    }
}

// MARK: - Private
extension ViewController {
    private func setupCalendar() {
        calendarView.scrollDirection = .horizontal
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.allowsMultipleSelection = false
    }

    private func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? CalendarDateCell else { return }
        let lectures = getLectures(cellState)
        cell.configure(with: cellState, lectures: lectures)
    }
    
    private func getLectures(_ cellState: CellState) -> [Lecture]? {
        let dateString = cellState.date.startOfDay.stringFormat("yyyy/MM/dd")
        return course?[dateString]
    }
    
    private func doForward(_ visibleDates: DateSegmentInfo) {
        let currect = visibleDates.getDisplayDate().start.dateByAddDays(-7)
        if currect < Date().startOfDay {
            self.calendarView.scrollToDate(Date(), animateScroll: true)
        } else {
            self.calendarView.scrollToDate(currect, animateScroll: true)
        }
    }
    
    private func doBackward(_ visibleDates: DateSegmentInfo) {
        let currect = visibleDates.getDisplayDate().end.dateByAddDays(1)
        calendarView.scrollToDate(currect, animateScroll: true)
    }
    
    private func isRepeatWeek(_ visibleDates: DateSegmentInfo) -> Bool {
        return visibleDates.getDisplayDate().start == self.visibleDates?.getDisplayDate().start
    }
    
    private func isForwardDirect(_ x: CGFloat) -> Bool {
        return offsetX > x
    }
}
