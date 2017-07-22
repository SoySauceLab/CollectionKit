
//
//  https://gist.github.com/CanTheAlmighty/70b3bf66eb1f2a5cee28
//

struct DictionaryTwoWay<S:Hashable, T:Hashable> : ExpressibleByDictionaryLiteral {
  // Literal convertible
  typealias Key   = S
  typealias Value = T

  // Real storage
  var st: [S : T] = [:]
  var ts: [T : S] = [:]

  init(leftRight st: [S:T]) {
    var ts: [T:S] = [:]

    for (key, value) in st {
      ts[value] = key
    }

    self.st = st
    self.ts = ts
  }

  init(rightLeft ts: [T:S]) {
    var st: [S:T] = [:]

    for (key, value) in ts {
      st[value] = key
    }

    self.st = st
    self.ts = ts
  }

  init(dictionaryLiteral elements: (Key, Value)...) {
    for element in elements {
      st[element.0] = element.1
      ts[element.1] = element.0
    }
  }

  init() { }

  subscript(key: S) -> T? {
    get {
      return st[key]
    }

    set(val) {
      remove(key)
      if let val = val {
        remove(val)
        st[key] = val
        ts[val] = key
      }
    }
  }

  subscript(key: T) -> S? {
    get {
      return ts[key]
    }

    set(val) {
      remove(key)
      if let val = val {
        remove(val)
        ts[key] = val
        st[val] = key
      }
    }
  }

  mutating func remove(_ key: S) {
    if let item = st.removeValue(forKey: key) {
      ts.removeValue(forKey: item)
    }
  }
  mutating func remove(_ key: T) {
    if let item = ts.removeValue(forKey: key) {
      st.removeValue(forKey: item)
    }
  }
}
