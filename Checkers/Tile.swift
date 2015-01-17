//
//  Tile.swift
//  Checkers
//
//  Created by Cal on 11/26/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

class Tile {
    
    let manager : TileManager
    let tileColor : TileColor
    let row: Int
    let col: Int
    let tileID : Int
    let node : SKShapeNode
    
    var checker : Checker?
    
    init(manager: TileManager, row: Int, col: Int, width: Int){
        self.manager = manager
        self.row = row
        self.col = col
        self.tileID = manager.idFromGrid(row, col)
        if ((col + row % 2) % 2 == 0) {
            tileColor = TileColor.Dark
        } else {
            tileColor = TileColor.Light
        }
        self.node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: width))
        self.node.position = CGPointMake(CGFloat((col - 1) * width), CGFloat((row - 1) * width))
        self.node.fillColor = tileColor.color
        self.node.strokeColor = tileColor.color
        self.node.name = "\(tileID)"
        self.node.zPosition = 0
    }
    
    func getValidMoveOptions() -> [Tile] {
        var options : [Tile?] = []
        if (self.checker?.player == Player.One || self.checker?.king == true) {
            options.append(manager.getTile(row: self.row + 1, col: self.col + 1))
            options.append(manager.getTile(row: self.row + 1, col: self.col - 1))
        }
        if (self.checker?.player == Player.Two || self.checker?.king == true) {
            options.append(manager.getTile(row: self.row - 1, col: self.col + 1))
            options.append(manager.getTile(row: self.row - 1, col: self.col - 1))
        }
        var validOptions : [Tile] = []
        for possibleValid in options {
            if var validTile = possibleValid {
                if validTile.checker == nil { validOptions.append(validTile) }
            }
        }
        
        return validOptions
    }
    
    func getValidJumpOptions(#player: Player, isKing: Bool) -> [(jump: Tile, previousSteps: [Tile])] {
        var options : [(target: Tile?, through: Tile?)] = []
        if (player == Player.One || isKing == true) {
            options.append(target: manager.getTile(row: self.row + 2, col: self.col + 2), through: manager.getTile(row: self.row + 1, col: self.col + 1))
            options.append(target: manager.getTile(row: self.row + 2, col: self.col - 2), through: manager.getTile(row: self.row + 1, col: self.col - 1))
        }
        if (player == Player.Two || isKing == true) {
            options.append(target: manager.getTile(row: self.row - 2, col: self.col + 2), through: manager.getTile(row: self.row - 1, col: self.col + 1))
            options.append(target: manager.getTile(row: self.row - 2, col: self.col - 2), through: manager.getTile(row: self.row - 1, col: self.col - 1))
        }
        var validJumpOptions : [(jump: Tile, previousSteps: [Tile])] = []
        for (possibleTarget, through) in options {
            if var validTarget = possibleTarget {
                if validTarget.checker == nil && through!.checker?.player == player.other() {
                    var previousSteps : [Tile] = []
                    validJumpOptions.extend([(validTarget, previousSteps)])
                    if through != nil {
                        previousSteps.append(validTarget)
                    }
                    for (multiJump, otherSteps) in validTarget.getValidJumpOptions(player: player, isKing: isKing){
                        previousSteps.extend(otherSteps)
                        validJumpOptions.extend([(multiJump, previousSteps)])
                    }
                }
            }
        }
        
        return validJumpOptions
    }
    
    func colorMoveChoices(color: UIColor) -> Int{
        var moveOptions = getValidMoveOptions()
        for move in moveOptions {
            move.node.fillColor = color
        }
        if var checker = self.checker {
            var jumpOptions = getValidJumpOptions(player: checker.player, isKing: checker.king)
            for (jump, _) in jumpOptions {
                jump.node.fillColor = color
            }
            return jumpOptions.count + moveOptions.count
        }
        return moveOptions.count
    }

}

enum TileColor{
    
    case Dark, Light
    
    var color : UIColor {
        get{
            switch(self){
            case Dark: return UIColor(hue: 0, saturation: 0, brightness: 0.6, alpha: 1)
            case Light: return UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            }
            
        }
    }
    
}