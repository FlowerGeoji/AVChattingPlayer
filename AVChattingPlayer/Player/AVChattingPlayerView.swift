//
//  AVChattingPlayerView.swift
//  AVChattingPlayer
//
//  Created by FlowerGeoji on 2018. 2. 5..
//  Copyright © 2018년 FlowerGeoji. All rights reserved.
//

import UIKit
import AVKit

class AVChattingPlayerView: UIView {
  private let playerLayer: AVPlayerLayer = AVPlayerLayer()
  private let player: AVPlayer = AVPlayer.init()
  private var subtitlesParser: SubtitlesParser?
  private let tableViewChats: UITableView = UITableView()
  
  private var timerObserver: Any?
  private let queue: DispatchQueue = DispatchQueue.init(label: "AVCPV_QUEUE")
  public var chatsIntervalSeconds: Double = 1.0
  
  private let keyOfCellChat = "CellChatIdentifier"
  private var chats: [String] = [] { didSet { self.tableViewChats.reloadData() } }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.commonInit()
  }
  
  private func commonInit() {
    self.backgroundColor = .black
    
    // Set AVPlayer
    playerLayer.player = self.player
    self.layer.insertSublayer(self.playerLayer, at: 0)
    playerLayer.frame = self.bounds
    
    // Set Chat's tableView
    self.addSubview(tableViewChats)
    tableViewChats.translatesAutoresizingMaskIntoConstraints = false
    tableViewChats.separatorStyle = .none
    tableViewChats.backgroundColor = .clear
    tableViewChats.delegate = self
    tableViewChats.dataSource = self
    tableViewChats.register(CellChat.self, forCellReuseIdentifier: keyOfCellChat)
    tableViewChats.heightAnchor.constraint(equalToConstant: 200).isActive = true
    tableViewChats.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    tableViewChats.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    tableViewChats.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
  }
  
  public func replaceVideo(videoUrl: URL, subtitleUrl: URL? = nil) {
    // reset resource
    let video: AVPlayerItem = AVPlayerItem(url: videoUrl)
    self.subtitlesParser = nil
    if let timerObserver = self.timerObserver {
      self.player.removeTimeObserver(timerObserver)
      self.timerObserver = nil
    }
    self.chats = []
    
    // replace video source
    self.player.replaceCurrentItem(with: video)
    
    // replace subtitles
    if let subtitleUrl = subtitleUrl {
      self.subtitlesParser = SubtitlesParser(file: subtitleUrl, encoding: .utf8)
      
      let interval = CMTime(seconds: self.chatsIntervalSeconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
      self.timerObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue: queue, using: { [weak self] (time) in
        guard let strongSelf = self else {
          return
        }
        strongSelf.handleSubtitle(seconds: time.seconds)
      })
    }
  }
  
  private func handleSubtitle(seconds: TimeInterval) {
    guard let subtitlesParser = self.subtitlesParser else {
      return
    }
    
    let subtitles = subtitlesParser.readNextSubtitles(to: seconds)
    
    DispatchQueue.main.sync {
      // Code for UI
      if subtitles.count > 0 {
        self.chats.append(contentsOf: subtitles)
      }
    }
  }
  
  public func play() {
    self.player.play()
  }
  
  public func pause() {
    self.player.pause()
  }
  
  class CellChat: UITableViewCell {
    private let test: UILabel = UILabel()
    var chat: String? {
      didSet {
        self.didSetChat()
      }
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      self.commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      self.commonInit()
    }
    
    private func commonInit() {
      self.contentView.addSubview(self.test)
      self.test.translatesAutoresizingMaskIntoConstraints = false
      self.test.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
      self.test.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
      self.test.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
      self.test.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    private func didSetChat() {
      guard let chat = self.chat else {
        return
      }
      
      self.test.text = chat
    }
  }
}

extension AVChattingPlayerView: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.chats.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: keyOfCellChat) as? CellChat else {
      return UITableViewCell()
    }
    
    cell.chat = self.chats[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 30
  }
}
