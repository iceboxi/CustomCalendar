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
