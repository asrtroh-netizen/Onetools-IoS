import Foundation
import XCTest
@testable import SigningLogic

final class ExpiryReminderTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private func day(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))
        precondition(date != nil)
        return date!
    }

    func testExactlySevenDaysSendsOneReminder() {
        let today = day(2026, 11, 12)
        let subjects = [ExpirySubject(id: "cert-a", expiresOn: day(2026, 11, 19, hour: 1))]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [ExpiryReminder(id: "cert-a", notice: .sevenDays)])
    }

    func testExactlyOneDaySendsOneReminder() {
        let today = day(2026, 11, 30, hour: 23)
        let subjects = [ExpirySubject(id: "profile-a", expiresOn: day(2026, 12, 1, hour: 0))]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [ExpiryReminder(id: "profile-a", notice: .oneDay)])
    }

    func testExpiredBeforeTodaySendsNothing() {
        let today = day(2026, 11, 12)
        let subjects = [
            ExpirySubject(id: "yesterday", expiresOn: day(2026, 11, 11, hour: 23)),
            ExpirySubject(id: "last-year", expiresOn: day(2025, 11, 12)),
        ]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [])
    }

    func testExpiresTodaySendsNothing() {
        let today = day(2026, 11, 12, hour: 8)
        let subjects = [ExpirySubject(id: "today", expiresOn: day(2026, 11, 12, hour: 1))]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [])
    }

    func testSixDaysSendsNothing() {
        let today = day(2026, 11, 12)
        let subjects = [ExpirySubject(id: "six", expiresOn: day(2026, 11, 18))]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [])
    }

    func testOtherDistancesSendNothing() {
        let today = day(2026, 11, 12)
        let subjects = [
            ExpirySubject(id: "two", expiresOn: day(2026, 11, 14)),
            ExpirySubject(id: "eight", expiresOn: day(2026, 11, 20)),
            ExpirySubject(id: "thirty", expiresOn: day(2026, 12, 12)),
        ]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [])
    }

    func testTimeOfDayDoesNotChangeTheCalendarDistance() {
        let today = day(2026, 11, 12, hour: 23)
        let subjects = [ExpirySubject(id: "cert-a", expiresOn: day(2026, 11, 19, hour: 0))]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [ExpiryReminder(id: "cert-a", notice: .sevenDays)])
    }

    func testSameCertificateOnTheSameDaySendsOnlyOneReminder() {
        let today = day(2026, 11, 12)
        let expiry = day(2026, 11, 13)
        let subjects = [
            ExpirySubject(id: "cert-a", expiresOn: expiry),
            ExpirySubject(id: "cert-a", expiresOn: day(2026, 11, 19)),
        ]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [ExpiryReminder(id: "cert-a", notice: .oneDay)])
    }

    func testCertificateAndProfileOnExactDaysBothSend() {
        let today = day(2026, 11, 28, hour: 15)
        let subjects = [
            ExpirySubject(id: "cert", expiresOn: day(2026, 12, 5, hour: 1)),
            ExpirySubject(id: "profile", expiresOn: day(2026, 11, 29, hour: 22)),
            ExpirySubject(id: "expired", expiresOn: day(2026, 11, 27)),
            ExpirySubject(id: "due-today", expiresOn: day(2026, 11, 28, hour: 1)),
            ExpirySubject(id: "six", expiresOn: day(2026, 12, 4)),
        ]
        let reminders = ExpiryReminderPlanner.reminders(for: subjects, on: today, calendar: calendar)
        XCTAssertEqual(reminders, [
            ExpiryReminder(id: "cert", notice: .sevenDays),
            ExpiryReminder(id: "profile", notice: .oneDay),
        ])
    }
}
