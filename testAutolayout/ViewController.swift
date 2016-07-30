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
        downloadQueue.name = "DownloadQueueLH"
        downloadQueue.maxConcurrentOperationCount = 2
        return downloadQueue
    }()
    
    var downdLoadImageOperationDic = [IndexPath:Operation]()
    
    //testing ====================
//    lazy var downloadImageSession:URLSession = {
//        let config = URLSessionConfiguration.background(withIdentifier: "lamdeptrai")
////        config.httpMaximumConnectionsPerHost = 1; // minh tao nhieu session
//        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
//        return session
//    }()
//    
//    var sessionDownload = URLSessionDownloadTask()
//    var session2 = URLSessionDownloadTask()
    
    var downTask:DispatchWorkItem? = nil
    
    lazy var bgQueue = DispatchQueue(label: "lamdeptrai", attributes: [.concurrent,.qosBackground], target: nil)
    
    //testing ====================
    
    @IBAction func touchInSide(_ sender: UIBarButtonItem) {
//        downloadImageQueue.cancelAllOperations()
        downTask?.cancel()
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
        
        parseJsonFromUrl()
        downLoadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func downLoadImage(){
//        let index = IndexPath(item: 1, section: 1)
//        let urlImage = URL(string: "http://192.168.1.142:8080/image/")
//        let temp = DownloadTask(indexPath: index, photoUrl: urlImage!, successDownload: {(image) in print()}, failDownload: {(err) in print()})
//        
//        downloadImageQueue.addOperation(temp)
        
        downTask = DispatchWorkItem{
            for item in 1...10{
                sleep(1)
                print(item)
            }
        }
        bgQueue.async(execute: downTask!)
//        DispatchQueue.main.async(execute: downTask!)
//        let bgQueue2 = DispatchQueue(label: "lamdept2rai", attributes: .qosBackground, target: nil)
        downTask = DispatchWorkItem{
            for item in 1...1000{
                sleep(1)
                print("lamha \(item)")
            }
        }
        bgQueue.async(execute: downTask!)
        
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
            self.tableViewBookList.dataSource = self//tranh chua co data da load
            self.tableViewBookList.delegate = self
            DispatchQueue.main.async(execute: {
                self.tableViewBookList.reloadData()
            })
            }.resume()
    }
    
//MARK: Manager Queue
    
    func startDownloadImage(operation:Operation, indexPath:IndexPath){
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
        }
        //main thread
    }
    
}


//MARK:extension

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRowLH;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewBookList.dequeueReusableCell(withIdentifier: "bookcell", for: indexPath) as! BookTableViewCell
        
//        let bookAtCell = arrList[indexPath.row] as Book
//        
//        cell.titileBook.text = bookAtCell.titleBook
        
        /*
        let userPhotoId = bookAtCell.imageUrl
        if let imageForCell = imageCacheList[userPhotoId] {//sai minh lam tiep nen ko dung guard dc
            cell.avatarBook.image = imageForCell
        }
        else{
            let urlImage = URL(string: "http://192.168.1.142:8080/image/\(bookAtCell.imageUrl)")
            print()//debug cho nay
            if !tableViewBookList.isDecelerating {
                let downloadOperation = DownloadTask(indexPath: indexPath, photoUrl: urlImage!, successDownload: { (image) in
//                    self.imageCacheList.setObject(image, forKey: bookAtCell.imageUrl)
                    self.imageCacheList[userPhotoId] = image
                    DispatchQueue.main.async(execute: {
                        self.tableViewBookList.reloadRows(at: [indexPath], with: .none)
                    })
//                    self.tableViewBookList.reloadRows(at: [indexPath], with: .none)//main thread
                    self.downdLoadImageOperationDic.removeValue(forKey: indexPath)
                    print()
                    }, failDownload: { (error) in
                        print()
                })
                startDownloadImage(operation: downloadOperation, indexPath: indexPath)
            }
            
        }
 */
        return cell;
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let bookAtCell = arrList[indexPath.row] as Book
        
        (cell as! BookTableViewCell).titileBook.text = bookAtCell.titleBook
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
            downloadImageQueue.cancelAllOperations()
            downdLoadImageOperationDic.removeAll()
        }
    }
    
}


/*
 Mai lam
 1. Dung cho no goi cellforrowatindexpath neu no da load ok roi
 2. check xem operation no da huy chua 
 3. check xem thang urlsession da huy chua
 */


