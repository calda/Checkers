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

class TileManager {
    
    var tiles : [Int : Tile] = [:]
    var currentPlayer : Player? = Player.One
    var focusedTile : Tile? = nil
    
    func getTile(#row: Int, col: Int) -> Tile?{
        if row > 8 || row < 1 || col > 8 || col < 1 { return nil }
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
            var touched = getTile(tileID)!
            
            //player touched checker
            if var checker = touched.checker {
                if checker.player == currentPlayer {
                    var moveOptions = touched.getValidMoveOptions()
                    for move in moveOptions {
                        move.node.fillColor = currentPlayer!.tileFill()
                    }
                    if moveOptions.count > 0 {
                        focusedTile = touched
                    }
                }
            }
            
            //player touched tinted tile
            if ("Optional(\(touched.node.fillColor))") == ("\(currentPlayer?.tileFill())") {
                if var checker = focusedTile?.checker? {
                    let toResetColor = checker.owner.getValidMoveOptions()
                    let animationDuration = checker.moveToTile(touched, animate: true)
                    for tile in toResetColor {
                        //get workable copies of start and end colors
                        let startColorString = "\(self.currentPlayer!.tileFill())".componentsSeparatedByString(" ")
                        let endColorString = "\(TileColor.Dark.color)".componentsSeparatedByString(" ")
                        var newColor : [CGFloat] = []
                        var startColor : [CGFloat] = []
                        var endColor : [CGFloat] = []
                        for i in 1...3 {
                            let startComponent = CGFloat((startColorString[i] as NSString).doubleValue)
                            startColor.append(startComponent)
                            let endComponent = CGFloat((endColorString[i] as NSString).doubleValue)
                            endColor.append(endComponent)
                        }
                        
                        println(startColor)
                        println(endColor)
                        
                        tile.node.runAction(SKAction.customActionWithDuration(animationDuration, actionBlock: { tile, elapsedTime in
                            var percentComplete = elapsedTime / CGFloat(animationDuration)
                            if(percentComplete > 1){ percentComplete = 1.0 }
                            var newColor : [CGFloat] = []
                            for i in 0...2{
                                let difference = endColor[i] - startColor[i]
                                let newComponent = startColor[i] + (difference / percentComplete)
                                newColor.append(newComponent)
                            }
                            (tile as SKShapeNode).fillColor = SKColor(red: newColor[0], green: newColor[1], blue: newColor[2], alpha: 1)
                            //println(SKColor(red: newColor[0], green: newColor[1], blue: newColor[2], alpha: 1))
                        }))
                    }
                    var nextPlayer = currentPlayer!.other()
                    checker.node.runAction(SKAction.waitForDuration(animationDuration), completion: { self.currentPlayer = nextPlayer })
                }
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