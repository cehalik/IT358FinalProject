//
//  WishController.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit
import CoreData

class WishController: UIViewController, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var favBooks: [Book]?
    var myindex = 0

    override func viewDidLoad() {
        favBooks = BookManager.sharedInstance.favList()
        tableView.dataSource = self
        tableView.delegate = self
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favBooks = BookManager.sharedInstance.favList()
        self.tableView.reloadData()
    }
    
    // MARK: - Table Data
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let nflTeams = favBooks else {

            return 0
        }
        return nflTeams.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! WishCell
        if let nflTeams = favBooks {
            
            let book = nflTeams[indexPath.row]

            cell.setWish(book: book)

        }
        return cell
    }
    // MARK: - Navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myindex = indexPath.row
        let vc = storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController
        vc?.bookID = favBooks![myindex].id
        vc?.detailBook = favBooks![myindex]
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }


}
