//
//  SetCardsView.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/17.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class SetView: UIView {
    override func draw(_ rect: CGRect) {
        var grid = Grid(layout: Grid.Layout.aspectRatio(CGFloat(SetCardView.cardAspectRatio)), frame: bounds)
        let visibleSubviews = subviews.filter {
            if let cardView = $0 as? SetCardView {
                return !cardView.isHidden && cardView.card.state != .isMatched
            } else {
                return false
            }
        }
        grid.cellCount = visibleSubviews.count
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: [],
            animations: {
                for case let (index, cardView) as (Int, SetCardView) in visibleSubviews.enumerated() {
                    if cardView.card.state != .isBeingDealt {
                        if let frame = grid[index] {
                            cardView.frame = frame.insetBy(dx: 0.5, dy: 0.5)
                            cardView.setNeedsDisplay()
                        }
                    }
                }
            },
            completion: { finished in
                var delayMultiplier = 0.0
                for case let (index, cardView) as (Int, SetCardView) in visibleSubviews.enumerated() {
                    if cardView.card.state == .isBeingDealt {
                        if let frame = grid[index] {
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.5,
                                delay: 0.25 * delayMultiplier,
                                options: [],
                                animations: {
                                    cardView.frame = frame.insetBy(dx: 0.5, dy: 0.5)
                                },
                                completion: { finished in
                                    UIView.transition(
                                        with: cardView,
                                        duration: 0.25,
                                        options: [.transitionFlipFromLeft],
                                        animations: {
                                            cardView.card.state = .isInPlay
                                            cardView.setNeedsDisplay()
                                        }
                                    )
                                }
                            )
                            delayMultiplier += 1.0
                        }
                    }
                }
            }
        )
    }
}
