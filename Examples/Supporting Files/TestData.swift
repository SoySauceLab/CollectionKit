//
//  TestData.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

let testMessages = [
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

let testImages: [UIImage] = [
  UIImage(named: "l1")!,
  UIImage(named: "l2")!,
  UIImage(named: "l3")!,
  UIImage(named: "1")!,
  UIImage(named: "2")!,
  UIImage(named: "3")!,
  UIImage(named: "4")!,
  UIImage(named: "5")!,
  UIImage(named: "6")!
]

let testArticles =
  [ArticleData(imageName: "1",
               title: "Fear and the Venture Capitalist",
               subTitle:"There are many pathologies that venture capitalists can develop and bring into the lab."),
   ArticleData(imageName: "2",
               title: "Your Brain is Your Phone",
               subTitle:"Smartphones are changing how we think—because they’re a part of how we think"),
   ArticleData(imageName: "3",
               title: "The Decline and Fall of America (In Numbers)",
               subTitle:"In numbers, a lot about the United States appears to be on the decline."),
   ArticleData(imageName: "4",
               title: "In Defence of The Emperor’s New Clothes",
               subTitle:"Once upon a time, there was an Emperor so fond of new clothes that he spent all his money"),
   ArticleData(imageName: "1",
               title: "Don’t let Silicon Valley tell you how to think",
               subTitle:"If we don’t have the courage to stand up to powerful people, we’re going to get steamrolled"),
   ArticleData(imageName: "2",
               title: "Kevin Kelly Writes To Find Out What He Doesn’t Know",
               subTitle:"Steven Johnson talks with the Wired co-founder and bestselling technology theorist about writing in public"),
   ArticleData(imageName: "3",
               title: "Why your API may be a better investment than your App",
               subTitle:"It seems like just yesterday when the mobile app became the most important way in which humans interact with"),
   ArticleData(imageName: "4",
               title: "Manly Man Things: The Jock Strap",
               subTitle:"What used to protect your balls from harm is now meant to show them off"),
   ArticleData(imageName: "1",
               title: "How the Jazz Age Lives on in NYC",
               subTitle:"The bygone era of flappers, jazz and speakeasies can still be found in New York City if you know where to look.")
]
