//
//  BreakoutUIViewController.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BreakoutUIViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
  
  
  @IBOutlet weak var gamePanel: UIView!
  
  func gamePanelReload(){
    isStop = true
    //排列球
    ball?.frame.origin = ballOrigin
    //排列paddle
    paddle.frame.origin = paddleOrigin
    
    breakoutAnimator.updateItemUsingCurrentState(ball!)
    breakoutAnimator.updateItemUsingCurrentState(paddle)
  }
  
  //MARK: animator & delegateMethod
  lazy var breakoutAnimator: UIDynamicAnimator = {
    let animator = UIDynamicAnimator(referenceView: self.gamePanel)
    animator.delegate = self
    return animator
  }()
  
  private var isStop = true
  
  //  func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
  //    code
  //  }
  
  let breakoutBehavior = BreakoutBehavior()
  
  //MARK: Delegate
  func collisionBehavior(behavior: UICollisionBehavior, endedContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
    let id = identifier as? NSString as? String
    if id == "gamePanel bottom"{
      //停止动画
      isStop = true
      breakoutBehavior.ballItenBehavior.anchored = true
      //弹出一个alert
      alertGameOver()
      return
    }
    //处理碰撞到砖块
    else if id != nil{
      //是以中心坐标为id的砖块
      //根据id取出UIView
      breakoutBehavior.removeBrickBoundary((id!, brickDic[id!]!))
    }
  }
  
  func alertGameOver(){
    let alert = UIAlertController(title: "Game Over", message: "请重新开始", preferredStyle: .ActionSheet)
    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: {
      [unowned self]
      (action) -> Void in
      self.gamePanelReload()
      self.breakoutBehavior.ballItenBehavior.anchored = false
      }))
    self.presentViewController(alert, animated: true, completion: nil)
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
  
  private func createOneBall() -> BallUIView{
    if let oldBall = ball{
      oldBall.removeFromSuperview()
    }
    let myBall = BallUIView(frame: CGRect(origin: ballOrigin, size: ballSize))
    ball = myBall
    return myBall
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
  
  lazy var paddle: UIView = {
    let p = UIView(frame: CGRect(origin: self.paddleOrigin, size: self.paddleSize))
    p.backgroundColor = UIColor.blackColor()
    return p
  }()
  
  
  //MARK: brick model
  private var brickSize: CGSize{
    return CGSize(width: paddleSize.width/2, height: paddleSize.height)
  }
  
  var numOfBrick: Int = 20 {
    didSet{
      gamePanelReload()
    }
  }
  var numOfRow: Int = 5{
    didSet{
      gamePanelReload()
    }
  }

  //用于存储boundaryId 和 brick的信息
  private var brickDic = [String : Brick]()
  //排列砖块的方法
  func arrangeBricks(numOfBrick: Int){
    //从父View中清空 brick
    for item in brickDic.values{
      item.removeFromSuperview()
    }
    brickDic.removeAll()
    //重新计算
    let brickWidth = brickSize.width
    var brickPoint = CGPointZero
    let horizon = (UIScreen.mainScreen().bounds.width - CGFloat(numOfRow)*brickWidth) / CGFloat(numOfRow + 1)
    var vertical = CGFloat(0)
    var bWidth = CGFloat(0)
    var distance = CGFloat(0)
    var item = 1
    var row = 0
    for i in 1...numOfBrick{
      item = i
      if i%numOfRow == 1{
        //换行
        vertical += ballSize.height
        row += 1
      }
      if item > numOfRow && row > 1{
        item -= ((row - 1) * numOfRow)
      }
      bWidth = CGFloat(item) * horizon
      distance = (CGFloat(2*item-1) * 0.5)*brickWidth
      brickPoint.x = bWidth + distance
      brickPoint.y = vertical
      let brickView = Brick(frame: CGRect(origin: brickPoint, size: brickSize))
      brickView.backgroundColor = paddle.backgroundColor
      //把序号当作key
      brickDic["\(i)"] = brickView
    }

    for brick in brickDic.values{
      gamePanel.addSubview(brick)
    }
    breakoutBehavior.addBricksBoundary(brickDic)
  }
  
  @IBAction func pushBall(sender: UITapGestureRecognizer) {
    if !isStop{
      return
    }
    let leftBottom = CGPoint(x: breakoutAnimator.referenceView!.bounds.minX,y: breakoutAnimator.referenceView!.bounds.maxY)
    let rightBottom = CGPoint(x: breakoutAnimator.referenceView!.bounds.maxX,y: breakoutAnimator.referenceView!.bounds.maxY)
    //不应该放在这里 导致每次点击都执行
    breakoutBehavior.collider.addBoundaryWithIdentifier("gamePanel bottom", fromPoint: leftBottom, toPoint: rightBottom)
    breakoutBehavior.startPush(ball!)
    isStop = false
    
  }
  @IBAction func movePaddle(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Ended:
      fallthrough
    case .Changed:
      let pointInView = sender.translationInView(gamePanel)
      paddle.center.x += pointInView.x
      //不能让paddle 越界
      if paddle.frame.maxX >= gamePanel.bounds.maxX{
        paddle.center = CGPointMake(gamePanel.bounds.maxX - paddle.bounds.width/2, paddle.center.y )
      }
      if paddle.frame.minX <= 0{
        paddle.center = CGPointMake(paddle.bounds.width/2, paddle.center.y)
      }
      //如果不调用这个更新状态的方法 每一次动画器读取的都是最初的状态
      breakoutAnimator.updateItemUsingCurrentState(paddle)
    default:
      break
    }
    sender.setTranslation(CGPointZero, inView: gamePanel)
  }
  
  //MARK: life cycle
  override func viewDidLoad() {
    breakoutAnimator.addBehavior(breakoutBehavior)
    breakoutBehavior.addRect(paddle)
    breakoutBehavior.addBall(createOneBall())
    breakoutBehavior.collider.collisionDelegate = self
    arrangeBricks(numOfBrick)
  }
  
  override func viewWillLayoutSubviews() {
    //横屏幕时发生
  }
  
}
