# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Annotations is a macOS-only Swift library (AppKit, no iOS) for annotating screenshots/images: arrows, rectangles, free-hand pen, numbered markers, text boxes, highlight and obfuscate areas. Swift 6 language mode (`swift-tools-version:6.0`) with strict concurrency — almost all UI-facing classes are `@MainActor`, models are `Sendable` value types.

## Commands

```bash
# Build the library (SPM package, dynamic library product)
swift build

# Build the example app (links the library via a local SPM package reference)
xcodebuild -workspace Example/Annotations.xcworkspace -scheme Annotations-Example build
```

There is no test target in the SPM package. The Example project has an `Annotations_Tests` target (placeholder XCTest only). To try changes interactively, run the `Annotations-Example` scheme from `Example/Annotations.xcworkspace` in Xcode — it opens a playground window (`Example/Annotations/Playground Controller/`) with a canvas and controls for every annotation type.

Note: `Annotations.podspec` is legacy — its `source_files` path (`Sources/Classes/**`) no longer matches the actual layout (`Sources/Annotations/Classes/**`), and the Example Podfile has all pods commented out. SPM is the supported integration.

## Architecture

All wiring happens in [Annotations.swift](Sources/Annotations/Annotations.swift): `AnnotationsCanvasFactory.instantiate()` builds the object graph and returns `(canvasView: DrawableCanvasView, parts: AnnotationsManagingParts)`, where the parts are the public API surface:

- **`ModelsManager`** — source of truth. Holds `CurrentValueSubject<AnnotationModelsSet>` of all annotation models; exposes add/select/delete/deselect and `allModelsPublisher`. Also implements the `DataSource` protocols the other managers depend on.
- **`SharedHistory`** — wraps `UndoManager` for undo/redo, exposes `canUndo/canRedoPublisher`. A custom instance can be injected into `instantiate()` to share history with the host app.
- **`Settings`** — the host app's input/output channel. Inputs are `CurrentValueSubject`s (current tool `CanvasItemType`, color, text style, obfuscate type, interaction enabled); outputs are publishers (text editing state, emoji picker presented).
- **`Analytics`** — read-only queries over current models (counts, types, color usage).

Everything is connected with Combine publishers, not delegates (the factory's `setupPublishers`/`bindSettings` do all binding). Communication is unidirectional:

```
DrawableCanvasView (mouse subjects) → MouseInteractionHandler → ModelsManager → Renderer → DrawableCanvasView (layers)
```

- **`MouseInteractionHandler`** ([Managers/](Sources/Annotations/Classes/Managers)) interprets mouse down/drag/up into creation, selection, movement, and knob-resize operations on models.
- **`Renderer`** ([Renderer/](Sources/Annotations/Classes/Renderer)) turns models into `LayerRenderingSet`s (CGPath + `LayerUISettings` + zPosition) and drives the canvas through the `RendererCanvas` protocol — the only interface it has to the view.
- **`DrawableCanvasView`** ([View/Canvas/](Sources/Annotations/Classes/View/Canvas)) implements `RendererCanvas`, managing `CAShapeLayer`-based drawables (`Classes/View/Drawables/`), obfuscate/highlight layers, and selection views (knobs, borders).

### Per-annotation-type factories

Models are `Codable & Sendable` structs conforming to `AnnotationModel` ([Model/Annotations/](Sources/Annotations/Classes/Model/Annotations)); `Rect` covers three variants via `RectModelType` (regular / obfuscate / highlight). Behavior for each type is spread across parallel factory hierarchies, each with a `Common/` protocol + factory and `Certain/` per-type implementations:

- `Model/Path Creator/` — model → CGPath
- `Renderer/Style Creator/` — model → layer stroke/fill style
- `Model/Selections/Knobs Creator/` and `SelectionPath/` — selection handles and outlines
- `Model/Transformations/Resize/` — knob-drag resize logic

Adding a new annotation type means adding a case to `CanvasItemType` and an implementation in each of these factories.

### Text annotations

Text is the special case: it is not a `CAShapeLayer` but an `NSTextView`-based view (`View/Drawables/TextAnnotation/`), managed by `TextAnnotationsManager` (`Model/Text Annotations/`) which handles editing state, dynamic sizing, scaling, and the legibility/emoji controls. The original functional spec with expected behaviors lives in [Sources/Spec/Specification.md](Sources/Spec/Specification.md).

### Serialization

`JSONSerializer` (`Classes/Serialization/`) saves/loads all models to JSON via intermediate `JSONSortedModel` types — keep these in sync when changing model fields, as annotation documents persist across app versions.
