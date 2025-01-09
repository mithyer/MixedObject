//
//  MixedObj.swift
//
//
//  Created by Ray
//

import Foundation

extension MixedObj: Encodable where OP: MixedObjTypeOption {
    
    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .array(let array):
            var container = encoder.unkeyedContainer()
            try encode(withUnkeyed: &container, array: array)
        case .dictionary(let dictionary):
            var container = encoder.container(keyedBy: MixedCodingKeys.self)
            try encode(withKeyed: &container, dic: dictionary)
        default:
            var container = encoder.singleValueContainer()
            if case .null = self {
                try container.encodeNil()
            } else if case let .bool(bool) = self {
                try container.encode(bool)
            } else if case let .double(double) = self {
                try container.encode(double)
            } else if case let .int(int) = self {
                try container.encode(int)
            } else if case let .string(string) = self {
                try container.encode(string)
            } else {
                throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "encode single error"))
            }
        }
    }
    
    private func encode<T: MixedObjTypeOption>(withKeyed container: inout KeyedEncodingContainer<MixedCodingKeys>, dic: [String: MixedObj<T>]) throws {
        for (key, value) in dic {
            let encodingKey = KeyedEncodingContainer<MixedCodingKeys>.Key(stringValue: key)!
            switch value {
            case .null:
                try container.encodeNil(forKey: encodingKey)
            case .bool(let bool):
                try container.encode(bool, forKey: encodingKey)
            case .double(let double):
                try container.encode(double, forKey: encodingKey)
            case .string(let string):
                try container.encode(string, forKey: encodingKey)
            case .int(let int):
                try container.encode(int, forKey: encodingKey)
            case .array(let array):
                var container = container.nestedUnkeyedContainer(forKey: encodingKey)
                try encode(withUnkeyed: &container, array: array)
            case .dictionary(let dictionary):
                var encoder = container.nestedContainer(keyedBy: MixedCodingKeys.self, forKey: encodingKey)
                try encode(withKeyed: &encoder, dic: dictionary)
            }
        }
    }
    
    private func encode<T: MixedObjTypeOption>(withUnkeyed container: inout UnkeyedEncodingContainer, array: [MixedObj<T>]) throws {
        for value in array {
            switch value {
            case .null:
                try container.encodeNil()
            case .bool(let bool):
                try container.encode(bool)
            case .double(let double):
                try container.encode(double)
            case .string(let string):
                try container.encode(string)
            case .int(let int):
                try container.encode(int)
            case .array(let array):
                var container = container.nestedUnkeyedContainer()
                try encode(withUnkeyed: &container, array: array)
            case .dictionary(let dictionary):
                var encoder = container.nestedContainer(keyedBy: MixedCodingKeys.self)
                try encode(withKeyed: &encoder, dic: dictionary)
            }
        }
    }
}
