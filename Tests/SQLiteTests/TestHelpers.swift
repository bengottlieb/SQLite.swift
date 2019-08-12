import XCTest
@testable import SQLite

class SQLiteTestCase : XCTestCase {
    private var trace:[String: Int]!
    var db:SQLConnection!
    let users = SQLTable("users")

    override func setUp() {
        super.setUp()
        db = try! SQLConnection()
        trace = [String:Int]()

        db.trace { SQL in
            print(SQL)
            self.trace[SQL, default: 0] += 1
        }
    }

    func CreateUsersTable() {
        try! db.execute("""
            CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                email TEXT NOT NULL UNIQUE,
                age INTEGER,
                salary REAL,
                admin BOOLEAN NOT NULL DEFAULT 0 CHECK (admin IN (0, 1)),
                manager_id INTEGER,
                FOREIGN KEY(manager_id) REFERENCES users(id)
            )
            """
        )
    }

    func InsertUsers(_ names: String...) throws {
        try InsertUsers(names)
    }

    func InsertUsers(_ names: [String]) throws {
        for name in names { try InsertUser(name) }
    }

    @discardableResult func InsertUser(_ name: String, age: Int? = nil, admin: Bool = false) throws -> SQLStatement {
        return try db.run(
            "INSERT INTO \"users\" (email, age, admin) values (?, ?, ?)",
            "\(name)@example.com", age?.datatypeValue, admin.datatypeValue
        )
    }

    func AssertSQL(_ SQL: String, _ executions: Int = 1, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(
            executions, trace[SQL] ?? 0,
            message ?? SQL,
            file: file, line: line
        )
    }

    func AssertSQL(_ SQL: String, _ statement: SQLStatement, _ message: String? = nil, file: StaticString = #file, line: UInt = #line) {
        try! statement.run()
        AssertSQL(SQL, 1, message, file: file, line: line)
        if let count = trace[SQL] { trace[SQL] = count - 1 }
    }

//    func AssertSQL(SQL: String, _ query: Query, _ message: String? = nil, file: String = __FILE__, line: UInt = __LINE__) {
//        for _ in query {}
//        AssertSQL(SQL, 1, message, file: file, line: line)
//        if let count = trace[SQL] { trace[SQL] = count - 1 }
//    }

    func async(expect description: String = "async", timeout: Double = 5, block: (@escaping () -> Void) -> Void) {
        let expectation = self.expectation(description: description)
        block({ expectation.fulfill() })
        waitForExpectations(timeout: timeout, handler: nil)
    }

}

let bool = SQLExpression<Bool>("bool")
let boolOptional = SQLExpression<Bool?>("boolOptional")

let data = SQLExpression<SQLBlob>("blob")
let dataOptional = SQLExpression<SQLBlob?>("blobOptional")

let date = SQLExpression<Date>("date")
let dateOptional = SQLExpression<Date?>("dateOptional")

let double = SQLExpression<Double>("double")
let doubleOptional = SQLExpression<Double?>("doubleOptional")

let int = SQLExpression<Int>("int")
let intOptional = SQLExpression<Int?>("intOptional")

let int64 = SQLExpression<Int64>("int64")
let int64Optional = SQLExpression<Int64?>("int64Optional")

let string = SQLExpression<String>("string")
let stringOptional = SQLExpression<String?>("stringOptional")

func AssertSQL(_ expression1: @autoclosure () -> String, _ expression2: @autoclosure () -> Expressible, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expression1(), expression2().asSQL(), file: file, line: line)
}

let table = SQLTable("table")
let qualifiedTable = SQLTable("table", database: "main")
let virtualTable = SQLVirtualTable("virtual_table")
let _view = SQLView("view") // avoid Mac XCTestCase collision

class TestCodable: Codable {
    let int: Int
    let string: String
    let bool: Bool
    let float: Float
    let double: Double
    let optional: String?
    let sub: TestCodable?

    init(int: Int, string: String, bool: Bool, float: Float, double: Double, optional: String?, sub: TestCodable?) {
        self.int = int
        self.string = string
        self.bool = bool
        self.float = float
        self.double = double
        self.optional = optional
        self.sub = sub
    }
}
