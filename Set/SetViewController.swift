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
    
    @IBOutlet weak var setView: SetView! {
        didSet {
            for card in set.cards {
                let cardView = SetCardView(card: card, frame: CGRect())
                setView.addSubview(cardView)
                let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCard(_:)))
                cardView.addGestureRecognizer(tap)
            }
        }
    }
    
    @IBOutlet weak var dealButton: UIButton!
    
    @IBOutlet private weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
        updateSetView()
    }
    
    @objc func chooseCard(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended && set.cardsBeingDealt.count == 0 && set.cardsBeingDiscarded.count == 0 {
            if let cardView = sender.view as? SetCardView {
                set.chooseCard(cardView.card)
                updateViewFromModel()
                
            }
        }
    }
    
    @IBAction private func touchDealButton(_ sender: UIButton) {
        if set.canDealThreeMoreCards() && set.cardsBeingDealt.count == 0 && set.cardsBeingDiscarded.count == 0 {
            set.dealThreeMoreCards()
            updateViewFromModel()
        }
    }
    
    private func updateViewFromModel() {
        updateSetView()
        updateDealButton()
        updateScoreLabel()
    }
    
    private func updateSetView() {
        // Sync setView.subviews to set.cards to preserve card order
        var cardViews = setView.subviews
        for view in setView.subviews {
            view.removeFromSuperview()
        }
        for card in set.cards {
            for case let (index, cardView) as (Int, SetCardView) in cardViews.enumerated() {
                if cardView.card == card {
                    setView.addSubview(cardView)
                    switch cardView.card.state {
                    case .isBeingDealt:
                        // frame of dealButton (with twice the height) in setView coordinate space
                        let frame = CGRect(
                            x: dealButton.frame.origin.x - setView.frame.origin.x,
                            y: dealButton.frame.origin.y - setView.frame.origin.y,
                            width: dealButton.frame.width,
                            height: 2.0 * dealButton.frame.height
                        )
                        cardView.frame = frame
                        cardView.isHidden = false
                        cardView.setNeedsDisplay()
                    case .isBeingDiscarded:
                        cardView.removeFromSuperview()
                        let newCardView = SetCardView(card: cardView.card, frame: cardView.frame)
                        setView.addSubview(newCardView)
                        newCardView.isHidden = false
                        flyawayBehavior.addItem(newCardView)
                        Timer.scheduledTimer(
                            withTimeInterval: 0.5,
                            repeats: false,
                            block: { timer in
                                self.flyawayBehavior.removeItem(newCardView)
                                // frame of scoreLabel (with twice the height) in self.view coordinate space
                                let frame = CGRect(
                                    x: self.scoreLabel.frame.origin.x,
                                    y: self.scoreLabel.frame.origin.y,
                                    width: self.scoreLabel.frame.width,
                                    height: 2.0 * self.scoreLabel.frame.height
                                )
                                let snap = UISnapBehavior(item: newCardView, snapTo: CGPoint(x: frame.midX, y: frame.midY))
                                snap.damping = 0.5
                                self.animator.addBehavior(snap)
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.1,
                                    delay: 0,
                                    options: [],
                                    animations: {
                                        newCardView.bounds.size = frame.size
                                    }
                                )
                            }
                        )
                    case .isInDeck, .isDiscarded:
                        cardView.isHidden = true
                    default:
                        cardView.isHidden = false
                    }
                    cardViews.remove(at: index)
                    break
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

    private func updateScoreLabel() {
        if set.score == 1 {
            scoreLabel.text = "1 Set"
        } else {
            scoreLabel.text = "\(set.score) Sets"
        }
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        let matchedSubviews = setView.subviews.filter {
            if let cardView = $0 as? SetCardView {
                return cardView.card.state == .isBeingDiscarded
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
