//
//  ViewController.swift
//  War
//
//  Created by David Cho on 11/17/20.
//  Copyright © 2020 David Cho. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import SocketIO
/*
 
Picture of Cards:
https://www.freepik.com/free-photos-vectors/scratch
 
*/

class ViewController: UIViewController {
    
    @IBOutlet weak var leftCardImageView: UIImageView!
    
    @IBOutlet weak var rightCardImageView: UIImageView!
    
    @IBOutlet weak var cpuScoreLabel: UILabel!
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    @IBOutlet weak var countdownTimer: UILabel!
    
    @IBOutlet weak var mainWarLabel: UILabel!
    
    @IBOutlet weak var dealButton: UIButton!
        
    var playerCardNumber = 0
    var opponentCardNumber = 0
    
    var playerScore = 0
    var opponentScore = 0
    
    var musicPlayer = AVAudioPlayer()
    var soundEffectPlayer = AVAudioPlayer()
    
    var arrayOfScores = [Int]()
    
    struct scores {
        static var newPlayerScore = ""
        static var newOpponentScore = ""
    }
    
    struct cardNums {
        static var newPlayerCard = ""
        static var newOpponentCard = ""
    }
    
    @IBAction func dealButtonPressed(_ sender: Any) {
        chooseNewCards()
        updateImageViews()
        updateScores()
        updateScoreLabels()
        animateDealButton()
        animateImageViews()
        emitScoresAndDisableButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SocketIOManager.sharedInstance.establishConnection()
        playASound(fileName:"AllTheWayUp", type:"mp3", isMusic:true)
        originalCountdownTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateOpponentScore(notification:)), name: NSNotification.Name(rawValue: "UpdateAccepted"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCardNum(notification:)), name: NSNotification.Name(rawValue: "UpdateCard"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UpdateAccepted"), object: nil)
    }

    func emitScoresAndDisableButton(){
        self.dealButton.isEnabled = false
        self.dealButton.alpha = 0.5
        SocketIOManager.sharedInstance.emitCardNums(cards: [playerCardNumber, opponentCardNumber])
        SocketIOManager.sharedInstance.emit(scores:[playerScore, opponentScore])
    }
    
    @objc func updateCardNum(notification: Notification) {
        print(String(cardNums.newOpponentCard) + "!")
        print(String(cardNums.newPlayerCard) + "!")
        let newPlayerCardFileName = "Card\(cardNums.newOpponentCard)"
        let newComputerCardFileName = "Card\(cardNums.newPlayerCard)"
        leftCardImageView.image = UIImage(named: newComputerCardFileName)
        rightCardImageView.image = UIImage(named: newPlayerCardFileName)
        playerCardNumber = Int(cardNums.newOpponentCard) ?? 0
        opponentCardNumber = Int(cardNums.newPlayerCard) ?? 0
        whichCardToShake()
    }
    
    @objc func updateOpponentScore(notification: Notification) {
        print(scores.newOpponentScore)
        print(scores.newPlayerScore)
        self.playerScoreLabel.text = scores.newOpponentScore
        self.cpuScoreLabel.text = scores.newPlayerScore
        self.dealButton.alpha = 1.0
        playerScore = Int(scores.newOpponentScore) ?? 0
        opponentScore = Int(scores.newPlayerScore) ?? 0
        self.dealButton.isEnabled = true

    }
    
    func playASound(fileName:String, type:String="mp3", isMusic:Bool=false) {
        let soundFile = URL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: type)!)
        
        do {
            if isMusic {
                musicPlayer = try AVAudioPlayer(contentsOf: soundFile)
                musicPlayer.play()
            } else {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: soundFile)
                soundEffectPlayer.play()
            }
        } catch {
            // couldn't load the file :(
        }
    }
    
    func animateImageViews() {
        if playerCardNumber > opponentCardNumber {
            Animations.swell(view: rightCardImageView)
            Animations.shrink(view: leftCardImageView)
        } else if opponentCardNumber > playerCardNumber {
            Animations.swell(view: leftCardImageView)
            Animations.shrink(view: rightCardImageView)
        }
    }
    
    func animateDealButton() {
        Animations.swell(view: dealButton)
    }
    
    func originalCountdownTimer() {
        
        var timeLeft = 30
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in

            timeLeft -= 1

            self.countdownTimer.text = String(timeLeft)
            print(timeLeft)

        if(timeLeft==0){
            timer.invalidate()
            self.dealButton.isEnabled = false
            self.dealButton.alpha = 0.5
            self.musicPlayer.pause()
            if self.playerScore > self.opponentScore {
                self.mainWarLabel.font = self.mainWarLabel.font.withSize(45)
                self.mainWarLabel.text = "You Won!"
                self.playAlert(value: "won")
                
            } else if self.opponentScore > self.playerScore {
                self.mainWarLabel.font = self.mainWarLabel.font.withSize(50)
                self.mainWarLabel.text = "You Lost..."
                self.playAlert(value: "lost")
                //print(self.computerCardNumber)
                //print(self.playerCardNumber)

            } else {
                self.mainWarLabel.font = self.mainWarLabel.font.withSize(50)
                self.mainWarLabel.text = "Tie!"
                self.playAlert(value: "stalemate")

            }
            
        }
            
        }
    }
        
    func updateScores() {
        checkForZeros()
        if playerCardNumber > opponentCardNumber {
            playerScore += 1
            animateTextChange(playerScoreLabel)
        } else if opponentCardNumber > playerCardNumber {
            opponentScore += 1
            animateTextChange(cpuScoreLabel)
        } else {
            //
        }
    }
    
    func animateTextChange(_ label:UILabel) {
        UIView.transition(with: label, duration: 0.25, options: .transitionFlipFromTop, animations: {}, completion: nil)
    }
    
    func playAlert(value:String) {
        if value == "won" {
            let alert = UIAlertController(title: "You Won The War!", message: "Congratulations!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Great!", style: .default, handler: { action in self.restart() }))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 130, width: 265, height: 265))

            imageView.image = UIImage(named: "won")

            alert.view.addSubview(imageView)

            self.present(alert, animated: true, completion: nil)
        } else if value == "lost" {
            let alert = UIAlertController(title: "You Lost The War...", message: "Live To Fight Another Day", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sign Peace Treaty...", style: .default, handler: { action in self.restart() }))
            var imageView = UIImageView(frame: CGRect(x: 0, y: 130, width: 265, height: 265))
            
            imageView.image = UIImage(named: "lost")

            alert.view.addSubview(imageView)

            self.present(alert, animated: true, completion: nil)
        } else if value == "stalemate" {
            let alert = UIAlertController(title: "Stalemate", message: "Tensions remain high", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Keep Calm, And Carry On", style: .default, handler: { action in self.restart() }))
            var imageView = UIImageView(frame: CGRect(x: 0, y: 130, width: 265, height: 265))
            
            imageView.image = UIImage(named: "stalemate")

            alert.view.addSubview(imageView)

            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func restart() {
        self.dealButton.isEnabled = true
        self.dealButton.alpha = 1.0
        self.mainWarLabel.text = "WAR"
        self.playerScoreLabel.text = "0"
        self.cpuScoreLabel.text = "0"
        playerScore = 0
        opponentScore = 0
        viewDidLoad()
    }
    
    func updateScoreLabels() {
        self.cpuScoreLabel.text = String(opponentScore)
        self.playerScoreLabel.text = String(playerScore)
    }
    
    func checkForZeros() {
        if playerCardNumber == 0 {
            playerScore = 0
        }
        
        if opponentCardNumber == 0 {
            opponentScore = 0
        }
    }
    
    func chooseNewCards() {
        playerCardNumber = Int.random(in: 0...15)
        opponentCardNumber = Int.random(in: 0...15)
    }
    
    func updateImageViews() {
        let playerCardFileName = "Card\(playerCardNumber)"
        
        let computerCardFileName = "Card\(opponentCardNumber)"
        
        leftCardImageView.image = UIImage(named: computerCardFileName)
        
        rightCardImageView.image = UIImage(named:playerCardFileName)
        
        whichCardToShake()
        
    }
    
    func shakeCard(_ viewToShake: UIImageView) {
        let animation = CABasicAnimation(keyPath: "position")
        
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        
        animation.fromValue = NSValue(cgPoint: CGPoint(
            x: viewToShake.center.x,
            y: viewToShake.center.y - 5
        ))
        
        animation.toValue = NSValue(cgPoint: CGPoint(
            x: viewToShake.center.x,
            y: viewToShake.center.y + 5
        ))
        
        viewToShake.layer.add(animation, forKey: "position")
    }
    
    func whichCardToShake() {
        if playerCardNumber > opponentCardNumber {
            shakeCard(rightCardImageView)
        } else if opponentCardNumber > playerCardNumber {
            shakeCard(leftCardImageView)
        } else {
            shakeCard(leftCardImageView)
            shakeCard(rightCardImageView)
        }
    }


}

