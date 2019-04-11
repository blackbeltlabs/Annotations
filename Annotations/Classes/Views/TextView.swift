//
//  TextView.swift
//  Annotations
//
//  Created by vuong dao on 4/9/19.
//

import Cocoa

protocol TextViewDelegate {
    func textView(_ textView: TextView, didUpdate model: TextModel, atIndex index: Int)
}

struct TextViewState {
    var model: TextModel
    var isSelected: Bool
}

protocol TextView: CanvasDrawable {
    var delegate: TextViewDelegate? { get set }
    var state: TextViewState { get set }
    var modelIndex: Int { get set }
    var layer: CAShapeLayer { get }
    var knobDict: [TextPoint: KnobView] { get }
}

extension TextView {
    var model: TextModel { return state.model }
    
    var knobs: [KnobView] {
        return TextPoint.allCases.map { knobAt(textPoint: $0) }
    }
    
    var path: CGPath {
        get {
            return layer.path!
        }
        set {
            layer.path = newValue
            layer.bounds = newValue.boundingBox
            layer.frame = layer.bounds
        }
    }
    
    var isSelected: Bool {
        get { return state.isSelected }
        set { state.isSelected = newValue }
    }
    
    static func createPath(model: TextModel) -> CGPath {
        let length = model.origin
        let text = NSBezierPath.text(
            from: CGPoint(x: model.origin.x, y: model.origin.y),
            tailWidth: 5,
            headWidth: 15,
            headLength: 20
        )
        
        return text.cgPath
    }
    
    static func createLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = NSColor.red.cgColor
        layer.strokeColor = NSColor.red.cgColor
        layer.lineWidth = 0
        
        return layer
    }
    
    func knobAt(point: PointModel) -> KnobView? {
        return knobs.first(where: { (knob) -> Bool in
            return knob.contains(point: point)
        })
    }
    
    func knobAt(textPoint: TextPoint) -> KnobView {
        return knobDict[textPoint]!
    }
    
    func contains(point: PointModel) -> Bool {
        return layer.path!.contains(point.cgPoint)
    }
    
    func addTo(canvas: CanvasView) {
        canvas.canvasLayer.addSublayer(layer)
    }
    
    func removeFrom(canvas: CanvasView) {
        layer.removeFromSuperlayer()
        knobs.forEach { $0.removeFrom(canvas: canvas) }
    }
    
    func dragged(from: PointModel, to: PointModel) {
        let delta = from.deltaTo(to)
        state.model = model.copyMoving(delta: delta)
    }
    
    func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
        let textPoint = (TextPoint.allCases.first { (textPoint) -> Bool in
            return knobDict[textPoint]! === knob
        })!
        let delta = from.deltaTo(to)
        state.model = model.copyMoving(textPoint: textPoint, delta: delta)
    }
    
    func render(state: TextViewState, oldState: TextViewState? = nil) {
        if state.model != oldState?.model {
            layer.shapePath = TextViewClass.createPath(model: state.model)
            
            for textPoint in TextPoint.allCases {
                knobAt(textPoint: textPoint).state.model = state.model.valueFor(textPoint: textPoint)
            }
            
            delegate?.textView(self, didUpdate: model, atIndex: modelIndex)
        }
        
        if state.isSelected != oldState?.isSelected {
            if state.isSelected {
                knobs.forEach { (knob) in
                    layer.addSublayer(knob.layer)
                }
            } else {
                knobs.forEach { (knob) in
                    knob.layer.removeFromSuperlayer()
                }
            }
        }
    }
}

class TextViewClass: TextView {
    var state: TextViewState {
        didSet {
            render(state: state, oldState: oldValue)
        }
    }
    
    var delegate: TextViewDelegate?
    
    var layer: CAShapeLayer
    var modelIndex: Int
    
    lazy var knobDict: [TextPoint: KnobView] = [
        .origin: KnobView1Class(model: model.origin)
    ]
    
    init(state: TextViewState, modelIndex: Int) {
        self.state = state
        self.modelIndex = modelIndex
        layer = TextViewClass.createLayer()
        render(state: state)
    }
}
