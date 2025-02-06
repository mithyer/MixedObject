//
//  MixedObj+Option.swift
//  MixedObject
//
//  Created by ray on 2025/2/6.
//

import Foundation

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
