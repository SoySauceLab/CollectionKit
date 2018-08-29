//
//  Messages.swift
//  CollectionKitExample
//
//  Created by YiLun Zhao on 2016-02-23.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

enum MessageType {
  case text
  case announcement
  case status
  case image
}
enum MessageAlignment {
  case left
  case center
  case right
}
class Message {
  var identifier: String = UUID().uuidString
  var fromCurrentUser = false
  var content = ""
  var type: MessageType

  init(_ fromCurrentUser: Bool, content: String) {
    self.fromCurrentUser = fromCurrentUser
    self.type = .text
    self.content = content
  }
  init(_ fromCurrentUser: Bool, status: String) {
    self.fromCurrentUser = fromCurrentUser
    self.type = .status
    self.content = status
  }
  init(_ fromCurrentUser: Bool, image: String) {
    self.fromCurrentUser = fromCurrentUser
    self.type = .image
    self.content = image
  }
  init(announcement: String) {
    self.type = .announcement
    self.content = announcement
  }

  var fontSize: CGFloat {
    switch type {
    case .text: return 14
    default: return 12
    }
  }
  var cellPadding: CGFloat {
    switch type {
    case .announcement: return 4
    case .text: return 12
    case .status: return 2
    case .image: return 0
    }
  }
  var showShadow: Bool {
    switch type {
    case .text, .image: return true
    default: return false
    }
  }
  var roundedCornder: Bool {
    switch type {
    case .announcement: return false
    default: return true
    }
  }
  var textColor: UIColor {
    switch type {
    case .text:
      if fromCurrentUser {
        return UIColor.white
      } else {
        return UIColor(red: 131/255, green: 138/255, blue: 147/255, alpha: 1.0)
      }
    default:
      return UIColor(red: 131/255, green: 138/255, blue: 147/255, alpha: 1.0)
    }
  }

  var backgroundColor: UIColor {
    switch type {
    case .text:
      if fromCurrentUser {
        return .lightBlue
      } else {
        return UIColor(white: showShadow ? 1.0 : 0.95, alpha: 1.0)
      }
    default:
      return UIColor.clear
    }
  }
  var shadowColor: UIColor {
    switch type {
    case .text:
      if fromCurrentUser {
        return UIColor(red: 0.1, green: 140/255, blue: 1.0, alpha: 1.0)
      } else {
        return UIColor(white: 0.8, alpha: 1.0)
      }
    case .image:
      return UIColor(white: 0.4, alpha: 1.0)
    default:
      return UIColor.clear
    }
  }
  var alignment: MessageAlignment {
    switch type {
    case .announcement: return .center
    default: return (fromCurrentUser ? .right : .left)
    }
  }

  func verticalPaddingBetweenMessage(_ previousMessage: Message) -> CGFloat {
    if type == .image && previousMessage.type == .image {
      return 2
    }
    if type == .announcement {
      return 15
    }
    if previousMessage.type == .announcement {
      return 5
    }
    if type == .status {
      return 3
    }
    if type == .text && type == previousMessage.type && fromCurrentUser == previousMessage.fromCurrentUser {
      return 5
    }
    return 15
  }

  func copy() -> Message {
    switch type {
    case .image:
      return Message(fromCurrentUser, image: content)
    case .announcement:
      return Message(announcement: content)
    case .text:
      return Message(fromCurrentUser, content: content)
    case .status:
      return Message(fromCurrentUser, status: content)
    }
  }
}

