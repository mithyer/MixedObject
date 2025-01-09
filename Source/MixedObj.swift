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
   case null
}

public protocol MixedObjTypeOption {
    static var types: Set<MixedObjType> { get }
    static var description: String { get }
    static func toDate(_ value: (Int?, Double?, String?)) -> Date?
}

fileprivate let iso8601withFractionalSeconds: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return formatter
}()

extension MixedObjTypeOption {
    
    public static func toDate(_ value: (Int?, Double?, String?)) -> Date? {
        if let value = value.0 {
            return Date.init(timeIntervalSince1970: TimeInterval(value))
        }
        if let value = value.1 {
            return Date.init(timeIntervalSince1970: value)
        }
        if let value = value.2 {
           return iso8601withFractionalSeconds.date(from: value)
        }
        return nil
    }
    
    public static var description: String {
        "unknown"
    }
}

public struct MOOption {
    public struct AnyObj: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = Set(MixedObjType.allCases)
        public static private(set) var description: String = "Any|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
    public struct StringOrInt: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.string, .int]
        public static private(set) var description: String = "StringOrInt|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
    public struct BoolOrInt: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.bool, .int]
        public static private(set) var description: String = "BoolOrInt|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
    public struct Array: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.array]
        public static private(set) var description: String = "Array|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
    public struct Dic: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.dic]
        public static private(set) var description: String = "Dic|\(types.map({$0.rawValue}).joined(separator: ",")))"
    }
    public struct ArrayOrDic: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.dic, .array]
        public static private(set) var description: String = "ArrayOrDic|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
    public struct Single: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.bool, .int, .double, .string]
        public static private(set) var description: String = "Single|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
    public struct Date: MixedObjTypeOption {
        public static var types: Set<MixedObjType> = [.int, .double, .string]
        public static private(set) var description: String = "Date|\(types.map({$0.rawValue}).joined(separator: ","))"
    }
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

public enum MixedObj<OP: MixedObjTypeOption>: Decodable, CustomStringConvertible {
    
    case bool(Bool)
    case double(Double)
    case string(String)
    case int(Int)
    case null
    indirect case array([MixedObj<MOOption.AnyObj>])
    indirect case dictionary([String: MixedObj<MOOption.AnyObj>])

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: MixedCodingKeys.self) {
            self = OP.types.contains(.dic) ? try MixedObj(from: container) : .null
        } else if let container = try? decoder.unkeyedContainer() {
            self = OP.types.contains(.array) ? try MixedObj(from: container) : .null
        } else if let container = try? decoder.singleValueContainer() {
            if container.decodeNil() {
                self = .null
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
        var dict: [String: MixedObj<MOOption.AnyObj>] = [:]
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
                dict[key.stringValue] = try MixedObj<MOOption.AnyObj>(from: value)
            } else if let value = try? container.nestedUnkeyedContainer(forKey: key) {
                dict[key.stringValue] = try MixedObj<MOOption.AnyObj>(from: value)
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [key], debugDescription: "not supported type by keyed"))
            }
        }
        self = .dictionary(dict)
    }

    private init(from container: UnkeyedDecodingContainer) throws {
        var container = container
        var arr: [MixedObj<MOOption.AnyObj>] = []
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
                arr.append(try MixedObj<MOOption.AnyObj>(from: value))
            } else if let value = try? container.nestedUnkeyedContainer() {
                arr.append(try MixedObj<MOOption.AnyObj>(from: value))
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "not supported type by unkeyed"))
            }
        }
        self = .array(arr)
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
    
    public subscript(index: Int) -> MixedObj<MOOption.AnyObj> {
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
    
    public subscript(key: String) -> MixedObj<MOOption.AnyObj> {
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
        switch self {
        case .bool(let bool):
            return type == Bool.self ? bool as? T : nil
        case .double(let double):
            if type == Double.self {
                return double as? T
            }
            if type == Float.self {
                return Float.init(double) as? T
            }
            return nil
        case .string(let string):
            return type == String.self ? string as? T : nil
        case .int(let int):
            return type == Int.self ? int as? T : (type == UInt.self ? UInt.init(int) as? T : nil)
        case .null, .array, .dictionary:
            return nil
        }
    }
    
    public func toArray() -> [Any]? {
        guard case let .array(array) = self else {
            return nil
        }
        return array.compactMap { (element: MixedObj<MOOption.AnyObj>) -> Any? in
            switch element {
            case .array:
                element.toArray()
            case .dictionary:
                element.toDic()
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
    
    public func toDic() -> [String: Any]? {
        guard case let .dictionary(dic) = self else {
            return nil
        }
        return dic.mapValues { (element: MixedObj<MOOption.AnyObj>) -> Any?  in
            switch element {
            case .array:
                element.toArray()
            case .dictionary:
                element.toDic()
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
    
}

