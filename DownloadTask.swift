//
//  DownloadTask.swift
//  testAutolayout
//
//  Created by Ha Lam on 7/26/16.
//  Copyright © 2016 Ha Lam. All rights reserved.
//

import Foundation
import UIKit

class DownloadTask: Operation {
    let indexPath:IndexPath
    let photoUrl:URL
    
//    lazy var downloadImageSession:URLSession = {
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        return session
//    }()
    
    let successDownload:(UIImage) -> Void
    let failDownload:(NSError) -> Void
    
    
    lazy var downloadImageSession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "lamdeptrai")
        config.httpMaximumConnectionsPerHost = 1; // minh tao nhieu session
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var sessionDownload = URLSessionDownloadTask()

    
    init(indexPath:IndexPath, photoUrl:URL, successDownload:(UIImage) -> Void, failDownload:(NSError) -> Void) {
        self.indexPath = indexPath
        self.photoUrl = photoUrl
        self.successDownload = successDownload
        self.failDownload = failDownload
    }
    
    override func main() {
        if isCancelled {return}
        let urlLH = URL(string: "http://192.168.1.142:8080/image/lam.png")
        sessionDownload = downloadImageSession.downloadTask(with: urlLH!);//config
        sessionDownload.resume();//run
        sleep(2)// need something to run for cancel this nsoperation
    }
    
    override func cancel() {
        print("lmaha ahanssana")
        sessionDownload.cancel()
        super.cancel()
//        return
    }
}

extension DownloadTask:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download done \(location) \n")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("bi loi \(error) \n")
        }
    }
}



