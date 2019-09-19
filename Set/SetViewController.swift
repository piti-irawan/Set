//
//  SetViewController.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/17.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    private let initialNumberOfCardsInPlay = 12
    private lazy var set = Set(initialNumberOfCardsInPlay: initialNumberOfCardsInPlay)
    
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var flyawayBehavior = FlyawayBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
    }
    
    @IBOutlet private weak var scoreLabel: UILabel! {
        didSet {
            updateScoreLabel()
        }
    }
    
    @IBOutlet weak var setView: SetView! {
        didSet {
            let frame = CGRect(
                x: dealButton.frame.origin.x - setView.frame.origin.x,
                y: dealButton.frame.origin.y - setView.frame.origin.y,
                width: dealButton.bounds.width,
                height: 2.0 * dealButton.bounds.height
            )
            for card in set.cards {
                let cardView = SetCardView(card: card, frame: frame)
                setView.addSubview(cardView)
                let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCard(_:)))
                cardView.addGestureRecognizer(tap)
            }
            updateSetView()
        }
    }
    
    @IBOutlet weak var dealButton: UIButton! {
        didSet {
            updateDealButton()
        }
    }
    
    @objc func chooseCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended && set.cardsBeingDealt.count == 0 && set.matchedCards.count == 0 {
            if let cardView = sender.view as? SetCardView {
                let card = cardView.card
                set.chooseCard(card)
                updateViewFromModel()
                
            }
        }
    }
    
    @IBAction private func touchDealButton(_ sender: UIButton) {
        if set.canDealThreeMoreCards() && set.cardsBeingDealt.count == 0 && set.matchedCards.count == 0 {
            set.dealThreeMoreCards()
            updateViewFromModel()
        }
    }
    
    private func updateViewFromModel() {
        updateScoreLabel()
        updateSetView()
        updateDealButton()
    }
    
    private func updateScoreLabel() {
        if set.score == 1 {
            scoreLabel.text = "1 Set"
        } else {
            scoreLabel.text = "\(set.score) Sets"
        }
    }
    
    private func updateSetView() {
        // Sync setView.subviews to set.cards to preserve card order
        var cardViews = setView.subviews
        for view in setView.subviews {
            view.removeFromSuperview()
        }
        for card in set.cards {
            for index in cardViews.indices {
                if let cardView = cardViews[index] as? SetCardView {
                    if cardView.card == card {
                        setView.addSubview(cardView)
                        switch cardView.card.state {
                        case .isInDeck:
                            cardView.isHidden = true
                        case .isBeingDealt:
                            // frame of dealButton relative to setView
                            let initialFrame = CGRect(
                                x: dealButton.frame.origin.x - setView.frame.origin.x,
                                y: dealButton.frame.origin.y - setView.frame.origin.y,
                                width: dealButton.bounds.width,
                                height: 2.0 * dealButton.bounds.height
                            )
                            cardView.frame = initialFrame
                            cardView.isHidden = false
                        case .isInPlay:
                            cardView.isHidden = false
                        case .isSelected:
                            cardView.isHidden = false
                        case .isMismatched:
                            cardView.isHidden = false
                        case .isMatched:
                            let newCardView = SetCardView(card: cardView.card, frame: cardView.frame)
                            cardView.removeFromSuperview()
                            setView.addSubview(newCardView)
                            newCardView.isHidden = false
                            flyawayBehavior.addItem(newCardView)
                            Timer.scheduledTimer(
                                withTimeInterval: 1,
                                repeats: false,
                                block: { timer in
                                    self.flyawayBehavior.removeItem(newCardView)
                                    // frame of scoreLabel relative to self.view
                                    let finalFrame = CGRect(
                                        x: self.scoreLabel.frame.origin.x,
                                        y: self.scoreLabel.frame.origin.y,
                                        width: self.scoreLabel.bounds.width,
                                        height: 2.0 * self.scoreLabel.bounds.height
                                    )
                                    let snap = UISnapBehavior(item: newCardView, snapTo: CGPoint(x: finalFrame.midX, y: finalFrame.midY))
                                    snap.damping = 0.5
                                    self.animator.addBehavior(snap)
                                    UIViewPropertyAnimator.runningPropertyAnimator(
                                        withDuration: 0.1,
                                        delay: 0,
                                        options: [],
                                        animations: {
                                            newCardView.bounds.size = finalFrame.size
                                        }
                                    )
                                }
                            )
                        case .isDiscarded:
                            cardView.isHidden = true
                        }
                        cardViews.remove(at: index)
                        break
                    }
                }
            }
        }
        setView.setNeedsDisplay()
    }
    
    private func updateDealButton() {
        if set.canDealThreeMoreCards() {
            dealButton.isHidden = false
        } else {
            dealButton.isHidden = true
        }
    }

    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        let matchedSubviews = setView.subviews.filter {
            if let cardView = $0 as? SetCardView {
                return cardView.card.state == .isMatched
            } else {
                return false
            }
        }
        for case let cardView as SetCardView in matchedSubviews {
            UIView.transition(
                with: cardView,
                duration: 0.25,
                options: [.transitionFlipFromLeft],
                animations: {
                    cardView.card.state = .isDiscarded
                    cardView.setNeedsDisplay()
                },
                completion: { finished in
                    animator.removeAllBehaviors()
                    animator.addBehavior(self.flyawayBehavior)
                    cardView.isHidden = true
                    cardView.setNeedsDisplay()
                }
            )
        }
    }
}
