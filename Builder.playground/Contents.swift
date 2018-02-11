import Foundation
import XCTest

/*:
 
 #### The Builder pattern

 In [issue \#41](https://swifting.io/blog/2017/05/06/41-architecture-wars-mvc-strikes-back-takes-a-photo-with-avfoundation/) in which we built an app that uses a photo camera to capture one's loayalty cards we used a pattern that we named `Builder` to configure properties of objects. How does the code look like when we use `Builder`?
 
 ```Swift
 let tableView = UITableView(frame: .zero, style: .plain).with {
    $0.backgroundColor = .red
    $0.separatorColor = .green
    $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    $0.allowsMultipleSelection = true
 }
 ```
 
 We simply initialize an object we want to configure and call the `with(:)` function on the newly initilized object. The `with(:)` function takes only one parameter - a closure in which one has possibility to set up properties of the object. How does it look like in the code?
 
 We created a protocol named `Builder` and in extension we created a default implementation of the `with(:)` function:
 */

protocol Builder {}
extension Builder {
    func with(configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}

/*:
 The `with(:)` function is very simple - it takes `configure` closure as a parameter. The closure is immediately called with `self` which allows "configuring" `self` - e.g. setting properties on it. We also conformed `NSObject` to this protocol so that every subclass can use `.with{}` syntax:
 */

extension NSObject: Builder {}

let tableView = UITableView(frame: .zero, style: .plain).with {
    $0.backgroundColor = .red
    $0.separatorColor = .green
    $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    $0.allowsMultipleSelection = true
}

/*:
 If we create a class that doesn't inherit from `NSObject` we need to conform to the protocol manually:
*/

class FooBar: Builder {
    var id: Int = 0
}

/*:
 We can check if our pattern works by using assertions from `XCTest` framework:
 */

var foobar = FooBar().with {
    XCTAssertTrue($0.id == 0) //checks default value
    $0.id = 1
}

XCTAssertTrue(foobar.id == 1) //checks value set in `configure` closure

/*:
 There is one problem with the presented approach. It doesn't work for value types (i.e. `struct`).
 
 ```Swift
 struct Foo: Builder {
    var id: Int = 0
 }
 
 var foo = Foo().with {
    XCTAssertTrue($0.id == 0)
    $0.id = 1 //🚨 Cannot assign to property: '$0' is immutable 💥
 }
 
 XCTAssertTrue(foo.id == 1)
```
 */

//struct Foo: Builder {
//    var id: Int = 0
//}
//
//var foo = Foo().with {
//    XCTAssertTrue($0.id == 0)
//    $0.id = 1 //🚨 Cannot assign to property: '$0' is immutable 💥
//}
//
//XCTAssertTrue(foo.id == 1)

/*:
 A struct given as a parameter to the `configure` closure is immutable by default. In order to make it mutable we need to use `inout` keyword and pass a reference to a type we want to configure. We want the syntax to work with `class` and `struct` types and we want to be able to assign returned type to a variable (as previously). So let's create a `BetterBuilder`!
 */

protocol BetterBuilder {}
extension BetterBuilder {
    public func with(configure: (inout Self) -> Void) -> Self {
        var this = self
        configure(&this)
        return this
    }
}

/*:
Our `BetterBuilder` now works for structs!
 */

struct Bar: BetterBuilder {
    var id: Int = 0
}

var bar = Bar().with {
    XCTAssertTrue($0.id == 0)
    $0.id = 1
}

XCTAssertTrue(bar.id == 1)

/*:
 And it still works for classes!
 */

class Car: BetterBuilder {
    var id: Int = 0
}

var car = Car().with {
    XCTAssertTrue($0.id == 0)
    $0.id = 1
}

XCTAssertTrue(car.id == 1)
