//
//  ViewController.swift
//  musicPlay
//
//  Created by Chu Go-Go on 2022/3/22.
//

import UIKit
import AVFoundation
import MediaPlayer
class ViewController: UIViewController {
    @IBOutlet weak var musicNameLB: UILabel!
    @IBOutlet weak var singerLB: UILabel!
    @IBOutlet weak var playTimeSlider: UISlider!
    @IBOutlet weak var starTimeLB: UILabel!
    @IBOutlet weak var lessTimeLB: UILabel!
    @IBOutlet weak var stopMusicButton: UIButton!
    @IBOutlet weak var nextMusicButton: UIButton!
    @IBOutlet weak var backMusicButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var musicPicIV: UIImageView!
//    控制音樂
    let player = AVPlayer()
//    控制音樂的內容
    var playerItem: AVPlayerItem!
//    控制音樂Track
    var asset: AVAsset?
//  控制音樂暫停播放圖示
    var playmusicIndex = 0
//    宣告音樂struct
    var musics = music()
//    控制音樂第幾首
    var musicIndex = 0
// 控制是否重播圖示
    var repeatIndex = 0
// 控制是否重播
    var repeatBool = false
//控制是否隨機播放圖示
    var shuffleIndex = 0
    override func viewDidLoad() {
        playMusic()
        updateUI()
        nowPlayTime()
        updateMusciUI()
        musicEnd()
//        打開畫面時的圖示
        repeatButton.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal)
        shuffleButton.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
        stopMusicButton.setImage(setbuttonImage(systemName: "pause.fill", pointSize: 30), for: .normal)
        nextMusicButton.setImage(setbuttonImage(systemName: "forward.end.fill", pointSize: 30), for: .normal)
        backMusicButton.setImage(setbuttonImage(systemName: "backward.end.fill", pointSize: 30), for: .normal)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func repeatButton(_ sender: UIButton) {
        repeatIndex += 1
        if repeatIndex == 1 {
            repeatButton.setImage(setbuttonImage(systemName: "repeat.1", pointSize: 15), for: .normal)
            repeatBool = true
            updateMusciUI()
            updateUI()
            nowPlayTime()
            
        }else{
            repeatIndex = 0
            repeatButton.setImage(setbuttonImage(systemName: "repeat", pointSize: 15), for: .normal)
            repeatBool = false
        }
        
    }
    @IBAction func shuffleButton(_ sender: Any) {
        shuffleIndex += 1
        if shuffleIndex == 1{
            
            shuffleButton.setImage(setbuttonImage(systemName: "shuffle.circle.fill", pointSize: 20), for: .normal)
            print("musicIndex\(musicIndex)")
            print("allmusic.count\(allmusic.count)")
        }else{
            shuffleIndex = 0
            shuffleButton.setImage(setbuttonImage(systemName: "shuffle.circle", pointSize: 20), for: .normal)
        }
    }
//    音樂暫停播放
    @IBAction func stopButton(_ sender: UIButton) {
//        按一下+1
        playmusicIndex += 1
//        等於1音樂暫停圖示變成播放按鈕
        if playmusicIndex == 1{
            player.pause()
            stopMusicButton.setImage(setbuttonImage(systemName: "play.fill", pointSize: 30), for: .normal)
        }else{
//            如果超過1就會歸0繼續播放按鈕換成暫停鍵
            player.play()
            playmusicIndex = 0
            stopMusicButton.setImage(setbuttonImage(systemName: "pause.fill", pointSize: 30), for: .normal)
        }
        
    }
//    下一首
    @IBAction func nextSoundButton(_ sender: UIButton) {
        playNextSound()
    }
//    上一首
    @IBAction func backSoundButton(_ sender: UIButton) {
        backSound()
    }
//    調音量
    @IBAction func volumeChange(_ sender: UISlider) {
        player.volume = volumeSlider.value
    }
//    拉Slider 音樂也會跟著動
    @IBAction func timeChage(_ sender: UISlider) {
//        設定slider的value
        let changeTime = Int64(sender.value)
//        宣告一個CMTime來控制音樂到跑到哪
        let time:CMTime = CMTimeMake(value: changeTime , timescale: 1)
//        音樂會跟著slider拉到的地方播放
        player.seek(to: time)
        print("sender.value\(sender.value)")
        print("sender.maximumValue\(sender.maximumValue)")
    }
    @IBAction func MvPlayerButton(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let MyAVPlayerVC = segue.destination as! MyAVPlayerViewController
        
        MyAVPlayerVC.player = player
    }
//    更新歌曲、歌手、畫面圖片
    func updateUI(){
        musicNameLB.text = allmusic[musicIndex].musicName
        singerLB.text = allmusic[musicIndex].singer
        musicPicIV.image = UIImage(named: allmusic[musicIndex].musicPic)
        //        starTimeLB.text = String(player.currentTime().seconds)
    }
//    更新歌曲時確認歌的時間讓Slider也更新
    func updateMusciUI() {
//        宣告一個算歌曲秒數的timeduration
        guard let timeduration = playerItem?.asset.duration else {
            return
        }
//        在轉換型態成CMTimeGetSeconds
        let seconds = CMTimeGetSeconds(timeduration)
//      總秒數就會等於timeShow(time: seconds)func裡的秒數
        lessTimeLB.text = timeShow(time: seconds)
//        拉秒數的Slider最小值為0
        playTimeSlider.minimumValue = 0
//        最大值就是這首歌的總秒數
        playTimeSlider.maximumValue = Float(seconds)
//        slider會不會持續動作
        playTimeSlider.isContinuous = true
        print("second:\(seconds)")
    }
//    顯示播放幾秒func
    func timeShow(time: Double) -> String {
        //        轉換成秒數
        let time = Int(time).quotientAndRemainder(dividingBy: 60)
//        顯示分鐘與秒數
        let timeString = ("\(String(time.quotient)) : \(String(format:"%02d", time.remainder))")
//        回傳到顯示
        return timeString
    }
    //    播放幾秒的Func
    func nowPlayTime(){
//        播放的計數器從1開始每一秒都在播放
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
//          如果音樂要播放
            if self.player.currentItem?.status == .readyToPlay{
//                就會得到player播放的時間
                let currenTime = CMTimeGetSeconds(self.player.currentTime())
//                Slider移動就會等於currenTime的時間
                self.playTimeSlider.value = Float(currenTime)
//                顯示播放了幾秒
                self.starTimeLB.text = self.timeShow(time: currenTime)
            }
        })
    }
//    確認音樂結束
    func musicEnd(){
//        叫出  NotificationCenter.default.addObserver來確認音樂是否結束
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
//            如果結束有打開repeatBool 就會從頭播放
            if self.repeatBool{
                let musicEndTime: CMTime = CMTimeMake(value: 0, timescale: 1)
                self.player.seek(to: musicEndTime)
                self.player.play()
            }else{
//            如果結束沒有打開repeatBool就會撥下一首歌
                self.playNextSound()
                
            }
            
        }
    }
//    播放音樂
    func playMusic(){
//  宣告一個fileUrl來呼叫音樂的檔案
        let fileUrl = Bundle.main.url(forResource: allmusic[musicIndex].music , withExtension: "mp4")!
//        儲存播放音樂的playerItem
        playerItem = AVPlayerItem(url: fileUrl)
//        播放音樂的player
        player.replaceCurrentItem(with: playerItem)
//        播放音樂
        player.play()
    }
//    設定Button圖示大小跟圖案
    func setbuttonImage(systemName:String,pointSize: Int)-> UIImage?{
//        設定一個圖示以及他的長寬
        let sfsymbol = UIImage.SymbolConfiguration(pointSize: CGFloat(pointSize), weight: .bold,scale: .large)
//        設定圖片名字，跟他的出處
        let sfsymbolImage = UIImage(systemName: systemName, withConfiguration: sfsymbol)
//        回傳
        return sfsymbolImage
    }
//    播放下一首歌
    func playNextSound(){
//        如果隨機播放是打開的
        if shuffleIndex == 1{
//            就用亂數播歌
            musicIndex = Int.random(in: 0...allmusic.count - 1)
            updateUI()
            playMusic()
            updateMusciUI()
        }else{
//            如果不是就是照列表播歌
            musicIndex += 1
            if musicIndex < allmusic.count{
                updateUI()
                playMusic()
                updateMusciUI()
            }else{
                musicIndex = 0
                updateUI()
                playMusic()
                updateMusciUI()
            }
        }
    }
    func backSound(){
        if shuffleIndex == 1{
            musicIndex = Int.random(in: 0...allmusic.count - 1)
            updateUI()
            playMusic()
            updateMusciUI()
        }else{
            musicIndex -= 1
            if musicIndex < 0{
                musicIndex = 0
                updateUI()
                playMusic()
                updateMusciUI()
            }else{
                updateUI()
                playMusic()
                updateMusciUI()
            }
        }
    }
}

