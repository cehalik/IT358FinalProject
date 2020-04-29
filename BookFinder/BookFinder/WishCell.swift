//
//  WishCell.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/26/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class WishCell: UITableViewCell {

    @IBOutlet weak var wishTitle: UILabel!
    
    func setWish(book: Book) {
        wishTitle.text = book.title
        
    }

}
