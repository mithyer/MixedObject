# MixedObj

MixedObj is a flexible Swift Decodable solution for handling mixed-type JSON decoding, providing type-safe access to nested JSON structures with support for various data types and automatic type conversion.

## Features

- 🔄 Type-safe JSON decoding for mixed-type values
- 🎯 Support for common data types: Bool, Int, Double, String, Array, Dictionary
- 📦 Nested JSON structure handling
- ⚡️ Easy subscript access for arrays and dictionaries
- 🕒 Built-in Date conversion support
- 🔍 Null value handling
- 🛡️ Type option protocols for flexible type constraints

## Usage

### Basic Usage

```swift
// Define your JSON data type
let jsonData = """
{
    "name": "John",
    "age": 30,
    "isActive": true,
    "scores": [85, 90, 95],
    "metadata": {
        "lastLogin": "2024-01-09T12:00:00.000Z"
    }
}
""".data(using: .utf8)!

// Decode with MixedObj
let decoded = try? JSONDecoder().decode(MixedObj<MOOption.AnyObj>.self, from: jsonData)

// Access values
let name = decoded?["name"].toSingle(String.self) // "John"
let age = decoded?["age"].toSingle(Int.self) // 30
let scores = decoded?["scores"].toArray() // [85, 90, 95]
let lastLogin = decoded?["metadata"]["lastLogin"].toDate() // Date object

// Or define your custom model
struct CustomModel: Decodable {
	var name: MixedObj<MOOption.StringOrInt>
	var age: MixedObj<MOOption.BoolOrInt>
	var scores: MixedObj<MOOption.Array>
	var metadata: [String: MixedObj<MOOption.Date>]
}

// Decode with CustomModel
let decoded = try! JSONDecoder().decode(CustomModel.self, from: jsonData)

// Access values
let name = decoded.name.toSingle(String.self) // "John"
let age = decoded.age.toSingle(Int.self) // 30
let scores = decoded.scores.toArray() // [85, 90, 95]
let lastLogin = decoded.metadata["lastLogin"].toDate() // Date object
```

### Type Options

MixedObj provides several predefined type options for different use cases:

- `MOOption.AnyObj`: Accepts all types
- `MOOption.StringOrInt`: Accepts String and Int only
- `MOOption.BoolOrInt`: Accepts Bool and Int only
- `MOOption.Array`: Accepts Array only
- `MOOption.Dic`: Accepts Dictionary only
- `MOOption.ArrayOrDic`: Accepts both Array and Dictionary
- `MOOption.Single`: Accepts primitive types (Bool, Int, Double, String)
- `MOOption.Date`: Accepts values that can be converted to Date

### Date Handling

MixedObj supports date conversion from multiple formats:
- Unix timestamp (Int)
- Unix timestamp with milliseconds (Double)
- ISO8601 formatted string

```swift
// Date from timestamp
let timestampJSON = "1704844800" // 2024-01-09 12:00:00
let timestampDate = try? JSONDecoder().decode(MixedObj<MOOption.Date>.self, from: timestampJSON.data(using: .utf8)!).toDate()

// Date from ISO string
let isoJSON = "\"2024-01-09T12:00:00.000Z\""
let isoDate = try? JSONDecoder().decode(MixedObj<MOOption.Date>.self, from: isoJSON.data(using: .utf8)!).toDate()
```

## Requirements

- iOS 11.0+ / macOS 10.13+
- Swift 5.0+

## Inspired by
[https://gist.github.com/mbuchetics/c9bc6c22033014aa0c550d3b4324411a](https://gist.github.com/mbuchetics/c9bc6c22033014aa0c550d3b4324411a)

---
