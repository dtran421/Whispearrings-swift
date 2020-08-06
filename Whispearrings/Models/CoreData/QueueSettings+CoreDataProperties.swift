//
//  QueueSettings+CoreDataProperties.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/6/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//
//

import Foundation
import CoreData


extension QueueSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueSettings> {
        return NSFetchRequest<QueueSettings>(entityName: "QueueSettings")
    }

    @NSManaged public var timing: Int16
    @NSManaged public var randomTiming: Bool
    @NSManaged public var shufflePlay: Bool
    @NSManaged public var repeatPlay: Bool

}
