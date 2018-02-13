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
    case JSONGeneralDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case JSONScheduleEventDateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
    case scheduleEventDateFormat = "MMM d, HH:mm"
    case weekdayDateFormat = "EEEE, MMM d"
    case hoursAndMinutesFormat = "HH:mm"
    case generalPresentationDateFormat = "dd/MM/yyyy"
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
    
    /// Returns the starting date for a date 'n' days in the future from the given date.
    /// - Parameters:
    ///     - n: The number of days in the future.
    ///     - from: The starting date.
    func startOfDay(in n: Int, from: Date) -> Date {
        return startOfDay(for: calendar.date(byAdding: .day, value: n, to: from)!)
    }
    
    /// Returns a Date instance representing the start of the current day (inclusive!).
    /// - Parameters:
    ///     - date: The date instance.
    func startOfDay(for date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    /// Returns a Date instance representing the end of the current day (non-inclusive!)
    /// - Parameters:
    ///     - date: The date instance.
    func endOfDay(for date: Date) -> Date {
        return calendar.date(byAdding: .day, value: 1, to: startOfDay(for: date))!
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
    func ISOStringToDate(_ string: String?, format: DateFormat, timeZone: TimeZone = NSTimeZone.local) -> Date? {
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = timeZone
        return (string == nil) ? nil : dateFormatter.date(from: string!)
    }
    
    /// Attempts to convert a Swift Date instance
    /// to an ISO-8601 dateTime string.
    ///
    /// - Parameters:
    ///     - date: The Date instance.
    func dateToISOString(_ date: Date?, format: DateFormat, timeZone: TimeZone = NSTimeZone.local) -> String? {
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = timeZone
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
