//
//  MenuSetting.swift
//  Breakout
//
//  Created by 杨威 on 16/7/1.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class MenuSetting{
  //MARK - NSUserDefault
  private var userData = NSUserDefaults.standardUserDefaults()
  
  //MARK - Options
  var brickRows: Int{
    get{
      return userData.objectForKey(Constant.brickRowsKey) as? Int ?? Constant.brickRowsDefault
    }
    set{
      userData.setObject(newValue, forKey: Constant.brickRowsKey)
    }
  }
  
  var brickCols: Int{
    get{
      return userData.objectForKey(Constant.brickColsKey) as? Int ?? Constant.brickColsDefault
    }
    set{
      userData.setObject(newValue, forKey: Constant.brickColsKey)
    }
  }
  
  var relPaddle: CGFloat{
    get{
      return userData.objectForKey(Constant.relPaddleKey) as? CGFloat ?? Constant.relPaddleDefault
    }
    set{
      userData.setObject(newValue, forKey: Constant.relPaddleKey)
    }
  }
  
  var pushMagnitude: CGFloat{
    get{
      return userData.objectForKey(Constant.pushMagnKey) as? CGFloat ?? Constant.pushMagnDefault
    }
    set{
      userData.setObject(newValue, forKey: Constant.pushMagnKey)
    }
  }
  
  var gravityOn: Bool {
    get{
      return userData.objectForKey(Constant.gravityKey) as? Bool ?? Constant.gravityDefault
    }
    set{
      userData.setObject(newValue, forKey: Constant.gravityKey)
    }
  }
  
  
  
  //MARK - Method
  func resetGameOptions(){
    brickRows = Constant.brickRowsDefault
    brickCols = Constant.brickColsDefault
    relPaddle = Constant.relPaddleDefault
    pushMagnitude = Constant.pushMagnDefault
    gravityOn = Constant.gravityDefault
  }
  
  
  //MARK - Constant
  
  private struct Constant{
    static let brickRowsKey = "brickRowsKey"
    static let brickRowsDefault = 5
    
    static let brickColsKey = "brickColsKey"
    static let brickColsDefault = 5
    
    static let relPaddleKey = "relPaddleKey"
    static let relPaddleDefault: CGFloat = 0.2
    
    static let pushMagnKey = "pushMagnKey"
    static let pushMagnDefault: CGFloat = 7.0
    
    static let gravityKey = "gravityKey"
    static let gravityDefault = false
  }
}
