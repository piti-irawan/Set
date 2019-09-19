//
//  SetCard.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/17.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import Foundation

class SetCard: Equatable, CustomStringConvertible {
    enum Number: CustomStringConvertible {
        case one
        case two
        case three
        var description: String {
            switch self {
            case .one: return "1"
            case .two: return "2"
            case .three: return "3"
            }
        }
    }
    enum Shape {
        case diamond
        case squiggle
        case oval
    }
    enum Shading {
        case solid
        case striped
        case open
    }
    enum Color {
        case red
        case green
        case purple
    }
    enum State {
        case isInDeck
        case isBeingDealt
        case isInPlay
        case isSelected
        case isMismatched
        case isMatched
        case isDiscarded
    }
    
    let number: Number
    let shape: Shape
    let shading: Shading
    let color: Color
    var state: State
    var description: String {
        return "\(number) \(color) \(shading) \(shape)"
    }
    
    static func == (lhs: SetCard, rhs: SetCard) -> Bool {
        return lhs.number == rhs.number && lhs.shape == rhs.shape && lhs.shading == rhs.shading && lhs.color == rhs.color
    }
    
    init(number: Number, shape: Shape, shading: Shading, color: Color) {
        self.number = number
        self.shape = shape
        self.shading = shading
        self.color = color
        state = State.isInDeck
    }
}
