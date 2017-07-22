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

let TestMessages = [
  Message(announcement: "CollectionView"),
  Message(false, content: "This is an advance example demostrating what CollectionView can do."),
  Message(false, content: "Checkout the source code to see how "),
  Message(false, content: "Nulla fringilla, dolor id congue elementum, urna diam rhoncus eros, sit amet hendrerit turpis velit eget nisl."),
  Message(false, content: "Quisque nulla sapien, dignissim ac risus nec, vehicula commodo lectus. Suspendisse lacinia mi sit amet nulla semper sollicitudin."),
  Message(true, content: "Test Content"),
  Message(announcement: "Today 9:30 AM"),
  Message(true, image: "l1"),
  Message(true, image: "l2"),
  Message(true, image: "l3"),
  Message(true, content: "Suspendisse ut turpis."),
  Message(true, content: "velit."),
  Message(false, content: "Suspendisse ut turpis velit."),
  Message(true, content: "Nullam placerat rhoncus erat ut placerat."),
  Message(false, content: "Fusce cursus metus viverra erat viverra, sed efficitur magna consequat. Ut tristique magna et sapien euismod, consequat maximus ipsum varius."),
  Message(false, content: "Nulla mattis odio a tortor fringilla pulvinar. Curabitur laoreet, velit nec malesuada finibus, massa arcu aliquam ex, a interdum justo massa eget erat. Curabitur facilisis molestie arcu id porta. Phasellus commodo rutrum mi a elementum. Etiam vestibulum volutpat sem, tincidunt auctor elit lobortis in. Pellentesque pellentesque tortor lectus, sed cursus augue porta vitae. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."),
  Message(false, content: "In bibendum nisl at arcu mollis volutpat vitae eu urna. Mauris sodales iaculis lorem, nec rutrum dui ullamcorper nec. Fusce nibh dolor, mollis ac efficitur condimentum, vulputate eget erat. Sed molestie neque eu blandit placerat. Fusce nec sagittis nulla. Sed aliquam elit sollicitudin egestas convallis. Vestibulum vel sem vel lectus porta tempus. Curabitur semper in nulla id lacinia. Sed consequat massa nisi, sed egestas quam facilisis id."),
  Message(false, image: "1"),
  Message(false, image: "2"),
  Message(false, image: "3"),
  Message(false, image: "4"),
  Message(false, image: "5"),
  Message(false, image: "6"),
  Message(true, content: "Etiam a leo nibh. Fusce cursus metus viverra erat viverra, sed efficitur magna consequat. Ut tristique magna et sapien euismod, consequat maximus ipsum varius."),
  Message(false, content: "Suspendisse ut turpis velit."),
  Message(true, content: "Vivamus et fermentum diam. Suspendisse vitae tempor lectus."),
  Message(true, content: "Duis eros eros"),
  Message(true, status: "Delivered"),
]
