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
    var arrList2:Array<String> = []
    lazy var downloadImageSession:URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let session2 = URLSession(configuration:config, delegate: nil,/*self*/ delegateQueue: nil)//All delegate method calls and completion handlers related to the session are performed on this queue.
        //Cai queue nay dung de quan ly download
        return session
    }() // bo di
    
//    var imageCell:UIImage? // bo di
//    let urlImageLH = URL(string: "http://192.168.1.142:8080/image/images_10.jpg")
    
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
    
    
//MARK: function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myBundle = Bundle.main
        let myNib = UINib(nibName: "BookTableViewCell", bundle: myBundle)
        tableViewBookList.register(myNib, forCellReuseIdentifier: "bookcell")
        
        parseJsonFromUrl()
//        downloadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    func parseJsonFromUrl_v2(){
        let urlLH = URL(string:"http://192.168.1.142:8080/data.json")!
        URLSession.shared.dataTask(with: urlLH) { (data, response, err) in
            do {
                guard let jsonLH = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String,AnyObject> else {print ("[Die] Parse Json die"); return}
                
                guard let totalLH = jsonLH["total"],
                    let dataLH = jsonLH["data"] else {print("die");return}
                
                self.numberRowLH = totalLH as! Int
                let data2 = dataLH as! Array<Dictionary<String,String>>
                for (index, value) in data2.enumerated(){
                    let book = Book(titleBook: value["booktitle"]!, imageUrl: value["image"]!)
                    self.arrList.insert(book, at: index)
                }
                self.tableViewBookList.dataSource = self;//tranh chua co data da load
                self.tableViewBookList.delegate = self
                DispatchQueue.main.async(execute: {
                    self.tableViewBookList.reloadData()
                })
            } catch {
                print("Error with Json: \(error)")
            }
            }.resume()
    }
    
    func parseJsonFromUrl(){
        let urlLH = URL(string:"http://192.168.1.142:8080/data.json")!
        URLSession.shared.dataTask(with: urlLH) { (data, response, err) in
            guard let jsonLH = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) else {print ("[Die] Parse Json die"); return}
            
            guard let totalLH = jsonLH["total"],
                let dataLH = jsonLH["data"] else {print("die");return}
            
            self.numberRowLH = totalLH as! Int
            let data2 = dataLH as! [[String:String]]//Array<Dictionary<String,String>>
            for (index, value) in data2.enumerated(){
                let book = Book(titleBook: value["booktitle"]!, imageUrl: value["image"]!)
                self.arrList.insert(book, at: index)
            }
            self.tableViewBookList.dataSource = self//tranh chua co data da load
//            self.tableViewBookList
            self.tableViewBookList.delegate = self
            DispatchQueue.main.async(execute: {
                self.tableViewBookList.reloadData()
            })
            }.resume()
    }
    
    func downloadImage() {
        let urlLH = URL(string: "http://192.168.1.142:8080/image/images_10.jpg")!
//        downloadImageSession.downloadTask(with: urlLH).resume() //xai delegate
        downloadImageSession.downloadTask(with: urlLH) { (url, response, err) in // trailing closure
            guard let httpRes = response as? HTTPURLResponse where httpRes.statusCode == 200, //response.mimeType
                let url = url where err == nil,
            let data = NSData(contentsOf: url),
            let imageCellLH = UIImage(data: data as Data)
                else{ print("die"); return }
//            self.imageCell = imageCellLH
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
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        reloadVisibleCell()
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.isDecelerating {
//            downloadImageQueue.cancelAllOperations()
//            downdLoadImageOperationDic.removeAll()
//        }
//    }
    
}

//MARK:extension

extension ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRowLH;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewBookList.dequeueReusableCell(withIdentifier: "bookcell", for: indexPath) as! BookTableViewCell
        
        let bookAtCell = arrList[indexPath.row] as Book
        
        cell.titileBook.text = bookAtCell.titleBook//(arrList[indexPath.row] as Book).titleBook
        
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
                
                //success: la thang up vao image cache
                //fail:
            }
            
        }
        
        
        
//        downloadImageSession.downloadTask(with: urlImageLH!){
//            (url, respond, err) in
//            guard let httpRes = respond as? HTTPURLResponse where httpRes.statusCode == 200, //response.mimeType
//                let url = url where err == nil,
//                let data = try? Data(contentsOf: url),
//                let imageCellLH = UIImage(data: data)
//                else{ print("die"); return }
//            cell.avatarBook.image = imageCellLH
//            DispatchQueue.main.async(execute: { 
//                self.tableViewBookList .reloadData()
//            })
//        }.resume()
        
        return cell;
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        reloadVisibleCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating {
            downloadImageQueue.cancelAllOperations()
            downdLoadImageOperationDic.removeAll()
        }
    }
    
}


