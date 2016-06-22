//
//  BreakoutUIViewController.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BreakoutUIViewController: UIViewController, UIDynamicAnimatorDelegate {
  
  @IBOutlet weak var gamePanel: UIView!
  
  //MARK: animator & delegateMethod
  lazy var breakoutAnimator: UIDynamicAnimator = {
    let animator = UIDynamicAnimator(referenceView: self.gamePanel)
    animator.delegate = self
    return animator
  }()
  
  func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
    <#code#>
  }
  
  
  
  //MARK: ball model
  private var ballSize: CGSize{
    let size = UIScreen.mainScreen().bounds.width / 10
    return CGSize(width: size, height: size)
  }
  
  private var ballOrigin: CGPoint{
    let x = UIScreen.mainScreen().bounds.width/2 - ballSize.width/2
    let y = UIScreen.mainScreen().bounds.height - ballSize.height - paddleSize.height
    return CGPoint(x: x, y: y)
  }
  var ball: BallUIView?
  
  private func disPlayBall(){
    if let oldBall = ball{
      oldBall.removeFromSuperview()
    }
    ball = BallUIView(frame: CGRect(origin: ballOrigin, size: ballSize))
    gamePanel.addSubview(ball!)
  }
  
  //MARK: paddle model
  
  private var paddleSize: CGSize{
    let width = ballSize.width*2
    let height = ballSize.height/5
    return CGSize(width: width, height: height)
  }
  
  private var paddleOrigin: CGPoint{
    let x = UIScreen.mainScreen().bounds.width/2 - paddleSize.width/2
    let y = UIScreen.mainScreen().bounds.height - paddleSize.height
    return CGPoint(x: x, y: y)
  }
  
  var paddle: UIView?
  
  private func displayPaddle(){
    if let oldPaddle = paddle{
      oldPaddle.removeFromSuperview()
    }
    paddle = UIView(frame: CGRect(origin: paddleOrigin, size: paddleSize))
    paddle?.backgroundColor = UIColor.blackColor()
    gamePanel.addSubview(paddle!)
  }
  
  
  
  //MARK: life cycle
  override func viewDidLoad() {
    disPlayBall()
    displayPaddle()
  }
  
  override func viewWillLayoutSubviews() {
    //横屏幕时发生
  }
  
}
