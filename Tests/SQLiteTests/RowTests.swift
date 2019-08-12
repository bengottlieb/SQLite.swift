import XCTest
@testable import SQLite

class RowTests : XCTestCase {

    public func test_get_value() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        let result = try! row.get(SQLExpression<String>("foo"))

        XCTAssertEqual("value", result)
    }

    public func test_get_value_subscript() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        let result = row[SQLExpression<String>("foo")]

        XCTAssertEqual("value", result)
    }

    public func test_get_value_optional() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        let result = try! row.get(SQLExpression<String?>("foo"))

        XCTAssertEqual("value", result)
    }

    public func test_get_value_optional_subscript() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        let result = row[SQLExpression<String?>("foo")]

        XCTAssertEqual("value", result)
    }

    public func test_get_value_optional_nil() {
        let row = SQLRow(["\"foo\"": 0], [nil])
        let result = try! row.get(SQLExpression<String?>("foo"))

        XCTAssertNil(result)
    }

    public func test_get_value_optional_nil_subscript() {
        let row = SQLRow(["\"foo\"": 0], [nil])
        let result = row[SQLExpression<String?>("foo")]

        XCTAssertNil(result)
    }

    public func test_get_type_mismatch_throws_unexpected_null_value() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        XCTAssertThrowsError(try row.get(SQLExpression<Int>("foo"))) { error in
            if case QueryError.unexpectedNullValue(let name) = error {
                XCTAssertEqual("\"foo\"", name)
            } else {
                XCTFail("unexpected error: \(error)")
            }
        }
    }

    public func test_get_type_mismatch_optional_returns_nil() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        let result = try! row.get(SQLExpression<Int?>("foo"))
        XCTAssertNil(result)
    }

    public func test_get_non_existent_column_throws_no_such_column() {
        let row = SQLRow(["\"foo\"": 0], ["value"])
        XCTAssertThrowsError(try row.get(SQLExpression<Int>("bar"))) { error in
            if case QueryError.noSuchColumn(let name, let columns) = error {
                XCTAssertEqual("\"bar\"", name)
                XCTAssertEqual(["\"foo\""], columns)
            } else {
                XCTFail("unexpected error: \(error)")
            }
        }
    }

    public func test_get_ambiguous_column_throws() {
        let row = SQLRow(["table1.\"foo\"": 0, "table2.\"foo\"": 1], ["value"])
        XCTAssertThrowsError(try row.get(SQLExpression<Int>("foo"))) { error in
            if case QueryError.ambiguousColumn(let name, let columns) = error {
                XCTAssertEqual("\"foo\"", name)
                XCTAssertEqual(["table1.\"foo\"", "table2.\"foo\""], columns.sorted())
            } else {
                XCTFail("unexpected error: \(error)")
            }
        }
    }
}
