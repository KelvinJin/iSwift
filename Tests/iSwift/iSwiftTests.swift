import XCTest
@testable import iSwift

class iSwiftTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(iSwift().text, "Hello, World!")
    }


    static var allTests : [(String, (iSwiftTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
