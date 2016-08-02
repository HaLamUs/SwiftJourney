//
//  LHConcurrentOperation.swift
//  testAutolayout
//
//  Created by Ha Lam on 8/1/16.
//  Copyright © 2016 Ha Lam. All rights reserved.
//

import Foundation

class LHConcurrentOperation: Operation {
    override var isAsynchronous: Bool{
        return true
    }
    
    private var _executing:Bool = false
    override var isExecuting: Bool{
        get {
            return _executing
        }
        set {
            if (_executing != newValue) {
                self.willChangeValue(forKey: "isExecuting")
                _executing = newValue
                self.didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var _finished:Bool = false
    override var isFinished: Bool{
        get {
            return _finished
        }
        set {
            if (_finished != newValue) {
                self.willChangeValue(forKey: "isFinished")
                _finished = newValue
                self.willChangeValue(forKey: "isFinished")
            }
        }
    }
    
    func completeOperationLH(){
        isExecuting = false
        isFinished = true
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        isExecuting = true
        main()
    }
    
}
