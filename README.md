# MixedObj

A Swift library for flexible JSON parsing and type conversion, providing a safe and convenient way to handle mixed-type JSON data.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Type-Specific Parsing](#type-specific-parsing)
  - [Array and Dictionary Access](#array-and-dictionary-access)
  - [Type Conversion](#type-conversion)
- [Custom Type Acceptance](#custom-type-acceptance)
- [中文文档](#mixedobj-1)

## Features

- 🔄 Type-safe JSON parsing with customizable type acceptance
- 🎯 Support for all common JSON data types (Bool, Int, Double, String, Array, Dictionary)
- 📦 Flexible type conversion between different data types
- ⚡️Null value handling
- 🕒 Custom date parsing
- 🔍 Array and Dictionary subscript support
- 🏏 Codable protocol compliance

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/mithyer/MixedObject.git", from: "1.2.0")
]
```

### Installation with CocoaPods

To integrate MixedObject into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'MixedObject'
```

## Usage

### Basic Usage

```swift
// Parse JSON data
let jsonData = """
{
    "name": "John",
    "age": 30,
    "scores": [85, 90, 95],
    "details": {
        "active": true,
        "lastLogin": "2025-02-10T10:30:00.000Z"
    }
}
""".data(using: .utf8)!

let decoded = try? JSONDecoder().decode(MXObj.self, from: jsonData)
```

### Type-Specific Parsing

```swift
// Number parsing
let number: MXNumber = try decoder.decode(MXNumber.self, from: jsonData)
let intValue = number.intValue() // With default value
let doubleValue = number.doubleValue

// Boolean parsing
let bool: MXBool = try decoder.decode(MXBool.self, from: jsonData)
let boolValue = bool.boolValue()

// Date parsing
let date: MXDate = try decoder.decode(MXDate.self, from: jsonData)
let dateValue = date.dateValue
```

### Array and Dictionary Access

```swift
// Array access
let array = decoded["scores"]
let firstScore = array[0].to(Int.self)

// Dictionary access
let details = decoded["details"]
let isActive = details["active"].to(Bool.self)
```

### Type Conversion

```swift
// Convert to native types
let stringArray = decoded["scores"].to([String].self)
let intDictionary = decoded["stats"].to([String: Int].self)

// Convert to common types
let anyArray = decoded.toCommonArray()
let anyDictionary = decoded.toCommonDic()
```

## Custom Type Acceptance

Create custom type accepters by implementing `MixedObjRootAccepter`:

```swift
struct CustomAccepter: MixedObjRootAccepter {
    static func acceptInt(value: Int) -> Bool { 
        // Custom validation logic
        return value >= 0 
    }
    static func acceptString(value: String) -> Bool { 
        // Custom validation logic
        return !value.isEmpty 
    }
}

typealias CustomObj = MixedObj<CustomAccepter>
```

---

# MixedObj

一个灵活的 JSON 解析和类型转换的 Swift 库，为处理混合类型的 JSON 数据提供安全便捷的方式。

## 目录
- [特性](#特性)
- [安装](#安装)
- [使用方法](#使用方法)
  - [基本用法](#基本用法)
  - [特定类型解析](#特定类型解析)
  - [数组和字典访问](#数组和字典访问)
  - [类型转换](#类型转换)
- [自定义类型接受器](#自定义类型接受器)
- [English Documentation](#mixedobj)

## 特性

- 类型安全的 JSON 解析，支持自定义类型接受规则
- 支持所有常见 JSON 数据类型（布尔值、整数、浮点数、字符串、数组、字典）
- 灵活的类型转换
- 空值处理
- 自定义日期解析
- 数组和字典下标访问支持
- 符合 Codable 协议

## 安装

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/mithyer/MixedObject.git", from: "1.2.0")
]
```

### Installation with CocoaPods

To integrate MixedObject into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'MixedObject'
```

## 使用方法

### 基本用法

```swift
// 解析 JSON 数据
let jsonData = """
{
    "name": "小明",
    "age": 30,
    "scores": [85, 90, 95],
    "details": {
        "active": true,
        "lastLogin": "2025-02-10T10:30:00.000Z"
    }
}
""".data(using: .utf8)!

let decoded = try? JSONDecoder().decode(MXObj.self, from: jsonData)
```

### 特定类型解析

```swift
// 数字解析
let number: MXNumber = try decoder.decode(MXNumber.self, from: jsonData)
let intValue = number.intValue() // 使用默认值
let doubleValue = number.doubleValue

// 布尔值解析
let bool: MXBool = try decoder.decode(MXBool.self, from: jsonData)
let boolValue = bool.boolValue()

// 日期解析
let date: MXDate = try decoder.decode(MXDate.self, from: jsonData)
let dateValue = date.dateValue
```

### 数组和字典访问

```swift
// 数组访问
let array = decoded["scores"]
let firstScore = array[0].to(Int.self)

// 字典访问
let details = decoded["details"]
let isActive = details["active"].to(Bool.self)
```

### 类型转换

```swift
// 转换为原生类型
let stringArray = decoded["scores"].to([String].self)
let intDictionary = decoded["stats"].to([String: Int].self)

// 转换为通用类型
let anyArray = decoded.toCommonArray()
let anyDictionary = decoded.toCommonDic()
```

## 自定义类型接受器

通过实现 `MixedObjRootAccepter` 创建自定义类型接受器：

```swift
struct CustomAccepter: MixedObjRootAccepter {
    static func acceptInt(value: Int) -> Bool { 
        // 自定义验证逻辑
        return value >= 0 
    }
    static func acceptString(value: String) -> Bool { 
        // 自定义验证逻辑
        return !value.isEmpty 
    }
}

typealias CustomObj = MixedObj<CustomAccepter>
```
