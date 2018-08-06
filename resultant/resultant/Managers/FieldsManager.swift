//
//  FieldsManager.swift
//  resultant
//
//  Created by Gennady Dmitrik on 06.08.2018.
//  Copyright © 2018 Gennady Dmitrik. All rights reserved.
//

import Foundation

typealias Fields = FieldsManager

struct FieldsManager {
    static let stock = "stock"                                                    // - main data key
    static let name = "name"                                                      // - currency name
    static let price = "price"                                                    // - price
    static let currency = "currency"                                              // - currency key
    static let volume = "volume"                                                  // - volume
    static let amount = "amount"                                                  // - amount
    static let symbol = "symbol"                                                  // - currency short name
    static let data = "data"                                                      // -
    
    static let didStartRefreshNotification = Notification.Name(rawValue: "didStartRefreshNotification")
    static let didEndRefreshNotification = Notification.Name(rawValue: "didEndRefreshNotification")
}
