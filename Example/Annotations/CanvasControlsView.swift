import Cocoa
import Annotations
import Combine

class CanvasControlsView: NSView {
  
  let colorSelected = CurrentValueSubject<NSColor, Never>(.orange)
  
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
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupUI()
    selectColor(with: colorPickerViews.first!)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  func setupUI() {
    wantsLayer = true
    layer?.backgroundColor = NSColor.lightGray.cgColor
    
    addSubview(colorsStackView)
    colorsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 5.0).isActive = true
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
    
  }
  
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
