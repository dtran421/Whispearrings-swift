//
//  Whisper+CoreDataProperties.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/6/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//
//

import Foundation
import CoreData


extension Whisper {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Whisper> {
        return NSFetchRequest<Whisper>(entityName: "Whisper")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var soundFile: String?
    @NSManaged public var type: String?
    @NSManaged public var value: String?
    @NSManaged public var times: NSSet?
    @NSManaged public var queue: QueueArray?

}

// MARK: Generated accessors for times
extension Whisper {

    @objc(addTimesObject:)
    @NSManaged public func addToTimes(_ value: Time)

    @objc(removeTimesObject:)
    @NSManaged public func removeFromTimes(_ value: Time)

    @objc(addTimes:)
    @NSManaged public func addToTimes(_ values: NSSet)

    @objc(removeTimes:)
    @NSManaged public func removeFromTimes(_ values: NSSet)

}
