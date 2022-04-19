//
//  Note+CoreDataClass.swift
//  ExtralogicTestTask
//
//  Created by Илья Андреев on 18.04.2022.
//
//

import Foundation
import CoreData


public final class Note: NSManagedObject {
    var modificationDescription: String {
        "Created at: " + created.inShortFormat() + ", modified at: " + changed.inShortFormat() + "."
    }
}
