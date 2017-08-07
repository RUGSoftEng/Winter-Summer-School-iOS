//
//  DateManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/13/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation

// MARK: - Enumerations
enum DateFormat: String {
    case eventPacketDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case eventDateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
    case scheduleEventDateFormat = "MMM d, HH:mm"
    case announcementDateFormat = "dd/MM/yyyy"
}

final class DateManager {
    
    // MARK: - Variables & Constants
    
    /// Singleton instance
    static let sharedInstance = DateManager()
    
    /// DateFormatter
    var dateFormatter: DateFormatter!
    
    /// StringFormatter
    var stringFormatter: DateFormatter!
    
    /// Calendar
    var calendar: Calendar!
    
    // MARK: - Private Methods
    
    
    
    // MARK: - Public Methods
    
    /// Returns the time for a given Date instance.
    ///
    /// - Parameters:
    ///     - date: The Date instance.
    func hoursAndMinutesFromDate(_ date: Date?) -> String? {
        if (date == nil) {
            return nil
        }
        stringFormatter.dateFormat = "HH:mm"
        let dateString: String = stringFormatter.string(from: date!)
        stringFormatter.dateStyle = .full
        return dateString
    }
    
    /// Returns the date without the weekday for a given
    /// Date instance.
    ///
    /// - Parameters:
    ///     - date: The Date instance.
    func longStyleDateFromDate(_ date: Date?) -> String? {
        if (date == nil) {
            return nil;
        }
        stringFormatter.dateFormat = "EEEE, MMMM d"
        let dateString: String = stringFormatter.string(from: date!)
        stringFormatter.dateStyle = .full
        return dateString
    }
    
    /// Returns the day of the week as a string for a given Date
    /// instance.
    ///
    /// - Parameters:
    ///     - date: The Date instance.
    func weekDayFromDate(_ date: Date?) -> String? {
        if (date == nil) {
            return nil;
        }
        stringFormatter.dateFormat = "EEEE"
        let day: String = stringFormatter.string(from: date!)
        stringFormatter.dateStyle = .full
        return day
    }
    
    /// Attempts to convert an ISO-8601
    /// dateTime string to a Swift Date instance.
    ///
    /// - Parameters:
    ///     - string: The ISO-8601 date string.
    func ISOStringToDate(_ string: String?, format: DateFormat) -> Date? {
        dateFormatter.dateFormat = format.rawValue
        return (string == nil) ? nil : dateFormatter.date(from: string!)
    }
    
    /// Attempts to convert a Swift Date instance
    /// to an ISO-8601 dateTime string.
    ///
    /// - Parameters:
    ///     - date: The Date instance.
    func dateToISOString(_ date: Date?, format: DateFormat) -> String? {
        dateFormatter.dateFormat = format.rawValue
        return (date == nil) ? nil : dateFormatter.string(from: date!)
    }
    
    // MARK: - Class Method Overrides
    
    required init() {
        
        // Initialize, set dateFormatter.
        dateFormatter = DateFormatter();
        
        // Initialize stringFormatter to produce desired strings.
        stringFormatter = DateFormatter();
        stringFormatter.dateStyle = .full
        
        // Initialize calendar
        calendar = Calendar(identifier: .gregorian)
    }
    
}
