//
//  DownloadTask.swift
//  testAutolayout
//
//  Created by Ha Lam on 7/26/16.
//  Copyright © 2016 Ha Lam. All rights reserved.
//

import Foundation
import UIKit

protocol DownloadImageOperationDelagate:class{
    func DownloadImageSuccess(operation:DownloadTask, image:UIImage)
    func DownloadImageFail(operation:DownloadTask)
}

class DownloadTask: Operation {
    let indexPath:IndexPath
    let photoUrl:URL
    
    weak var delegate:DownloadImageOperationDelagate?
    
    
//    lazy var downloadImageSession:URLSession = {
//        let config = URLSessionConfiguration.background(withIdentifier: "lamdeptrai")
////        config.httpMaximumConnectionsPerHost = 1; // minh tao nhieu session
//        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
//        return session
//    }()
    
    var sessionDownload = URLSessionDownloadTask()
    var downloadImageSession = URLSession()

    
    init(indexPath:IndexPath, photoUrl:URL, delegate:DownloadImageOperationDelagate?) {
//        super.init()
        self.indexPath = indexPath
        self.photoUrl = photoUrl
        self.delegate = delegate
//        configDownloadSession()
//        let config = URLSessionConfiguration.background(withIdentifier: "\(photoUrl)")
//        downloadImageSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    

    override func main() {
        if isCancelled {return}
        print()
        let config = URLSessionConfiguration.background(withIdentifier: "\(photoUrl)")
        let downloadImageSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        sessionDownload = downloadImageSession.downloadTask(with: photoUrl);
        sessionDownload.resume();
        if isCancelled {
            return
        }
//        sleep(2)// need something to run for cancel this nsoperation
    }
    
    override func start() {
        if isCancelled {return}
        main()//them cai nay, doc ky phan custom nsoperation
    }
    
    override func cancel() {
        sessionDownload.cancel()
        super.cancel()
    }
    
}

extension DownloadTask:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download done \(location) \n")
        let imageData = try? Data(contentsOf: location)
        let downLoadImage = UIImage(data: imageData!)
        self.delegate?.DownloadImageSuccess(operation: self, image: downLoadImage!)
//        self.cancel()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("bi loi \(error) \n")
            self.delegate?.DownloadImageFail(operation: self)
        }
    }
}



