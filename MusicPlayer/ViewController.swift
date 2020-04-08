//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Hyeonjin on 2020/04/08.
//  Copyright © 2020 Jinny. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    // MARK:- Properties
    var player: AVAudioPlayer!
    var timer: Timer!

    // MARK: IBOutlets
    // IBOutlets를 명시하지 않을 경우, 인터페이스 빌더의 ViewController에 나오지 않음
    // Insatnce와 connection이 다 되었을때 왼쪽 동그라미가 다 채워짐
   @IBOutlet var playPauseButton: UIButton!
   @IBOutlet var timeLabel: UILabel!
   @IBOutlet var progressSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.initalizePlayer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: IBAction
    @IBAction func touchUpPlayStopButton(_ sender: UIButton) {
        print("button tapped")
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            self.player?.play()
        }else{
            self.player?.stop()
        }
        
        if sender.isSelected{
            self.makeAndFireTimer()
        }else{
            self.invalidTimer()
        }
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("slider value changed")
        
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
        
    }

    
    // MARK: AVAudioPlayerDelegate
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        guard let error: Error = error else{
            print("오디오 플레이어 디코드 오류 발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"

        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
    
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
            (action: UIAlertAction) -> Void in
            
            self.dismiss(animated: true, completion:  nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidTimer()
    }
    
    
    // MARK:- Methods
    // MARK: Custom Methods
    
    func initalizePlayer(){
        
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else{
            
            print("음원 파일 에셋을 가져올 수 없습니다")
            return
        }
        
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
                self.player.delegate = self
        } catch let error as NSError {
                print("플레이어 초기화 실패")
                print("에러 코드: \(error.code), 에러 메시지: \(error.localizedDescription)")
        }
        
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
        
        
        }
    
    func updateTimeLabelText(time: TimeInterval){
        let minute: Int = Int(time/60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 1000)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        self.timeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
           self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
             
               if self.progressSlider.isTracking { return }
               
               self.updateTimeLabelText(time: self.player.currentTime)
               self.progressSlider.value = Float(self.player.currentTime)
           })
           self.timer.fire()
       }
    
    func invalidTimer(){
        self.timer.invalidate()
        self.timer = nil
    }
  
        
    
}

