//
//  ViewController.swift
//  SwiftRingNode
//
//  Created by Derek Soike on 12/05/2018.
//  Copyright (c) 2018 Derek Soike. All rights reserved.
//

import UIKit
import SwiftRingNode

class ViewController: UIViewController, SwiftRingNodeDelegate {
    
    var timer: Timer? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var swiftRingNode: SwiftRingNode!
    
    // MARK: View Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swiftRingNode.delegate = self
        swiftRingNode.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        swiftRingNode.setNeedsDisplay()
        swiftRingNode.isHidden = false
        startTimer()
    }
    
    internal func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            self.swiftRingNode.setNeedsDisplay()
        })
    }
    
    // MARK: SwiftRingNodeDelegate Methods
    
    func didTapSwiftRingNode(_ swiftRingNode: SwiftRingNode) {
        swiftRingNode.title = getRandomTitle()
        swiftRingNode.nodeColor = getRandomColor()
        swiftRingNode.ringColor = getRandomColor()
        swiftRingNode.ringProgress = getRandomProgress()
        swiftRingNode.setNeedsDisplay()
        restartTimer()
    }
    
    internal func getRandomTitle() -> String {
        let titles: [String] = ["Hello", "My Node", "Ring Ring!", "Spin it", "Heyo!"]
        return titles[Int.random(in: 0..<titles.count)]
    }
    
    internal func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.blue, .brown, .cyan, .green, .magenta, .orange, .purple, .red, .yellow]
        return colors[Int.random(in: 0..<colors.count)]
    }
    
    internal func getRandomProgress() -> Double {
        let progressAmounts: [Double] = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
        return progressAmounts[Int.random(in: 0..<progressAmounts.count)]
    }
    
    internal func restartTimer() {
        if let timer = timer { timer.invalidate() }
        startTimer()
    }
    
    func didLongPressSwiftRingNode(_ swiftRingNode: SwiftRingNode) {
        let alert = UIAlertController(title: "Long Press!", message: "You long pressed!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

