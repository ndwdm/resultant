//
//  DataSourceManager.swift
//  resultant
//
//  Created by Gennady Dmitrik on 06.08.2018.
//  Copyright © 2018 Gennady Dmitrik. All rights reserved.
//

import Foundation

typealias DataSource = DataSourceManager

final class DataSourceManager {
    static let shared = DataSourceManager()
    var quotesData: [[String: AnyObject]] = []
}
