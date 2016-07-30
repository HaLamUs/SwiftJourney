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
//    let indexPath:IndexPath
    let photoUrl:URL
    
    weak var delegate:DownloadImageOperationDelagate?
    
    
    lazy var downloadImageSession:URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "lamdeptrai")
//        config.httpMaximumConnectionsPerHost = 1; // minh tao nhieu session
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var sessionDownload = URLSessionDownloadTask()

    
    init(/*indexPath:IndexPath,*/ photoUrl:URL, delegate:DownloadImageOperationDelagate?) {
//        self.indexPath = indexPath
        self.photoUrl = photoUrl
        self.delegate = delegate
    }
    
    override func main() {
        if isCancelled {return}
        sessionDownload = downloadImageSession.downloadTask(with: photoUrl);
        sessionDownload.resume();
//        sleep(2)// need something to run for cancel this nsoperation
    }
    
    override func start() {
        if isCancelled {return}
        main()//them cai nay, doc ky phan custom nsoperation
    }
    
    override func cancel() {
        sessionDownload.cancel()
    }
}

extension DownloadTask:URLSessionDownloadDelegate{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download done \(location) \n")
        let imageData = try? Data(contentsOf: location)
        let downLoadImage = UIImage(data: imageData!)
        self.delegate?.DownloadImageSuccess(operation: self, image: downLoadImage!)
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("bi loi \(error) \n")
            self.delegate?.DownloadImageFail(operation: self)
        }
    }
}



