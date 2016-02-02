//
//  Space.swift
//  Chessagon_sprite
//
//  Created by Preston Langford on 11/7/15.
//  Copyright © 2015 Preston Langford. All rights reserved.
//
//

import Foundation
import SpriteKit

class Button: SKNode {
    var center: CGPoint!
    
    //graphics objects
    var readySprite: SKSpriteNode!
    var notReadySprite: SKSpriteNode!
    
    var ready: Bool {
        didSet (newValue) {
            readySprite.hidden = !ready
            notReadySprite.hidden = ready
        }
    }
    
    init(name: String){
        ready = false
        
        super.init()
        self.name = name
        
        let lengthY: CGFloat = Graphics.gameBoardSize*3.3*0.125
        let lengthX: CGFloat = Graphics.gameBoardSize*2.9*0.125*cospi6
        
        switch self.name! {
        case "forward":
            readySprite = SKSpriteNode(texture: Graphics.forwardReady)
            notReadySprite = SKSpriteNode(texture: Graphics.forwardNotReady)
            center = CGPoint(x: lengthX, y: lengthY)
            break
        case "backward":
            readySprite = SKSpriteNode(texture: Graphics.backwardReady)
            notReadySprite = SKSpriteNode(texture: Graphics.backwardNotReady)
            center = CGPoint(x: -lengthX, y: lengthY)
            break
        case "accept":
            readySprite = SKSpriteNode(texture: Graphics.acceptReady)
            notReadySprite = SKSpriteNode(texture: Graphics.acceptNotReady)
            center = CGPoint(x: lengthX, y: -lengthY)
            break
        case "reject":
            readySprite = SKSpriteNode(texture: Graphics.rejectReady)
            notReadySprite = SKSpriteNode(texture: Graphics.rejectNotReady)
            center = CGPoint(x: -lengthX, y: -lengthY)
            break
        default: break
        }
        

        self.position = center
        self.zPosition = Graphics.layer_piece
        //bound = self.frame
        self.addChild(readySprite)
        self.addChild(notReadySprite)
        self.setScale(Graphics.buttonScale)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if memoryManagement {
            numspaces -= 1
            print("dealloc space: " + String(numspaces))
        }
        
    }
    

    

    func press(){
        if ready {
            self.position.x = center.x + 3
            self.position.y = center.y - 5
        }
    }
    
    func depress(){
        self.position.x = center.x
        self.position.y = center.y
    }
}
