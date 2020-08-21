//
//  CircularSeekerManager.swift
//  CircularSeekerLib
//
//  Created by mac 2018 on 8/20/20.
//

import Foundation
@objc(CircularSeeker)
class CircularSeeker: RCTViewManager {

  override func view() -> UIView! {
    return CircularSeekerView()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
