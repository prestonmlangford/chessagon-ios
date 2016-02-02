//
//  Declerations.swift
//  Chessagon_sprite
//
//  Created by Preston Langford on 11/7/15.
//  Copyright © 2015 Preston Langford. All rights reserved.
//

import Foundation
import SpriteKit


//graphics scaling and geometry constants
let cospi6: CGFloat = 0.866025403784439
let pi: CGFloat = 3.1415926535

struct Graphics {
    static let atlas = SKTextureAtlas(named: "Sprites")
    
    //pieces
    static let wPawn = atlas.textureNamed("wpawn")
    static let wDuke = atlas.textureNamed("wduke")
    static let wBishop = atlas.textureNamed("wbishop")
    static let wKnight = atlas.textureNamed("wknight")
    static let wRook = atlas.textureNamed("wrook")
    static let wKing = atlas.textureNamed("wking")
    static let wQueen = atlas.textureNamed("wqueen")
    static let bPawn = atlas.textureNamed("bpawn")
    static let bDuke = atlas.textureNamed("bduke")
    static let bBishop = atlas.textureNamed("bbishop")
    static let bKnight = atlas.textureNamed("bknight")
    static let bRook = atlas.textureNamed("brook")
    static let bKing = atlas.textureNamed("bking")
    static let bQueen = atlas.textureNamed("bqueen")
    static let pieceScale: CGFloat = 0.9
    static let pieceRate: CGFloat = 800 //pixels per second
    
    //piece highlight
    
    //space highlight
    static let orangeHighlight = atlas.textureNamed("orange_highlight")
    static let orangeHighlightScale: CGFloat = 0.8
    static let orangeHighlightAnchor: CGPoint = CGPoint(x: 0.62, y: 0.5)
    
    
    //background
    static let board = atlas.textureNamed("iosGameBoardBlueHexagon")
    
    
    //buttons
    static let acceptReady = atlas.textureNamed("AcceptReady")
    static let acceptNotReady = atlas.textureNamed("AcceptNotReady")
    
    static let rejectReady = atlas.textureNamed("RejectReady")
    static let rejectNotReady = atlas.textureNamed("RejectNotReady")
    
    static let forwardReady = atlas.textureNamed("ForwardReady")
    static let forwardNotReady = atlas.textureNamed("ForwardNotReady")
    
    static let backwardReady = atlas.textureNamed("BackwardReady")
    static let backwardNotReady = atlas.textureNamed("BackwardNotReady")
    
    static let buttonScale: CGFloat = 0.4
    
    
    //graphics layers
    static let layer_hidden: CGFloat = 0
    static let layer_background: CGFloat = 1
    static let layer_board: CGFloat = 2
    static let layer_highlight: CGFloat = 3
    static let layer_piece: CGFloat = 4
    
    //GameScene parameters
    static let gameBoardSize: CGFloat = 1000
    static let gameSceneSize = CGSize(width: gameBoardSize*cospi6, height: gameBoardSize)
    static let gameBoardCenter = CGPoint(x: 0, y: 0)
    
}

struct LocalSettings {
    let defaults = NSUserDefaults.standardUserDefaults()
    var localPlayerSettings: Int { // ....[piece style 4][board style 4][board rotated 1][show possible moves 1]
        get {
            return defaults.integerForKey("ChessagonLocalSettings") //if key not defined, returns 0
        }
        set (newValue){
            defaults.setInteger(newValue, forKey: "ChessagonLocalSettings")
        }
    }
    
    var showPossibleMoves: Bool{
        get {
            return (localPlayerSettings & 0b1) != 0
        }
        set (newValue){
            var newSetting: Int = localPlayerSettings
            newSetting = newValue ? (newSetting | 0b1) : (newSetting & 0b0)
            localPlayerSettings = newSetting
        }
    }
    
    var boardRotated: Bool{
        get {
            return (localPlayerSettings & 0b10) != 0
        }
        set (newValue){
            var newSetting: Int = localPlayerSettings
            newSetting = newValue ? (newSetting | 0b10) : (newSetting & 0b01)
            localPlayerSettings = newSetting
        }
    }
    
    var pieceStyle: Int{
        get {
            return (localPlayerSettings & 0b1111000000) >> 6
        }
        set (newValue){
            var newSetting: Int = localPlayerSettings
            newSetting = (newSetting & 0b0000111111) | ((newValue & 0b1111) << 6)
            localPlayerSettings = newSetting
        }
    }
    
    var boardStyle: Int{
        get {
            return (localPlayerSettings & 0b0011110000) >> 4
        }
        set (newValue){
            var newSetting: Int = localPlayerSettings
            newSetting = (newSetting & 0b1100001111) | ((newValue & 0b1111) << 4)
            localPlayerSettings = newSetting
        }
    }
    init(){
        
    }
}

//memory management
let memoryManagement: Bool = false
var numpieces = 0
var numspaces = 0
var numgameboards = 0
var numgamescenes = 0
