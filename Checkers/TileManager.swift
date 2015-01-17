//
//  TileManager.swift
//  Checkers
//
//  Created by Cal on 11/27/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

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
    
    func idFromGrid(row: Int, _ col: Int) -> Int{
        return (row - 1) * 8 + (col - 1)
    }
    
    func gridFromID(tileID : Int) -> (row: Int, col: Int){
        return (Int(tileID / 8) + 1, (tileID % 8) + 1)
    }
    
    func processTouch(node : SKNode){
        if(!(node is SKShapeNode)){ return }
        if var tileID = node.name?.toInt() {
            var touched = getTile(tileID)!
            //player touched checker
            if var checker = touched.checker {
                if checker.player == currentPlayer {
                    if var previousFocus = focusedTile {
                        previousFocus.colorMoveChoices(TileColor.Dark.color)
                    }
                    touched.colorMoveChoices(checker.player.tileFill())
                    focusedTile = touched
                }
            }
            //player touched tinted tile
            if ("Optional(\(touched.node.fillColor))") == ("\(currentPlayer?.tileFill())") {
                if var checker = focusedTile?.checker? {
                    let validMoves = checker.owner.getValidMoveOptions()
                    let validJumps = checker.owner.getValidJumpOptions(player: checker.player, isKing: checker.king)
                    var toResetColor = Array(validMoves)
                    for (tile, _) in validJumps {
                        toResetColor.append(tile)
                    }
                    var animationDuration = NSTimeInterval(0)
                    //check if regular jump
                    for move in validMoves {
                        if move.col == touched.col && move.row == touched.row {
                            animationDuration = checker.moveToTile(touched, animate: true)
                            break;
                        }
                    }
                    //move is a jump
                    if animationDuration == NSTimeInterval(0) {
                        for (final, thru) in validJumps {
                            if final.col == touched.col && final.row == touched.row {
                                var queue = Array(thru)
                                queue.append(final)
                                var jumpPath : [(jump: Tile, over: Tile)] = []
                                for i in 0...(queue.count - 1) {
                                    let previous : Tile = (i == 0 ? focusedTile! : queue[i - 1])
                                    let moveTo = queue[i]
                                    let betweenRow = Int((previous.row + moveTo.row) / 2)
                                    let betweenCol = Int((previous.col + moveTo.col) / 2)
                                    if let betweenTile = getTile(row: betweenRow, col: betweenCol) {
                                        jumpPath.append(jump: moveTo, over: betweenTile)
                                    }
                                }
                                animationDuration = checker.jumpAlongPath(jumpPath)
                                break;
                            }
                        }
                    }
                    
                    for tile in toResetColor {
                        fadeNode(tile.node, toColor: tile.tileColor.color, inDuration: CGFloat(animationDuration))
                    }
                    var nextPlayer = currentPlayer!.other()
                    checker.node.runAction(SKAction.waitForDuration(animationDuration), completion: { self.currentPlayer = nextPlayer })
                }
            }
        }
    }
    
    private func fadeNode(node: SKShapeNode, toColor: UIColor, inDuration duration: CGFloat){
        var startColor : [CGFloat] = [0.0, 0.0, 0.0]
        node.fillColor.getHue(&startColor[0], saturation: &startColor[1], brightness: &startColor[2], alpha: nil)
        var endColor : [CGFloat] = [0.0, 0.0, 0.0]
        toColor.getHue(&endColor[0], saturation: &endColor[1], brightness: &endColor[2], alpha: nil)
        node.runAction(SKAction.customActionWithDuration(NSTimeInterval(duration), actionBlock: { tile, elapsedTime in
            var percentComplete = elapsedTime / duration
            if(percentComplete > 1){ percentComplete = 1.0 }
            var newColor : [CGFloat] = []
            for i in 0...2{
                let difference = endColor[i] - startColor[i]
                let newComponent = startColor[i] + (difference * percentComplete)
                newColor.append(newComponent)
            }
            (tile as SKShapeNode).fillColor = SKColor(hue: startColor[0], saturation: newColor[1], brightness: newColor[2], alpha: 1)
        }))
    }
    
}