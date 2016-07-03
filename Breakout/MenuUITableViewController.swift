//
//  MenuUITableViewController.swift
//  Breakout
//
//  Created by 杨威 on 16/7/1.
//  Copyright © 2016年 demo. All rights reserved.
//

import UIKit

class MenuUITableViewController: UITableViewController {
  //MARK: - Outlets
  
  //命名要采用对象属性类型的方式
  @IBOutlet weak var brickRowLabel: UILabel!
  @IBOutlet weak var brickRowStepper: UIStepper!
  
  @IBOutlet weak var brickColLabel: UILabel!
  @IBOutlet weak var brickColStepper: UIStepper!

  @IBOutlet weak var paddleSizeLabel: UILabel!
  @IBOutlet weak var paddleSizeSlider: UISlider!
  
  @IBOutlet weak var gravitySwitch: UISwitch!
  
  @IBOutlet weak var pushMagnitudeLabel: UILabel!
  @IBOutlet weak var pushMagnitudeSlider: UISlider!
  
  var userData = MenuSetting()
 
  //MARK: - Models
  private var rowOfBricks: Int{
    get{
      return Int(brickRowStepper.value)
    }
    set{
      brickRowStepper.value = Double(newValue)
      brickRowLabel.text = "\(newValue)"
    }
  }
  
  private var colOfBricks: Int{
    get{
      return Int(brickColStepper.value)
    }
    set{
      brickColStepper.value = Double(newValue)
      brickColLabel.text = "\(newValue)"
    }
  }
  
  private var relPaddleSize: CGFloat{
    get{
      return CGFloat(paddleSizeSlider.value)
    }
    set{
      paddleSizeSlider.value = Float(newValue)
      paddleSizeLabel.text = "\(newValue)"
    }
  }
  
  private var gravityOn: Bool{
    get{
      return gravitySwitch.on
    }
    set{
      gravitySwitch.on = newValue
    }
  }
  
  private var pushMagn: CGFloat{
    get{
      return CGFloat(pushMagnitudeSlider.value)
    }
    set{
      pushMagnitudeSlider.value = Float(newValue)
      pushMagnitudeLabel.text = "\(newValue)"
    }
  }
  //MARK: - IBActions
  
  @IBAction func brickRowChange(sender: UIStepper) {
    rowOfBricks = Int(sender.value)
    //存储进NSUserdefault
    userData.brickRows = rowOfBricks
  }
  
  @IBAction func brickColChange(sender: UIStepper) {
    colOfBricks = Int(sender.value)
    userData.brickCols = colOfBricks
  }
  
  @IBAction func paddleSizeChange(sender: UISlider) {
    relPaddleSize = CGFloat(sender.value)
    userData.relPaddle = relPaddleSize
  }
  
  
  @IBAction func gravityOnChange(sender: UISwitch) {
    gravityOn = sender.on
    userData.gravityOn = gravityOn
  }
  
  
  @IBAction func reset(sender: UIButton) {
    userData.resetGameOptions()
    menuOptionReset()
  }
  
  @IBAction func pushMagnChange(sender: UISlider) {
    pushMagn = CGFloat(sender.value)
    userData.pushMagnitude = pushMagn
  }
  private func menuOptionReset(){
    rowOfBricks = userData.brickRows
    colOfBricks = userData.brickRows
    relPaddleSize = userData.relPaddle
    gravityOn = userData.gravityOn
    pushMagn = userData.pushMagnitude
    
  }
  
}
