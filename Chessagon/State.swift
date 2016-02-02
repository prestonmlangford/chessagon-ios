//
//  GameLogic.swift
//  chessagon_ios
//
//  Created by Preston Langford on 1/23/16.
//  Copyright © 2016 Preston Langford. All rights reserved.
//

import Foundation

class State {
    var game: [Board]
    var numMoves: Int {
        get {
            return game.count - 1
        }
    }
    
    var currentBoard: Board! {
        get {
            return game.last!
        }
    }
    
    var hash: Int {
        get {
            return currentBoard.hash
        }
    }
    
    
    //Int format is as follows:
    //[0 - prfd][0 - rrfc][0 - krfc][0000 - type of piece]
    ///piecetype
    var log: Log
    var indexSelected: Bool = false
    var selectedIndex: Int = 0
    var moves = Set<PML>()
    var playerTurn: String
    var turnNumber: Int
    var firstPlayerIsWhite: Bool
    
    var secondPlayerIsWhite: Bool {
        get {
            return !firstPlayerIsWhite
        }
    }
    
    var firstPlayerTurn: Bool {
        get{
            return playerTurn == "first player"
        }
    }
    
    var secondPlayerTurn: Bool {
        get{
            return playerTurn == "second player"
        }
    }
    
    var turnColor: String {
        get {
            return isWhiteTurn ? "white" : "black"
        }
    }
    
    var isGameOver: Bool {
        get {
            return playerTurn == "game over"
        }
    }
    
    var isWhiteTurn: Bool {
        get {
            return firstPlayerTurn == firstPlayerIsWhite
        }
    }
    
    var isBlackTurn: Bool {
        get {
            return !isWhiteTurn
        }
    }
    
    
    init(){
        log = Log()
        playerTurn = "first player"
        firstPlayerIsWhite = true
        turnNumber = 1
        game = []
        let initialBoardSetup: Board = Board()
        game.append(initialBoardSetup)
    }
    
    func load(savedLog: Log) {
        log = savedLog
        for entry in log.getIndices() {
            let from = entry.from
            let to = entry.to
            let nextBoard = currentBoard.tryMove(from: from, to: to)
            game.append(nextBoard)
            next()
            print(entry)
        }
    }
    
    
    func undo() {
        moves = []
        indexSelected = false
        if (turnNumber > 1) && !isGameOver {
            log.undoLastMove()
            previous()
            game.removeLast()
        }
    }
    
    func next(){
        if firstPlayerTurn {
            playerTurn = "second player"
        } else {
            playerTurn = "first player"
        }
        turnNumber++
    }
    
    func previous(){
        if turnNumber > 1 {
            if firstPlayerTurn {
                playerTurn = "second player"
            } else {
                playerTurn = "first player"
            }
            turnNumber--
        }
    }
    
    func gameOver() {
        playerTurn = "game over"
    }
    
    
    func selectionValid(isWhite isWhite: Bool) -> Bool{
        return isWhiteTurn == isWhite
    }
    
    func deselect(){
        indexSelected = false
    }
    
    func gameplay(index: Int) -> String {
        if indexSelected {
            if moves.contains(PML(index: index)) {
                move(from: selectedIndex, to: index)
            }
            indexSelected = false
        } else {
            if selectionValid(isWhite: currentBoard.isWhite(index)) {
                indexSelected = true
                selectedIndex = index
                moves = validMoves(board: currentBoard, index: index)
            }
        }
        return playerTurn
    }
    
    func move(from from: Int, to: Int) {
        let nextBoard = currentBoard.tryMove(from: from, to: to)
        if check(turnColor, board: nextBoard) {
            print("can't move into check")
        } else {
            log.move(from: from, to: to)
            game.append(nextBoard)
            next()
            if check(turnColor, board: currentBoard) {
                
                if checkmate(turnColor, board: currentBoard) { // only then check to see if they are in checkmate
                    gameOver()
                    print("game over")
                }
            }
        }
    }
}



