import Cocoa
import Annotations
import Combine

enum CanvasAnnotationType: CaseIterable {
  case noType
  case text
  case arrow
  case pen
  case rect
  case obfuscate
  case highlight
  case number
  
  var title: String {
    switch self {
    case .noType:
      return "No type"
    case .text:
      return "Text"
    case .arrow:
      return "Arrow"
    case .pen:
      return "Pen"
    case .rect:
      return "Rect"
    case .obfuscate:
      return "Obfuscate"
    case .highlight:
      return "Highlight"
    case .number:
      return "Number"
    }
  }
}

class CanvasControlsView: NSView {
  
  let colorSelected = CurrentValueSubject<NSColor, Never>(.orange)
  let canvasAnnotationType = CurrentValueSubject<CanvasAnnotationType, Never>(.arrow)
  
  // MARK: - Colors
  lazy var colorPickerColors: [NSColor] = {
    return ModelColor.defaultColors().map { NSColor.color(from: $0) }
  }()
  
  var colorPickerViews: [ColorPickerView] {
    return colorsStackView.arrangedSubviews.compactMap {
      $0 as? ColorPickerView
    }
  }
  
  lazy var colorsStackView: NSStackView = {
    let stackView = NSStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .horizontal
    return stackView
  }()
  
  // MARK: - Mode
  lazy var createModePopupButton: NSPopUpButton = {
    self.popupButton(with: canvasAnnotationTypes)
  }()
  
  private lazy var canvasAnnotationTypes: [NSMenuItem] = {
    let availableItems: [CanvasAnnotationType] = CanvasAnnotationType.allCases
    return availableItems.map { type in
      let item = NSMenuItem(title: type.title,
                            action: #selector(canvasAnnotationTypeSelected(_:)),
                            keyEquivalent: "")
      item.target = self
      item.representedObject = type
      return item
    }
  }()
  

  // MARK: - Init
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupUI()
    selectColor(with: colorPickerViews.first!)
    selectAnnotationType(.arrow)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  // MARK: - Setup UI
  private func setupUI() {
    wantsLayer = true
    layer?.backgroundColor = NSColor.lightGray.cgColor
    
    addSubview(colorsStackView)
    colorsStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    colorsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5.0).isActive = true
    colorsStackView.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
    
    for (index, color) in colorPickerColors.enumerated() {
      let pickerView = ColorPickerView(frame: .zero)
      pickerView.viewId = index
      pickerView.translatesAutoresizingMaskIntoConstraints = false
      pickerView.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
      pickerView.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
      pickerView.setBackgroundColor(color: color)
      
      let clickGR = NSClickGestureRecognizer(target: self,
                                             action: #selector(colorPickerViewTapped(gr:)))
      pickerView.addGestureRecognizer(clickGR)
      
      colorsStackView.addArrangedSubview(pickerView)
    }
    
    addSubview(createModePopupButton)
    
    createModePopupButton.leadingAnchor.constraint(equalTo: colorsStackView.trailingAnchor,
                                                   constant: 10).isActive = true
    createModePopupButton.centerYAnchor.constraint(equalTo: colorsStackView.centerYAnchor).isActive = true
  }
  
  // MARK: - Color actions
  @objc
  func colorPickerViewTapped(gr: NSGestureRecognizer) {
    guard let pickerView = gr.view as? ColorPickerView else { return }
    print("Pressed = \(pickerView.viewId)")
    selectColor(with: pickerView)
  }
  
  func selectColor(with pickerView: ColorPickerView) {
    colorPickerViews.forEach { $0.isSelected = false }
    pickerView.isSelected = true
    
    colorSelected.send(colorPickerColors[pickerView.viewId])
  }

  // MARK: - Mode actions
  @objc
  func canvasAnnotationTypeSelected(_ menuItem: NSMenuItem) {
    guard let selected = menuItem.representedObject as? CanvasAnnotationType else { return }
    selectAnnotationType(selected)
  }
  
  func selectAnnotationType(_ selected: CanvasAnnotationType) {
    for type in canvasAnnotationTypes {
      if let annotationType = type.representedObject as? CanvasAnnotationType,
            annotationType == selected {
        createModePopupButton.select(type)
      } else {
        continue
      }
    }
    canvasAnnotationType.send(selected)
  }
}

// current create mode
extension CanvasControlsView {
  private func popupButton(with menuItems: [NSMenuItem]) -> NSPopUpButton {
    let popupButton = NSPopUpButton(frame: .zero, pullsDown: false)
    popupButton.translatesAutoresizingMaskIntoConstraints = false
    popupButton.menu?.items = menuItems
    return popupButton
  }
}


// MARK: - Previews
import SwiftUI

struct CanvasControlsView_Previews: PreviewProvider {
    static var previews: some View {
        AnyViewPreview<CanvasControlsView>()
          .previewLayout(.fixed(width: 600, height: 100))
          .frame(width: 600.0,
                 height: 65.0,
                 alignment: .center)
          .padding(10.0)
          .background(Color.yellow)
    }
}
