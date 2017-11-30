//
//  MessagesViewController.swift
//  CollectionKitExample
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class MessageDataProvider: ArrayDataProvider<Message> {
  init() {
    super.init(data: testMessages, identifierMapper: { (_, data) in
      return data.identifier
    })
  }
}

class MessageLayout: SimpleLayout<Message> {
  override func simpleLayout(collectionSize: CGSize,
                       dataProvider: CollectionDataProvider<Message>,
                       sizeProvider: @escaping CollectionSizeProvider<Message>) -> [CGRect] {
    var frames: [CGRect] = []
    var lastMessage: Message?
    var lastFrame: CGRect?
    let maxWidth: CGFloat = collectionSize.width
    
    for i in 0..<dataProvider.numberOfItems {
      let message = dataProvider.data(at: i)
      var yHeight: CGFloat = 0
      var xOffset: CGFloat = 0
      var cellFrame = MessageCell.frameForMessage(message, containerWidth: maxWidth)
      if let lastMessage = lastMessage, let lastFrame = lastFrame {
        if message.type == .image &&
          lastMessage.type == .image && message.alignment == lastMessage.alignment {
          if message.alignment == .left && lastFrame.maxX + cellFrame.width + 2 < maxWidth {
            yHeight = lastFrame.minY
            xOffset = lastFrame.maxX + 2
          } else if message.alignment == .right && lastFrame.minX - cellFrame.width - 2 > 0 {
            yHeight = lastFrame.minY
            xOffset = lastFrame.minX - 2 - cellFrame.width
            cellFrame.origin.x = 0
          } else {
            yHeight = lastFrame.maxY + message.verticalPaddingBetweenMessage(lastMessage)
          }
        } else {
          yHeight = lastFrame.maxY + message.verticalPaddingBetweenMessage(lastMessage)
        }
      }
      cellFrame.origin.x += xOffset
      cellFrame.origin.y = yHeight
      
      lastFrame = cellFrame
      lastMessage = message
      
      frames.append(cellFrame)
    }

    return frames
  }
}

class MessagePresenter: WobblePresenter {
  var dataProvider: MessageDataProvider?
  weak var sourceView: UIView?
  var sendingMessage = false

  override func insert(collectionView: CollectionView, view: UIView, at index: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: index, frame: frame)
    guard let messages = dataProvider?.data,
      let sourceView = sourceView,
      collectionView.hasReloaded,
      collectionView.reloading else { return }
    if sendingMessage && index == messages.count - 1 {
      // we just sent this message, lets animate it from inputToolbarView to it's position
      view.frame = collectionView.convert(sourceView.bounds, from: sourceView)
      view.alpha = 0
      view.yaal.alpha.animateTo(1.0)
      view.yaal.bounds.animateTo(frame.bounds, stiffness: 400, damping: 40)
    } else if collectionView.visibleFrame.intersects(frame) {
      if messages[index].alignment == .left {
        let center = view.center
        view.center = CGPoint(x: center.x - view.bounds.width, y: center.y)
        view.yaal.center.animateTo(center, stiffness:250, damping: 20)
      } else if messages[index].alignment == .right {
        let center = view.center
        view.center = CGPoint(x: center.x + view.bounds.width, y: center.y)
        view.yaal.center.animateTo(center, stiffness:250, damping: 20)
      } else {
        view.alpha = 0
        view.yaal.scale.from(0).animateTo(1)
        view.yaal.alpha.animateTo(1)
      }
    }
  }
}

class MessagesViewController: CollectionViewController {

  var loading = false

  let dataProvider = MessageDataProvider()
  let presenter = MessagePresenter()
  
  let newMessageButton = UIButton(type: .system)

  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
    view.clipsToBounds = true

    newMessageButton.setImage(UIImage(named:"ic_send")!, for: .normal)
    newMessageButton.addTarget(self, action: #selector(send), for: .touchUpInside)
    newMessageButton.sizeToFit()
    newMessageButton.backgroundColor = .lightBlue
    newMessageButton.tintColor = .white
    view.addSubview(newMessageButton)

    collectionView.delegate = self
    collectionView.contentInset = UIEdgeInsetsMake(30, 10, 54, 10)
    collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(30, 0, 54, 0)
    
    presenter.sourceView = newMessageButton
    presenter.dataProvider = dataProvider
    let provider = CollectionProvider(
      dataProvider: dataProvider,
      viewUpdater: { (view: MessageCell, data: Message, at: Int) in
        view.message = data
      }
    )
    provider.layout = MessageLayout()
    provider.presenter = presenter
    self.provider = provider
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    newMessageButton.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
    
    let isAtBottom = collectionView.contentOffset.y >= collectionView.offsetFrame.maxY - 10
    if !collectionView.hasReloaded {
      collectionView.reloadData() {
        return CGPoint(x: self.collectionView.contentOffset.x,
                       y: self.collectionView.offsetFrame.maxY)
      }
    }
    if isAtBottom {
      if collectionView.hasReloaded {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                y: collectionView.offsetFrame.maxY), animated: true)
      } else {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                y: collectionView.offsetFrame.maxY), animated: true)
      }
    }
  }
}

// For sending new messages
extension MessagesViewController {
  @objc func send() {
    let text = UUID().uuidString
    
    presenter.sendingMessage = true
    dataProvider.data.append(Message(true, content: text))
    collectionView.reloadData()
    collectionView.scrollTo(edge: .bottom, animated:true)
    presenter.sendingMessage = false

    delay(1.0) {
      self.dataProvider.data.append(Message(false, content: text))
      self.collectionView.reloadData()
      self.collectionView.scrollTo(edge: .bottom, animated:true)
    }
  }
}

extension MessagesViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // PULL TO LOAD MORE
    // load more messages if we scrolled to the top
    if collectionView.hasReloaded,
      scrollView.contentOffset.y < 500,
      !loading {
      loading = true
      delay(0.5) { // Simulate network request
        let newMessages = testMessages.map{ $0.copy() }
        self.dataProvider.data = newMessages + self.dataProvider.data
        let oldContentHeight = self.collectionView.offsetFrame.maxY - self.collectionView.contentOffset.y
        self.collectionView.reloadData() {
          return CGPoint(x: self.collectionView.contentOffset.x,
                         y: self.collectionView.offsetFrame.maxY - oldContentHeight)
        }
        self.loading = false
      }
    }
  }
}
