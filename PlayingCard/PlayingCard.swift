//
//  PlayingCard.swift
//  PlayingCard
//
//  Created by Peter Forward on 8/12/19.
//  Copyright © 2019 Peter Forward. All rights reserved.
//

import Foundation

struct PlayingCard: CustomStringConvertible {
    var description: String {return "\(rank)\(suit)"}
    
    var suit: Suit
    var rank: Rank
   
    /**
     Emoji for each suit in a deck of cards
     
     *Values*
     ♠️♥️♣️♦️
     */
    enum Suit: String, CustomStringConvertible {
        var description: String {return "\(rawValue)"}
        
        case spades = "♠️"
        case hearts = "♥️"
        case clubs = "♣️"
        case diamonds = "♦️"
        
        static var all = [Suit.spades,Suit.hearts,Suit.clubs,Suit.diamonds]
    }
    

    enum Rank: CustomStringConvertible {
        var description: String {return "\(order)"}
        
        case ace
        case face(String)
        case numeric(Int)
        
        var order: Int {
            switch self {
            case .ace: return 1
            case .numeric(let pips): return pips
            case .face(let kind) where kind == "J": return 11
            case .face(let kind) where kind == "Q": return 12
            case .face(let kind) where kind == "K": return 13
            default: return 0
            }
        }
        
        
        static var all: [Rank] {
            var allRanks = [Rank.ace]
            for pips in 2...10 {
                allRanks.append(Rank.numeric(pips))
            }
            allRanks += [Rank.face("J"),.face("Q"),.face("K")]
            return allRanks
        }
    }
}
