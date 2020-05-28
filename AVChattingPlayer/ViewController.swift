//
//  ViewController.swift
//  AVChattingPlayer
//
//  Created by FlowerGeoji on 2018. 2. 5..
//  Copyright © 2018년 FlowerGeoji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var chattingPlayerView: AVChattingPlayerView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    guard let videoUrl = URL.init(string: "https://view.pufflive.me/live/ec58-2018-01-03/1514966117_M4w28A.mp4") else {
      return
    }
    guard let subtitleUrl = URL.init(string: "https://asset.pufflive.me/subtitles/11313/1514970441/subtitles_ec58-2018-01-03/1514966117_M4w28A.vtt") else {
      return
    }
    
    self.chattingPlayerView.replaceVideo(videoUrl: videoUrl, subtitleUrl: subtitleUrl)
    self.chattingPlayerView.play()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

