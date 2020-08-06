//
//  QueueArray+CoreDataProperties.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/6/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueArray {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueArray> {
        return NSFetchRequest<QueueArray>(entityName: "QueueArray")
    }

    @NSManaged public var queue: NSSet?

}

// MARK: Generated accessors for queue
extension QueueArray {

    @objc(insertObject:inQueueAtIndex:)
    @NSManaged public func insertIntoQueue(_ value: Whisper, at idx: Int)

    @objc(removeObjectFromQueueAtIndex:)
    @NSManaged public func removeFromQueue(at idx: Int)

    @objc(insertQueue:atIndexes:)
    @NSManaged public func insertIntoQueue(_ values: [Whisper], at indexes: NSIndexSet)

    @objc(removeQueueAtIndexes:)
    @NSManaged public func removeFromQueue(at indexes: NSIndexSet)

    @objc(replaceObjectInQueueAtIndex:withObject:)
    @NSManaged public func replaceQueue(at idx: Int, with value: Whisper)

    @objc(replaceQueueAtIndexes:withQueue:)
    @NSManaged public func replaceQueue(at indexes: NSIndexSet, with values: [Whisper])

    @objc(addQueueObject:)
    @NSManaged public func addToQueue(_ value: Whisper)

    @objc(removeQueueObject:)
    @NSManaged public func removeFromQueue(_ value: Whisper)

    @objc(addQueue:)
    @NSManaged public func addToQueue(_ values: NSSet)

    @objc(removeQueue:)
    @NSManaged public func removeFromQueue(_ values: NSSet)

}
