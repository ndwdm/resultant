//
//  APIManager.swift
//  resultant
//
//  Created by Gennady Dmitrik on 06.08.2018.
//  Copyright © 2018 Gennady Dmitrik. All rights reserved.
//

import Foundation

typealias Dict = [String: AnyObject]

enum APIResult: Equatable {
    case success
    case failure
    case error
}

func == (result1: APIResult, result2: APIResult) -> Bool {
    switch (result1, result2) {
    case (.success, .success): return true
    case (.failure, .failure): return true
    case (.error, .error): return true
    default: return false
    }
}

class APIManager: NSObject {
    let baseUrl = "http://phisix-api3.appspot.com/"
    static let shared = APIManager()
    var isRefreshing = false
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 0
        config.timeoutIntervalForResource = 0
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    var quotesRefreshTimer = Timer()
    
    fileprivate override init() {
        super.init()
        quotesRefreshTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(refreshQuotesData), userInfo: nil, repeats: true)
    }
   
    @objc func refreshQuotesData() {
        print(">>>>trying to start update")
        if !isRefreshing {
            getQuotesData { (_, _) in }
        }
    }
    
    func getQuotesData(_ callback:@escaping (_ result: APIResult, _ info: Dict?) -> Void) {
        isRefreshing = true
        NotificationCenter.default.post(name: Fields.didStartRefreshNotification, object: nil, userInfo: ["state": ""])
        print(">>>>started update...")
        let url = baseUrl + "stocks.json"
        var request = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json;charset=UTF-8;text/plain", forHTTPHeaderField: "Accept")
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.isRefreshing = false
            guard let httpUrlResponse = response as? HTTPURLResponse else {
                if error?._code ==  NSURLErrorTimedOut {
                    print("time out")
                    callback(.error, nil)
                }
                NotificationCenter.default.post(name: Fields.didEndRefreshNotification, object: nil, userInfo: ["state": "error"])
                callback(.error, error?._userInfo as? Dict)
                return
            }
            switch httpUrlResponse.statusCode {
            case 200:
                if let jsonDictionary = self.dictFromResponse(data, response: response, error: error as NSError?), let data = jsonDictionary[Fields.stock] {
                    DataSource.shared.quotesData = data as! [[String : AnyObject]]
                    callback(.success, jsonDictionary)
                } else {
                    callback(.error, nil)
                }
            case 404:
                callback(.failure, nil)
            default:
                callback(.error, nil)
            }
            NotificationCenter.default.post(name: Fields.didEndRefreshNotification, object: nil, userInfo: ["state": httpUrlResponse.statusCode != 200 ? "error" : ""])
        })
        task.resume()
    }
    
    func dictFromResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> Dict? {
        guard let httpUrlResponse = response as? HTTPURLResponse else {
            print("there was a problem converting the response to HTTP. \nError = \(String(describing: error))")
            return nil
        }
        print("httpUrlResponse.statusCode = \(httpUrlResponse.statusCode)")
        if error != nil {
            print("There was an error processing the request")
            print("Error: \(String(describing: error))")
            print("Response: \(String(describing: response))")
        }
        guard let dataUnwrapped = data, dataUnwrapped.count > 0 else {
            print("Response data was nil")
            return nil
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: dataUnwrapped, options: JSONSerialization.ReadingOptions(rawValue: 0)) else {
            print("Error reading JSON response data from API call")
            return nil
        }
        var needObject = jsonObject
        if let array = needObject as? [AnyObject] {
            needObject = [Fields.data: array]
        }
        guard let jsonDictionary = needObject as? Dict else {
            print("Error converting JSON NSDictionary to Swift Dictionary")
            return nil
        }
        return jsonDictionary
    }
}

extension APIManager: URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {}
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {}
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard response is HTTPURLResponse else { return }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didComplete error: NSError?) {}
}
