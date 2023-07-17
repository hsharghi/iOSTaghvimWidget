//
//  DateConvertor.swift
//  TaghvimWidgetExtension
//
//  Created by Hadi Sharghi on 7/18/23.
//

import Foundation

enum CalendarType {
    case gregorain
    case qamari
    case shamsi
}

struct DateConverter {
    var currentCalendar: CalendarType
    var currentDate: Date
    
    init(calendar: CalendarType? = nil, date: Date = .init()) {
        self.currentCalendar = calendar ?? .shamsi
        self.currentDate = date
    }
    
    func dateDisplayText() -> String {
        let components = calendar.dateComponents(in: .current, from: currentDate)
        return "\(components.year!)/\(components.month!)/\(components.day!)"
    }
    
    func getDateComponents() -> DateComponents {
        return calendar.dateComponents(in: .current, from: currentDate)
    }
    
    var year: String {
        "\(getDateComponents().year!)".convertedDigitsToLocale(.init(identifier: calendar.locale!.identifier))
    }
    var month: String {
        "\(getDateComponents().month!)".convertedDigitsToLocale(.init(identifier: calendar.locale!.identifier))
    }
    var day: String {
        "\(getDateComponents().day!)".convertedDigitsToLocale(.init(identifier: calendar.locale!.identifier))
    }
    var weekday: String {
        "\(getDateComponents().weekday!)".convertedDigitsToLocale(.init(identifier: calendar.locale!.identifier))
    }
    var weekdayAsText: String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        return formatter.weekdaySymbols[calendar.component(.weekday, from: currentDate) - 1]
    }
    var monthAsText: String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        return formatter.monthSymbols[calendar.component(.month, from: currentDate) - 1]
    }

    var calendar: Calendar {
        var calendar: Calendar
        switch currentCalendar {
        case .gregorain:
            calendar = Calendar.init(identifier: .gregorian)
            calendar.locale = Locale.init(identifier: "en_US")
        case .shamsi:
            calendar = Calendar.init(identifier: .persian)
            calendar.locale = Locale.init(identifier: "fa_IR")
        case .qamari:
            calendar = Calendar.init(identifier: .islamicUmmAlQura)
            calendar.locale = Locale.init(identifier: "ar_SA")
        }
        return calendar
    }
}

extension String {
    private static let formatter = NumberFormatter()

    func clippingCharacters(in characterSet: CharacterSet) -> String {
        components(separatedBy: characterSet).joined()
    }

    func convertedDigitsToLocale(_ locale: Locale = .current) -> String {
        let digits = Set(clippingCharacters(in: CharacterSet.decimalDigits.inverted))
        guard !digits.isEmpty else { return self }

        Self.formatter.locale = locale
        let maps: [(original: String, converted: String)] = digits.map {
            let original = String($0)
            guard let digit = Self.formatter.number(from: String($0)) else {
                assertionFailure("Can not convert to number from: \(original)")
                return (original, original)
            }
            guard let localized = Self.formatter.string(from: digit) else {
                assertionFailure("Can not convert to string from: \(digit)")
                return (original, original)
            }
            return (original, localized)
        }

        var converted = self
        for map in maps { converted = converted.replacingOccurrences(of: map.original, with: map.converted) }
        return converted
    }
}
