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
    
    @IBOutlet weak var swiftRingNode: SwiftRingNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swiftRingNode.delegate = self
        swiftRingNode.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
        
        let _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            print("here")
            self.swiftRingNode.isHidden = false
            self.swiftRingNode.setNeedsDisplay()
            self.swiftRingNode.label = "Hello"
        })
    }
    
    func didTapSwiftRingNode(_ swiftRingNode: SwiftRingNode) {
        swiftRingNode.title = getRandomTitle()
        swiftRingNode.setNeedsDisplay()
    }
    
    func getRandomTitle() -> String {
        let titles: [String] = [
            "My Node",
            "Ring Ring!",
            "Spin it",
            "Heyo!"
        ]
        return titles[Int.random(in: 0..<titles.count)]
    }
}

