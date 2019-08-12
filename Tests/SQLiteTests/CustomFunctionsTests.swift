import XCTest
import SQLite

class CustomFunctionNoArgsTests : SQLiteTestCase {
    typealias FunctionNoOptional              = ()  -> SQLExpression<String>
    typealias FunctionResultOptional          = ()  -> SQLExpression<String?>

    func testFunctionNoOptional() {
        let _: FunctionNoOptional = try! db.createFunction("test", deterministic: true) {
            return "a"
        }
        let result = try! db.prepare("SELECT test()").scalar() as! String
        XCTAssertEqual("a", result)
    }

    func testFunctionResultOptional() {
        let _: FunctionResultOptional = try! db.createFunction("test", deterministic: true) {
            return "a"
        }
        let result = try! db.prepare("SELECT test()").scalar() as! String?
        XCTAssertEqual("a", result)
    }
}

class CustomFunctionWithOneArgTests : SQLiteTestCase {
    typealias FunctionNoOptional              = (SQLExpression<String>)  -> SQLExpression<String>
    typealias FunctionLeftOptional            = (SQLExpression<String?>) -> SQLExpression<String>
    typealias FunctionResultOptional          = (SQLExpression<String>)  -> SQLExpression<String?>
    typealias FunctionLeftResultOptional      = (SQLExpression<String?>) -> SQLExpression<String?>

    func testFunctionNoOptional() {
        let _: FunctionNoOptional = try! db.createFunction("test", deterministic: true) { a in
            return "b"+a
        }
        let result = try! db.prepare("SELECT test(?)").scalar("a") as! String
        XCTAssertEqual("ba", result)
    }

    func testFunctionLeftOptional() {
        let _: FunctionLeftOptional = try! db.createFunction("test", deterministic: true) { a in
            return "b"+a!
        }
        let result = try! db.prepare("SELECT test(?)").scalar("a") as! String
        XCTAssertEqual("ba", result)
    }

    func testFunctionResultOptional() {
        let _: FunctionResultOptional = try! db.createFunction("test", deterministic: true) { a in
            return "b"+a
        }
        let result = try! db.prepare("SELECT test(?)").scalar("a") as! String
        XCTAssertEqual("ba", result)
    }

    func testFunctionLeftResultOptional() {
        let _: FunctionLeftResultOptional = try! db.createFunction("test", deterministic: true) { (a:String?) -> String? in
            return "b"+a!
        }
        let result = try! db.prepare("SELECT test(?)").scalar("a") as! String
        XCTAssertEqual("ba", result)
    }
}

class CustomFunctionWithTwoArgsTests : SQLiteTestCase {
    typealias FunctionNoOptional              = (SQLExpression<String>,  SQLExpression<String>)  -> SQLExpression<String>
    typealias FunctionLeftOptional            = (SQLExpression<String?>, SQLExpression<String>)  -> SQLExpression<String>
    typealias FunctionRightOptional           = (SQLExpression<String>,  SQLExpression<String?>) -> SQLExpression<String>
    typealias FunctionResultOptional          = (SQLExpression<String>,  SQLExpression<String>)  -> SQLExpression<String?>
    typealias FunctionLeftRightOptional       = (SQLExpression<String?>, SQLExpression<String?>) -> SQLExpression<String>
    typealias FunctionLeftResultOptional      = (SQLExpression<String?>, SQLExpression<String>)  -> SQLExpression<String?>
    typealias FunctionRightResultOptional     = (SQLExpression<String>,  SQLExpression<String?>) -> SQLExpression<String?>
    typealias FunctionLeftRightResultOptional = (SQLExpression<String?>, SQLExpression<String?>) -> SQLExpression<String?>

    func testNoOptional() {
        let _: FunctionNoOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a+b
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String
        XCTAssertEqual("ab", result)
    }

    func testLeftOptional() {
        let _: FunctionLeftOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a!+b
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String
        XCTAssertEqual("ab", result)
    }

    func testRightOptional() {
        let _: FunctionRightOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a+b!
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String
        XCTAssertEqual("ab", result)
    }

    func testResultOptional() {
        let _: FunctionResultOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a+b
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String?
        XCTAssertEqual("ab", result)
    }

    func testFunctionLeftRightOptional() {
        let _: FunctionLeftRightOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a!+b!
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String
        XCTAssertEqual("ab", result)
    }

    func testFunctionLeftResultOptional() {
        let _: FunctionLeftResultOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a!+b
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String?
        XCTAssertEqual("ab", result)
    }

    func testFunctionRightResultOptional() {
        let _: FunctionRightResultOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a+b!
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String?
        XCTAssertEqual("ab", result)
    }

    func testFunctionLeftRightResultOptional() {
        let _: FunctionLeftRightResultOptional = try! db.createFunction("test", deterministic: true) { a, b in
            return a!+b!
        }
        let result = try! db.prepare("SELECT test(?, ?)").scalar("a", "b") as! String?
        XCTAssertEqual("ab", result)
    }
}
