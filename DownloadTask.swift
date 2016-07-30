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
//    let indexPath:IndexPath
    let photoUrl:URL
    
    let successDownload:(UIImage) -> Void
    let failDownload:(NSError) -> Void
    
    
    lazy var downloadImageSession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "lamdeptrai")
        config.httpMaximumConnectionsPerHost = 1; // minh tao nhieu session
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var sessionDownload = URLSessionDownloadTask()

    
    init(/*indexPath:IndexPath,*/ photoUrl:URL, successDownload:(UIImage) -> Void, failDownload:(NSError) -> Void) {
//        self.indexPath = indexPath
        self.photoUrl = photoUrl
        self.successDownload = successDownload
        self.failDownload = failDownload
    }
    
    override func main() {
        if isCancelled {return}
//        let urlLH = URL(string: "http://192.168.1.142:8080/image/lam.png")
        sessionDownload = downloadImageSession.downloadTask(with: photoUrl);
        sessionDownload.resume();
        sleep(2)// need something to run for cancel this nsoperation
    }
    
    override func cancel() {
        sessionDownload.cancel()
        super.cancel()
    }
}

extension DownloadTask:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download done \(location) \n")
        /*
         et data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
         imageView.image = UIImage(data: data!)
         */
//        let data = Data(contentsOf: location)
//        self.successDownload(UIImage(data:data)
//        
//        let data = data()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("bi loi \(error) \n")
        }
    }
}



