//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {

  
  
  //MARK: collisionbehavior
  lazy var collider: UICollisionBehavior = {
    let collider = UICollisionBehavior()
    collider.translatesReferenceBoundsIntoBoundary = true
    collider.collisionMode = .Everything
    return collider
  }()
  
  
  lazy var ballItenBehavior: UIDynamicItemBehavior = {
    var ballBehavior = UIDynamicItemBehavior()
    ballBehavior.allowsRotation = true
    //弹性百分百
    ballBehavior.elasticity = 1.0
    //摩擦力为零
    ballBehavior.friction = 0
    return ballBehavior
  }()
}
