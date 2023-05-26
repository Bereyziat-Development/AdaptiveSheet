# SwiftUIAdaptiveActionSheet

A custom SwiftUI component that provides an adaptive action sheet behavior similar to the native iOS action sheet.



## Features


![Simulator Screen Recording - iPhone 14 Pro - 2023-05-26 at 15 10 56](https://github.com/Bereyziat-Development/SwiftUIAdaptiveActionSheet/assets/101000022/6b389a8e-b39c-443c-8fe7-4572d4b1a15e)



- Adaptive action sheet behavior based on iOS 15 or later
- Fullscreen cover presentation for older iOS versions
- Customizable appearance and behavior

## Requirements

- iOS 15 or later
- Swift 5.5 or later

## Installation

### Swift Package Manager

To install the SwiftUIAdaptiveActionSheet library using Swift Package Manager, follow these steps:

1. In Xcode, open your project.
2. Go to **File** > **Swift Packages** > **Add Package Dependency**.
3. Enter the repository URL: `https://github.com/Bereyziat-Development/SwiftUIAdaptiveActionSheet`.
4. Click **Next** and follow the remaining steps to add the package to your project.

## Usage

1. Import the SwiftUIAdaptiveActionSheet library in your SwiftUI view:

```swift
import SwiftUIAdaptiveActionSheet

struct ContentView: View {
    @State private var showActionSheet = false
    
    var body: some View {
        Button("Show Action Sheet") {
            showActionSheet.toggle()
        }
        .adaptiveHeightSheet(isPresented: $showActionSheet) {
            // Add your action sheet content here
            Text("This is an example action sheet")
        }
    }
}
```

2. Customization

The SwiftUIAdaptiveActionSheet component provides various customization options. You can modify the appearance and behavior using the available properties and modifiers.

Example
Here's an example of customizing the component:

```swift
Button("Show Action Sheet") {
    showActionSheet.toggle()
}
.adaptiveHeightSheet(isPresented: $showActionSheet) {
    // Add your action sheet content here
    Text("This is an example action sheet")
}
.font(.title)
.padding()
.background(Color.blue)
.foregroundColor(.white)
.cornerRadius(10)
```
## License
This library is available under the MIT license. See the LICENSE file for more information.
