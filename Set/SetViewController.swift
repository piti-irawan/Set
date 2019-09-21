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
    
    @IBOutlet weak var setView: SetView!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet private weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.delegate = self
        for card in set.cards {
            let cardView = SetCardView(card: card, frame: CGRect())
            setView.addSubview(cardView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCard(_:)))
            cardView.addGestureRecognizer(tap)
        }
        updateViewFromModel()
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
        for cardView in setView.cardViewsBeingDiscarded {
            if let selectedIndex = setView.subviews.firstIndex(of: cardView), let replacementIndex = set.cards.firstIndex(of: cardView.card) {
                setView.exchangeSubview(at: selectedIndex, withSubviewAt: replacementIndex)
            }
        }
        // Handle cards that are being dealt
        for cardView in setView.cardViewsBeingDealt {
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
        }
        // Handle cards that are being discarded
        for cardView in setView.cardViewsBeingDiscarded {
            cardView.isHidden = false
            cardView.setNeedsDisplay()
            flyawayBehavior.addItem(cardView)
            Timer.scheduledTimer(
                withTimeInterval: 0.5,
                repeats: false,
                block: { [unowned self] timer in
                    self.flyawayBehavior.removeItem(cardView)
                    // frame of scoreLabel (with twice the height) in self.view coordinate space
                    let frame = CGRect(
                        x: self.scoreLabel.frame.origin.x,
                        y: self.scoreLabel.frame.origin.y,
                        width: self.scoreLabel.frame.width,
                        height: 2.0 * self.scoreLabel.frame.height
                    )
                    let snap = UISnapBehavior(item: cardView, snapTo: CGPoint(x: frame.midX, y: frame.midY))
                    snap.damping = 0.5
                    self.animator.addBehavior(snap)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.1,
                        delay: 0,
                        options: [],
                        animations: {
                            cardView.bounds.size = frame.size
                        }
                    )
                }
            )
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
        for cardView in setView.cardViewsBeingDiscarded {
            UIView.transition(
                with: cardView,
                duration: 0.25,
                options: [.transitionFlipFromLeft],
                animations: {
                    cardView.card.state = .isDiscarded
                    cardView.setNeedsDisplay()
                },
                completion: { [unowned self] finished in
                    animator.removeAllBehaviors()
                    animator.addBehavior(self.flyawayBehavior)
                    cardView.isHidden = true
                    cardView.setNeedsDisplay()
                }
            )
        }
    }
}
