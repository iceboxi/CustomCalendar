//
//  CalendarDateHeader.swift
//  Calendar
//
//  Created by ice on 2021/7/4.
//

import UIKit
import JTAppleCalendar

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
    
    func configure(_ calendar: JTACMonthView, and visibleDates: DateSegmentInfo) {
        setupTimeRange(visibleDates)
        setupHeaderButton(calendar)
    }
    
    func setupHeaderButton(_ calendar: JTACMonthView) {
        let forwardStatus = calendar.contentOffset.x <= 0
        setupForwardButton(forwardStatus)
        
        let backwardStatus = calendar.contentOffset.x >= calendar.contentSize.width - UIScreen.main.bounds.width
        setupBackwardButton(backwardStatus)
    }
}

// MARK: - Action
extension CalendarDateHeader {
    @IBAction func backwardAction() {
        backwardHandler?()
    }
    
    @IBAction func forwardAction() {
        forwardHandler?()
    }
}

// MARK: - Private
extension CalendarDateHeader {
    private func setupForwardButton(_ status: Bool) {
        forward.isEnabled = !status
        forward.tintColor = status ? .lightGray : .darkGray
    }
    
    private func setupBackwardButton(_ status: Bool) {
        backward.isEnabled = !status
        backward.tintColor = status ? .lightGray : .darkGray
    }
    
    private func setupTimeRange(_ visibleDates: DateSegmentInfo) {
        let (start, end) = visibleDates.getDisplayDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd - "
        
        var str = formatter.string(from: start)
        formatter.dateFormat = "dd"
        str.append(formatter.string(from: end))
        
        timeRange.text = str
    }
}
