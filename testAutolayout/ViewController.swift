//
//  ViewController.swift
//  testAutolayout
//
//  Created by Ha Lam on 7/19/16.
//  Copyright © 2016 Ha Lam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
//MARK: Varible
    
    @IBOutlet weak var tableViewBookList: UITableView!
    
    var numberRowLH:Int = 0
    var arrList = [Book]()
    
//    let imageCacheList = Cache<AnyObject,AnyObject>()
    var imageCacheList = [String:UIImage]()
    
    lazy var downloadImageQueue: OperationQueue = {
        let downloadQueue = OperationQueue()
//        downloadQueue.name = "DownloadQueueLH"
        downloadQueue.maxConcurrentOperationCount = 2
        return downloadQueue
    }()
    
    var downdLoadImageOperationDic = [IndexPath:Operation]()
    
    @IBAction func touchInSide(_ sender: UIBarButtonItem) {
//        downloadImageQueue.cancelAllOperations()
//        downTask?.cancel()
    }

    @IBAction func huyThangThu2(_ sender: UIBarButtonItem) {
        print()
//        session2.cancel()
    }
    
//MARK: function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myBundle = Bundle.main
        let myNib = UINib(nibName: "BookTableViewCell", bundle: myBundle)
        tableViewBookList.register(myNib, forCellReuseIdentifier: "bookcell")
        
//        parseJsonFromUrl()
        downLoadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func downLoadImage(){
        
        let index = IndexPath(item: 1, section: 1)
        for indexw in 1 ... 50 {
            let urlImage = URL(string: "http://192.168.1.142:8080/image/images_\(indexw).jpg")
            let downloadOperation = DownloadTask(indexPath: index, photoUrl: urlImage!, delegate: self)
            downloadImageQueue.addOperation(downloadOperation)
        }
        print()
    }
    
    func downLoadImage_v2(){
        let urlImage = URL(string: "http://192.168.1.142:8080/image/test.zip")
        let index = IndexPath(item: 1, section: 1)
        let downloadOperation = DownloadTask(indexPath: index, photoUrl: urlImage!, delegate: self)
        
         let downloadOperation2 = DownloadTask(indexPath: index, photoUrl: URL(string: "http://192.168.1.142:8080/image/test2.zip")!, delegate: self)
        let downloadOperation3 = DownloadTask(indexPath: index, photoUrl: URL(string: "http://192.168.1.142:8080/image/test3.zip")!, delegate: self)
//        downloadImageQueue.addOperation(downloadOperation3)
        downloadImageQueue.addOperation(downloadOperation2)
        downloadImageQueue.addOperation(downloadOperation)
        print()
    }
    
    func parseJsonFromUrl(){
        let urlLH = URL(string:"http://192.168.1.142:8080/data.json")!
        URLSession.shared.dataTask(with: urlLH) { (data, response, err) in
            guard let data = data,
                let jsonLH = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {print ("[Die] Parse Json die"); return}
            
            guard let totalLH = jsonLH["total"],
                let dataLH = jsonLH["data"] else {print("die");return}
            
            self.numberRowLH = totalLH as! Int
            let data2 = dataLH as! [[String:String]]
            for (index, value) in data2.enumerated(){
                let book = Book(titleBook: value["booktitle"]!, imageUrl: value["image"]!)
                self.arrList.insert(book, at: index)
            }
//            self.tableViewBookList.dataSource = self//tranh chua co data da load
//            self.tableViewBookList.delegate = self
//            DispatchQueue.main.async(execute: {
//                self.tableViewBookList.reloadData()
//            })
            }.resume()
    }
    
//MARK: Manager Queue
    
    func startDownloadImage(operation:DownloadTask, indexPath:IndexPath){
        if (downdLoadImageOperationDic[indexPath] != nil){
            return
        }
        downdLoadImageOperationDic[indexPath] = operation
        downloadImageQueue.addOperation(operation)
    }
    
    func reloadVisibleCell() {
        let visibleCellsAtIndexPaths =  self.tableViewBookList.indexPathsForVisibleRows
        DispatchQueue.main.async { 
            self.tableViewBookList.reloadRows(at: visibleCellsAtIndexPaths!, with: .none)
        }//main thread
    }
}

//MARK:extension

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRowLH;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewBookList.dequeueReusableCell(withIdentifier: "bookcell", for: indexPath) as! BookTableViewCell
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bookAtCell = arrList[indexPath.row] as Book
        (cell as! BookTableViewCell).titileBook.text = bookAtCell.titleBook
        
        let titleBook = bookAtCell.titleBook
        if let imageForCell = imageCacheList[titleBook] {
            (cell as! BookTableViewCell).avatarBook.image = imageForCell
        }
        else{
             let urlImage = URL(string: "http://192.168.1.142:8080/image/\(bookAtCell.imageUrl)")
            if !tableViewBookList.isDecelerating {
                let downloadOperation = DownloadTask(indexPath: indexPath, photoUrl: urlImage!, delegate: self)
                startDownloadImage(operation: downloadOperation, indexPath: indexPath)
            }
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard imageCacheList.count < 50 else {
            return
        }
        reloadVisibleCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard imageCacheList.count < 50 else {
            return
        }
        
        if scrollView.isDecelerating {
//            downloadImageQueue.cancelAllOperations()
            for oper in downloadImageQueue.operations{
                oper.cancel()
            }
            downdLoadImageOperationDic.removeAll()
        }
    }
}

extension ViewController:DownloadImageOperationDelagate{
    func DownloadImageFail(operation: DownloadTask) {
        self.downdLoadImageOperationDic.removeValue(forKey: operation.indexPath)
    }
    
    func DownloadImageSuccess(operation: DownloadTask, image: UIImage) {
        print()
        let bookAtCell = arrList[operation.indexPath.row] as Book
        imageCacheList[bookAtCell.titleBook] = image
        DispatchQueue.main.async(execute: {
            self.tableViewBookList.reloadRows(at: [operation.indexPath], with: .none)
        })
        self.downdLoadImageOperationDic.removeValue(forKey: operation.indexPath)
    }
}

