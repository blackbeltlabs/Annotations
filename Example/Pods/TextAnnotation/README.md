# TextAnnotation

[![CI Status](https://img.shields.io/travis/blackbeltlabs/TextAnnotation.svg?style=flat)](https://travis-ci.org/blackbeltlabs/TextAnnotation)
[![Version](https://img.shields.io/cocoapods/v/TextAnnotation.svg?style=flat)](https://cocoapods.org/pods/TextAnnotation)
[![License](https://img.shields.io/cocoapods/l/TextAnnotation.svg?style=flat)](https://cocoapods.org/pods/TextAnnotation)
[![Platform](https://img.shields.io/cocoapods/p/TextAnnotation.svg?style=flat)](https://cocoapods.org/pods/TextAnnotation)

A textbox component that behaves like typical drawing or annotation apps require - think Sketch, Skitch, CloudApp etc.

The module is designed to be used alongside other drawing modules which for example support pen, rectangle or arrow annotations.

**This module is a work in progress - to contribute review the spec:**

- [Development Spec](Spec/Specification.md)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

TextAnnotation is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TextAnnotation'
```

## Usage

Text annotation support can be added by adopting the `TextAnnotationsController` protocol on a `NSViewController` instance.
The protocol adds default handling of click and drag events but needs to be notified by those.
The `TextAnnotationDelegate` protocol can be used to handle editing and move operations.
Newly created `TextAnnotation` instances get by default the controller assigned as delegate.

### Example

```swift
class ViewController: NSViewController, TextAnnotationsController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Programmatically creating a text annotation
    let location = CGPoint(x: 100, y: 150)
    
    // Method supplied by TextAnnotationsController protocol implementation
    addTextAnnotation(text: "Some text", location: location)
  }
  
  override func mouseDown(with event: NSEvent) {
    // TextAnnotationsController needs to handle mouse down events
    textAnnotationsMouseDown(event: event)
  }
  
  override func mouseDragged(with event: NSEvent) {
    // TextAnnotationsController needs to handle drag events
    textAnnotationsMouseDragged(event: event)
  }
}

extension ViewController: TextAnnotationDelegate {
  func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    print(textAnnotation.text)
  }
  
  func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    print(textAnnotation.frame)
  }
}
```

## Interface Definition

### TextAnnotation

```swift
public protocol TextAnnotation {
  var text: String { get set }
  var frame: CGRect { get set }
}
```

### TextAnnotationsController

```swift
public protocol TextAnnotationsController {
  func addTextAnnotation(_ textAnnotation: TextAnnotation)
  func textAnnotationsMouseDown(event: NSEvent)
  func textAnnotationsMouseDragged(event: NSEvent)
}
```

### TextAnnotationDelegate

```swift
public protocol TextAnnotationDelegate {
  func textAnnotationDidEdit(textAnnotation: TextAnnotation)
  func textAnnotationDidMove(textAnnotation: TextAnnotation)
}
```


## Author

Mirko Kiefer, mail@mirkokiefer.com

## License

TextAnnotation is available under the MIT license. See the LICENSE file for more info.
