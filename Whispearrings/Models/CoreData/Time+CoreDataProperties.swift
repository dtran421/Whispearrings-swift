//
//  Time+CoreDataProperties.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/6/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//
//

import Foundation
import CoreData


extension Time {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Time> {
        return NSFetchRequest<Time>(entityName: "Time")
    }

    @NSManaged public var time: String?
    @NSManaged public var whisper: Whisper?

}
