//
//  FlyawayBehavior.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/18.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class FlyawayBehavior: UIDynamicBehavior {
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    private lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi / 2.0) * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi - (CGFloat.pi / 2.0) * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
            case let (x, y) where x < center.x && y > center.y:
                push.angle = -(CGFloat.pi / 2.0) * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + (CGFloat.pi / 2.0) * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
            default:
                push.angle = (2.0 * CGFloat.pi) * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
            }
        }
        push.magnitude = CGFloat(1.0) + CGFloat(2.0) * (CGFloat(arc4random_uniform(UInt32.max)) / CGFloat(UInt32.max))
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
}
