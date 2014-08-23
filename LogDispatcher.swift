//
//  LogDispatcher.swift
//  
//
//  Created by YuAo on 8/23/14.
//
//

public func println<T>(object: Dictionary<String,T>) -> Bool {
    var processed = false
    for logProcessingModule in LogDispatcher.logProcessingModules {
        for (key, value) in object {
            if key == logProcessingModule.logKey {
                if logProcessingModule.processLog(value) {
                    processed = true
                }
            }
        }
    }
    if !processed {
        let result: Void = println(object)
    }
    return processed
}

public protocol LogProcessingModuleType {
    
    var logKey: String { get }
    
    func processLog<T>(content: T) -> Bool /* Bool -> Processed */
}

public struct LogDispatcher {
    
    public private(set) static var logProcessingModules = [LogProcessingModuleType]()
    
    public static func registerLogProcessingModule(logProcessingModule: LogProcessingModuleType) {
        logProcessingModules.append(logProcessingModule)
    }
}