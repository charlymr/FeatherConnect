import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EntityTesting.allTests),
        testCase(BlogPostConnectionTests.allTests),
    ]
}
#endif
