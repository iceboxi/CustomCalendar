//
//  CalendarDateCell.swift
//  Calendar
//
//  Created by ice on 2021/7/4.
//

import Foundation
import JTAppleCalendar

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
        
        setupColor(with: cellState)
        drawTime(with: lectures)
    }
    
    private func drawTime(with lectures: [Lecture]?) {
        lectures?.forEach({ lecture in
            let lbl = getCutsomLabel()
            lbl.text = lecture.start.stringFormat("HH:mm")
            lbl.textColor = lecture.booked ? .lightGray : .green
            eventStack.addArrangedSubview(lbl)
        })
    }
    
    private func getCutsomLabel() -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.contentMode = .center
        return lbl
    }
    
    private func setupColor(with cellState: CellState) {
        if isExpire(cellState.date) {
            setAsExpire()
        } else {
            setAsVaild()
        }
    }
    
    private func isExpire(_ date: Date) -> Bool {
        return date < Date().startOfDay
    }
    
    private func setAsExpire() {
        dayColor.backgroundColor = .lightGray
        dayLabel.textColor = .lightGray
        dateLabel.textColor = .lightGray
    }
    
    private func setAsVaild() {
        dayColor.backgroundColor = .green
        dayLabel.textColor = .black
        dateLabel.textColor = .black
    }
}
