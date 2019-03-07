//
//  Status.swift
//  Cairo
//
//  Created by Alsey Coleman Miller on 5/8/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

@_exported import CCairo

public struct Status {

    public var cairo_status: cairo_status_t

    public init(_ status: cairo_status_t) {
        self.cairo_status = status
    }

    public init(rawValue: cairo_status_t.RawValue) {
        self.cairo_status = cairo_status_t(rawValue: rawValue)
    }

    public func toError() -> CairoError? {
        
        return CairoError(rawValue: self.cairo_status.rawValue)
    }
}

extension Cairo.Status: CustomStringConvertible {
    
    public var description: String {
        
        let cString = cairo_status_to_string(self.cairo_status)!
        
        let string = String(cString: cString)
        
        return string
    }
}

public struct CairoError: RawRepresentable, CustomStringConvertible, Error {
    
    public typealias RawValue = cairo_status_t.RawValue
    
    public let rawValue: RawValue
    
    public init?(rawValue: RawValue) {
        
        guard rawValue > 0 && rawValue < CAIRO_STATUS_LAST_STATUS.rawValue
            else { return nil }
        
        self.rawValue = rawValue
    }
    
    public var description: String {
        
        return Cairo.Status(rawValue: self.rawValue).description
    }
}
