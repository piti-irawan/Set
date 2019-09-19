//
//  SetCardView.swift
//  Set and Concentration
//
//  Created by Piti Irawan on 2019/09/17.
//  Copyright © 2019 Piti Irawan. All rights reserved.
//

import UIKit

class SetCardView: UIView {
    static let cardAspectRatio = 0.625
    static let cornerRadiusToBoundsHeight: CGFloat = 0.06
    static let lineWidthToBoundsHeight: CGFloat = 0.06
    static let halfRectHeightToBoundsHeight: CGFloat = 0.06
    private var cornerRadius: CGFloat {
        return bounds.size.height * SetCardView.cornerRadiusToBoundsHeight
    }
    private var lineWidth: CGFloat {
        return bounds.size.height * SetCardView.lineWidthToBoundsHeight / 4.0
    }
    private var borderWidth: CGFloat {
        return bounds.size.height * SetCardView.lineWidthToBoundsHeight
    }
    private var halfRectHeight: CGFloat {
        return bounds.size.height * SetCardView.halfRectHeightToBoundsHeight
    }
    let card: SetCard
    
    init(card: SetCard, frame: CGRect) {
        self.card = card
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        switch card.state {
        case .isInDeck: UIColor.darkGray.setFill()
        case .isBeingDealt: UIColor.darkGray.setFill()
        case .isInPlay: UIColor.white.setFill()
        case .isSelected: UIColor.white.setFill()
        case .isMismatched: UIColor.orange.setFill()
        case .isMatched: UIColor.white.setFill()
        case .isDiscarded: UIColor.darkGray.setFill()
        }
        roundedRect.fill()
        if card.state == .isSelected || card.state == .isMismatched || card.state == .isMatched {
            roundedRect.lineWidth = borderWidth
            UIColor.black.setStroke()
            roundedRect.stroke()
        }
        
        if card.state == .isInPlay || card.state == .isSelected || card.state == .isMismatched || card.state == .isMatched {
            var path = UIBezierPath()
            var transforms = [CGAffineTransform]()
            let pathRect = CGRect(x: bounds.midX - 2.0 * halfRectHeight, y: bounds.midY - halfRectHeight, width: 4.0 * halfRectHeight, height: 2.0 * halfRectHeight)
            switch card.shape {
            case .diamond:
                path = diamondPath(in: pathRect)
            case .squiggle:
                path = squigglePath(in: pathRect)
            case .oval:
                path = ovalPath(in: pathRect)
            }
            switch card.number {
            case .one:
                transforms = [CGAffineTransform.identity]
            case .two:
                let transform1 = CGAffineTransform(translationX: 0.0, y: -2.0 * halfRectHeight)
                let transform2 = CGAffineTransform(translationX: 0.0, y: 2.0 * halfRectHeight)
                transforms = [transform1, transform2]
            case .three:
                let transform1 = CGAffineTransform(translationX: 0.0, y: -4.0 * halfRectHeight)
                let transform2 = CGAffineTransform.identity
                let transform3 = CGAffineTransform(translationX: 0.0, y: 4.0 * halfRectHeight)
                transforms = [transform1, transform2, transform3]
            }
            switch card.color {
            case .red:
                UIColor.red.setStroke()
            case .green:
                UIColor.green.setStroke()
            case .purple:
                UIColor.purple.setStroke()
            }
            switch card.shading {
            case .solid:
                switch card.color {
                case .red:
                    UIColor.red.setFill()
                    UIColor.red.setStroke()
                case .green:
                    UIColor.green.setFill()
                    UIColor.green.setStroke()
                case .purple:
                    UIColor.purple.setFill()
                    UIColor.purple.setStroke()
                }
                for transform in transforms {
                    if let currentPath = path.copy() as? UIBezierPath {
                        currentPath.apply(transform)
                        currentPath.fill()
                        currentPath.lineWidth = lineWidth
                        currentPath.stroke()
                    }
                }
            case .striped:
                switch card.color {
                case .red:
                    UIColor.red.setStroke()
                case .green:
                    UIColor.green.setStroke()
                case .purple:
                    UIColor.purple.setStroke()
                }
                for transform in transforms {
                    if let currentPath = path.copy() as? UIBezierPath {
                        currentPath.apply(transform)
                        if let context = UIGraphicsGetCurrentContext() {
                            context.saveGState()
                            currentPath.addClip()
                            for x in stride(from: pathRect.minX, to: pathRect.maxX, by: 2.0 * lineWidth) {
                                let stripe = UIBezierPath()
                                stripe.move(to: CGPoint(x: x, y: pathRect.minY))
                                stripe.addLine(to: CGPoint(x: x, y: pathRect.maxY))
                                stripe.apply(transform)
                                stripe.lineWidth = lineWidth
                                stripe.stroke()
                            }
                            context.restoreGState()
                        }
                        currentPath.lineWidth = lineWidth
                        currentPath.stroke()
                    }
                }
            case .open:
                switch card.color {
                case .red:
                    UIColor.red.setStroke()
                case .green:
                    UIColor.green.setStroke()
                case .purple:
                    UIColor.purple.setStroke()
                }
                for transform in transforms {
                    if let currentPath = path.copy() as? UIBezierPath {
                        currentPath.apply(transform)
                        currentPath.lineWidth = lineWidth
                        currentPath.stroke()
                    }
                }
            }
        }
    }
    
    private func diamondPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.close()
        return path
    }
    
    private func squigglePath(in rect: CGRect) -> UIBezierPath {
        // From https://github.com/rubenbaca/cs193p_iOS11/blob/master/Set/Set/CardView.swift
        
        let path = UIBezierPath()
        var point, cp1, cp2: CGPoint
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.05, y: rect.origin.y + rect.size.height*0.40)
        path.move(to: point)
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.35, y: rect.origin.y + rect.size.height*0.25)
        cp1 = CGPoint(x: rect.origin.x + rect.size.width*0.09, y: rect.origin.y + rect.size.height*0.15)
        cp2 = CGPoint(x: rect.origin.x + rect.size.width*0.18, y: rect.origin.y + rect.size.height*0.10)
        path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.75, y: rect.origin.y + rect.size.height*0.30)
        cp1 = CGPoint(x: rect.origin.x + rect.size.width*0.40, y: rect.origin.y + rect.size.height*0.30)
        cp2 = CGPoint(x: rect.origin.x + rect.size.width*0.60, y: rect.origin.y + rect.size.height*0.45)
        path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.97, y: rect.origin.y + rect.size.height*0.35)
        cp1 = CGPoint(x: rect.origin.x + rect.size.width*0.87, y: rect.origin.y + rect.size.height*0.15)
        cp2 = CGPoint(x: rect.origin.x + rect.size.width*0.98, y: rect.origin.y + rect.size.height*0.00)
        path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.45, y: rect.origin.y + rect.size.height*0.85)
        cp1 = CGPoint(x: rect.origin.x + rect.size.width*0.95, y: rect.origin.y + rect.size.height*1.10)
        cp2 = CGPoint(x: rect.origin.x + rect.size.width*0.50, y: rect.origin.y + rect.size.height*0.95)
        path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.25, y: rect.origin.y + rect.size.height*0.85)
        cp1 = CGPoint(x: rect.origin.x + rect.size.width*0.40, y: rect.origin.y + rect.size.height*0.80)
        cp2 = CGPoint(x: rect.origin.x + rect.size.width*0.35, y: rect.origin.y + rect.size.height*0.75)
        path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
        
        point = CGPoint(x: rect.origin.x + rect.size.width*0.05, y: rect.origin.y + rect.size.height*0.40)
        cp1 = CGPoint(x: rect.origin.x + rect.size.width*0.00, y: rect.origin.y + rect.size.height*1.10)
        cp2 = CGPoint(x: rect.origin.x + rect.size.width*0.005, y: rect.origin.y + rect.size.height*0.60)
        path.addCurve(to: point, controlPoint1: cp1, controlPoint2: cp2)
        
        return path
    }
    
    private func ovalPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(ovalIn: rect)
        return path
    }
}
