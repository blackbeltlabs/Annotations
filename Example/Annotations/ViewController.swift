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
    
    //Mark: Text
    var annotations = [TAContainerView]()
    var activeAnnotation: TAContainerView! {
        didSet {
            if let aTextView = activeAnnotation {
                for item in annotations {
                    guard item != aTextView else { continue }
                    item.state = .inactive
                }
            } else {
                for item in annotations {
                    item.state = .inactive
                }
                view.window?.makeFirstResponder(nil)
            }
        }
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
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
//MARK: HANDLE TEXT
    override func viewDidAppear() {
        super.viewDidAppear()
        
        activeAnnotation = nil
    }
    
    override func mouseUp(with event: NSEvent) {
        if activeAnnotation != nil {
            activeAnnotation.state = .active
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let screenPoint = event.locationInWindow
        
        // check annotation to activate or break resize
        let locationInView = view.convert(screenPoint, to: nil)
        var annotationToActivate: TAContainerView!
        
        for annotation in annotations {
            if annotation.frame.contains(locationInView) {
                annotationToActivate = annotation
                break
            }
        }
        
        if annotationToActivate == nil {
            activeAnnotation = nil
        } else {
            activeAnnotation?.initialTouchPoint = screenPoint
            activeAnnotation?.state = .active
        }
        
        super.mouseDown(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        textAnnotationsMouseDragged(event: event)
        super.mouseDragged(with: event)
    }
    
    // MARK: - Private
    
    private func textAnnotationsMouseDragged(event: NSEvent) {
        let screenPoint = event.locationInWindow
        
        // are we should continue resize or scale
        if activeAnnotation != nil, activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight || activeAnnotation.state == .scaling {
            
            let initialDragPoint = activeAnnotation.initialTouchPoint
            activeAnnotation.initialTouchPoint = screenPoint
            let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
                                    height: screenPoint.y - initialDragPoint.y)
            
            if activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight {
                activeAnnotation.resizeWithDistance(difference.width)
            } else if activeAnnotation.state == .scaling {
                activeAnnotation.scaleWithDistance(difference)
            }
            return
        }
        
        // check annotation to activate or break resize
        let locationInView = view.convert(screenPoint, to: nil)
        var annotationToActivate: TAContainerView!
        
        for annotation in annotations {
            if annotation.frame.contains(locationInView) {
                annotationToActivate = annotation
                break
            }
        }
        
        // start dragging or resize
        if let annotation = annotationToActivate, annotation.state == .active {
            let locationInAnnotation = view.convert(screenPoint, to: annotation)
            
            var state: TAContainerView.TAContainerViewState = .active // default state
            if annotation.leftTally.frame.contains(locationInAnnotation) {
                state = .resizeLeft
            } else if annotation.rightTally.frame.contains(locationInAnnotation) {
                state = .resizeRight
            } else if annotation.scaleTally.frame.contains(locationInAnnotation) {
                state = .scaling
            }
            
            if state != .active && annotation.state != .dragging {
                annotation.state = state
                activeAnnotation = annotation
                return
            }
        }
        
        if activeAnnotation == nil ||
            (annotationToActivate != nil && activeAnnotation != annotationToActivate) {
            if activeAnnotation != nil {
                activeAnnotation.state = .inactive
            }
            
            activeAnnotation = annotationToActivate
        }
        guard activeAnnotation != nil else { return }
        
        // here we can only drag
        if activeAnnotation.state != .dragging {
            activeAnnotation.initialTouchPoint = screenPoint
        }
        activeAnnotation.state = .dragging
        
        let initialDragPoint = activeAnnotation.initialTouchPoint
        activeAnnotation.initialTouchPoint = screenPoint
        let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
                                height: screenPoint.y - initialDragPoint.y)
        
        activeAnnotation.origin = CGPoint(x: activeAnnotation.frame.origin.x + difference.width,
                                          y: activeAnnotation.frame.origin.y + difference.height)
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
    if self.canvasView.createMode == .text {
        let size = CGSize.zero
        if let data = model.description.data(using: .utf8) {
            do {
                let temp = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let modeled = ((temp?["texts"] as? [[String: Any]])?.last) {
                    if let te = modeled["origin"] as? [String: Any] {
                    let view1 = TAContainerView(frame: NSRect(origin: CGPoint(x: (te["x"] as? Double)!, y: (te["y"] as? Double)!), size: size))
                    view1.text = "1"
                    view1.activateResponder = self
                    view.addSubview(view1)
                    annotations.append(view1)
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        

    }
  }
}
