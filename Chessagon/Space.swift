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

class Space: SKSpriteNode{
    var pml: PML
    var a1: A1
    var center: CGPoint
    var highlight_threat: Bool = false
    var highlight_movement: Bool = false
    var v1: (x: CGFloat, y: CGFloat) = (x: 0.0,y: 0.0)
    var v2: (x: CGFloat, y: CGFloat) = (x: 0.0,y: 0.0)
    var v3: (x: CGFloat, y: CGFloat) = (x: 0.0,y: 0.0)
    var index: Int
    
    
    init(index: Int){
        self.index = index
        
        pml = PML(index: index)
        a1 = A1(index: index)
        
        //fun fact! (l - m) is always divisble by 3! but it doesn't even matter :(
        center = CGPoint(x: CGFloat(12 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m)/48)
        
        //vertices are arranged in decreasing y value to ensure pip works correctly
        if(pml.isWhite){
            v1 = (x: CGFloat(13 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m + 3)/48)
            v2 = (x: CGFloat(10 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m + 0)/48)
            v3 = (x: CGFloat(13 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m - 3)/48)
        }else{
            v1 = (x: CGFloat(11 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m + 3)/48)
            v2 = (x: CGFloat(14 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m + 0)/48)
            v3 = (x: CGFloat(11 - pml.p)*cospi6/24, y: CGFloat(pml.l - pml.m - 3)/48)
        }
        
        center.x = Graphics.gameBoardSize*center.x + Graphics.gameBoardCenter.x
        center.y = Graphics.gameBoardSize*center.y + Graphics.gameBoardCenter.y
        v1.x = Graphics.gameBoardSize*v1.x + Graphics.gameBoardCenter.x
        v1.y = Graphics.gameBoardSize*v1.y + Graphics.gameBoardCenter.y
        v2.x = Graphics.gameBoardSize*v2.x + Graphics.gameBoardCenter.x
        v2.y = Graphics.gameBoardSize*v2.y + Graphics.gameBoardCenter.y
        v3.x = Graphics.gameBoardSize*v3.x + Graphics.gameBoardCenter.x
        v3.y = Graphics.gameBoardSize*v3.y + Graphics.gameBoardCenter.y
        
        if memoryManagement {
            numspaces += 1
            print("alloc space: " + String(numspaces))
        }
        super.init(texture: Graphics.orangeHighlight, color: UIColor(), size: Graphics.orangeHighlight.size())
        let angle: CGFloat = CGFloat(CGFloat(!isWhite())*pi)
        self.anchorPoint = Graphics.orangeHighlightAnchor
        self.position = center
        self.zPosition = Graphics.layer_hidden
        self.zRotation = angle
        self.setScale(Graphics.orangeHighlightScale)
        
        self.name = String(index)
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
    
    func highlight(yes: Bool){
        self.zPosition = yes ? Graphics.layer_highlight : Graphics.layer_hidden
    }
    
    func isWhite()->Bool{
        return pml.isWhite
    }
    
    func isBlack()->Bool{
        return pml.isBlack
    }
    
    func pip(loc: CGPoint)->Bool{
        //    Input:  three points v1, v2, and (x,y)
        //    Return: >0 for P2 left of the line through P0 to P1
        //          =0 for P2 on the line
        //          <0 for P2 right of the line
        // (P1.x - P0.x) * (P2.y - P0.y) - (P2.x - P0.x) * (P1.y - P0.y)
        // for some reason it is working backwards, for now i am not questioning it
        let e12:Bool = (v2.x - v1.x)*(loc.y - v1.y) - (loc.x - v1.x)*(v2.y - v1.y) < 0
        let e23:Bool = (v3.x - v2.x)*(loc.y - v2.y) - (loc.x - v2.x)*(v3.y - v2.y) < 0
        let e13:Bool = (v3.x - v1.x)*(loc.y - v1.y) - (loc.x - v1.x)*(v3.y - v1.y) < 0
        return (isWhite() && !e12 && !e23 && e13) || (isBlack() && e12 && e23 && !e13)
    }
}
