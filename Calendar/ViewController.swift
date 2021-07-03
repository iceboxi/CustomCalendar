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
    
    private var testModel = EventModel.test()?.expandEvents() ?? [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.scrollDirection = .horizontal
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.allowsMultipleSelection = false
        
        let test = EventModel.test()
        print("\(test)")
        print("\(test?.expandEvents())")
    }

    private func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? CalendarDateCell else { return }
        let dateString = cellState.date.startOfDay.stringFormat("yyyy/MM/dd")
        cell.configure(with: cellState, lectures: testModel[dateString])
    }
}

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

class CalendarDateCell: JTACDayCell {
    @IBOutlet weak var dayColor: UIView! 
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        eventStack.removeAllArrangedSubviews()
    }
    
    func configure(with cellState: CellState, lectures: [Lecture]?) {
        dateLabel.text = cellState.text
        dayLabel.text = cellState.day.desription
        
        if cellState.date < Date().startOfDay {
            dayColor.backgroundColor = .lightGray
            dayLabel.textColor = .lightGray
            dateLabel.textColor = .lightGray
        } else {
            dayColor.backgroundColor = .green
            dayLabel.textColor = .black
            dateLabel.textColor = .black
        }
        
        lectures?.forEach({ lecture in
            let lbl = UILabel()
            lbl.text = lecture.start.stringFormat("HH:mm")
            lbl.textColor = lecture.booked ? .lightGray : .green
            lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            lbl.contentMode = .center
            eventStack.addArrangedSubview(lbl)
        })
    }
}

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

extension UIStackView {
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

class CalendarDateHeader: UIView {
    @IBOutlet weak var title: UILabel! {
        didSet {
            title.text = NSLocalizedString("Lesson Time", comment: "Lesson Time")
        }
    }
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var backward: UIButton!
    @IBOutlet weak var timeRange: UILabel!
    @IBOutlet weak var zone: UILabel! {
        didSet {
            let localName = TimeZone.current.localizedName(for: .shortGeneric, locale: Locale.current) ?? ""
            let abbr = TimeZone.current.abbreviation() ?? ""
            zone.text = String(format: NSLocalizedString("*time with %@(%@)", comment: "*time with %@(%@)"), localName, abbr)
        }
    }
    
    var backwardHandler: (() -> Void)?
    var forwardHandler: (() -> Void)?
    
    @IBAction func backwardAction() {
        backwardHandler?()
    }
    
    @IBAction func forwardAction() {
        forwardHandler?()
    }
}
