//
//  SecondViewController.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/2/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var myView: UIView!
    var detailBook: Book?
    var bookID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(bookID)
        loadDetails(id: bookID)
        loadImage(id: bookID)
        if(detailBook!.fav == true){
            view.setGradientBackground(colorOne: UIColor.white, colorTwo: UIColor.systemBlue)
            favButton.setTitle("Unfavorite", for: .normal)
        }
        else{
            favButton.setTitle("Favorite", for: .normal)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func favChange(_ sender: UIButton) {
        if(detailBook!.fav == false){
            detailBook!.setFav(true)
            BookManager.sharedInstance.favSet(book: detailBook!)
            favButton.setTitle("Unfavorite", for: .normal)
        }
        else if(detailBook!.fav == true) {
            //favorite = false
            detailBook!.setFav(false)
            BookManager.sharedInstance.favSet(book: detailBook!)
            favButton.setTitle("Favorite", for: .normal)
        }
    }
    
    func loadDetails(id: String) {
        try? BookManager.sharedInstance.getDetails(withID: id, { (bookDetails) in
            DispatchQueue.main.async {
                var bookSummary = bookDetails.title ?? "Title not available"
                bookSummary += "\n\nPublished: " + self.formatDate(date: bookDetails.publicationDate)
                bookSummary += "\nISBN: " + (bookDetails.ISBN ?? "Not available")
                
                if let title = bookDetails.title {
                    self.title = title
                }
                
                self.titleLabel.text = bookSummary
                self.descLabel.attributedText = self.formatDescription(description: bookDetails.description ?? "Description not available")
                
                /*DispatchQueue.main.async {
                    self.resizeViews()
                }*/
            }
        })
    }
    func loadImage(id: String) {
        try? BookManager.sharedInstance.getImage(withID: id, { (data) in
            DispatchQueue.main.async {
                self.bookImage.image = UIImage(data: data)
            }
        })
    }
    func formatDate(date: Date?) -> String {
        if date != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            return dateFormatter.string(from: date!)
        } else {
            return "Not available"
        }
    }
    func formatDescription(description: String) -> NSAttributedString {
        let data = description.data(using: String.Encoding.unicode)! // mind "!"
        return try! NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
    }


}

