//
//  MixedObj.swift
//
//
//  Created by Ray
//

import Foundation

public enum MixedObjType: String, CaseIterable {
   case bool, int, double, string
   case array, dic
}

struct MixedCodingKeys: CodingKey {
    
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}

public extension KeyedDecodingContainer {
    func decode<T: MixedObjRootAccepter>(_: MixedObj<T>.Type, forKey key: Key) throws -> MixedObj<T> {
        if let value = try decodeIfPresent(MixedObj<T>.self, forKey: key) {
            return value
        } else {
            return .null
        }
    }
}

fileprivate let iso8601withFractionalSeconds: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return formatter
}()

public enum MixedObj<T: MixedObjRootAccepter>: Decodable, CustomStringConvertible {
    
    case bool(Bool)
    case double(Double)
    case string(String)
    case int(Int)
    case null
    indirect case array([MixedObj<MXRootAccepter.All>])
    indirect case dictionary([String: MixedObj<MXRootAccepter.All>])

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: MixedCodingKeys.self) {
            self = T.acceptDic() ? try MixedObj(from: container) : .null
        } else if let container = try? decoder.unkeyedContainer() {
            self = T.acceptArray() ? try MixedObj(from: container) : .null
        } else if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .null
            } else if let value = try? container.decode(Bool.self) {
                self = T.acceptBool(value: value) ? .bool(value) : .null
            } else if let value = try? container.decode(Int.self) {
                self = T.acceptInt(value: value) ? .int(value) : .null
            } else if let value = try? container.decode(Double.self) {
                self = T.acceptDouble(value: value) ? .double(value) : .null
            } else if let value = try? container.decode(String.self) {
                self = T.acceptString(value: value) ? .string(value) : .null
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "single value decode error"))
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "no such category for decoder"))
        }
    }

    private init(from container: KeyedDecodingContainer<MixedCodingKeys>) throws {
        var dict: [String: MixedObj<MXRootAccepter.All>] = [:]
        for key in container.allKeys {
            if true == (try? container.decodeNil(forKey: key)) {
                dict[key.stringValue] = .null
            } else if let value = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = .bool(value)
            } else if let value = try? container.decode(Int.self, forKey: key) {
                dict[key.stringValue] = .int(value)
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = .double(value)
            } else if let value = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = .string(value)
            } else if let value = try? container.nestedContainer(keyedBy: MixedCodingKeys.self, forKey: key) {
                dict[key.stringValue] = try MixedObj<MXRootAccepter.All>(from: value)
            } else if let value = try? container.nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = try MixedObj<MXRootAccepter.All>(from: value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [key], debugDescription: "not supported type by keyed"))
            }
        }
        self = .dictionary(dict)
    }

    private init(from container: UnkeyedDecodingContainer) throws {
        var container = container
        var arr: [MixedObj<MXRootAccepter.All>] = []
        while !container.isAtEnd {
            if true == (try? container.decodeNil()) {
                arr.append(.null)
            } else if let value = try? container.decode(Bool.self) {
                arr.append(.bool(value))
            } else if let value = try? container.decode(Int.self) {
                arr.append(.int(value))
            } else if let value = try? container.decode(Double.self) {
                arr.append(.double(value))
            } else if let value = try? container.decode(String.self) {
                arr.append(.string(value))
            } else if let value = try? container.nestedContainer(keyedBy: MixedCodingKeys.self){
                arr.append(try MixedObj<MXRootAccepter.All>(from: value))
            } else if let value = try? container.nestedUnkeyedContainer() {
                arr.append(try MixedObj<MXRootAccepter.All>(from: value))
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "not supported type by unkeyed"))
            }
        }
        self = .array(arr)
    }
    
    public var description: String {
        return "==>\nMixedObj(\(T.self)):\n\(jsonString())\n<=="
    }
    
    public func jsonString() -> String {
        switch self {
        case .bool(let bool):
            return "\(bool)"
        case .int(let int):
            return "\(int)"
        case .null:
            return "null"
        case .double(let double):
            return "\(double)"
        case .string(let string):
            return "\"\(string)\""
        case .array(let array):
            return "[" + array.map({ json in
                json.jsonString()
            }).joined(separator: ",") + "]"
        case .dictionary(let dictionary):
            return "{" + dictionary.mapValues({ json in
                json.jsonString()
            }).keys.map({ key in
                "\"\(key)\": \(dictionary[key]?.jsonString() ?? "null")"
            }).joined(separator: ",") + "}"
        }
    }
    
    public subscript(index: Int) -> MixedObj<MXRootAccepter.All> {
        get {
            if case let .array(list) = self {
                return list[index]
            }
            return .null
        }
        mutating set(newValue) {
            if case var .array(list) = self {
                list[index] = newValue
                self = .array(list)
            }
        }
    }
    
    public subscript(key: String) -> MixedObj<MXRootAccepter.All> {
        get {
            if case let .dictionary(dic) = self {
                return dic[key] ?? .null
            }
            return .null
        }
        mutating set(newValue) {
            if case var .dictionary(dic) = self {
                dic[key] = newValue
                self = .dictionary(dic)
            }
        }
    }
    
    public func isNull() -> Bool {
        if case .null = self {
            return true
        }
        return false
    }
    
    
    public func to<S: FixedWidthInteger>(_ type: S.Type) -> S? {
        switch self {
        case .double(let double):
            return S(double)
        case .string(let string):
            return S(string)
        case .int(let int):
            return S(int)
        case .bool, .null, .array, .dictionary:
            return nil
        }
    }
    
    public func to<S: StringProtocol>(_ type: S.Type) -> S? {
        return "\(jsonString())"
    }
    
    public func to<S: BinaryFloatingPoint>(_ type: S.Type) -> S? {
        switch self {
        case .double(let double):
            return S(double)
        case .string(let string):
            if let double = Double(string) {
                return S(double)
            }
            return nil
        case .int(let int):
            return S(int)
        case .bool, .null, .array, .dictionary:
            return nil
        }
    }

    public func to<S>(_ type: S.Type) -> S? {
        if type == Bool.self {
            switch self {
            case .bool(let bool):
                return bool as? S
            case .int(let int):
                if int == 0 {
                    return false as? S
                }
                if int == 1 {
                    return true as? S
                }
                return nil
            case .string(let string):
                let string = string.lowercased()
                if string == "0" || string == "false" {
                    return false as? S
                }
                if string == "1" || string == "true" {
                    return true as? S
                }
            case .double, .null, .array, .dictionary:
                return nil
            }
        } else if type == Date.self {
            switch self {
            case .double(let double):
                return Date.init(timeIntervalSince1970: double) as? S
            case .string(let string):
                return iso8601withFractionalSeconds.date(from: string) as? S
            case .int(let int):
                return Date.init(timeIntervalSince1970: TimeInterval(int)) as? S
            case .null, .array, .dictionary, .bool:
                return nil
            }
        } else if type == Decimal.self {
            switch self {
            case .int(let int):
                return Decimal(int) as? S
            case .string(let string):
                return Decimal(string: string) as? S
            case .double(let double):
                return Decimal(double) as? S
            case .null, .array, .dictionary, .bool:
                return nil
            }
        }
        return nil
    }
    
    public func to<S: FixedWidthInteger>(_ type: Dictionary<String, S>.Type) -> Dictionary<String, S?>? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { value in
            return value.to(S.self)
        }
    }
    
    public func to<S: StringProtocol>(_ type: Dictionary<String, S>.Type) -> Dictionary<String, S?>? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { value in
            return value.to(S.self)
        }
    }
    
    public func to<S: BinaryFloatingPoint>(_ type: Dictionary<String, S>.Type) -> Dictionary<String, S?>? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { value in
            return value.to(S.self)
        }
    }
    
    public func to<S>(_ type: Dictionary<String, S>.Type) -> Dictionary<String, S?>? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { value in
            return value.to(S.self)
        }
    }
    
    public func to<S: FixedWidthInteger>(_ type: Array<S>.Type) -> Array<S?>? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { element in
            return element.to(S.self)
        }
    }
    
    public func to<S: StringProtocol>(_ type: Array<S>.Type) -> Array<S?>? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { element in
            return element.to(S.self)
        }
    }
    
    public func to<S: BinaryFloatingPoint>(_ type: Array<S>.Type) -> Array<S?>? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { element in
            return element.to(S.self)
        }
    }
    
    public func to<S>(_ type: Array<S>.Type) -> Array<S?>? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { element in
            return element.to(S.self)
        }
    }
    
    public func toCommonArray() -> [Any?]? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { (element: MixedObj<MXRootAccepter.All>) -> Any? in
            switch element {
            case .array:
                element.toCommonArray()
            case .dictionary:
                element.toCommonDic()
            case .bool(let bool):
                bool
            case .double(let double):
                double
            case .int(let int):
                int
            case .string(let string):
                string
            case .null:
                nil
            }
        }
    }
    
    public func toCommonDic() -> [String: Any?]? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { (element: MixedObj<MXRootAccepter.All>) -> Any?  in
            switch element {
            case .array:
                element.toCommonArray()
            case .dictionary:
                element.toCommonDic()
            case .bool(let bool):
                bool
            case .double(let double):
                double
            case .int(let int):
                int
            case .string(let string):
                string
            case .null:
                nil
            }
        }
    }
}
