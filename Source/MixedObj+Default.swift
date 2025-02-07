//
//  MixedObj+Default.swift
//  MixedObject
//
//  Created by ray on 2025/2/6.
//

import Foundation

public protocol MixedObjValueDefault {
    static var defaultBool: Bool? { get }
    static var defaultInt: Int? { get }
    static var defaultString: String? { get }
    static var defaultDouble: Double? { get }
    static var defaultDic: [String: Any]? { get }
    static var defaultArray: [Any]? { get }
}

extension MixedObjValueDefault {
    public static var defaultBool: Bool? { nil }
    public static var defaultInt: Int? { nil }
    public static var defaultString: String? { nil }
    public static var defaultDouble: Double? { nil }
    public static var defaultDic: [String: Any]? { nil }
    public static var defaultArray: [Any]? { nil }
}

public struct MODefault {
    public struct Null: MixedObjValueDefault {}
    
    public struct Init: MixedObjValueDefault {
        public static var defaultBool: Bool? { false }
        public static var defaultInt: Int? { 0 }
        public static var defaultString: String? { "" }
        public static var defaultDouble: Double? { 0 }
        public static var defaultDic: [String : Any]? { [:] }
        public static var defaultArray: [Any]? { [] }
    }
    
    public struct Empty: MixedObjValueDefault {
        public static var defaultString: String? { "" }
        public static var defaultDic: [String : Any]? { [:] }
        public static var defaultArray: [Any]? { [] }
    }
    
    public struct Zero: MixedObjValueDefault {
        public static var defaultInt: Int? { 0 }
        public static var defaultString: String? { "" }
        public static var defaultDouble: Double? { 0 }
    }
    
    public struct True: MixedObjValueDefault {
        public static var defaultBool: Bool? { true }
    }
    
    public struct False: MixedObjValueDefault {
        public static var defaultBool: Bool? { false }
    }
}

extension MixedObj where OP: MixedObjTypeOption, DF: MixedObjValueDefault {
    
    static func createDefault(type: MixedObjType) -> Self {
        switch type {
        case .bool:
            if let value = DF.defaultBool {
                return .bool(value)
            }
        case .int:
            if let value = DF.defaultInt {
                return .int(value)
            }
        case .double:
            if let value = DF.defaultDouble {
                return .double(value)
            }
        case .string:
            if let value = DF.defaultString {
                return .string(value)
            }
        case .array:
            if let value = DF.defaultArray {
                if value.isEmpty {
                    return .array([])
                } else if let data = try? JSONSerialization.data(withJSONObject: value) {
                    let decoder = JSONDecoder()
                    return (try? decoder.decode(Self.self, from: data)) ?? .null
                }
            }
        case .dic:
            if let value = DF.defaultDic {
                if value.isEmpty {
                    return .dictionary([:])
                } else if let data = try? JSONSerialization.data(withJSONObject: value) {
                    let decoder = JSONDecoder()
                    return (try? decoder.decode(Self.self, from: data)) ?? .null
                }
            }
        }
        return .null
    }
    
}

public extension KeyedDecodingContainer {
    func decode<T: MixedObjTypeOption, S: MixedObjValueDefault>(_: MixedObj<T, S>.Type, forKey key: Key) throws -> MixedObj<T, S> {
        if let value = try decodeIfPresent(MixedObj<T, S>.self, forKey: key) {
            return value
        } else {
            for type in T.types {
                let obj = MixedObj<T, S>.createDefault(type: type)
                if case .null = obj {
                    continue
                }
                return obj
            }
            return .null
        }
    }
}
