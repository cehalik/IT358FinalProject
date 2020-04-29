//
//  BookManager.swift
//  BookFinder
//
//  Created by Beverly L Brown on 4/23/20.
//  Copyright © 2020 Chris Halikias. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct BookDetails {
    var title: String?
    var author: String?
    var description: String?
    var publicationDate: Date?
    var ISBN: String?
}

enum JSONError: Error {
    case InvalidURL(String)
    case InvalidKey(String)
    case InvalidArray(String)
    case InvalidData
    case InvalidImage
    case indexOutOfRange
    
}

class BookManager {
    public static let sharedInstance = BookManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let requestBooks = NSFetchRequest<NSFetchRequestResult>(entityName: "Book2")
    
    private static let BOOKS_URL = "https://www.googleapis.com/books/v1/volumes"
    private static let BOOK_QUERY_TEMPLATE = [
        URLQueryItem(name: "maxResults", value: "10"),
        URLQueryItem(name: "fields", value: "items(id,volumeInfo(title,authors,publishedDate))")
    ]
    
    private static let BOOK_IMAGE_URL = "https://books.google.com/books/content"
    //?printsec=frontcover&img=1&source=gbs_api
    private static let BOOK_IMAGE_QUERY_TEMPLATE = [
        URLQueryItem(name: "printsec", value: "frontcover"),
        URLQueryItem(name: "img", value: "1"),
        URLQueryItem(name: "source", value: "gbs_api")
    ]
    
    var searchData: [Book] = []
    var historyData: [Book] = []
    var favData: [Book] = []
    /*
    var initialBooks:[Book] = [
    Book(title: "Harry Potter and the Sorcer's Stone", image: #imageLiteral(resourceName: "Harry"), auth: "J.K Rowling", desc: "Dope Book", wish: false)!,
    Book(title: "Cat In the Hat", image: #imageLiteral(resourceName: "cathat"), auth: "Dr.Seuss", desc: "Good Book")!,
    Book(title: "Hunger Game", image: #imageLiteral(resourceName: "hungerGames"), auth: "Collins", desc: "Drama", wish: false)!]*/
    
    // MARK: - favorites
    func favList() -> [Book]{
        favData = historyData.filter {$0.fav == true}
        return favData
    }
    
    func favSet(book: Book){
        if let index = self.historyData.firstIndex(where: {$0.title == book.title}) {
               historyData[index] = book
            
        }
        saveBooks()
    }
    
    
    // MARK: - history
    public func addHistory(bookH: Book){
        self.historyData.append(bookH)
        saveBooks()
    }
    public func getBook(atIndex index: Int) throws -> Book {
        print(searchData[index])
        return self.searchData[index]
    }
    
    public var count: Int {
        get {
            return searchData.count;
        }
    }
    
    public func search(withText text: String, _ completion: @escaping ()->()) throws {
        let session = URLSession.shared
        
        // Generate the query for this text
        var query = BookManager.BOOK_QUERY_TEMPLATE
        query.append(URLQueryItem(name: "q", value: text))
        
        guard let booksUrl = NSURLComponents(string: BookManager.BOOKS_URL) else {
            throw JSONError.InvalidURL(BookManager.BOOKS_URL)
        }
        
        booksUrl.queryItems = query
        
        // Generate the query url from the query items
        let url = booksUrl.url!
        
        session.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                guard let items = json["items"] as! [[String: Any]]? else {
                    throw JSONError.InvalidArray("items")
                }
                
                self.searchData = []
                
                for item in items {
                    guard let id = item["id"] as! String? else {
                        throw JSONError.InvalidKey("id")
                    }
                    
                    guard let volumeInfo = item["volumeInfo"] as! [String: AnyObject]? else {
                        throw JSONError.InvalidKey("volumeInfo")
                    }
                    
                    let title = volumeInfo["title"] as? String ?? "Title not available"
                    
                    var authors = "No author information"
                
                    if let authorsArray = volumeInfo["authors"] as! [String]? {
                        authors = authorsArray.joined(separator: ", ")
                    }
                    
                    let book = Book(title: title, author: authors, id: id)
                    self.searchData.append(book!)
                    
                }
                
            } catch  {
                print("Error thrown: \(error)")
            }
            completion()
        }).resume()
    }
    
    public func getDetails(withID id: String, _ completion: @escaping (BookDetails)->()) throws {
        let session = URLSession.shared
        
        guard let bookUrl = NSURLComponents(string: BookManager.BOOKS_URL + "/" + id) else {
            throw JSONError.InvalidURL(BookManager.BOOKS_URL)
        }
        
        print(bookUrl)
        
        session.dataTask(with: bookUrl.url!, completionHandler: {(data, response, error) -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String: AnyObject]
                guard let info = json["volumeInfo"] as! [String: Any]? else {
                    throw JSONError.InvalidArray("volumeInfo")
                }
                
                let title = info["title"] as? String ?? "Title not available"
                
                var authors: String? = nil
                
                if let authorsArray = info["authors"] as! [String]? {
                    authors = authorsArray.joined(separator: ", ")
                }
                
                let description = info["description"] as? String ?? "Description not available"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                
                var pubDate: Date? = nil
                if let dateString = info["publishedDate"] as! String? {
                    print(dateString)
                    pubDate = dateFormatter.date(from: dateString)
                }
                
                var isbn: String? = nil
                if let isbns = info["industryIdentifiers"] as! [[String: Any]]? {
                    for isbnObject in isbns {
                        if let isbnType = isbnObject["type"] as! String? {
                            if isbnType == "ISBN_10" {
                                isbn = isbnObject["identifier"] as? String ?? "N/A"
                                break
                            }
                        }
                    }
                }
                
                completion(BookDetails(title: title, author: authors, description: description, publicationDate: pubDate, ISBN: isbn))
            } catch {
                print("Error thrown: \(error)")
            }
        }).resume()
    }
    
    public func getImage(withID id: String, _ completion: @escaping (Data)->()) throws {
        guard let bookUrl = NSURLComponents(string: BookManager.BOOK_IMAGE_URL) else {
            throw JSONError.InvalidURL(BookManager.BOOK_IMAGE_URL)
        }
        
        var query = BookManager.BOOK_IMAGE_QUERY_TEMPLATE
        query.append(URLQueryItem(name: "id", value: id))
        
        bookUrl.queryItems = query
        
        DispatchQueue.global(qos: .background).async {
            let data = try? Data(contentsOf: bookUrl.url!)
            completion(data!)
        }
    }
    
    
    // MARK: - Core Data Functions
    
     func saveBooks(){
         deleteAll()
         let entity = NSEntityDescription.entity(forEntityName: "Book2", in: context.viewContext)
         for book in BookManager.sharedInstance.historyData{
             let newEntity = NSManagedObject(entity: entity!, insertInto: context.viewContext)
             newEntity.setValue(book.title, forKey: "title")
             newEntity.setValue(book.author, forKey: "author")
             newEntity.setValue(book.id, forKey: "id")
             newEntity.setValue(book.fav, forKey: "fav")
         }
         do{
             try context.viewContext.save()
             print("New data has been saved")
         }catch{
             print("Failed to save data")
         }
     }
     func deleteAll() {
         let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: requestBooks)
         do {
             try context.viewContext.execute(batchDeleteRequest)
         } catch {
             print("All is deleted")
         }
     }
     func getBooks(){
         requestBooks.returnsObjectsAsFaults = false
         
         do{
             let result = try self.context.viewContext.fetch(requestBooks)
             for data in result as! [NSManagedObject]{
                 historyData.append(Book(title: data.value(forKey: "title") as! String, author: data.value(forKey: "author") as! String, id: data.value(forKey: "id") as! String, fav: data.value(forKey: "fav") as! Bool)!)
             }
         } catch{
             
         }
     }
}
