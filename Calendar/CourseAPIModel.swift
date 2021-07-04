//
//  CourseAPIModel.swift
//  Calendar
//
//  Created by ice on 2021/7/3.
//

import Foundation

struct CourseAPIModel {
    struct ClassModel: Codable {
        var available: [EventDate]
        var booked: [EventDate]
        
        static func convert(with json: String) -> ClassModel? {
            guard let data = json.data(using: .utf8) else {
                return nil
            }
            
            return convert(with: data)
        }
        
        static func convert(with data: Data?) -> ClassModel? {
            guard let data = data else {
                return nil
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let model = try decoder.decode(ClassModel.self, from: data)
                return model
            } catch {
                print("\(error)")
                return nil
            }
        }
        
        func expandEvents() -> [String: [Lecture]] {
            func generateKey(with date: Date) -> String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                return formatter.string(from: date)
            }
            
            func nextStep(_ date: inout Date) {
                date = date.dateByAddSeconds(60*30)
            }
            
            func saveLectureSchedule(_ result: inout [String: [Lecture]], lesson: EventDate, booked: Bool) {
                var temp = lesson.start
                while temp < lesson.end {
                    let key = generateKey(with: temp)
                    var value: [Lecture] = result[key] ?? []
                    value.append(Lecture(start: temp, booked: booked))
                    result[key] = value
                    nextStep(&temp)
                }
            }
            
            func sortSchedule(_ result: inout [String: [Lecture]]) {
                for key in result.keys {
                    let value = result[key]
                    result[key] = value?.sorted(by: { $0.start < $1.start })
                }
            }
            
            var result = [String: [Lecture]]()
            for lesson in available {
                saveLectureSchedule(&result, lesson: lesson, booked: false)
            }
            
            for book in booked {
                saveLectureSchedule(&result, lesson: book, booked: true)
            }
            
            sortSchedule(&result)
            
            return result
        }
    }
    
    struct EventDate: Codable {
        var start: Date
        var end: Date
    }
}
