# ALTextInputBar
An auto growing text input bar for messaging apps. Written in Swift.  
ALTextInputBar is designed to solve a few issues that folks usually encounter when building messaging apps.

![With some text](https://cloud.githubusercontent.com/assets/932822/7333301/a510aa22-eb6a-11e4-988b-ac12e4e6c363.png)
![With lots of text](https://cloud.githubusercontent.com/assets/932822/7333307/cf101c04-eb6a-11e4-9a80-799cf3353a70.png)

### Features
- Simple to use and configure
- Automatic resizing based on content
- Interactive dismiss gesture support

### Installation & Requirements

This project requires Xcode 8.0 to run and compiles with swift 3.0

ALTextInputBar is available on [CocoaPods](http://cocoapods.org).  Add the following to your Podfile:

```ruby
pod 'ALTextInputBar'
```

### Usage

This is the minimum configuration required to attach an input bar to the keyboard.
```swift
class ViewController: UIViewController {

    let textInputBar = ALTextInputBar()

    // The magic sauce
    // This is how we attach the input bar to the keyboard
    override var inputAccessoryView: UIView? {
        get {
            return textInputBar
        }
    }

    // Another ingredient in the magic sauce
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
```

## License
ALTextInputBar is available under the MIT license. See the LICENSE file for more info.
