//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Сергей Петров on 20.05.2026.
//

import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        print("DaysValueTransformer transformedValue:", type(of: value))
        guard let days = value as? [Weekday] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        print("DaysValueTransformer reverseTransformedValue:", type(of: value))
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Weekday].self, from: data as Data)
    }

    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
