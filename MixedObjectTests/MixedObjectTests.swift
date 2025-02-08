//
//  MixedObjTests.swift
//  MixedObjTests
//
//  Created by Ray on 1/9/25.
//

import XCTest
import Foundation
@testable import MixedObject

final class MixedObjTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func randomSingle() -> Any {
        switch Int.random(in: 0...3) {
        case 0:
            return Int.random(in: Int.min...Int.max)
        case 1:
            return Bool.random()
        case 2:
            return Double.random(in: Double.leastNormalMagnitude...Double.greatestFiniteMagnitude)
        case 3:
            return "s_\(Int.random(in: Int.min...Int.max))"
        default:
            XCTAssert(false)
            return 0
        }
    }
    
    func randomDic() -> [String: Any] {
        var dic = [String: Any]()
        for i in 0..<Int.random(in: 0...2) {
            switch Int.random(in: 0...2) {
            case 0:
                dic["key\(i)"] = randomSingle()
            case 1:
                dic["key\(i)"] = randomDic()
            case 2:
                dic["key\(i)"] = randomArray()
            default:
                XCTAssert(false)
            }
        }
        return dic
    }
    
    func randomArray() -> [Any] {
        var arr = [Any]()
        for _ in 0..<Int.random(in: 0...3) {
            switch Int.random(in: 0...2) {
            case 0:
                arr.append(randomSingle())
            case 1:
                arr.append(randomDic())
            case 2:
                arr.append(randomArray())
            default:
                XCTAssert(false)
            }
        }
        return arr
    }
    
    func compareFailed<T: Equatable>(_ l: Any, _ r: Any, _ type: T.Type) -> Bool {
        if l is T {
            if !(r is T) {
                return true
            }
            if l as! T != r as! T {
                return true
            }
        }
        return false
    }
    
    func compareArray(array1: [Any], array2: [Any]) -> Bool {
        if array1.count != array2.count {
            return false
        }
        for (index, value1) in array1.enumerated() {
            let value2 = array2[index]
            if compareFailed(value1, value2, Int.self) ||
                compareFailed(value1, value2, String.self) ||
                compareFailed(value1, value2, Double.self) ||
                compareFailed(value1, value2, Bool.self)
            {
                return false
            }
            if value1 is [String: Any] {
                if !(value2 is [String: Any]) {
                    return false
                }
                if !compareDic(dic1: value1 as! [String: Any], dic2: value2 as! [String: Any]) {
                    return false
                }
            }
            if value1 is [Any] {
                if !(value2 is [Any]) {
                    return false
                }
                if !compareArray(array1: value1 as! [Any], array2: value2 as! [Any]) {
                    return false
                }
            }
        }
        return true
    }

    
    func compareDic(dic1: [String: Any], dic2: [String: Any]) -> Bool {
        if dic1.count != dic2.count {
            return false
        }
        for (key, value1) in dic1 {
            guard let value2 = dic2[key] else {
                return false
            }
            if compareFailed(value1, value2, Int.self) ||
                compareFailed(value1, value2, String.self) ||
                compareFailed(value1, value2, Double.self) ||
                compareFailed(value1, value2, Bool.self)
            {
                return false
            }
            if value1 is [String: Any] {
                if !(value2 is [String: Any]) {
                    return false
                }
                if !compareDic(dic1: value1 as! [String: Any], dic2: value2 as! [String: Any]) {
                    return false
                }
            }
            if value1 is [Any] {
                if !(value2 is [Any]) {
                    return false
                }
                if !compareArray(array1: value1 as! [Any], array2: value2 as! [Any]) {
                    return false
                }
            }
        }
        return true
    }
    
    func _testCollection<T: MixedObjTypeOption>(_ type: T.Type, idx: Int) {
        let testObj: Any = idx%2 == 0 ? randomArray() : randomDic()

        guard let data = try? JSONSerialization.data(withJSONObject: testObj) else {
            XCTAssert(false)
            return
        }
        
        let decoder = JSONDecoder()
        
        guard let model = try? decoder.decode(MixedObj<T, MODefault.Null>.self, from:data) else {
            XCTAssert(false)
            return
        }
        
        if !T.types.contains(.array) && !T.types.contains(.dic) {
            XCTAssert(model.isNull())
            return
        }
        
        let jsonString = model.jsonString()
        print("======>")
        print(jsonString)
        print("<======")
        

        if testObj is [Any] {
            if !T.types.contains(.array) {
                XCTAssert(model.isNull())
                return
            }
            let testObjShadow = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as! [Any]
            XCTAssert(compareArray(array1: testObj as! [Any], array2: testObjShadow))
        } else if testObj is [String: Any] {
            if !T.types.contains(.dic) {
                XCTAssert(model.isNull())
                return
            }
            let testObjShadow = try! JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as! [String: Any]
            XCTAssert(compareDic(dic1: testObj as! [String: Any], dic2: testObjShadow))
        }
    }
    
    func _testSingle<T: MixedObjTypeOption>(_ type: T.Type) {
        let testObj: Any = randomSingle()
        let decoder = JSONDecoder()
        let testObjJsonString = testObj is String ? "\"\(testObj as! String)\"" : "\(testObj)"
        guard let model = try? decoder.decode(MixedObj<T, MODefault.Null>.self, from: testObjJsonString.data(using: .utf8)!) else {
            XCTAssert(false)
            return
        }
        if testObj is Bool, !T.types.contains(.bool) {
            XCTAssert(model.isNull())
            return
        }
        if testObj is Double, !T.types.contains(.double) {
            XCTAssert(model.isNull())
            return
        }
        if testObj is Int, !T.types.contains(.int) {
            XCTAssert(model.isNull())
            return
        }
        if testObj is String, !T.types.contains(.string) {
            XCTAssert(model.isNull())
            return
        }
        
        let modelJsonString = model.jsonString()
        print("======>")
        print(modelJsonString)
        print("<======")
        
        XCTAssertEqual(modelJsonString, testObjJsonString)
    }

    func testDecodeRandomly() throws {
        
        var typeOptions: [MixedObjTypeOption.Type] = [MOOption.AnyObj.self,
                                                      MOOption.NumberOrString.self,
                                                      MOOption.Number.self,
                                                      MOOption.Array.self,
                                                      MOOption.Dic.self,
                                                      MOOption.ArrayOrDic.self,
                                                      MOOption.Date.self]

        typeOptions = [MOOption.ArrayOrDic.self]
        for i in 0..<100 {
            _testCollection(typeOptions.randomElement()!, idx: i)
            _testSingle(typeOptions.randomElement()!)
        }
    }
    
    struct MyDefaultArray: MixedObjValueDefault {
        public static let defaultValue: Any? = [1, 2, 3]
    }
    
    struct Wrapper: Decodable {
        var obj: MixedObj<MOOption.Array, MyDefaultArray>
    }
    
    func testDefaultObj() throws {
        
        let decoder = JSONDecoder()
        let res = try? decoder.decode(Wrapper.self, from: "{}".data(using: .utf8)!)

        XCTAssert(nil != res)
        XCTAssertEqual(res!.obj.convertToCommonArray()!.compactMap({ $0 as? Int }), [1, 2, 3])
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
