//
//  MixedObj+Default.swift
//  MixedObject
//
//  Created by ray on 2025/2/6.
//

import Foundation

public protocol MixedObjValueDefault {
    static var defaultValue: Any? { get }
}

public struct MODefault {
    public struct Null: MixedObjValueDefault {
        public static var defaultValue: Any?
    }
    
    public struct IntZero: MixedObjValueDefault {
        public static var defaultValue: Any? { Int(0) }
    }
    
    public struct DoubleZero: MixedObjValueDefault {
        public static var defaultValue: Any? { Double(0) }
    }
    
    public struct EmptyString: MixedObjValueDefault {
        public static var defaultValue: Any? { "" }
    }
    
    public struct EmptyDic: MixedObjValueDefault {
        public static var defaultValue: Any? { [String: Any]() }
    }
    
    public struct EmptyArray: MixedObjValueDefault {
        public static var defaultValue: Any? { [Any]() }
    }
    
    public struct True: MixedObjValueDefault {
        public static var defaultValue: Any? { true }
    }
    
    public struct False: MixedObjValueDefault {
        public static var defaultValue: Any? { false }
    }
}

extension MixedObj where OP: MixedObjTypeOption, DF: MixedObjValueDefault {
    
    static func createDefault() -> Self {
        let value = DF.defaultValue
        switch value {
        case nil:
            return .null
        case is Int:
            return .int(value as! Int)
        case is Double:
            return .double(value as! Double)
        case is String:
            return .string(value as! String)
        case is [Any]:
            let value = value as! [Any]
            if value.isEmpty {
                return .array([])
            } else if let data = try? JSONSerialization.data(withJSONObject: value) {
                let decoder = JSONDecoder()
                return (try? decoder.decode(Self.self, from: data)) ?? .null
            }
        case is [String: Any]:
            let value = value as! [String: Any]
            if value.isEmpty {
                return .dictionary([:])
            } else if let data = try? JSONSerialization.data(withJSONObject: value) {
                let decoder = JSONDecoder()
                return (try? decoder.decode(Self.self, from: data)) ?? .null
            }
        default:
            return .null
        }
        return .null
    }
    
}

public extension KeyedDecodingContainer {
    func decode<T: MixedObjTypeOption, S: MixedObjValueDefault>(_: MixedObj<T, S>.Type, forKey key: Key) throws -> MixedObj<T, S> {
        if let value = try decodeIfPresent(MixedObj<T, S>.self, forKey: key) {
            return value
        } else {
            return MixedObj<T, S>.createDefault()
        }
    }
}
