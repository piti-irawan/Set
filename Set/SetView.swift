//
//  SetCardsView.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/17.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class SetView: UIView {
    var cardViews: [SetCardView] {
        return subviews.compactMap { $0 as? SetCardView }
    }
    var cardViewsBeingDealt: [SetCardView] {
        return cardViews.filter { $0.card.state == .isBeingDealt }
    }
    var cardViewsBeingDiscarded: [SetCardView] {
        return cardViews.filter { $0.card.state == .isBeingDiscarded }
    }
    var cardViewsInGrid: [SetCardView] {
        return cardViews.filter { !$0.isHidden && $0.card.state != .isBeingDiscarded && $0.card.state != .isDiscarded }
    }

    override func draw(_ rect: CGRect) {
        var grid = Grid(layout: Grid.Layout.aspectRatio(CGFloat(SetCardView.cardAspectRatio)), frame: bounds)
        grid.cellCount = cardViewsInGrid.count
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.5,
            delay: 0,
            options: [],
            animations: { [unowned self] in
                for (index, cardView) in self.cardViewsInGrid.enumerated() {
                    if cardView.card.state != .isBeingDealt {
                        if let frame = grid[index] {
                            cardView.frame = frame.insetBy(dx: SetCardView.frameInset, dy: SetCardView.frameInset)
                            cardView.setNeedsDisplay()
                        }
                    }
                }
            },
            completion: { [unowned self] finished in
                var delayMultiplier = 0.0
                for (index, cardView) in self.cardViewsInGrid.enumerated() {
                    if cardView.card.state == .isBeingDealt {
                        if let frame = grid[index] {
                            UIViewPropertyAnimator.runningPropertyAnimator(
                                withDuration: 0.5,
                                delay: 0.25 * delayMultiplier,
                                options: [],
                                animations: {
                                    cardView.frame = frame.insetBy(dx: SetCardView.frameInset, dy: SetCardView.frameInset)
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
