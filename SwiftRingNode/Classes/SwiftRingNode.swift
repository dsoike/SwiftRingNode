//
//  SwiftRingNode.swift
//  SwiftRingNode
//
//  Created by Derek Soike on 12/05/2018.
//  Copyright (c) 2018 Derek Soike. All rights reserved.
//

import UIKit

public protocol SwiftRingNodeDelegate {
    func didTapSwiftRingNode(_ swiftRingNode: SwiftRingNode)
    func didLongPressSwiftRingNode(_ swiftRingNode: SwiftRingNode)
}

@IBDesignable
public class SwiftRingNode: UIView {
    
    public var delegate: SwiftRingNodeDelegate? = nil
    public var label: String? = nil
    
    internal var firstDraw: Bool = true // first draw is for storyboard display, subsequent draws involve animation
    internal var ringShapeLayer: CAShapeLayer? = nil
    
    @IBInspectable public var title: String = "Title"
    @IBInspectable public var titleColor: UIColor = UIColor.white
    @IBInspectable public var titleFontName: String = UIFont.boldSystemFont(ofSize: 0).fontName
    @IBInspectable public var titleFontSize: CGFloat = 20
    @IBInspectable public var titleNumberOfLines: Int = 0
    @IBInspectable public var nodeColor: UIColor = UIColor.init(red: 99/255, green: 116/255, blue: 127/255, alpha: 1)
    @IBInspectable public var ringProgress: Double = 70
    @IBInspectable public var ringColor: UIColor = UIColor.init(red: 122/255, green: 202/255, blue: 255/255, alpha: 1)
    @IBInspectable public var ringThickness: CGFloat = 40
    @IBInspectable public var ringAnimationSpeed: CGFloat = 1
    
    // ----------------------------------------------------------------------------------------------------
    // MARK: View Methods
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }
    
    override public func draw(_ rect: CGRect) {
        removeSubviewsAndSublayers()
        drawNode(inRect: rect)
        drawRing(inRect: rect)
        setupGestureRecognizers()
    }
    
    func removeSubviewsAndSublayers() {
        self.subviews.forEach({$0.removeFromSuperview()})
        if let sublayers = self.layer.sublayers {
            sublayers.forEach({ $0.removeFromSuperlayer() })
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    // MARK: Draw Node Methods
    
    internal func drawNode(inRect rect: CGRect) {
        let nodeCenterBounds = getSquare(centeredInRect: rect, withMargin: ringThickness / 2)
        let titleLabelFrame = getSquare(centeredInRect: rect, withMargin: ringThickness * 1.25)
        drawNodeCenter(inSquare: nodeCenterBounds)
        drawNodeTitle(withFrame: titleLabelFrame)
    }
    
    internal func drawNodeCenter(inSquare square: CGRect) {
        let path = UIBezierPath(ovalIn: square)
        nodeColor.setFill()
        path.fill()
    }
    
    internal func drawNodeTitle(withFrame frame: CGRect) {
        let label = UILabel(frame: frame)
        label.text = title
        label.textColor = titleColor
        label.font = UIFont(name: titleFontName, size: titleFontSize)
        label.numberOfLines = titleNumberOfLines
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        self.addSubview(label)
    }
    
    // ----------------------------------------------------------------------------------------------------
    // MARK: Draw Ring Methods
    
    internal func drawRing(inRect rect: CGRect) {
        let ringBounds = getSquare(centeredInRect: rect, withMargin: 0)
        drawRing(inSquare: ringBounds)
    }
    
    internal func drawRing(inSquare square: CGRect) {
        if firstDraw {
            drawRingDummy(inSquare: square)
            firstDraw = false
        } else {
            drawRingActual(inSquare: square)
        }
    }
    
    internal func drawRingDummy(inSquare square: CGRect) { // for storyboard
        let path = getRingPath(inSquare: square)
        path.lineWidth = ringThickness
        ringColor.setStroke()
        path.stroke()
    }
    
    internal func drawRingActual(inSquare square: CGRect) {
        let path = getRingPath(inSquare: square)
        let animations = getRingAnimations()
        let layer = getRingLayer(forPath: path.cgPath, withAnimations: animations)
        displayRing(layer)
    }
    
    internal func getRingPath(inSquare square: CGRect) -> UIBezierPath {
        let center = getCenter(ofRect: square)
        let radius: CGFloat = max(square.width, square.height)
        let startAngle: CGFloat = .pi / 2
        let endAngle: CGFloat = startAngle + 2 * .pi * CGFloat(ringProgress) / 100
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius/2 - ringThickness/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path
    }
    
    internal func getRingAnimations() -> CAAnimationGroup {
        
        let pathStartPointAnimation = CABasicAnimation(keyPath: "strokeStart")
        pathStartPointAnimation.fromValue = 0
        pathStartPointAnimation.toValue = 0
        pathStartPointAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let pathEndPointAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathEndPointAnimation.fromValue = 0
        pathEndPointAnimation.toValue = 1.0
        pathEndPointAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let animation = CAAnimationGroup()
        animation.animations = [pathStartPointAnimation, pathEndPointAnimation]
        animation.duration = 1 * ringProgress / 100 * Double(ringAnimationSpeed) // 1 sec for full ring animation
        return animation
    }
    
    internal func getRingLayer(forPath path: CGPath, withAnimations animations: CAAnimationGroup?) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path
        layer.backgroundColor = UIColor.clear.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = ringColor.cgColor
        layer.lineWidth = ringThickness
        if let animations = animations {
            layer.add(animations, forKey: "RingAnimation")
        }
        return layer
    }
    
    internal func displayRing(_ layer: CAShapeLayer) {
        if let existingLayer = ringShapeLayer {
            existingLayer.removeFromSuperlayer()
        }
        self.ringShapeLayer = layer
        self.layer.addSublayer(layer)
    }
    
    // ----------------------------------------------------------------------------------------------------
    // MARK: Gesture Methods
    
    internal func setupGestureRecognizers() {
        let touchFrame = getSquare(centeredInRect: self.bounds, withMargin: 0)
        let touchView = UIView(frame: touchFrame)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapRingNode(_:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPressRingNode(_:)))
        touchView.addGestureRecognizer(tapGesture)
        touchView.addGestureRecognizer(longPressGesture)
        touchView.layer.zPosition = 1000
        self.addSubview(touchView)
    }
    
    @objc internal func didTapRingNode(_ sender: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.didTapSwiftRingNode(self)
        }
    }
    
    @objc internal func didLongPressRingNode(_ sender: UILongPressGestureRecognizer) {
        if let delegate = delegate {
            delegate.didLongPressSwiftRingNode(self)
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    // MARK: Helper Methods
    
    internal func getSquare(centeredInRect rect: CGRect, withMargin margin: CGFloat) -> CGRect {
        let minDim: CGFloat = min(rect.width, rect.height)
        let side: CGFloat = minDim - margin * 2
        let center: CGPoint = getCenter(ofRect: rect)
        let originX: CGFloat = center.x - side / 2
        let originY: CGFloat = center.y - side / 2
        let origin: CGPoint = CGPoint(x: originX, y: originY)
        let size: CGSize = CGSize(width: side, height: side)
        return CGRect(origin: origin, size: size)
    }
    
    internal func getCenter(ofRect rect: CGRect) -> CGPoint {
        let centerX: CGFloat = (rect.maxX - rect.minX) / 2 + rect.minX
        let centerY: CGFloat = (rect.maxY - rect.minY) / 2 + rect.minY
        return CGPoint(x: centerX, y: centerY)
    }
    
}
