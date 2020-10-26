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
  
  @IBOutlet weak var backgroundImageView: NSImageView!
  @IBOutlet weak var canvasView: CanvasView!
  @IBOutlet var undoButton: NSButton!
  @IBOutlet var redoButton: NSButton!
  @IBOutlet weak var pickerViewsStackView: NSStackView!
  @IBOutlet weak var littleImageView: NSImageView!
  
  var selectedPickerView: ColorPickerView?
  
  var colorPickerViews: [ColorPickerView] {
    return pickerViewsStackView.arrangedSubviews.compactMap {
      $0 as? ColorPickerView
    }
  }
  
  lazy var colorPickerColors: [NSColor] = {
    return ModelColor.defaultColors().map { NSColor.color(from: $0) }
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let url = Bundle.main.url(forResource: "test_drawing", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    var model = try! decoder.decode(CanvasModel.self, from: data)
        
    if let globalStyle = model.style {
      // apply global style params to each text and update each param if it is nil
      let texts = model.texts.map { (textModel) -> TextModel in
        let currentStyle = textModel.style
        return textModel.copyWithTextParams(currentStyle.updatedModelWithTextParamsIfNil(globalStyle))
      }
      model.texts = texts
    }

    canvasView.createMode = .text
    history = CanvasHistory(model: model)
    updateHistoryButtons()
    canvasView.delegate = self
    canvasView.dataSource = self
    canvasView.update(model: model)
    setupColorPickerViews()
    canvasView.textStyle = TextParams.randomFont()
    
    littleImageView.wantsLayer = true
    littleImageView.layer?.borderColor = NSColor.green.cgColor
    littleImageView.layer?.borderWidth = 1.0
  }
  
  func setupColorPickerViews() {
    
    for (index, element) in colorPickerViews.enumerated() {
      element.viewId = index
      let clickGR = NSClickGestureRecognizer(target: self, action: #selector(colorPickerViewTapped(gr:)))
      element.addGestureRecognizer(clickGR)
    }
    
    for (pickerView, color) in zip(colorPickerViews, colorPickerColors) {
      pickerView.setBackgroundColor(color: color)
    }
    
    if let firstPickerView = colorPickerViews.first {
      selectColor(with: firstPickerView)
    }
  }
  
  //MARK: IBAction
  @IBAction func chooseDrawAction(_ sender: NSSegmentedControl) {
    switch sender.indexOfSelectedItem {
    case 0:
      canvasView.createMode = .text
    case 1:
      canvasView.createMode = .arrow
    case 2:
      canvasView.createMode = .rect
    case 3:
      canvasView.createMode = .pen
    case 4:
      canvasView.createMode = .obfuscate
    case 5:
      canvasView.createMode = .highlight
    default: return
    }
  }
  
  @IBAction func deleteShape(_ sender: Any) {
    canvasView.deleteSelectedItem()
  }
  
  @IBAction func undo(_ sender: Any) {
    if canvasView.isSelectedTextAnnotation {
      canvasView.deselectTextAnnotation()
    }
    canvasView.update(model: history.undo())
    updateHistoryButtons()
  }
  
  @IBAction func redo(_ sender: Any) {
    canvasView.update(model: history.redo())
    updateHistoryButtons()
  }
  
  @IBAction func didToggleCheckbox(_ sender: NSButton) {
    let isOn = sender.state == .on
    canvasView.isUserInteractionEnabled = isOn
  }
  
  @IBAction func didTapReset(_ sender: NSButton) {
    canvasView.update(model: CanvasModel())
  }
  
  @objc func colorPickerViewTapped(gr: NSGestureRecognizer) {
    guard let pickerView = gr.view as? ColorPickerView else { return }
    selectColor(with: pickerView)
  }
  
  func selectColor(with pickerView: ColorPickerView) {
    let color = colorPickerColors[pickerView.viewId]
    
    selectedPickerView?.isSelected = false
    
    pickerView.isSelected = true
    selectedPickerView = pickerView
    
    canvasView.createColor = color.annotationModelColor
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
  func canvasView(_ canvasView: CanvasView, didTransform annotation: CanvasDrawable, action: CanvasViewTransformAction) {
    
  }
  
  func canvasView(_ canvasView: CanvasView, didCreateAnnotation annotation: CanvasDrawable) {
    print("did create annotation \(annotation.modelType)")
  }
  
  func canvasView(_ canvasView: CanvasView, didStartEditing annotation: TextAnnotation) {
    print("did start editing")
  }
  
  func canvasView(_ canvasView: CanvasView, didDeselect annotation: TextAnnotation) {
    print("did select canvas")
  }
  
  func canvasView(_ canvasView: CanvasView, didEndEditing annotation: TextAnnotation) {
    print("did end editing")
  }
  
  func canvasView(_ canvasView: CanvasView, didUpdateModel model: CanvasModel) {
    print("did update")
    self.canvasView.textStyle = TextParams.randomFont()
    save(model: model)
  }
}

extension ViewController: CanvasViewDataSource {
  func cropImage(for rect: CGRect) -> NSImage? {
    
    let image = backgroundImageView.image!
    
    guard rect.size.width != 0 && rect.size.height != 0 else {
      return nil
    }
    
    let trimmed = trim(image: image, rect: rect)
  
    let pixellated = applyPixelateFilter(trimmed)
    
    littleImageView.image = pixellated
    
    return pixellated
    
  }
  
  func trim(image: NSImage, rect: CGRect) -> NSImage {
    
    var updatedRect = rect
  
    let screenScale = NSScreen.main!.backingScaleFactor
  
    updatedRect.origin.x *= screenScale
    updatedRect.origin.y *= screenScale
    updatedRect.size.width *= screenScale
    updatedRect.size.height *= screenScale
    
    let result = NSImage(size: updatedRect.size)
    print(image.size)
    result.lockFocus()
    
    let destRect = CGRect(origin: .zero,
                          size: result.size)
    
    image.draw(in: destRect,
               from: updatedRect,
               operation: .copy,
               fraction: 1.0,
               respectFlipped: true,
               hints: nil)

    result.unlockFocus()
    return result
  }
  
  
  
  func transformRectToQuartz(rect: CGRect, screenHeight: CGFloat) -> CGRect {
    var transform = CGAffineTransform(scaleX: 1, y: -1)
    transform = transform.translatedBy(x: 0, y: -screenHeight)
    return rect.applying(transform)
  }
  
  func applyPixelateFilter(_ image: NSImage) -> NSImage? {
    guard let ciImage = image.ciImage else { return nil }
  
    guard let blurFilter = CIFilter(name: "CIPixellate") else {
      return nil
    }
    blurFilter.setValue(ciImage, forKey: kCIInputImageKey)
    
    blurFilter.setValue(NSNumber(integerLiteral: 10), forKey: "inputScale")
    
    guard let outputImage = blurFilter.outputImage else {
      return nil
    }
  
    return outputImage.nsImage
  }
}


// MARK: - Extensions
private extension NSImage {
  var ciImage: CIImage? {
    guard let tiffImage = tiffRepresentation else {
      return nil
    }
    return CIImage(data: tiffImage)
  }
}

private extension CIImage {
  var nsImage: NSImage {
    let rep = NSCIImageRep(ciImage: self)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)
    return nsImage
  }
}
