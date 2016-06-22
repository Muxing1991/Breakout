//
//  BallUIView.swift
//  Breakout
//
//  Created by 杨威 on 16/6/22.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class BallUIView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    //设定颜色为红色的球
    self.backgroundColor = UIColor.redColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawRect(rect: CGRect) {
    //圆角矩形 设为 宽的一半
    self.layer.cornerRadius = rect.width/2
    self.layer.masksToBounds = true
  }

}
