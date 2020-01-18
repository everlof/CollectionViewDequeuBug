//
//  Test+CoreDataProperties.swift
//  CollectionViewBug
//
//  Created by David Everlöf on 2020-01-18.
//  Copyright © 2020 David Everlöf. All rights reserved.
//
//

import Foundation
import CoreData


extension Test {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Test> {
        return NSFetchRequest<Test>(entityName: "Test")
    }

    @NSManaged public var a: String?
    @NSManaged public var b: String?

}
