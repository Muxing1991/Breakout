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
  
  //MARK: - Gesture
  
  @IBAction func ball(sender: UITapGestureRecognizer) {
    startBall()
  }
  
  
  @IBAction func panPaddle(sender: UIPanGestureRecognizer) {
    switch sender.state {
    case .Ended:
      fallthrough
    //即使是停止 也要移动
    case .Changed:
      let transX = sender.translationInView(gamePanel).x
      if transX != 0{
        paddleXPosition += transX
      }
      sender.setTranslation(CGPointZero, inView: gamePanel)
    default:
      break
    }
  }
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
    pushBehavior.magnitude = pushMagnitude * ballArea / 10000.0
    pushBehavior.angle = CGFloat(randomAngle())
    //清理这个UIPushBehavior
    pushBehavior.action = {
      [unowned pushBehavior] in
      pushBehavior.dynamicAnimator!.removeBehavior(pushBehavior)
    }
    breakoutAnimator.addBehavior(pushBehavior)
  }
  
  
  
  
  private func randomAngle() -> Double {
    //这两个是一个样的
    //这里如果不先转换成double arc4random / max 就一直会是 0  Double(0) = 0
    return 2 * M_PI * Double(arc4random()) / Double(UINT32_MAX)
   
  }
  
  
  //MARK: - Model Ball
  
  private var ballSize: CGSize{
    let size = Constants.relBallSize * min(gamePanel.bounds.size.width, gamePanel.bounds.size.height)
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
      let points = ballSize.width/2.0
      let ballArea = CGFloat(M_PI) * points * points
      pushBall(ball, ballArea: ballArea)
      
    }
    else{
      //球已经存在了
      //先让球停止 然后再push
      let ball = breakoutBehavior.items.last!
      breakoutBehavior.stopBall(ball)
      //重新push
      let points = ballSize.width/2.0
      let ballArea = CGFloat(M_PI) * points * points
      pushBall(ball, ballArea: ballArea)
      
    }
  }
  
  private func placedBall(ball: BallUIView){
    ball.center = paddle.center
    ball.center.y -= (ballSize.height + paddleSize.height)/2
    
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
    let width = relPaddleWidth * gamePanel.bounds.size.width
    return CGSize(width: width, height: Constants.paddleHeight)
  }
  
  private lazy var paddle: UIView = {
    let p = UIView(frame: CGRect(origin: CGPointZero, size: self.paddleSize))
    p.backgroundColor = UIColor.blackColor()
    self.gamePanel.addSubview(p)
    return p
  }()
  
  private var paddleXPosition: CGFloat{
    get{
      return paddle.frame.origin.x
    }
    set{
      paddle.frame.origin.x = min(max(newValue, 0), gamePanel.bounds.maxX - paddleSize.width)
      //更新边界
      let arg1 = UIBezierPath(ovalInRect: paddle.frame)
      breakoutBehavior.addBarrier(arg1, identifier: PathIdentifier.paddleIdentiifer)
    }
  }
  
  
  private func resetPaddle(){
    //重新利用计算属性paddleSize 来设置大小
    paddle.frame.size = paddleSize
    //重新设置位置 之前的origin是设置为 CGPointZero
    let x = gamePanel.bounds.midX
    let y = UIScreen.mainScreen().bounds.height - paddleSize.height/2 - Constants.paddleYOffSet
    paddle.center = CGPointMake(x, y)
    //增加边界
    let arg1 = UIBezierPath(ovalInRect: paddle.frame)
    breakoutBehavior.addBarrier(arg1, identifier: PathIdentifier.paddleIdentiifer)
  }
  
  
  //MARK: - Bricks
  
  private var brickRows: Int!{
    //隐式解析可选类型 不设置默认值
    didSet{
      if !gameViewSizeChange && oldValue != brickRows{
        generateBricks()
      }
    }
  }
  
  private var brickCols: Int!{
    didSet{
      if !gameViewSizeChange && oldValue != brickRows{
        generateBricks()
      }
    }
  }
  
  private var brickSize: CGSize{
    let width = (gamePanel.bounds.width - Constants.brickSeparation*(CGFloat(brickCols)+1))/CGFloat(brickCols)
    return CGSizeMake(width, Constants.brickHeight)
  }
  
  private var bricks = [UIView]()
  
  private func generateBricks(){
    removeBricks()
    let top = gamePanel.bounds.minY + Constants.brickSeparation
    let middle = Constants.brickYOffSet
    let midPoint = brickRows/2
    if midPoint != 0 {
      let origin = CGPoint(x: Constants.brickSeparation, y: top)
      addBricks(origin, startRow: 0, endRow: midPoint - 1)
    }
    
    let origin = CGPoint(x: Constants.brickSeparation, y: top + middle + CGFloat(midPoint)*(Constants.brickHeight + Constants.brickSeparation) - Constants.brickSeparation)
    addBricks(origin, startRow: midPoint, endRow: brickRows - 1)
  }
  
  //设定排列的起始行 终止行
  private func addBricks(origin: CGPoint, startRow: Int, endRow: Int){
    var brickOrigin = origin
    for _ in startRow...endRow{
      for _ in 1...brickCols{
        let brick = UIView(frame: CGRect(origin: brickOrigin, size: brickSize))
        brick.backgroundColor = Constants.brickColor
        gamePanel.addSubview(brick)
        bricks.append(brick)
        breakoutBehavior.addBarrier(UIBezierPath(rect: brick.frame), identifier: "\(bricks.count-1)")
        //更新横坐标
        brickOrigin.x += Constants.brickSeparation + brickSize.width
      }
      //换行了
      brickOrigin.x = origin.x
      brickOrigin.y += Constants.brickSeparation + brickSize.height
    }
  }
  
  private func removeBricks(){
    if bricks.count == 0 {
      return
    }
    for i in 0..<bricks.count{
      breakoutBehavior.removeBarrier("\(i)")
      bricks[i].removeFromSuperview()
    }
    bricks = []
  }
  
  private var hitBrickNum = 0
  
  private func removeBrickHited(i: Int){
    breakoutBehavior.removeBarrier("\(i)")
    hitBrickNum += 1
    //旋转淡出的效果
    UIView.transitionWithView(bricks[i], duration: 0.5, options: .TransitionFlipFromLeft, animations: {
      self.bricks[i].alpha = 0
      
      }, completion: nil)
    
    if bricks.count == hitBrickNum{
      endTheGame()
    }
  }
  
  private func endTheGame(){
    for item in breakoutBehavior.items{
      breakoutBehavior.removeBall(item)
      hitBrickNum = 0
    }
    
    let alert = UIAlertController(title: "Game Over", message: "Start new game?", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
      (action) in
      self.resetPaddle()
      self.generateBricks()
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    
    presentViewController(alert, animated: true, completion: nil)
    
    
  }
  
  //MARK: - Lifecycle
  
  private var gameViewSizeChange = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    breakoutAnimator.addBehavior(breakoutBehavior)
    //碰撞的delegate设置为该controller
    breakoutBehavior.collisionDelegate = self
    //设置下  背景
    if let backgroundPic = UIImage(named: "box"){
      //这里设置的 backgroundColor
      gamePanel.backgroundColor  = UIColor(patternImage: backgroundPic)
    }
    
    
  }
  
  override func viewWillAppear(animated: Bool) {

    super.viewWillAppear(animated)
    //在跳回游戏界面后 要重新设置setting
    let mySetting = MenuSetting()
    brickCols = mySetting.brickCols
    brickRows = mySetting.brickRows
    relPaddleWidth = mySetting.relPaddle
    pushMagnitude = mySetting.pushMagnitude
    breakoutBehavior.gravityOn = mySetting.gravityOn
    
    //restart ball
    if !ballVelocity.isEmpty {
      for i in 0..<breakoutBehavior.items.count{
        breakoutBehavior.startBall(breakoutBehavior.items[i], veloctity: ballVelocity[i])
      }
    }
    
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    gameViewSizeChange = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let mySetting = MenuSetting()
    brickCols = mySetting.brickCols
    brickRows = mySetting.brickRows
    relPaddleWidth = mySetting.relPaddle
    pushMagnitude = mySetting.pushMagnitude
    breakoutBehavior.gravityOn = mySetting.gravityOn
    
    //restart ball
    if !ballVelocity.isEmpty {
      for i in 0..<breakoutBehavior.items.count{
        breakoutBehavior.startBall(breakoutBehavior.items[i], veloctity: ballVelocity[i])
      }
    }

    
    if gameViewSizeChange{
      gameViewSizeChange = false
      
      setThreeSideBarrier()
      
      resetPaddle()
      
      for item in breakoutBehavior.items{
        if !CGRectContainsRect(item.frame, gamePanel.frame){
          placedBall(item)
          breakoutAnimator.updateItemUsingCurrentState(item)
        }
      }
      generateBricks()
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    //把球停下来
    ballVelocity = []
    for item in breakoutBehavior.items{
      ballVelocity.append(breakoutBehavior.stopBall(item))
    }
  }
  //MARK: - Delegate
  
  func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
    if let bricksId = Int((identifier as? String)!){
      removeBrickHited(bricksId)
    }
  }
}



private struct Constants{
  //宽度的十分之一就行
  static let relBallSize = CGFloat(0.1)
  static let ballColor = UIColor.blackColor()
  
  static let paddleHeight = CGFloat(10)
  static let paddleYOffSet = CGFloat(70)
  
  static let brickHeight = CGFloat(8)
  static let brickSeparation = CGFloat(4)
  static let brickYOffSet = CGFloat(70)
  static let brickColor = UIColor.purpleColor()
}

private struct PathIdentifier{
  static let topBarrier = "Top Barrier"
  static let leftBarrier = "Left Barrier"
  static let rightBarrier = "Right Barrier"
  
  static let paddleIdentiifer = "Paddle"
}
