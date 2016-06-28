//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
  
  //MARK: Ball
  private var ballItems = [BallUIView]()
  func addBall(newBall: BallUIView){
    if !ballItems.contains(newBall){
      ballItems.append(newBall)
      //添加进View
      self.dynamicAnimator?.referenceView?.addSubview(newBall)
      //增加ItemBehavior
      ballItenBehavior.addItem(newBall)
      //增加碰撞
      collider.addItem(newBall)
    }
  }
  func removeBall(oldBall: BallUIView){
    if ballItems.contains(oldBall){
      ballItems.removeAtIndex(ballItems.indexOf(oldBall)!)
      ballItenBehavior.removeItem(oldBall)
      collider.removeItem(oldBall)
     // oldBall.removeFromSuperview()
    }
  }
  //MARK: paddle & rectUIView
  private var rectUIViews = [UIView]()
  func addRect(rect: UIView){
    rectUIViews.append(rect)
    self.dynamicAnimator?.referenceView?.addSubview(rect)
    collider.addItem(rect)
    paddleItemBehavior.addItem(rect)
  }
  func removeRect(rect: UIView){
    if rectUIViews.contains(rect){
      rectUIViews.removeAtIndex(rectUIViews.indexOf(rect)!)
      collider.removeItem(rect)
      paddleItemBehavior.removeItem(rect)
      rect.removeFromSuperview()
    }
  }
  
  //MARK: collisionbehavior
  lazy var collider: UICollisionBehavior = {
    let collider = UICollisionBehavior()
    collider.translatesReferenceBoundsIntoBoundary = true
    //在下边界增加一个boundary 如果碰到 就触发
    collider.collisionMode = .Everything
    
    return collider
  }()
  func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
    
  }
  
  
  //MARK: ballItenBehavior
  lazy var ballItenBehavior: UIDynamicItemBehavior = {
    var ballBehavior = UIDynamicItemBehavior()
    //允许自转会使能量耗损
    ballBehavior.allowsRotation = false
    //弹性百分百
    ballBehavior.elasticity = 1.0
    //摩擦力为零
    ballBehavior.friction = 0
    ballBehavior.resistance = 0
    return ballBehavior
  }()
  
  //MARK: paddleItemBehavior
  lazy var paddleItemBehavior: UIDynamicItemBehavior = {
    var pib = UIDynamicItemBehavior()
    pib.allowsRotation = false
    pib.elasticity = 1.0
    pib.friction = 0
    pib.resistance = 0
    pib.anchored = true
    return pib
  }()
  
  //MARK: brickItemBehavior
   var brickItemBehavior: UIDynamicItemBehavior {
    let bib = UIDynamicItemBehavior()
    
    bib.elasticity = 1.0
    bib.friction = 0
    bib.resistance = 0
    bib.allowsRotation = false
    bib.anchored = true
    return bib
  }
  //MARK: pushBehavior
 var pushBehavior: UIPushBehavior {
    let pb = UIPushBehavior(items: self.ballItems, mode: .Instantaneous)
    pb.setAngle(CGFloat(arc4random()),magnitude: 1)
    pb.action = { [unowned pb] in    
        pb.dynamicAnimator!.removeBehavior(pb)
    }
    return pb
  }
  
  //MARK: init
  override init() {
    super.init()
    self.addChildBehavior(collider)
    self.addChildBehavior(ballItenBehavior)
    self.addChildBehavior(paddleItemBehavior)
    self.addChildBehavior(brickItemBehavior)
  }
  //增加障碍
  func addBarrierByIdentifier(path: UIBezierPath, name: String){
    collider.removeBoundaryWithIdentifier(name)
    collider.addBoundaryWithIdentifier(name, forPath: path)
  }
  
  func addBricksBoundary(bricks: [String:Brick]){
    for key in bricks.keys{
      brickItemBehavior.addItem(bricks[key]!)
      
      //collider.addItem(brick)
      //根据 砖块的rect 来添加 碰撞边界  用砖块的中心来做id
      //砖块的消失 与 碰撞边界的消失要同步
      collider.addBoundaryWithIdentifier(key, forPath: UIBezierPath(rect: bricks[key]!.frame))
    }
  }
  
  func removeBrickBoundary(brick: (String, Brick)){
    //删除边界
    collider.removeBoundaryWithIdentifier("\(brick.0)")
    //删除图像
    brick.1.removeFromSuperview()
  }
  
  func startPush(ball: UIView){
    self.addChildBehavior(pushBehavior)
  }
}
