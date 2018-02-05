//
//  AVChattingPlayerTests.swift
//  AVChattingPlayerTests
//
//  Created by FlowerGeoji on 2018. 2. 5..
//  Copyright © 2018년 FlowerGeoji. All rights reserved.
//

import XCTest
@testable import AVChattingPlayer

class AVChattingPlayerTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }


  func testInitialize() {
    // Test Initialization of AVPlayer & SubtitlesParser
    
    // 1. Initialize SubtitlesParser
    let filePathString = "https://asset.pufflive.me/subtitles/11313/1514970441/subtitles_ec58-2018-01-03/1514966117_M4w28A.vtt"
    guard let fileUrl: URL = URL.init(string: filePathString) else {
      return
    }
    
    let parser1: SubtitlesParser = SubtitlesParser(file: fileUrl)
    let parser2: SubtitlesParser = SubtitlesParser(file: fileUrl, encoding: .utf8)
    
    XCTAssertNotNil(parser1.savedString, "SubtitlesParser should be can read VTT file")
    XCTAssertGreaterThan((parser1.savedString?.count)!, 0, "Count of string from the vtt-file should be greated than 0")
    XCTAssertGreaterThan((parser1.parsedPayload?.count)!, 0, "Count of subtitles should be greated than 0")
    
    XCTAssertNotNil(parser2.savedString, "SubtitlesParser should be can read VTT file")
    XCTAssertGreaterThan((parser2.savedString?.count)!, 0, "Count of string from the vtt-file should be greated than 0")
    XCTAssertGreaterThan((parser2.parsedPayload?.count)!, 0, "Count of subtitles should be greated than 0")
  }

  func testPerformanceExample() {
  // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
