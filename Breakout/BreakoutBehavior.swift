//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
  
  //MARK: - Behavior
  //gravity 为 let
  let gravity = UIGravityBehavior()
  
  private lazy var collider: UICollisionBehavior = {
    let c = UICollisionBehavior()
    //要手动设置三边
    c.translatesReferenceBoundsIntoBoundary = false
    return c
  }()
  
  private lazy var ballItemBehavior: UIDynamicItemBehavior = {
    let b = UIDynamicItemBehavior()
    //不可自旋
    b.allowsRotation = false
    //阻力
    b.resistance = 0
    //弹性
    b.elasticity = 1.0
    //摩擦力0
    b.friction = 0
    
    b.action = {
      for item in self.items{
        if !CGRectIntersectsRect(item.frame, self.dynamicAnimator!.referenceView!.bounds){
          //如果已经掉出
          b.removeItem(item)
        }
      }
    }
    return b
  }()
  
  
  
  
  
  //MARK: - property
  var items: [UIView]{
    return self.ballItemBehavior.items.map{$0 as! UIView}
  }
  //隐式解析可选类型 第一次赋值后 可以确定这个可选类型都会有值 不用在判断 这里也不用初始化
  var gravityOn: Bool!
  
  
  
  //封装 collision Behavior需要的delegate
  var collisionDelegate: UICollisionBehaviorDelegate?{
    didSet{
      collider.collisionDelegate = collisionDelegate
    }
  }
  
  //MARK: - method
  
  override init() {
    super.init()
    self.addChildBehavior(gravity)
    self.addChildBehavior(collider)
    self.addChildBehavior(ballItemBehavior)
  }
  
  func addBarrier(path: UIBezierPath, identifier: String){
    collider.removeBoundaryWithIdentifier(identifier)
    collider.addBoundaryWithIdentifier(identifier, forPath: path)
  }
  
  func addBoundary(startPoint: CGPoint, endPoint: CGPoint, identifier: String){
    collider.addBoundaryWithIdentifier(identifier, fromPoint: startPoint, toPoint: endPoint)
  }
  
  func removeBarrier(identifier: String){
    collider.removeBoundaryWithIdentifier(identifier)
  }
  
  func addBall(ball: UIView){
    self.dynamicAnimator?.referenceView?.addSubview(ball)
    //这里的gravity是一个可选类型  不能直接当做bool
    if gravityOn == true{
      gravity.addItem(ball)
    }
    collider.addItem(ball)
    ballItemBehavior.addItem(ball)
  }
  
  func removeBall(ball: UIView){
    gravity.removeItem(ball)
    collider.removeItem(ball)
    ballItemBehavior.removeItem(ball)
    ball.removeFromSuperview()
  }
  //给球一个相反的线速度 然后返回线速度
  func stopBall(ball: UIView) -> CGPoint{
    if self.items.contains(ball){
     let linearVelocity = ballItemBehavior.linearVelocityForItem(ball)
      //设置一个相反方向的线速度
      ballItemBehavior.addLinearVelocity(CGPoint(x: -linearVelocity.x, y: -linearVelocity.y), forItem: ball)
      return linearVelocity
    }
    return CGPointZero
  }
  
  //给球增加一个特定的速度
  func startBall(ball: UIView, veloctity: CGPoint){
    ballItemBehavior.addLinearVelocity(veloctity, forItem: ball)
  }
  
}
