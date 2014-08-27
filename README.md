LogDispatcher.Swift
===================

LogDispatcher is a simple demonstration of how we can use [method overloading](http://en.wikipedia.org/wiki/Method_overloading) to override a swift library function `println(_:)` , giving it an opportunity to be more powerful and useful.

__With LogDispatcher, you can create `LogProcessingModule`s.__

When you call `println(_:)` to print/log something, LogDispatcher will walk through a list of registered log processing modules, choose the proper one, and use it to do some additional processing for the log.

For instance, you can have a log processing module that automaically adds a :warning: sign before the warning log, a log processing module that automaically report the error, etc.

__LogDispather is totally transparent.__

If your code is included in a target that do not have LogDispatcher, it will compile and all the `println(_:)` will become normal `println(_:)`. You do not need to change a single line of code.

##Usage and Examples

The overloaded `println(_:)` takes a dictionary parameter.

```swift
public func println<T>(object: Dictionary<String,T>) -> Bool
```

When you print a dictionary, LogDispatch will take over.

```swift
println(["Error": "Cannot find the saved configuration file, the default configuration will be used"])
```

You can create `LogProcessingModule`s by confirming to the `LogProcessingModuleType` protocol

```swift
public protocol LogProcessingModuleType {
    var logKey: String { get }
    
    func processLog<T>(content: T) -> Bool /* Bool -> Processed */
}
```

####Example 1: Auto error reporting

An error reporting log processing module can look like this

```swift
public class ErrorLogProcessingModule: LogProcessingModuleType {
    public var logKey: String {
        //The identifier of error log will be "Error"
        return "Error"
    }
    public func processLog<T>(content: T) -> Bool {
        if let content = content as? String {
            println("!!ERROR!!\n\(content)")
            //Send error info to your server
            //NSURLConnection.sendAsynchronousRequest(request, queue: nil, completionHandler: nil)
            return true
        } else {
            return false
        }
    }
}

```

Then, register the log processing module

```swift
let errorProcessingModule = ErrorLogProcessingModule()

LogDispatcher.registerLogProcessingModule(errorProcessingModule)
```

After that, if you call `println(["Error": "Cannot find the saved configuration file, the default configuration will be used"])`, the error will be printed as below and will be reported to your server as well. 

```
!!ERROR!!
Cannot find the saved configuration file, the default configuration will be used
```

