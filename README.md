LogDispatcher.Swift
===================

LogDispatcher is a simple __demonstration__ of how we can use [method overloading](http://en.wikipedia.org/wiki/Method_overloading) to override a swift library function `println(_:)` , giving it an opportunity to be more powerful and useful.

__With LogDispatcher, you can create `LogProcessingModule`s.__

When you call `println(_:)` to print/log something, LogDispatcher will walk through a list of registered log processing modules, choose the proper one, and use it to do some additional processing for the log.

For instance, you can have a log processing module that automaically adds a :warning: sign before the warning log, a log processing module that automaically report the error, etc.

__LogDispather is totally transparent.__

If your code is included in a target that does not have LogDispatcher, it will compile and all the `println(_:)` will become normal `println(_:)`. You do not have to change a single line of code.

===

*Checkout the `NSLog()`/(Objective-C) version > [JKLoggerDispatcher](https://github.com/fsjack/JKLoggerDispatcher)*

##Usage and Examples

The overloaded `println(_:)` takes a dictionary parameter.

```swift
public func println<T>(object: Dictionary<String,T>) -> Bool
```

You can create `LogProcessingModule`s by confirming to the `LogProcessingModuleType` protocol

```swift
public protocol LogProcessingModuleType {
    var logKey: String { get }
    
    func processLog<T>(content: T) -> Bool /* Bool -> Processed */
}
```

When you print a dictionary, LogDispatch will take over.

```swift
//Example
println(["Error": "Cannot find the saved configuration file, the default configuration will be used"])
```

It will go through every `(key, value)` in the dictionary, see if there's a `LogProcessingModule` which can handle and process the `value` by matching the `key` with the `LogProcessingModule`'s `logKey` property. Once it finds a `LogProcessingModule`, it will call the `LogProcessingModule`'s `func processLog<T>(content: T) -> Bool`, passing the `value` to the method.

####Example: Auto error reporting

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

##Implementation

LogDispatcher is simple. Everything is in the [LogDispatcher.swift](LogDispatcher.swift), less than 40 lines of code.

__But there's one tricky part:__

LogDispatcher wants to call the __original__ `println(_:)` when it cannot find a `LogProcessingModule` for a log.

There's already a overloaded version of `println(_:)` which handles the `Dictionary<String,T>` input, how can we call the __original__ `println(_:)` with the `Dictionary<String,T>` parameter?

The solution is to use a different return type for the overloaded version.

You may have noticed that the overloaded version of `println(_:)` returns a `Bool` to indicate whether a log has been processed. Thus, if we explicitly mark the return type as `Void`, we can reach the original version of the function.

Here comes the unused `result`

```
if !processed {
    let result: Void = println(object)
}
```

##Contributing

If you have any questions, bug reports, improvements, please file an issue.
