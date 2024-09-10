//
//  HimiClipUITests.swift
//  HimiClipUITests
//
//  Created by himicoswilson on 9/5/24.
//

import XCTest

final class HimiClipUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    @MainActor
    func testClipEditorView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 测试编辑器视图是否存在
        XCTAssertTrue(app.textViews["clipEditorTextView"].exists)
        
        // 测试保存按钮是否存在
        XCTAssertTrue(app.buttons["saveButton"].exists)
        
        // 测试复制和粘贴按钮是否存在
        XCTAssertTrue(app.buttons["copyButton"].exists)
        XCTAssertTrue(app.buttons["pasteButton"].exists)
    }

    @MainActor
    func testClipHistoryView() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 切换到历史记录视图
        app.tabBars.buttons["History"].tap()
        
        // 测试历史记录列表是否存在
        XCTAssertTrue(app.tables["clipHistoryTable"].exists)
        
        // 测试搜索栏是否存在
        XCTAssertTrue(app.searchFields["Search Clip"].exists)
    }
}
