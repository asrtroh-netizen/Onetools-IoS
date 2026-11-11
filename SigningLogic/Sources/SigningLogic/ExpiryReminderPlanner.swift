import Foundation

public struct ExpirySubject: Equatable {
    public let id: String
    public let expiresOn: Date

    public init(id: String, expiresOn: Date) {
        self.id = id
        self.expiresOn = expiresOn
    }
}

public enum ExpiryNotice: Equatable {
    case sevenDays
    case oneDay
}

public struct ExpiryReminder: Equatable {
    public let id: String
    public let notice: ExpiryNotice

    public init(id: String, notice: ExpiryNotice) {
        self.id = id
        self.notice = notice
    }
}

public enum ExpiryReminderPlanner {
    public static func reminders(
        for subjects: [ExpirySubject],
        on today: Date,
        calendar: Calendar = .current
    ) -> [ExpiryReminder] {
        var sent: Set<String> = []
        var reminders: [ExpiryReminder] = []
        for subject in subjects {
            guard let notice = notice(for: subject.expiresOn, on: today, calendar: calendar) else {
                continue
            }
            guard sent.insert(subject.id).inserted else {
                continue
            }
            reminders.append(ExpiryReminder(id: subject.id, notice: notice))
        }
        return reminders
    }

    private static func notice(
        for expiration: Date,
        on today: Date,
        calendar: Calendar
    ) -> ExpiryNotice? {
        guard let days = calendarDays(from: today, to: expiration, calendar: calendar) else {
            return nil
        }
        if days == 7 {
            return .sevenDays
        }
        if days == 1 {
            return .oneDay
        }
        return nil
    }

    private static func calendarDays(
        from today: Date,
        to expiration: Date,
        calendar: Calendar
    ) -> Int? {
        let startParts = calendar.dateComponents([.year, .month, .day], from: today)
        let endParts = calendar.dateComponents([.year, .month, .day], from: expiration)
        guard
            let start = calendar.date(from: startParts),
            let end = calendar.date(from: endParts)
        else {
            return nil
        }
        return calendar.dateComponents([.day], from: start, to: end).day
    }
}
