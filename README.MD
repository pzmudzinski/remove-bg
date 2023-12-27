# Swit Client for remove.bg

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
![Tests](https://github.com/pzmudzinski/remove-bg/actions/workflows/tests.yml/badge.svg)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/pzmudzinski/remove-bg/blob/main/LICENSE)

## Overview

This Swift package is an API wrapper for the [remove.bg](https://remove.bg) API.
It simplifies the integration of remove.bg's functionality into Swift-based projects, providing an easy and efficient way to access and utilize the API's capabilities.

## Features

- Covers all available configuration options,
- `async`/`await` API,
- iOS and MacOS support

## Requirements

iOS 16.0 or later / macOS 12 or later.

## Installation

### Installing via Swift Package Manager (SPM)

You can easily integrate `RemoveBg` into your project using Swift Package Manager:

1. Open your Xcode project.
2. Click on "File" > "Swift Packages" > "Add Package Dependency..."
3. Enter the URL of this repository: `https://github.com/pzmudzinski/remove-bg.git`
4. Choose "Up To Next Major Version": 1.0.0
5. Click "Add Package"

## Usage

Import the package and use it to interact with the remove.bg API.

### Basic

```swift
import RemoveBg


let client = RemoveBgClient(apiKey: "my-api-key")
let result = try await client.removeBackground(fromImageData: imageData)
let image = UIImage(data: result.imageData)
```

### Configuration

You can configure all available removal options using `ApiOptions`:

```swift
let apiOptions = ApiOptions(size: .preview, bgColor: "#F00")
let result = try await client.removeBackground(fromImageData: loaded, options: apiOptions)
```

### Diferent image inputs

You can also use remote URL or base64 string as image input:

```swift
try await client.removeBackground(fromFileAtUrl: ...)
try await client.removeBackground(fromBase64Image: ...)
```

### Reading result meta

`ApiResult` contains `meta` object containing all information about request made, such as credits charged or foreground position:

```swift
result.meta?.creditsCharged
```

### Full SwiftUI example

```swift
struct ContentView: View {
    @State private var avatarItem: PhotosPickerItem?
    @State private var image: UIImage?

    var body: some View {
        VStack {
            PhotosPicker("Select image", selection: $avatarItem, matching: .images)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .onChange(of: avatarItem) {
            Task {
                if let loaded = try? await avatarItem?.loadTransferable(type: Data.self) {
                    do {
                        let client = RemoveBgClient(apiKey: "my-api-key")

                        let result = try await client.removeBackground(fromImageData: loaded)

                        self.image = UIImage(data: result.imageData)
                    } catch {
                        print(error)
                    }
                } else {
                    print("Failed")
                }
            }
        }
    }
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
