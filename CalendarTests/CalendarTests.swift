//
//  CalendarTests.swift
//  CalendarTests
//
//  Created by ice on 2021/7/3.
//

import XCTest
@testable import Calendar

class CalendarTests: XCTestCase {
    var session: NetworkSessionMock!
    var manager: NetworkManager!
    
    override func setUpWithError() throws {
        session = NetworkSessionMock()
        manager = NetworkManager(session: session)
    }

    override func tearDownWithError() throws {
        session = nil
        manager = nil
    }
    
    func testClassModelConvert() throws {
        let model = CourseAPIModel.ClassModel.convert(with: testJson)
        XCTAssertEqual(model?.available.count, 8)
        XCTAssertEqual(model?.booked.count, 3)
    }
    
    func testAPIMock() throws {
        let promise = expectation(description: "Completion handler invoked")
        
        let data = testJson.data(using: .utf8)
        session.data = data
        
        let url = URL(fileURLWithPath: "url")
        var model: CourseAPIModel.ClassModel?
        manager.loadData(from: url) { result in
            model = result
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 5)
        XCTAssertEqual(model?.available.count, 8)
        XCTAssertEqual(model?.booked.count, 3)
    }
    
    func testExpandSchedule() throws {
        let json = """
            {
              "available": [
                {
                  "start": "2020-07-04T08:30:00Z",
                  "end": "2020-07-04T16:00:00Z"
                },
                {
                  "start": "2020-07-05T08:30:00Z",
                  "end": "2020-07-05T16:00:00Z"
                },
                {
                  "start": "2020-07-06T08:30:00Z",
                  "end": "2020-07-06T16:00:00Z"
                }
              ],
              "booked": [
                {
                  "start": "2999-07-24T17:30:00Z",
                  "end": "2999-07-24T18:30:00Z"
                },
                {
                  "start": "2999-07-27T17:00:00Z",
                  "end": "2999-07-27T17:30:00Z"
                },
                {
                  "start": "2999-07-28T11:00:00Z",
                  "end": "2999-07-28T11:30:00Z"
                }
              ]
            }
            """
        let model = CourseAPIModel.ClassModel.convert(with: json)
        let result = model?.expandSchedule()
        XCTAssertEqual(result?.keys.count, 2)
    }
    
    func testExpandFilterOlderSchedule() throws {
        let json = """
            {
              "available": [
                {
                  "start": "2020-07-04T08:30:00Z",
                  "end": "2020-07-04T16:00:00Z"
                },
                {
                  "start": "2020-07-05T08:30:00Z",
                  "end": "2020-07-05T16:00:00Z"
                },
                {
                  "start": "2020-07-06T08:30:00Z",
                  "end": "2020-07-06T16:00:00Z"
                }
              ],
              "booked": [
                {
                  "start": "2020-07-24T17:30:00Z",
                  "end": "2020-07-24T18:30:00Z"
                },
                {
                  "start": "2020-07-27T17:00:00Z",
                  "end": "2020-07-27T17:30:00Z"
                },
                {
                  "start": "2020-07-28T11:00:00Z",
                  "end": "2020-07-28T11:30:00Z"
                }
              ]
            }
            """
        let model = CourseAPIModel.ClassModel.convert(with: json)
        let result = model?.expandSchedule()
        XCTAssertEqual(result?.keys.count, 0)
    }

    func testPerformanceExample() throws {
        measure {
            let promise = expectation(description: "Completion handler invoked")
            
            let data = testJson.data(using: .utf8)
            session.data = data
            
            let url = URL(fileURLWithPath: "url")
            var model: CourseAPIModel.ClassModel?
            manager.loadData(from: url) { result in
                model = result
                _ = model?.expandSchedule()
                promise.fulfill()
            }
            
            wait(for: [promise], timeout: 5)
        }
    }

    func testInvaildData() throws {
        let promise = expectation(description: "Completion handler invoked")
        
        let json = """
            {
              "available": [
                {
                  "start": "2021-07-23T08:30:00Z",
                  "end": "2021-07-23T16:00:00Z"
                }
              ],
              "booked": ""
            }
            """
        let data = json.data(using: .utf8)
        session.data = data
        
        let url = URL(fileURLWithPath: "url")
        var model: CourseAPIModel.ClassModel?
        manager.loadData(from: url) { result in
            model = result
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 5)
        XCTAssertNil(model)
    }
    
    func testExpandSchedule2() throws {
        let json = """
            {
              "available": [
                {
                  "start": "2021-07-23T08:30:00Z",
                  "end": "2021-07-23T10:00:00Z"
                }
              ],
              "booked": [
              ]
            }
            """
        let model = CourseAPIModel.ClassModel.convert(with: json)
        let result = model?.expandSchedule()
        XCTAssertEqual(result?.keys.count, 1)
        XCTAssertEqual(result?.keys.first, "2021/07/23")
        XCTAssertEqual(result?[(result?.keys.first)!]?.count, 3)
    }
}
