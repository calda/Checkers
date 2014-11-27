//
//  Player.swift
//  Checkers
//
//  Created by Cal on 11/26/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

class Checker{
    
    var owner : Tile
    let player : Player
    var king : Bool = false
    let node : SKShapeNode
    
    init(owner : Tile, player : Player){
        self.player = player
        self.node = SKShapeNode(circleOfRadius: 40)
        self.node.fillColor = player.lightColor()
        self.node.strokeColor = player.primaryColor()
        self.node.lineWidth = 10.0
        self.node.zPosition = 1
        self.owner = owner
        moveToTile(owner, animate: false)
    }
    
    func moveToTile(tile : Tile, animate : Bool = true){
        self.owner = tile
        tile.checker = self
        node.name = tile.node.name
        let newPosition = CGPoint(x: owner.node.position.x + 50, y: owner.node.position.y + 50)
        if(animate){
            let distance = pow(pow(node.position.x - newPosition.x, 2) + pow(node.position.y - newPosition.y, 2), 0.5)
            let duration = distance / 1000
            let translate = SKAction.moveTo(newPosition, duration: NSTimeInterval(duration))
            let scale = SKAction.sequence([
                SKAction.scaleBy(2, duration: NSTimeInterval(duration / 3)),
                SKAction.waitForDuration(NSTimeInterval(duration / 3)),
                SKAction.scaleBy(0.5, duration: NSTimeInterval(duration / 3)),
                SKAction.runBlock({ self.node.zPosition = 1 })
            ])
            node.zPosition = 2
            node.runAction(translate)
            node.runAction(scale)
        }
        else{
            node.position = newPosition
        }
    }
    
}

enum Player{
    
    case One, Two
    
    func primaryColor() -> UIColor {
        switch(self){
            case .One: return UIColor(red: 0.667, green: 0.224, blue: 0.224, alpha: 1)
            case .Two: return UIColor(red: 0.133, green: 0.4, blue: 0.4, alpha: 1)
        }
    }
    
    func lightColor() -> UIColor {
        switch(self){
            case .One: return UIColor(red: 0.831, green: 0.416, blue: 0.416, alpha: 1)
            case .Two: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        }
    }
    
    func darkColor() -> UIColor {
        switch(self){
            case .One: return UIColor(red: 0.502, green: 0.082, blue: 0.082, alpha: 1)
            case .Two: return UIColor(red: 0.051, green: 0.302, blue: 0.302, alpha: 1)
        }
    }
    
}