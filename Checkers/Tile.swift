//
//  Tile.swift
//  Checkers
//
//  Created by Cal on 11/26/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

class TileManager {
    
    var tiles : [Int : Tile] = [:]
    
    func getTile(#row: Int, col: Int) -> Tile?{
        let tileID = idFromGrid(row, col)
        return getTile(tileID)
    }
    
    func getTile(tileID : Int) -> Tile?{
        return tiles[tileID]?
    }
    
    init(board: SKNode, tileWidth: Int){
        for row in 1...8 {
            for col in 1...8{
                let tile = Tile(manager: self, row: row, col: col, width: tileWidth)
                tiles[idFromGrid(row, col)] = tile
                board.addChild(tile.node)
                var player : Player? = nil
                if(row <= 3){
                    player = .One
                }
                if(row >= 6){
                    player = .Two
                }
                if(player != nil && tile.tileColor == TileColor.Dark){
                    let checker = Checker(owner: tile, player: player!)
                    board.addChild(checker.node)
                }
            }
        }
    }
    
    func processTouch(node : SKNode){
        if(!(node is SKShapeNode)){ return }
        if var tileID = node.name?.toInt() {
            var tile = getTile(tileID)!
            if var checker = tile.checker {
                checker.moveToTile(getTile(row: 1, col: 1)!)
            }
        }
    }
    
    func idFromGrid(row: Int, _ col: Int) -> Int{
        return (row - 1) * 8 + (col - 1)
    }
    
    func gridFromID(tileID : Int) -> (row: Int, col: Int){
        return (Int(tileID / 8) + 1, (tileID % 8) + 1)
    }
    
}

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