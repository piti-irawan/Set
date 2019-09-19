//
//  Set.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/17.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import Foundation

class Set {
    var score: Int
    var cards: [SetCard]
    var cardsInDeck: [SetCard] {
        return cards.filter { $0.state == .isInDeck }
    }
    var cardsBeingDealt: [SetCard] {
        return cards.filter { $0.state == .isBeingDealt }
    }
    var cardsInPlay: [SetCard] {
        return cards.filter { $0.state == .isInPlay }
    }
    var selectedCards: [SetCard] {
        return cards.filter { $0.state == .isSelected }
    }
    var mismatchedCards: [SetCard] {
        return cards.filter { $0.state == .isMismatched }
    }
    var matchedCards: [SetCard] {
        return cards.filter { $0.state == .isMatched }
    }
    
    init(initialNumberOfCardsInPlay: Int) {
        score = 0
        cards = [SetCard]()
        for number in [SetCard.Number.one, SetCard.Number.two, SetCard.Number.three] {
            for shape in [SetCard.Shape.diamond, SetCard.Shape.squiggle, SetCard.Shape.oval] {
                for shading in [SetCard.Shading.solid, SetCard.Shading.striped, SetCard.Shading.open] {
                    for color in [SetCard.Color.red, SetCard.Color.green, SetCard.Color.purple] {
                        let card = SetCard(number: number, shape: shape, shading: shading, color: color)
                        cards += [card]
                    }
                }
            }
        }
        cards.shuffle()
        for index in 0...initialNumberOfCardsInPlay-1 {
            cards[index].state = .isBeingDealt
        }
    }
    
    func chooseCard(_ card: SetCard) {
        assert(selectedCards.count <= 2)
        if selectedCards.count == 0 {
            if mismatchedCards.count == 3 {
                for mismatchedCard in mismatchedCards {
                    mismatchedCard.state = .isInPlay
                }
            }
            card.state = .isSelected
        } else if selectedCards.count == 1 {
            if selectedCards.contains(card) {
                card.state = .isInPlay
            } else {
                card.state = .isSelected
            }
        } else if selectedCards.count == 2 {
            if selectedCards.contains(card) {
                card.state = .isInPlay
            } else {
                card.state = .isSelected
                if matchFound() {
                    score += 1
                    if canDealThreeMoreCards() {
                        for selectedCard in selectedCards {
                            if let selectedIndex = cards.firstIndex(of: selectedCard) {
                                if let replacementCard = cardsInDeck.first {
                                    if let replacementIndex = cards.firstIndex(of: replacementCard) {
                                        // Replace selectedCard with replacementCard to preserve card order
                                        cards[selectedIndex] = replacementCard
                                        cards[replacementIndex] = selectedCard
                                        selectedCard.state = .isMatched
                                        replacementCard.state = .isBeingDealt
                                    }
                                }
                            }
                        }
                    } else {
                        for selectedCard in selectedCards {
                            selectedCard.state = .isMatched
                        }
                    }
                } else {
                    for selectedCard in selectedCards {
                        selectedCard.state = .isMismatched
                    }
                }
            }
        }
    }
    
    private func matchFound() -> Bool {
        assert(selectedCards.count == 3)
        let card1 = selectedCards[0]
        let card2 = selectedCards[1]
        let card3 = selectedCards[2]
        let numberSet: Bool
        if (card1.number == card2.number && card1.number == card3.number) || (card1.number != card2.number && card1.number != card3.number && card2.number != card3.number) {
            numberSet = true
        } else {
            numberSet = false
        }
        let shapeSet: Bool
        if (card1.shape == card2.shape && card1.shape == card3.shape) || (card1.shape != card2.shape && card1.shape != card3.shape && card2.shape != card3.shape) {
            shapeSet = true
        } else {
            shapeSet = false
        }
        let shadingSet: Bool
        if (card1.shading == card2.shading && card1.shading == card3.shading) || (card1.shading != card2.shading && card1.shading != card3.shading && card2.shading != card3.shading) {
            shadingSet = true
        } else {
            shadingSet = false
        }
        let colorSet: Bool
        if (card1.color == card2.color && card1.color == card3.color) || (card1.color != card2.color && card1.color != card3.color && card2.color != card3.color) {
            colorSet = true
        } else {
            colorSet = false
        }
        return numberSet && shapeSet && shadingSet && colorSet
    }
    
    func dealThreeMoreCards() {
        if canDealThreeMoreCards() {
            for _ in 1...3 {
                if let card = cardsInDeck.first {
                    card.state = .isBeingDealt
                }
            }
        }
    }
    
    func canDealThreeMoreCards() -> Bool {
        return cardsInDeck.count >= 3 
    }
}
