//
//  Declerations.swift
//  Chessagon_sprite
//
//  Created by Preston Langford on 11/7/15.
//  Copyright © 2015 Preston Langford. All rights reserved.
//

import Foundation


struct PML: Hashable{
    let p: Int
    let m: Int
    let l: Int
    var hashValue: Int {
        get {
            return p<<10 + m<<5 + l<<0
        }
    }
    var onTheBoard: Bool {
        get{
            var v: Bool = true
            v = v&&(p + m + l == 36)
            v = v&&(p > 0)&&(p < 24)&&(p%3 != 0)
            v = v&&(m > 0)&&(m < 24)&&(m%3 != 0)
            v = v&&(l > 0)&&(l < 24)&&(l%3 != 0)
            return v
        }
    }
    var isWhite: Bool {
        get {
            return (p-1)%3 == 0
        }
    }
    var isBlack: Bool {
        get {
            return (p-2)%3 == 0
        }
    }
    var color: String {
        get{
            var result = ""
            if (p-1)%3 == 0 {
                result = "white"
            } else {
                result = "black"
            }
            return result
        }
    }
    init(index: Int){
        p = pmlsnp[index][0]
        m = pmlsnp[index][1]
        l = pmlsnp[index][2]
    }
    init(p: Int, m: Int, l: Int){
        self.p = p
        self.m = m
        self.l = l
    }
    var index: Int? {
        get {
            var result: Int?
            for (i,entry) in pmlsnp.enumerate() {
                if (entry[0] == self.p) && (entry[1] == self.m) && ((entry[2] == self.l)){
                    result = i
                    break
                }
            }
            return result
        }
    }
}

func + (left: PML, right: PML) -> PML {
    return PML(p: left.p + right.p, m: left.m + right.m, l: left.l + right.l)
}

func - (left: PML, right: PML) -> PML {
    return PML(p: left.p - right.p, m: left.m - right.m, l: left.l - right.l)
}

func == (left: PML, right: PML) -> Bool {
    return left.hashValue == right.hashValue
}

func * (left: Int, right: PML) -> PML{
    return PML(p: left*right.p, m: left*right.m, l: left*right.l)
}

let num2Type: [Int:String] = [
    0: "empty",
    1: "black king",
    2: "black queen",
    3: "black duke",
    4: "black bishop",
    5: "black knight",
    6: "black rook",
    7: "black pawn",
    8: "white king",
    9: "white queen",
    10: "white duke",
    11: "white bishop",
    12: "white knight",
    13: "white rook",
    14: "white pawn"]

let num2Letter: [Int:String] = [
    0: "empty",
    1: "K",
    2: "Q",
    3: "D",
    4: "B",
    5: "N",
    6: "R",
    7: "P",
    8: "K",
    9: "Q",
    10: "D",
    11: "B",
    12: "N",
    13: "R",
    14: "P"]

let type2Num: [String:Int] = [
    "empty":  0,
    "black king":  1,
    "black queen":  2,
    "black duke":  3,
    "black bishop":  4,
    "black knight":  5,
    "black rook":  6,
    "black pawn":  7,
    "white king":  8,
    "white queen":  9,
    "white duke": 10,
    "white bishop": 11,
    "white knight": 12,
    "white rook": 13,
    "white pawn": 14]


struct Board {
    var spaces: [Int]
    var whitePieces: Set<PML>
    var blackPieces: Set<PML>
    var hash: Int {
        get {
            var result: Int = 0
            for space in spaces {
                result = result ^ space
            }
            return result
        }
    }
    init() {
        spaces = [Int](count: pmlsnp.count, repeatedValue: 0)
        whitePieces = Set<PML>()
        blackPieces = Set<PML>()
        for (index, entry) in pmlsnp.enumerate(){
            let piece: String = num2Type[entry[5]]!
            if piece != "empty" {
                setType(index, type: piece)
                if (piece == "white pawn")||(piece == "black pawn"){
                    setprfd(index, newValue: true)
                }
                if (piece == "white rook")||(piece == "black rook"){
                    setrrfc(index, newValue: true)
                }
                if (piece == "white king")||(piece == "black king"){
                    setkrfc(index, newValue: true)
                }
                setName(index, name: index)
            }
        }
        computePieces()
    }
    
    func tryMove(from from: Int, to: Int) -> Board{
        var result = self
        result.spaces[to] = result.spaces[from]
        result.setprfd(to, newValue: false)
        result.setrrfc(to, newValue: false)
        result.setkrfc(to, newValue: false)
        result.spaces[from] = 0
        result.computePieces()
        return result
    }
    
    mutating func computePieces(){
        whitePieces.removeAll()
        blackPieces.removeAll()
        for (index, _ ) in spaces.enumerate() {
            if isWhite(index) {
                whitePieces.insert(PML(index: index))
            }
            if isBlack(index) {
                blackPieces.insert(PML(index: index))
            }
        }
    }
    //piece Int format is as follows:
    //[0000000 - name][0 - prfd][0 - rrfc][0 - krfc][0000 - type of piece]
    ///piecetype
    func type(index: Int) -> String{
        return num2Type[spaces[index] & 0b0001111]!
    }
    mutating func setType(index: Int, type: String){
        spaces[index] = (spaces[index] & ~0b0001111) | (type2Num[type]! & 0b0001111)
    }
    
    func isWhite(index: Int) -> Bool{
        return ((spaces[index] & 0b0001000) != 0) && ((spaces[index] & 0b0001111) != 0)
    }
    
    func isBlack(index: Int) -> Bool{
        return ((spaces[index] & 0b0001000) == 0) && ((spaces[index] & 0b0001111) != 0)
    }
    
    func prfd(index: Int) -> Bool{
        return spaces[index] & 0b1000000 != 0
    }
    mutating func setprfd(index: Int, newValue: Bool){
        spaces[index] = (spaces[index] & ~0b1000000) | (newValue ? 0b1000000: 0b0000000)
    }
    
    func rrfc(index: Int) -> Bool{
        return spaces[index] & 0b0100000 != 0
    }
    mutating func setrrfc(index: Int, newValue: Bool){
        spaces[index] = (spaces[index] & ~0b0100000) | (newValue ? 0b0100000: 0b0000000)
    }
    
    func krfc(index: Int) -> Bool{
        return spaces[index] & 0b0010000 != 0
    }
    mutating func setkrfc(index: Int, newValue: Bool){
        spaces[index] = (spaces[index] & ~0b0010000) | (newValue ? 0b0010000: 0b0000000)
    }
    
    func name(index: Int) -> String {
        return String((spaces[index] >> 7) & 0b1111111)
    }
    mutating func setName(index: Int, name: Int){
        spaces[index] = (spaces[index] & 0b00000001111111) | ((name & 0b1111111) << 7)
    }
}



struct A1{
    let a: Int
    let n: Int
    var text: String {
        get{
            switch a{
            case 1:
                return "a" + String(n)
            case 2:
                return "b" + String(n)
            case 3:
                return "c" + String(n)
            case 4:
                return "d" + String(n)
            case 5:
                return "e" + String(n)
            case 6:
                return "f" + String(n)
            case 7:
                return "g" + String(n)
            case 8:
                return "h" + String(n)
            case 9:
                return "i" + String(n)
            case 10:
                return "j" + String(n)
            case 11:
                return "k" + String(n)
            case 12:
                return "l" + String(n)
            case 13:
                return "m" + String(n)
            case 14:
                return "n" + String(n)
            case 15:
                return "o" + String(n)
            default:
                return "unknown coordinate"
            }
        }
    }
    init(a: Int, n: Int){
        self.a = a
        self.n = n
    }
    init(index: Int){
        self.a = pmlsnp[index][4]
        self.n = pmlsnp[index][3]
    }
}


func currentTimeMillis() -> Int64{
    let nowFloat = NSDate().timeIntervalSince1970
    return Int64(nowFloat*1000)
}




func validMoves(board board: Board, index: Int)->Set<PML>{
    var result =  Set<PML>()
    
    if board.type(index) == "empty" {
        return result
    }
    
    let piece: String = board.type(index)
    let space: PML = PML(index: index)
    
    let whitePieces = board.whitePieces
    let blackPieces = board.blackPieces
    
    
    switch piece {
    case "black king":
        var sign = 1
        if space.isBlack{
            sign *= -1
        }
        let moves: [PML] = [
            sign*PML(p:-2,m: 1,l: 1)+space,
            sign*PML(p: 1,m:-2,l: 1)+space,
            sign*PML(p: 1,m: 1,l:-2)+space,
            sign*PML(p: 4,m:-2,l:-2)+space,
            sign*PML(p:-2,m: 4,l:-2)+space,
            sign*PML(p:-2,m:-2,l: 4)+space,
            sign*PML(p: 0,m:-3,l: 3)+space,
            sign*PML(p: 0,m: 3,l:-3)+space,
            sign*PML(p:-3,m: 0,l: 3)+space,
            sign*PML(p: 3,m: 0,l:-3)+space,
            sign*PML(p:-3,m: 3,l: 0)+space,
            sign*PML(p: 3,m:-3,l: 0)+space,
        ]
        
        for move in moves {
            let capture = whitePieces.contains(move)
            let conflict = !move.onTheBoard || blackPieces.contains(move)
            if capture || !conflict {
                result.insert(move)
            }
        }
    case "black queen":
        //rook moves
        var directions: [PML] = [
            PML(p: 2,m:-1,l:-1),// black-to-white is negative white-to-black
            PML(p:-1,m: 2,l:-1),
            PML(p:-1,m:-1,l: 2)
        ]
        for blackToWhite in directions {
            for whiteToBlack in directions {
                if !(whiteToBlack == blackToWhite) {
                    var capture: Bool = false
                    var conflict: Bool = false
                    var move: PML = space
                    while(!capture && !conflict) {
                        if move.isWhite{
                            move = move - whiteToBlack
                        }else{
                            move = move + blackToWhite
                        }
                        conflict = !move.onTheBoard || blackPieces.contains(move)
                        capture = whitePieces.contains(move)
                        
                        if capture || !conflict {
                            result.insert(move)
                        }
                    }
                    
                }
            }
        }
        
        //bishop moves
        directions = [
            PML(p: 0,m: 3,l:-3),
            PML(p: 0,m:-3,l: 3),
            PML(p: 3,m: 0,l:-3),
            PML(p:-3,m: 0,l: 3),
            PML(p:-3,m: 3,l: 0),
            PML(p: 3,m:-3,l: 0)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                conflict = !move.onTheBoard || blackPieces.contains(move)
                capture = whitePieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
        }
        
        //duke moves
        directions = [
            PML(p: 2,m:-1,l:-1),
            PML(p:-2,m: 1,l: 1),
            PML(p:-1,m: 2,l:-1),
            PML(p: 1,m:-2,l: 1),
            PML(p:-1,m:-1,l: 2),
            PML(p: 1,m: 1,l:-2)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                if !move.onTheBoard {
                    move = move + increment
                }
                conflict = !move.onTheBoard || blackPieces.contains(move)
                capture = whitePieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
        }
        
    case "black duke":
        let directions: [PML] = [
            PML(p: 2,m:-1,l:-1),
            PML(p:-2,m: 1,l: 1),
            PML(p:-1,m: 2,l:-1),
            PML(p: 1,m:-2,l: 1),
            PML(p:-1,m:-1,l: 2),
            PML(p: 1,m: 1,l:-2)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                if !move.onTheBoard {
                    move = move + increment
                }
                conflict = !move.onTheBoard || blackPieces.contains(move)
                capture = whitePieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
        }
    case "black bishop":
        let directions: [PML] = [
            PML(p: 0,m: 3,l:-3),
            PML(p: 0,m:-3,l: 3),
            PML(p: 3,m: 0,l:-3),
            PML(p:-3,m: 0,l: 3),
            PML(p:-3,m: 3,l: 0),
            PML(p: 3,m:-3,l: 0)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                conflict = !move.onTheBoard || blackPieces.contains(move)
                capture = whitePieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
        }
    case "black knight":
        var sign = 1
        if space.isBlack {
            sign *= -1
        }
        let moves: [PML] = [
            sign*PML(p:-2,m:-5,l: 7)+space,
            sign*PML(p:-5,m:-2,l: 7)+space,
            sign*PML(p: 1,m:-5,l: 4)+space,
            sign*PML(p: 4,m:-5,l: 1)+space,
            sign*PML(p: 7,m:-5,l:-2)+space,
            sign*PML(p: 7,m:-2,l:-5)+space,
            sign*PML(p: 1,m: 4,l:-5)+space,
            sign*PML(p: 4,m: 1,l:-5)+space,
            sign*PML(p:-2,m: 7,l:-5)+space,
            sign*PML(p:-5,m: 7,l:-2)+space,
            sign*PML(p:-5,m: 4,l: 1)+space,
            sign*PML(p:-5,m: 1,l: 4)+space,
        ]
        for move in moves {
            let conflict = !move.onTheBoard || blackPieces.contains(move)
            
            if !conflict {
                result.insert(move)
            }
        }
        
    case "black rook":
        let directions: [PML] = [
            PML(p: 2,m:-1,l:-1),// black-to-white is negative white-to-black
            PML(p:-1,m: 2,l:-1),
            PML(p:-1,m:-1,l: 2)
        ]
        for blackToWhite in directions {
            for whiteToBlack in directions {
                if !(whiteToBlack == blackToWhite) {
                    var capture: Bool = false
                    var conflict: Bool = false
                    var move: PML = space
                    while(!capture && !conflict) {
                        if move.isWhite{
                            move = move - whiteToBlack
                        }else{
                            move = move + blackToWhite
                        }
                        conflict = !move.onTheBoard || blackPieces.contains(move)
                        capture = whitePieces.contains(move)
                        
                        if capture || !conflict {
                            result.insert(move)
                        }
                    }
                    
                }
            }
        }
        
    case "black pawn":
        
        let s: Int = Int(!space.isWhite)
        var move = PML(p: 1, m:-2, l: 1) + 1*s*PML(p:-2, m: 1, l: 1) + space
        var conflict = !move.onTheBoard
        conflict = conflict || blackPieces.contains(move)
        conflict = conflict || whitePieces.contains(move)
        
        if !conflict {
            result.insert(move)
            move = PML(p: 3, m:-6, l: 3) + 3*s*PML(p:-2, m: 1, l: 1) + space
            conflict = !move.onTheBoard
            conflict = conflict || blackPieces.contains(move)
            conflict = conflict || whitePieces.contains(move)
            
            if !conflict && board.prfd(index){
                result.insert(move)
            }
            
        }
        
        move = PML(p:-2, m:-2, l: 4) - 2*s*PML(p:-2, m: 1, l: 1) + space
        conflict = !move.onTheBoard
        conflict = conflict || blackPieces.contains(move)
        conflict = conflict || whitePieces.contains(move)
        
        if !conflict {
            result.insert(move)
            move = PML(p:-3, m:-3, l: 6) - 3*s*PML(p:-2, m: 1, l: 1) + space
            conflict = !move.onTheBoard
            conflict = conflict || blackPieces.contains(move)
            conflict = conflict || whitePieces.contains(move)
            
            if !conflict && board.prfd(index) {
                result.insert(move)
            }
            
        }
        
        let threats: [PML] = [
            PML(p: 0, m:-3, l: 3),
            PML(p:-3, m: 0, l: 3),
            PML(p: 3, m:-3, l: 0)
        ]
        for direction in threats{
            let move = direction + space
            let capture = whitePieces.contains(move)
            if capture {
                result.insert(move)
            }
        }
        
        //KML: Detect if Pawn reaches back of board and needs to be promoted.....here?
        //      - after valid moves resolved,
        //      - after valid threats resolved
        //      - after valid captures resolved
        //      - automatically covert the pawn to a queen
        
        
    case "white king":
        var sign = 1
        if space.isBlack{
            sign *= -1
        }
        let moves: [PML] = [
            sign*PML(p:-2,m: 1,l: 1)+space,
            sign*PML(p: 1,m:-2,l: 1)+space,
            sign*PML(p: 1,m: 1,l:-2)+space,
            sign*PML(p: 4,m:-2,l:-2)+space,
            sign*PML(p:-2,m: 4,l:-2)+space,
            sign*PML(p:-2,m:-2,l: 4)+space,
            sign*PML(p: 0,m:-3,l: 3)+space,
            sign*PML(p: 0,m: 3,l:-3)+space,
            sign*PML(p:-3,m: 0,l: 3)+space,
            sign*PML(p: 3,m: 0,l:-3)+space,
            sign*PML(p:-3,m: 3,l: 0)+space,
            sign*PML(p: 3,m:-3,l: 0)+space,
        ]
        for move in moves {
            let capture = blackPieces.contains(move)
            let conflict = !move.onTheBoard || whitePieces.contains(move)
            if capture || !conflict {
                result.insert(move)
            }
            
        }
        
    case "white queen":
        //rook moves
        var directions: [PML] = [
            PML(p: 2,m:-1,l:-1),// black-to-white is negative white-to-black
            PML(p:-1,m: 2,l:-1),
            PML(p:-1,m:-1,l: 2)
        ]
        for blackToWhite in directions {
            for whiteToBlack in directions {
                if !(whiteToBlack == blackToWhite) {
                    var capture: Bool = false
                    var conflict: Bool = false
                    var move: PML = space
                    while !capture && !conflict {
                        if move.isWhite {
                            move = move - whiteToBlack
                        }else{
                            move = move + blackToWhite
                        }
                        conflict = !move.onTheBoard || whitePieces.contains(move)
                        capture = blackPieces.contains(move)
                        
                        if capture || !conflict {
                            result.insert(move)
                        }
                    }
                    
                }
            }
        }
        
        //bishop moves
        directions = [
            PML(p: 0,m: 3,l:-3),
            PML(p: 0,m:-3,l: 3),
            PML(p: 3,m: 0,l:-3),
            PML(p:-3,m: 0,l: 3),
            PML(p:-3,m: 3,l: 0),
            PML(p: 3,m:-3,l: 0)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                conflict = !move.onTheBoard || whitePieces.contains(move)
                capture = blackPieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
        }
        
        //duke moves
        directions = [
            PML(p: 2,m:-1,l:-1),
            PML(p:-2,m: 1,l: 1),
            PML(p:-1,m: 2,l:-1),
            PML(p: 1,m:-2,l: 1),
            PML(p:-1,m:-1,l: 2),
            PML(p: 1,m: 1,l:-2)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                if !move.onTheBoard {
                    move = move + increment
                }
                conflict = !move.onTheBoard || whitePieces.contains(move)
                capture = blackPieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
            
        }
        
    case "white duke":
        let directions: [PML] = [
            PML(p: 2,m:-1,l:-1),
            PML(p:-2,m: 1,l: 1),
            PML(p:-1,m: 2,l:-1),
            PML(p: 1,m:-2,l: 1),
            PML(p:-1,m:-1,l: 2),
            PML(p: 1,m: 1,l:-2)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                if !move.onTheBoard {
                    move = move + increment
                }
                conflict = !move.onTheBoard || whitePieces.contains(move)
                capture = blackPieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
            
        }
    case "white bishop":
        let directions: [PML] = [
            PML(p: 0,m: 3,l:-3),
            PML(p: 0,m:-3,l: 3),
            PML(p: 3,m: 0,l:-3),
            PML(p:-3,m: 0,l: 3),
            PML(p:-3,m: 3,l: 0),
            PML(p: 3,m:-3,l: 0)
        ]
        for increment in directions {
            var capture: Bool = false
            var conflict: Bool = false
            var move: PML = space
            while !capture && !conflict {
                move = move + increment
                conflict = !move.onTheBoard || whitePieces.contains(move)
                capture = blackPieces.contains(move)
                if capture || !conflict {
                    result.insert(move)
                }
            }
        }
        
    case "white knight":
        var sign = 1
        if space.isBlack{
            sign *= -1
        }
        let moves: [PML] = [
            sign*PML(p:-2,m:-5,l: 7)+space,
            sign*PML(p:-5,m:-2,l: 7)+space,
            sign*PML(p: 1,m:-5,l: 4)+space,
            sign*PML(p: 4,m:-5,l: 1)+space,
            sign*PML(p: 7,m:-5,l:-2)+space,
            sign*PML(p: 7,m:-2,l:-5)+space,
            sign*PML(p: 1,m: 4,l:-5)+space,
            sign*PML(p: 4,m: 1,l:-5)+space,
            sign*PML(p:-2,m: 7,l:-5)+space,
            sign*PML(p:-5,m: 7,l:-2)+space,
            sign*PML(p:-5,m: 4,l: 1)+space,
            sign*PML(p:-5,m: 1,l: 4)+space,
        ]
        for move in moves {
            let conflict = !move.onTheBoard || whitePieces.contains(move)
            
            if !conflict {
                result.insert(move)
            }
        }
    case "white rook":
        let directions: [PML] = [
            PML(p: 2,m:-1,l:-1),// black-to-white is negative white-to-black
            PML(p:-1,m: 2,l:-1),
            PML(p:-1,m:-1,l: 2)
        ]
        for blackToWhite in directions {
            for whiteToBlack in directions {
                if !(whiteToBlack == blackToWhite) {
                    var capture: Bool = false
                    var conflict: Bool = false
                    var move: PML = space
                    while !capture && !conflict {
                        if move.isWhite {
                            move = move - whiteToBlack
                        }else{
                            move = move + blackToWhite
                        }
                        conflict = !move.onTheBoard || whitePieces.contains(move)
                        capture = blackPieces.contains(move)
                        
                        if capture || !conflict {
                            result.insert(move)
                        }
                    }
                    
                }
            }
        }
    case "white pawn":
        let s: Int = Int(!space.isWhite)
        var move = PML(p: 1,m: 1,l:-2) - 1*s*PML(p: 2,m:-1,l:-1) + space
        var conflict = !move.onTheBoard
        conflict = conflict || blackPieces.contains(move)
        conflict = conflict || whitePieces.contains(move)
        
        if !conflict {
            result.insert(move)
            move = PML(p: 3,m: 3, l:-6) - 3*s*PML(p: 2, m:-1,l:-1) + space
            conflict = !move.onTheBoard
            conflict = conflict || blackPieces.contains(move)
            conflict = conflict || whitePieces.contains(move)
            
            if !conflict && board.prfd(index) {
                result.insert(move)
            }
            
        }
        
        move = PML(p:-2,m: 4,l:-2) + 2*s*PML(p: 2,m:-1,l:-1) + space
        conflict = !move.onTheBoard
        conflict = conflict || blackPieces.contains(move)
        conflict = conflict || whitePieces.contains(move)
        
        if !conflict {
            result.insert(move)
            move = PML(p:-3,m: 6, l:-3) + 3*s*PML(p: 2, m:-1,l:-1) + space
            conflict = !move.onTheBoard
            conflict = conflict || blackPieces.contains(move)
            conflict = conflict || whitePieces.contains(move)
            
            if !conflict && board.prfd(index) {
                result.insert(move)
            }
            
        }
        
        let threats: [PML] = [
            PML(p: 3,m: 0,l:-3),
            PML(p: 0,m: 3,l:-3),
            PML(p:-3,m: 3,l: 0)
        ]
        for direction in threats{
            let move = direction + space
            let capture = blackPieces.contains(move)
            if capture {
                result.insert(move)
            }
        }
        
        //KML: Detect if Pawn reaches back of board and needs to be promoted.....here?
        //      - after valid moves resolved,
        //      - after valid threats resolved
        //      - after valid captures resolved
        //      - automatically covert the pawn to a queen
        
        
        
    case "empty": break
    default: break
    }
    
    return result
}

func validThreats(board board: Board, index: Int)->Set<PML>{
    var result =  Set<PML>()
    
    if board.spaces[index] == 0 {
        return result
    }
    
    let piece: String = board.type(index)
    let space: PML = PML(index: index)
    
    let whitePieces = board.whitePieces
    let blackPieces = board.blackPieces
    
    
    switch piece {
    case "black pawn":
        let threats: [PML] = [
            PML(p: 0, m:-3, l: 3),
            PML(p:-3, m: 0, l: 3),
            PML(p: 3, m:-3, l: 0)
        ]
        
        for direction in threats{
            let move = direction + space
            let capture = whitePieces.contains(move)
            if capture {
                result.insert(move)
            }
        }
    case "white pawn":
        let threats: [PML] = [
            PML(p: 3,m: 0,l:-3),
            PML(p: 0,m: 3,l:-3),
            PML(p:-3,m: 3,l: 0)
        ]
        for direction in threats{
            let move = direction + space
            let capture = blackPieces.contains(move)
            if capture {
                result.insert(move)
            }
        }
    case "empty": break
    default:
        result = validMoves(board: board, index: index)
    }
    return result
}


func check(color: String, board: Board) -> Bool{
    var king: PML!
    var threats: Set<PML> = []
    for (index, _ ) in board.spaces.enumerate() {
        if (board.type(index) == "white king") && (color == "white") ||
            (board.type(index) == "black king") && (color == "black") {
                king = PML(index: index)
        }
        if (board.isBlack(index) && color == "white") || (board.isWhite(index) && color == "black"){
            threats = threats.union(validThreats(board: board, index: index))
        }
    }
    return threats.contains(king)
}

func checkmate(color: String, board: Board) -> Bool{
    let begin = currentTimeMillis()
    var result: Bool = true
    
    for (pieceIndex, _ ) in board.spaces.enumerate() {
        if (board.isWhite(pieceIndex) && (color == "white")) || (board.isBlack(pieceIndex) && (color == "black")) {
            let moves = validMoves(board: board, index: pieceIndex)
            for (moveIndex, _ ) in pmlsnp.enumerate() {
                for move in moves {
                    if move == PML(index: moveIndex) {
                        let testBoard = board.tryMove(from: pieceIndex, to: moveIndex)
                        result = result && check(color, board: testBoard)
                        if result == false {
                            let end = currentTimeMillis()
                            print(end - begin)
                            return result
                        }
                    }
                }
            }
        }
    }
    let end = currentTimeMillis()
    print("checkmate called. Time: " + String(end - begin) + " ms")
    return result
}


//0,1,2 are PML coordinates
//4,3  are A1 coordinates
//5 is the piece
let pmlsnp: [[Int]] = [
    [ 1, 13, 22, 1, 11,  0],
    [ 1, 16, 19, 1,  9,  0],
    [ 1, 19, 16, 1,  7,  0],
    [ 1, 22, 13, 1,  5,  0],
    [ 2, 11, 23, 1, 12, 14],                //white pawn
    [ 2, 14, 20, 1, 10,  0],
    [ 2, 17, 17, 1,  8,  0],
    [ 2, 20, 14, 1,  6,  0],
    [ 2, 23, 11, 1,  4,  7],     //black pawn
    [ 4, 10, 22, 2, 12, 14],                //white pawn
    [ 4, 13, 19, 2, 10,  0],
    [ 4, 16, 16, 2,  8,  0],
    [ 4, 19, 13, 2,  6,  0],
    [ 4, 22, 10, 2,  4,  7],     //black pawn
    [ 5,  8, 23, 2, 13, 13],                //white rook
    [ 5, 11, 20, 2, 11, 14],                //white pawn
    [ 5, 14, 17, 2,  9,  0],
    [ 5, 17, 14, 2,  7,  0],
    [ 5, 20, 11, 2,  5,  7],     //black pawn
    [ 5, 23,  8, 2,  3,  6],     //black rook
    [ 7,  7, 22, 3, 13, 12],                //white knight
    [ 7, 10, 19, 3, 11, 14],                //white pawn
    [ 7, 13, 16, 3,  9,  0],
    [ 7, 16, 13, 3,  7,  0],
    [ 7, 19, 10, 3,  5,  7],     //black pawn
    [ 7, 22,  7, 3,  3,  5],     //black knight
    [ 8,  5, 23, 3, 14, 11],                //white bishop
    [ 8,  8, 20, 3, 12, 14],                //white pawn
    [ 8, 11, 17, 3, 10,  0],
    [ 8, 14, 14, 3,  8,  0],
    [ 8, 17, 11, 3,  6,  0],
    [ 8, 20,  8, 3,  4,  7],     //black pawn
    [ 8, 23,  5, 3,  2,  4],     //black bishop
    [10,  4, 22, 4, 14, 10],                //white duke
    [10,  7, 19, 4, 12, 14],                //white pawn
    [10, 10, 16, 4, 10,  0],
    [10, 13, 13, 4,  8,  0],
    [10, 16, 10, 4,  6,  0],
    [10, 19,  7, 4,  4,  7],     //black pawn
    [10, 22,  4, 4,  2,  3],     //black duke
    [11,  2, 23, 4, 15,  8],                //white king
    [11,  5, 20, 4, 13, 14],                //white pawn
    [11,  8, 17, 4, 11,  0],
    [11, 11, 14, 4,  9,  0],
    [11, 14, 11, 4,  7,  0],
    [11, 17,  8, 4,  5,  0],
    [11, 20,  5, 4,  3,  7],     //black pawn
    [11, 23,  2, 4,  1,  1],     //black king, should oppose white king  //KML
    [13,  1, 22, 5, 15,  9],                //white queen
    [13,  4, 19, 5, 13, 14],                //white pawn
    [13,  7, 16, 5, 11,  0],
    [13, 10, 13, 5,  9,  0],
    [13, 13, 10, 5,  7,  0],
    [13, 16,  7, 5,  5,  0],
    [13, 19,  4, 5,  3,  7],     //black pawn
    [13, 22,  1, 5,  1,  2],     //black king, should oppose white queen  //KML
    [14,  2, 20, 5, 14, 10],                //white duke
    [14,  5, 17, 5, 12, 14],                //white pawn
    [14,  8, 14, 5, 10,  0],
    [14, 11, 11, 5,  8,  0],
    [14, 14,  8, 5,  6,  0],
    [14, 17,  5, 5,  4,  7],     //black pawn
    [14, 20,  2, 5,  2,  3],     //black duke
    [16,  1, 19, 6, 14, 11],                //white bishop
    [16,  4, 16, 6, 12, 14],                //white pawn
    [16,  7, 13, 6, 10,  0],
    [16, 10, 10, 6,  8,  0],
    [16, 13,  7, 6,  6,  0],
    [16, 16,  4, 6,  4,  7],     //black pawn
    [16, 19,  1, 6,  2,  4],     //black bishop
    [17,  2, 17, 6, 13, 12],                //white knight
    [17,  5, 14, 6, 11, 14],                //white pawn
    [17,  8, 11, 6,  9,  0],
    [17, 11,  8, 6,  7,  0],
    [17, 14,  5, 6,  5,  7],     //black pawn
    [17, 17,  2, 6,  3,  5],     //black knight
    [19,  1, 16, 7, 13, 13],                //white rook
    [19,  4, 13, 7, 11, 14],                //white pawn
    [19,  7, 10, 7,  9,  0],
    [19, 10,  7, 7,  7,  0],
    [19, 13,  4, 7,  5,  7],     //black pawn
    [19, 16,  1, 7,  3,  6],     //black rook
    [20,  2, 14, 7, 12, 14],                //white pawn
    [20,  5, 11, 7, 10,  0],
    [20,  8,  8, 7,  8,  0],
    [20, 11,  5, 7,  6,  0],
    [20, 14,  2, 7,  4,  7],     //black pawn
    [22,  1, 13, 8, 12, 14],                //white pawn
    [22,  4, 10, 8, 10,  0],
    [22,  7,  7, 8,  8,  0],
    [22, 10,  4, 8,  6,  0],
    [22, 13,  1, 8,  4,  7],     //black pawn
    [23,  2, 11, 8, 11,  0],
    [23,  5,  8, 8,  9,  0],
    [23,  8,  5, 8,  7,  0],
    [23, 11,  2, 8,  5,  0]
]
