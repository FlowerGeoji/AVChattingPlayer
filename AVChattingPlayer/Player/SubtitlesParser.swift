//
//  SubtitlesParser.swift
//  AVChattingPlayer
//
//  Created by FlowerGeoji on 2018. 2. 5..
//  Copyright © 2018년 FlowerGeoji. All rights reserved.
//

import Foundation

public class SubtitlesParser {
  private(set) var savedString: String?
  private(set) var parsedPayload: [String:[[String:Any]]]?
  private var previousReadTimeInterval: TimeInterval = 0.0
  
  public init(file filePath: URL, encoding: String.Encoding = String.Encoding.utf8) {
    if let string = try? String(contentsOf: filePath, encoding: encoding) {
      self.savedString = string
      parsedPayload = parseSubtitles(string)
    }
  }
  
  public init(subtitles string: String) {
    self.savedString = string
    parsedPayload = parseSubtitles(string)
  }
}
