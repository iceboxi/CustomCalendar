//
//  NetworkManager.swift
//  Calendar
//
//  Created by ice on 2021/7/4.
//

import Foundation

enum NetworkResult {
    case success
    case failure(Error?)
}

protocol NetworkSession {
    func loadData(from url: URL,
                  completionHandler: @escaping (Data?, Error?) -> Void)
}

extension URLSession: NetworkSession {
    func loadData(from url: URL,
                  completionHandler: @escaping (Data?, Error?) -> Void) {
        let task = dataTask(with: url) { (data, _, error) in
            completionHandler(data, error)
        }

        task.resume()
    }
}

class NetworkManager {
    private let session: NetworkSession

    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }

    func loadData(from url: URL,
                  completionHandler: @escaping (CourseAPIModel.ClassModel?) -> Void) {
        session.loadData(from: url) { data, error in
            let result = CourseAPIModel.ClassModel.convert(with: data)
            completionHandler(result)
        }
    }
}

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var error: Error?

    func loadData(from url: URL,
                  completionHandler: @escaping (Data?, Error?) -> Void) {
        completionHandler(data, error)
    }
}

let testJson = """
    {
      "available": [
        {
          "start": "2021-07-04T08:30:00Z",
          "end": "2021-07-04T16:00:00Z"
        },
        {
          "start": "2021-07-05T08:30:00Z",
          "end": "2021-07-05T16:00:00Z"
        },
        {
          "start": "2021-07-06T08:30:00Z",
          "end": "2021-07-06T16:00:00Z"
        },
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
