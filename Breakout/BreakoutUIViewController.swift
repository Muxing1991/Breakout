//
//  BreakoutUIViewController.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BreakoutUIViewController: UIViewController, UICollisionBehaviorDelegate {
  
  //MARK: - Outlets
  @IBOutlet weak var gamePanel: UIView!
  
  //MARK: - Property
  
  lazy var breakoutAnimator: UIDynamicAnimator = {
    let animaotr = UIDynamicAnimator(referenceView: self.gamePanel)
    return animaotr
  }()
  
  let breakoutBehavior = BreakoutBehavior()
  
  //隐式解析可选类型 这里不用初始化 但是保证在第一次初始化后 会一直都有值
  private var pushMagnitude: CGFloat!
  
  
  
  
  //MARK: - Methods
  
  private func pushBall(ball: UIView, ballArea: CGFloat){
    let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
    pushBehavior.magnitude = pushMagnitude * ballArea / 1000
    pushBehavior.angle = CGFloat(randomAngle())
    //清理这个UIPushBehavior
    pushBehavior.action = {
      [unowned pushBehavior] in
      pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
    }
    breakoutAnimator.addBehavior(pushBehavior)
  }
  
  
  
  
  private func randomAngle() -> Double {
    return 2 * M_PI * Double(arc4random() / UInt32.max)
  }
  
  
  //MARK: - Model Ball
  
  private var ballSize: CGSize{
    let size = Constants.relBallSize * min(gamePanel.bounds.width, gamePanel.bounds.height)
    return CGSize(width: size, height: size)
  }
  
  private var ballVelocity = [CGPoint]()
  
  private class BallView: UIView{
    private override var collisionBoundsType: UIDynamicItemCollisionBoundsType{
      //重写碰撞边界类型
      return .Ellipse
    }
    override init(frame: CGRect) {
      super.init(frame: frame)
      self.backgroundColor = Constants.ballColor
      //设为圆形
      self.layer.cornerRadius = self.bounds.width / 2
      self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
  
  private func startBall(){
    if breakoutBehavior.items.count == 0{
      //没有球 新建一个
      let ball = BallUIView(frame: CGRect(origin: CGPointZero, size: ballSize))
      placedBall(ball)
      breakoutBehavior.addBall(ball)
      
      //可以开始弹射了
      //计算球的面积
      let ballArea = CGFloat(M_PI) * (ballSize.width/2) * (ballSize.width/2)
      pushBall(ball, ballArea: ballArea)
      
    }
    else{
      //球已经存在了
      //先让球停止 然后再push
      let ball = breakoutBehavior.items.last!
      breakoutBehavior.stopBall(ball)
      //重新push
      let ballArea = CGFloat(M_PI) * (ballSize.width/2) * (ballSize.width/2)
      pushBall(ball, ballArea: ballArea)

    }
  }
  
  private func placedBall(ball: BallUIView){
    //TODO: 这里要摆放球
  }
  
  //MARK: - Barrier & Paddle
  
  //添加三边的边界
  private func setThreeSideBarrier(){
    let topLeft = CGPoint(x: 0, y: 0)
    let topRight = CGPoint(x: gamePanel.bounds.width, y: 0)
    let leftBottom = CGPoint(x: 0, y: gamePanel.bounds.height)
    let rightBottom = CGPoint(x: gamePanel.bounds.width, y: gamePanel.bounds.height)
    breakoutBehavior.addBoundary(topLeft, endPoint: topRight, identifier: PathIdentifier.topBarrier)
    breakoutBehavior.addBoundary(topLeft, endPoint: leftBottom , identifier: PathIdentifier.leftBarrier)
    breakoutBehavior.addBoundary(topRight, endPoint: rightBottom, identifier: PathIdentifier.rightBarrier)
    
  }
  //隐式解析可选类型 在初始化游戏时决定 并且可以设置
  private var relPaddleWidth: CGFloat!{
    didSet{
      if !gameViewSizeChange && oldValue != relPaddleWidth{
        resetPaddle()
      }
    }
  }
  
  private var paddleSize: CGSize{
    //按照比例 以宽度来设置
    let width = relPaddleWidth * gamePanel.bounds.width
    return CGSize(width: width, height: Constants.paddleHeight)
  }
  
  private lazy var paddle: UIView = {
    let p = UIView(frame: CGRect(origin: CGPointZero, size: self.paddleSize))
    p.backgroundColor = UIColor.blackColor()
    self.gamePanel.addSubview(p)
    return p
  }()
  
  private func resetPaddle(){
    
  }
  
  //MARK: - Lifecycle
  
  private var gameViewSizeChange = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    breakoutAnimator.addBehavior(breakoutBehavior)
    
    //设置下  背景
    if let backgroundPic = UIImage(named: "box"){
      //这里设置的 backgroundColor
      gamePanel.backgroundColor  = UIColor(patternImage: backgroundPic)
    }
  }
  
  //MARK: - Delegate
  
  func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
    if let bricksId = Int((identifier as? String)!){
      
    }
  }
  
}


private struct Constants{
  static let relBallSize = CGFloat(0.1)
  static let ballColor = UIColor.blackColor()
  
  static let paddleHeight = CGFloat(10)
  static let paddleYOffSet = CGFloat(50)
  
  static let brickHeight = CGFloat(8)
  static let brickSeparation = CGFloat(4)
  static let brickYOffSet = CGFloat(70)
}

private struct PathIdentifier{
  static let topBarrier = "Top Barrier"
  static let leftBarrier = "Left Barrier"
  static let rightBarrier = "Right Barrier"
  
  static let paddleIdentiifer = "Paddle"
}
