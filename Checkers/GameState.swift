//
//  GameState.swift
//  Checkers
//
//  Created by Cal on 11/27/14.
//  Copyright (c) 2014 Cal. All rights reserved.
//

import Foundation
import SpriteKit

enum Player{
    
    case One, Two
    
    func checkerBorder() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.667, green: 0.224, blue: 0.224, alpha: 1)
        case .Two: return UIColor(red: 0.133, green: 0.4, blue: 0.4, alpha: 1)
        }
    }
    
    func checkerFill() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.831, green: 0.416, blue: 0.416, alpha: 1)
        case .Two: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        }
    }
    
    func tileFill() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.831, green: 0.416, blue: 0.416, alpha: 1)
        case .Two: return UIColor(red: 0.251, green: 0.498, blue: 0.498, alpha: 1)
        }
    }
    
    func darkestColor() -> UIColor {
        switch(self){
        case .One: return UIColor(red: 0.502, green: 0.082, blue: 0.082, alpha: 1)
        case .Two: return UIColor(red: 0.051, green: 0.302, blue: 0.302, alpha: 1)
        }
    }
    
    func other() -> Player {
        switch(self){
        case .One: return .Two
        case .Two: return .One
        }
    }
    
}