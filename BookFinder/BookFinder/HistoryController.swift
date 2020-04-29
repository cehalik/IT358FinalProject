//
//  HistoryController.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HistoryController: UITableViewController {
    
    // MARK: Properties
    var history: [Book]?
    var myindex = 0
    
    override func viewDidLoad() {
        history = BookManager.sharedInstance.historyData
        super.viewDidLoad()
    }
    
    
    
    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        history = BookManager.sharedInstance.historyData
        self.tableView.reloadData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let nflTeams = history else {

            return 0
        }
        return nflTeams.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        if let nflTeams = history {
            
            let book = nflTeams[indexPath.row]

            cell.setHistory(book: book)

        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myindex = indexPath.row
        let vc = storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController
        vc?.bookID = BookManager.sharedInstance.historyData[myindex].id
        vc?.detailBook = BookManager.sharedInstance.historyData[myindex]
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
