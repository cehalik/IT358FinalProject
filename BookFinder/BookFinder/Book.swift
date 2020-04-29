//
//  Book.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Book {
    var title: String
    var author: String
    var id: String
    var fav: Bool
    init?(title: String, author: String, id: String, fav: Bool = false){
        self.title = title
        self.author = author
        self.id = id
        self.fav = fav
    }
    mutating public func setFav(_ fav: Bool){
        self.fav = fav
    }
}
