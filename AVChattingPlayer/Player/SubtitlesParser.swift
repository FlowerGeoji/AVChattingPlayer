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
  
  private func parseSubtitles(_ subtitles: String) -> [String:[[String:Any]]]? {
    
    do {
      
      // Prepare payload
      var subtitles = subtitles.replacingOccurrences(of: "\n\r\n", with: "\n\n")
      subtitles = subtitles.replacingOccurrences(of: "\n\n\n", with: "\n\n")
      subtitles = subtitles.replacingOccurrences(of: "\r\n", with: "\n")
      
      // Parsed dict
      var parsed :[String:[[String:Any]]] = [:]
      
      // Get regex groups
      //      (\\d+:\\d+:\\d+.\\d+)\\s*-->\\s*(\\d+:\\d+:\\d+.\\d+)\\s*(\\{.*?\\})c
      let regexStr = "(\\d+:\\d+:\\d+.\\d+)\\s*-->\\s*(\\d+:\\d+:\\d+.\\d+)\\s*(\\{.*?\\})"
      let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
      let matches = regex.matches(in: subtitles, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, subtitles.count))
      for match in matches {
        var chatDictionary:[String:Any] = [:]
        let lastRangeIndex = match.numberOfRanges - 1
        if lastRangeIndex == 3 {
          // 1 : start time
          var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0
          let stringStart = (subtitles as NSString).substring(with: match.range(at: 1))
          let scannerStart = Scanner(string: stringStart)
          scannerStart.scanDouble(&h)
          scannerStart.scanString(":", into: nil)
          scannerStart.scanDouble(&m)
          
          scannerStart.scanString(":", into: nil)
          scannerStart.scanDouble(&s)
          let start = (h * 3600.0) + (m * 60.0) + s
          chatDictionary["start"] = start
          
          // 2 : end time
          h = 0.0; m = 0.0; s = 0.0
          let stringEnd = (subtitles as NSString).substring(with: match.range(at: 2))
          let scannerEnd = Scanner(string: stringEnd)
          scannerEnd.scanDouble(&h)
          scannerEnd.scanString(":", into: nil)
          scannerEnd.scanDouble(&m)
          scannerEnd.scanString(":", into: nil)
          scannerEnd.scanDouble(&s)
          let end = (h * 3600.0) + (m * 60.0) + s
          chatDictionary["end"] = end
          
          // 3 : chat json
          chatDictionary["chat"] = (subtitles as NSString).substring(with: match.range(at: 3))
          
          let startSecond = Int(start)
          if parsed[startSecond.description] == nil {
            parsed[startSecond.description] = []
          }
          parsed[startSecond.description]?.append(chatDictionary)
        }
      }
      
      return parsed
      
    } catch {
      
      return nil
      
    }
  }
  
  public func searchSubtitles(at time: TimeInterval) -> [String] {
    guard let parsedPayload = self.parsedPayload else {
      return []
    }
    
    var messages: [String] = []
    
    let intTime = Int(time)
    for i in 0..<intTime {
      guard let secondParsedSubtitles = parsedPayload[i.description], secondParsedSubtitles.count > 0 else {
        continue
      }

      secondParsedSubtitles.forEach({ (subtitleDictionary) in
        if let message = subtitleDictionary["chat"] as? String {
          messages.append(message)
        }
      })
    }

    guard let secondParsedSubtitles = parsedPayload[intTime.description], secondParsedSubtitles.count > 0 else {
      return messages
    }
    let filteredSubtitles = secondParsedSubtitles.filter { (subtitleDictionary) -> Bool in
      guard let startTiem = subtitleDictionary["start"] as? TimeInterval else {
        return false
      }

      return startTiem <= time
    }


    filteredSubtitles.forEach { (subtitle) in
      guard let message = subtitle["chat"] as? String else {
        return
      }
      messages.append(message)
    }
    
    return messages
  }
  
  public func readNextSubtitles(to time: TimeInterval) -> [String] {
    guard let parsedPayload = self.parsedPayload, time > self.previousReadTimeInterval else {
      self.previousReadTimeInterval = time
      return []
    }
    
    let previousSecond = Int(self.previousReadTimeInterval)
    let second = Int(time)
    
    var messages: [String] = []
    
    for s in previousSecond...second {
      guard let secondParsedSubtitles = parsedPayload[s.description] else {
        continue
      }
      
      secondParsedSubtitles.forEach({ (subtitle) in
        guard let startTime = subtitle["start"] as? TimeInterval, let message = subtitle["chat"] as? String else {
          return
        }
        
        if startTime > self.previousReadTimeInterval, startTime <= time {
          messages.append(message)
        }
      })
    }
    
    self.previousReadTimeInterval = time
    return messages
  }
}
