//
//  CalendarDateHeader.swift
//  Calendar
//
//  Created by ice on 2021/7/4.
//

import UIKit

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
