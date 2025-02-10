//
//  MixedObj+Accepter.swift
//  MixedObject
//
//  Created by ray on 2025/2/6.
//

import Foundation

public protocol MixedObjRootAccepter {
    static func acceptInt(value: Int) -> Bool
    static func acceptDouble(value: Double) -> Bool
    static func acceptBool(value: Bool) -> Bool
    static func acceptString(value: String) -> Bool
    static func acceptDic() -> Bool
    static func acceptArray() -> Bool
}

extension MixedObjRootAccepter {
    public static func acceptInt(value: Int) -> Bool { false }
    public static func acceptDouble(value: Double) -> Bool { false }
    public static func acceptBool(value: Bool) -> Bool { false }
    public static func acceptString(value: String) -> Bool { false }
    public static func acceptDic() -> Bool { false }
    public static func acceptArray() -> Bool { false }
}


public struct MXRootAccepter {
    
    public struct All: MixedObjRootAccepter {
        public static func acceptInt(value: Int) -> Bool { true }
        public static func acceptDouble(value: Double) -> Bool { true }
        public static func acceptBool(value: Bool) -> Bool { true }
        public static func acceptString(value: String) -> Bool { true }
        public static func acceptDic() -> Bool { true }
        public static func acceptArray() -> Bool { true }
    }
    
    public struct NumberConvertable: MixedObjRootAccepter {
        public static func acceptInt(value: Int) -> Bool { true }
        public static func acceptDouble(value: Double) -> Bool { true }
        private static var acceptChars: Set<Character> = Set("0123456789.")
        public static func acceptString(value: String) -> Bool {
            for char in value {
                if !acceptChars.contains(char) {
                    debugPrint("\(value) is not accept for \(Self.self)")
                    return false
                }
            }
            return true
        }
    }
    
    public struct BoolConvertable: MixedObjRootAccepter {
        public static func acceptInt(value: Int) -> Bool {
            return value == 1 || value == 0
        }
        public static func acceptBool(value: Bool) -> Bool { true }
        private static var acceptStrings: Set<String> = Set(["0", "1", "true", "false"])
        public static func acceptString(value: String) -> Bool {
            return acceptStrings.contains(value.lowercased())
        }
    }
    
    public struct DateConvertable: MixedObjRootAccepter {
        public static func acceptInt(value: Int) -> Bool { true }
        public static func acceptDouble(value: Double) -> Bool { true }
        public static func acceptString(value: String) -> Bool { true }
    }
    
    public struct DicOrArray: MixedObjRootAccepter {
        public static func acceptDic() -> Bool { true }
        public static func acceptArray() -> Bool { true }
    }
}

typealias MXObj = MixedObj<MXRootAccepter.All>
typealias MXNumber = MixedObj<MXRootAccepter.NumberConvertable>
typealias MXBool = MixedObj<MXRootAccepter.BoolConvertable>
typealias MXDate = MixedObj<MXRootAccepter.DateConvertable>
typealias MXCollection = MixedObj<MXRootAccepter.DicOrArray>

extension MXNumber {
    
    public var intValue: Int? {
        return to(Int.self)
    }
    
    public var doubleValue: Double? {
        return to(Double.self)
    }
    
    public var stringValue: String? {
        return to(String.self)
    }
    
    public func intValue(with defaultValue: Int = 0) -> Int {
        return intValue ?? defaultValue
    }
    
    public func doubleValue(with defaultValue: Double = 0) -> Double {
        return doubleValue ?? defaultValue
    }
    
    public func stringValue(with defaultValue: String = "") -> String {
        return stringValue ?? defaultValue
    }
}

extension MXBool {
    
    public var boolValue: Bool? {
        return to(Bool.self)
    }
    
    public func boolValue(with defaultValue: Bool = false) -> Bool {
        return boolValue ?? defaultValue
    }
}

extension MXDate {
    
    public var dateValue: Date? {
        return to(Date.self)
    }
    
    public func dateValue(with defaultValue: Date = Date(timeIntervalSince1970: 0)) -> Date {
        return dateValue ?? defaultValue
    }
}

extension MXCollection {
    
    public struct AnyValueType {}
    
    public func toArray<S>(valueType: S = AnyValueType.self, with defaultArray: [Any]? = nil) -> [Any?]? {
        guard case .array = self else {
            return defaultArray
        }
        if valueType is AnyValueType {
            return toCommonArray() ?? defaultArray
        }
        return to([S].self) ?? defaultArray
    }
    
    public func toDic<S>(valueType: S = AnyValueType.self, with defaultDic: [String: Any]? = nil) -> [String: Any?]? {
        guard case .dictionary = self else {
            return defaultDic
        }
        if valueType is AnyValueType {
            return toCommonDic() ?? defaultDic
        }
        return to([String: S].self) ?? defaultDic
    }
}
