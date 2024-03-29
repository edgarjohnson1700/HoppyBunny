//
//  Obstacle.swift
//  HoppyBunny
//
//  Created by Edgar Johnson on 7/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Obstacle : CCNode {
    weak var topCarrot : CCNode!
    weak var bottomCarrot : CCNode!
    
    let topCarrotMinimumPositionY : CGFloat = 128
    let bottomCarrotMaximumPositionY : CGFloat = 440
    let carrotDistance : CGFloat = 142
    
    func setupRandomPosition() {
        let randomPrecision : UInt32 = 100
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision)
        let range = bottomCarrotMaximumPositionY - carrotDistance - topCarrotMinimumPositionY
        topCarrot.position = ccp(topCarrot.position.x, topCarrotMinimumPositionY + (random * range));
        bottomCarrot.position = ccp(bottomCarrot.position.x, topCarrot.position.y + carrotDistance);
    }
    
    func didLoadFromCCB() {
        topCarrot.physicsBody.sensor = true
        bottomCarrot.physicsBody.sensor = true
    }
}