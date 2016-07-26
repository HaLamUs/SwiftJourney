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
    
    lazy var downloadImageSession:URLSession = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        return session
    }()
    
    let successDownload:(UIImage) -> Void
    let failDownload:(NSError) -> Void
    
    init(indexPath:IndexPath, photoUrl:URL, successDownload:(UIImage) -> Void, failDownload:(NSError) -> Void) {
        self.indexPath = indexPath
        self.photoUrl = photoUrl
        self.successDownload = successDownload
        self.failDownload = failDownload
    }
    
    override func main() {
        if isCancelled {return}
       
        
        downloadImageSession.downloadTask(with: photoUrl){
            (url, respond, err) in
            guard let httpRes = respond as? HTTPURLResponse where httpRes.statusCode == 200,
                let url = url where err == nil,
                let data = try? Data(contentsOf: url),
                let imageCellLH = UIImage(data: data)
                else{
                    self.failDownload(err!)
                    print("die")
                    return }
            self.successDownload(imageCellLH)
            }.resume()
        
        
    }
}
