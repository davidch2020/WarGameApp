//
//  SocketIOManager.swift
//  connectToSocket
//
//  Created by David Cho on 11/30/20.
//  Copyright © 2020 David Cho. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    let manager = SocketManager(socketURL: URL(string: "https://herokuswiftapp.herokuapp.com")!, config: [.log(true), .compress]);

    var socket: SocketIOClient!

    override init() {
    super.init()
        socket = manager.defaultSocket
        socket.on("receiveUpdatedScores") { (data, ack) in
            print("Received Socket")
            let arrayData = data[0] as! [Int]
            ViewController.scores.newPlayerScore = String(arrayData[0])
            ViewController.scores.newOpponentScore = String(arrayData[1])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateAccepted"), object: self)

        }
        socket.on("receiveNewCardNums") { (data, ack) in
            print("Received Socket")
            let cardData = data[0] as! [Int]
            ViewController.cardNums.newPlayerCard = String(cardData[0])
            ViewController.cardNums.newOpponentCard = String(cardData[1])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateCard"), object: self)

        }
    }

    //Function for your app to emit some information to your server.
    func emit(scores:[Int]) {
        print("Sending Data...")
        manager.defaultSocket.emit("scores", scores)

    }
    
    func emitCardNums(cards:[Int]) {
        print("Sending Data...")
        manager.defaultSocket.emit("cards", cards)
        
    }

    func establishConnection() {
        socket.connect()
        print("Connected to Socket !")

    }

    func closeConnection() {
        socket.disconnect()
        print("Disconnected from Socket !")

    }
}

