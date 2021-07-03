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
        
        static func test() -> ClassModel? {
            let json = """
                {
                  "available": [
                    {
                      "start": "2021-07-23T08:30:00Z",
                      "end": "2021-07-23T16:00:00Z"
                    },
                    {
                      "start": "2021-07-24T16:00:00Z",
                      "end": "2021-07-24T17:30:00Z"
                    },
                    {
                      "start": "2021-07-24T18:30:00Z",
                      "end": "2021-07-27T17:00:00Z"
                    },
                    {
                      "start": "2021-07-27T17:30:00Z",
                      "end": "2021-07-28T11:00:00Z"
                    },
                    {
                      "start": "2021-07-28T11:30:00Z",
                      "end": "2021-07-28T17:00:00Z"
                    }
                  ],
                  "booked": [
                    {
                      "start": "2021-07-24T17:30:00Z",
                      "end": "2021-07-24T18:30:00Z"
                    },
                    {
                      "start": "2021-07-27T17:00:00Z",
                      "end": "2021-07-27T17:30:00Z"
                    },
                    {
                      "start": "2021-07-28T11:00:00Z",
                      "end": "2021-07-28T11:30:00Z"
                    }
                  ]
                }
                """
            
            guard let data = json.data(using: .utf8) else {
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
            var result = [String: [Lecture]]()
            for lesson in available {
                var temp = lesson.start
                while temp < lesson.end {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    let key = formatter.string(from: temp)
                    var value: [Lecture] = result[key] ?? []
                    value.append(Lecture(start: temp, booked: false))
                    result[key] = value
                    temp = temp.dateByAddSeconds(60*30)
                }
            }
            
            for book in booked {
                var temp = book.start
                while temp < book.end {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    let key = formatter.string(from: temp)
                    var value: [Lecture] = result[key] ?? []
                    value.append(Lecture(start: temp, booked: true))
                    result[key] = value
                    temp = temp.dateByAddSeconds(60*30)
                }
            }
            
            for key in result.keys {
                let value = result[key]
                result[key] = value?.sorted(by: { $0.start < $1.start })
            }
            
            return result
        }
    }
    
    struct EventDate: Codable {
        var start: Date
        var end: Date
    }
}

struct Lecture {
    var start: Date
    var booked: Bool
}
