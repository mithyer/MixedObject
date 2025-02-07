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

public enum MixedObj<OP: MixedObjTypeOption, DF: MixedObjValueDefault>: Decodable, CustomStringConvertible {
    
    case bool(Bool)
    case double(Double)
    case string(String)
    case int(Int)
    case null
    indirect case array([MixedObj<MOOption.AnyObj, MODefault.Null>])
    indirect case dictionary([String: MixedObj<MOOption.AnyObj, MODefault.Null>])

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: MixedCodingKeys.self) {
            self = OP.types.contains(.dic) ? try MixedObj(from: container) : .null
        } else if let container = try? decoder.unkeyedContainer() {
            self = OP.types.contains(.array) ? try MixedObj(from: container) : .null
        } else if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                if let first = OP.types.first {
                    self = Self.createDefault(type: first)
                } else {
                    self = .null
                }
            } else if let value = try? container.decode(Bool.self) {
                self = OP.types.contains(.bool) ? .bool(value) : .null
            } else if let value = try? container.decode(Int.self) {
                if OP.types.contains(.int) {
                    self = .int(value)
                } else if OP.types.contains(.double), let value = try? container.decode(Double.self) {
                    self = .double(value)
                } else {
                    self = .null
                }
            } else if let value = try? container.decode(Double.self) {
                self = OP.types.contains(.double) ? .double(value) : .null
            } else if let value = try? container.decode(String.self) {
                self = OP.types.contains(.string) ? .string(value) : .null
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "single value decode error"))
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "no such category for decoder"))
        }
    }

    private init(from container: KeyedDecodingContainer<MixedCodingKeys>) throws {
        var dict: [String: MixedObj<MOOption.AnyObj, MODefault.Null>] = [:]
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
                dict[key.stringValue] = try MixedObj<MOOption.AnyObj, MODefault.Null>(from: value)
            } else if let value = try? container.nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = try MixedObj<MOOption.AnyObj, MODefault.Null>(from: value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [key], debugDescription: "not supported type by keyed"))
            }
        }
        if dict.isEmpty {
            self = Self.createDefault(type: .dic)
        } else {
            self = .dictionary(dict)
        }
    }

    private init(from container: UnkeyedDecodingContainer) throws {
        var container = container
        var arr: [MixedObj<MOOption.AnyObj, MODefault.Null>] = []
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
                arr.append(try MixedObj<MOOption.AnyObj, MODefault.Null>(from: value))
            } else if let value = try? container.nestedUnkeyedContainer() {
                arr.append(try MixedObj<MOOption.AnyObj, MODefault.Null>(from: value))
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "not supported type by unkeyed"))
            }
        }
        if arr.isEmpty {
            self = Self.createDefault(type: .array)
        } else {
            self = .array(arr)
        }
    }
    
    public var description: String {
        return "==>\nMixedObj(\(OP.description)):\n\(jsonString())\n<=="
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
    
    public subscript(index: Int) -> MixedObj<MOOption.AnyObj, MODefault.Null> {
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
    
    public subscript(key: String) -> MixedObj<MOOption.AnyObj, MODefault.Null> {
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
    
    public func toSingle<T>(_ type: T.Type) -> T? {
        if type == Date.self {
            return toDate() as? T
        }
        if type == Decimal.self {
            return toDecimal() as? T
        }
        switch self {
        case .bool(let bool):
            if type == Bool.self {
                return bool as? T
            }
            if type == String.self {
                return "\(bool)" as? T
            }
            return nil
        case .double(let double):
            if type == Double.self {
                return double as? T
            }
            if type == Float.self {
                return Float.init(double) as? T
            }
            if type == String.self {
                return "\(double)" as? T
            }
            return nil
        case .string(let string):
            if type == String.self {
                return string as? T
            }
            if type == Bool.self {
                return (string == "true" ? true : (string == "false" ? false : nil)) as? T
            }
            if type == Double.self {
                return Double(string) as? T
            }
            if type == Int.self {
                return Int(string) as? T
            }
            if type == UInt.self {
                return UInt(string) as? T
            }
            if type == Float.self {
                return Float(string) as? T
            }
            return nil
        case .int(let int):
            if type == Int.self {
                return int as? T
            }
            if type == UInt.self {
                return int > 0 ? UInt.init(int) as? T : nil
            }
            if type == Double.self {
                return Double.init(exactly: int) as? T
            }
            if type == Float.self {
                return Float.init(exactly: int) as? T
            }
            if type == String.self {
                return "\(int)" as? T
            }
            return nil
        case .null, .array, .dictionary:
            return nil
        }
    }
    
    public func toArray<T>(_ elementType: T.Type) -> [T?]? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { element in
            return element.toSingle(T.self)
        }
    }
    
    public func toDic<T>(_ valueType: T.Type) -> [String: T?]? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { value in
            return value.toSingle(T.self)
        }
    }
    
    public func toAnyValueArray() -> [Any?]? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.map { (element: MixedObj<MOOption.AnyObj, MODefault.Null>) -> Any? in
            switch element {
            case .array:
                element.toAnyValueArray()
            case .dictionary:
                element.toAnyValueDic()
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
    
    public func toAnyValueDic() -> [String: Any?]? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { (element: MixedObj<MOOption.AnyObj, MODefault.Null>) -> Any?  in
            switch element {
            case .array:
                element.toAnyValueArray()
            case .dictionary:
                element.toAnyValueDic()
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
    
    public func toDate() -> Date? {
        switch self {
        case .double(let double):
            return OP.toDate((nil, double, nil))
        case .string(let string):
            return OP.toDate((nil, nil, string))
        case .int(let int):
            return OP.toDate((int, nil, nil))
        case .null, .array, .dictionary, .bool:
            return nil
        }
    }
    
    public func toDecimal() -> Decimal? {
        switch self {
        case .int(let int):
            return Decimal(int)
        case .string(let string):
            return Decimal(string: string)
        case .double(let double):
            return Decimal(double)
        case .null, .array, .dictionary, .bool:
            return nil
        }
        
    }
    
}

