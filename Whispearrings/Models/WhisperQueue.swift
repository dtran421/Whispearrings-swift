//
//  WhisperQueue.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/27/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import Foundation

protocol Queue {
    associatedtype Element
    //enqueue：add an object to the end of the Queue
    mutating func enqueue(_ element: Element)
    //dequeue：delete the object at the beginning of the Queue
    mutating func dequeue() -> Element?
    //isEmpty：check if the Queue is nil
    var isEmpty: Bool { get }
    //peek：return the object at the beginning of the Queue without removing it
    var peek: Element? { get }
}

struct WhisperQueue<T>: Queue {
    private var enqueueStack = [T]()
    private var dequeueStack = [T]()
    
    var isEmpty: Bool {
        return dequeueStack.isEmpty && enqueueStack.isEmpty
    }
    
    var peek: T? {
        return !dequeueStack.isEmpty ? dequeueStack.last : enqueueStack.first
    }
    
    mutating func enqueue(_ element: T) {
        enqueueStack.append(element)
    }
    
    @discardableResult
    mutating func dequeue() -> T? {
        if dequeueStack.isEmpty {
            dequeueStack = enqueueStack.reversed()
            enqueueStack.removeAll()
        }
        return dequeueStack.popLast()
    }
}
