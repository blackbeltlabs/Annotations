//
//  History.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/3/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public protocol History: AnyObject {
  associatedtype Item

  var history: [Item] { get set }
  var pointer: Int { get set }
}

extension History {
  public var currentState: Item {
    return history[pointer]
  }
  
  public var canUndo: Bool { return pointer > 0 }
  public var canRedo: Bool { return pointer < history.count - 1 }
  
  var historyToPointer: [Item] {
    return Array(history.prefix(upTo: pointer + 1))
  }
  
  public func save(item: Item) {
    history = historyToPointer + [item]
    pointer += 1
  }
  
  public func undo() -> Item {
    guard canUndo else {
      return currentState
    }
    
    pointer -= 1
    
    return currentState
  }
  
  public func redo() -> Item {
    guard canRedo else {
      return currentState
    }
    
    pointer += 1
    
    return currentState
  }
}

public class HistoryClass<Item>: History {
  public var history: [Item]
  public var pointer: Int = 0
  
  public init(model: Item) {
    self.history = [model]
  }
}
