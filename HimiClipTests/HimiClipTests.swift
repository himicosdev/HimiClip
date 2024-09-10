//
//  HimiClipTests.swift
//  HimiClipTests
//
//  Created by himicoswilson on 9/5/24.
//

import Testing
@testable import HimiClip

struct HimiClipTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func testRequestManager() async throws {
        let requestManager = RequestManager()
        let expectation = XCTestExpectation(description: "API call")
        
        let url = URL(string: "http://localhost:8080/api/clips")!
        requestManager.performRequest(url: url, method: "GET", onSuccess: { data in
            XCTAssertNotNil(data)
            expectation.fulfill()
        }, onFailure: {
            XCTFail("API call failed")
        })
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @Test func testDateFormatter() {
        let dateString = "2024-09-07T12:34:56"
        let formattedDate = DateUtility.formattedDate(dateString)
        XCTAssertEqual(formattedDate, "2024.09.07 12:34")
    }

    @Test func testClipEntryModel() {
        let clip = ClipEntry(id: 1, content: "Test content", contentType: "text", createdAt: "2024-09-07T12:34:56", updatedAt: nil)
        XCTAssertEqual(clip.id, 1)
        XCTAssertEqual(clip.content, "Test content")
        XCTAssertEqual(clip.contentType, "text")
        XCTAssertEqual(clip.createdAt, "2024-09-07T12:34:56")
        XCTAssertNil(clip.updatedAt)
    }

}
