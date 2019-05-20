//
//  ViewController.swift
//  Annotations
//
//  Created by Mirko Kiefer on 03/21/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa
import Annotations

typealias CanvasHistory = HistoryClass<CanvasModel>

class ViewController: NSViewController {
  var history: CanvasHistory!
  
  @IBOutlet var undoButton: NSButton!
  @IBOutlet var redoButton: NSButton!
  
  var canvasView: EditableCanvasView {
    return view as! EditableCanvasView
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "test_drawing", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        let model = try! decoder.decode(CanvasModel.self, from: data)
        canvasView.createMode = .text
        history = CanvasHistory(model: model)
        updateHistoryButtons()
        canvasView.delegate = self
        canvasView.update(model: model)
    }
    
//MARK: IBAction
    @IBAction func chooseDrawAction(_ sender: NSSegmentedControl) {
        switch sender.indexOfSelectedItem {
        case 0:
            canvasView.createMode = .text
            break
        case 1:
            canvasView.createMode = .arrow
            break
        case 2:
            canvasView.createMode = .rect
            break
        case 3:
            canvasView.createMode = .pen
            break
        default:
            break
        }
    }
    
  
  @IBAction func deleteShape(_ sender: Any) {
    canvasView.deleteSelectedItem()
  }
  
  @IBAction func undo(_ sender: Any) {
    canvasView.update(model: history.undo())
    updateHistoryButtons()
  }
  
  @IBAction func redo(_ sender: Any) {
    canvasView.update(model: history.redo())
    updateHistoryButtons()
  }
  
  func save(model: CanvasModel) {
    history.save(item: model)
    updateHistoryButtons()
  }
  
  func updateHistoryButtons() {
    undoButton.isEnabled = history.canUndo
    redoButton.isEnabled = history.canRedo
  }
}

extension ViewController: CanvasViewDelegate {
  func canvasView(_ canvasView: CanvasView, didUpdateModel model: CanvasModel) {
    save(model: model)
  }
}
