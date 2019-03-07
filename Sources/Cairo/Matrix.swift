//
//  Matrix.swift
//  Cairo
//
//  Created by Alsey Coleman Miller on 5/8/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

@_exported import CCairo

public struct Matrix {

    public var cairo_matrix: cairo_matrix_t

    // MARK: - Initialization
    
    public static var identity: Matrix {
        
        @inline(__always)
        get {
            
            var matrix = Matrix()
    
            cairo_matrix_init_identity(&matrix.cairo_matrix)
            
            return matrix
        }
    }

    @inline(__always)
    public init() {
        self.cairo_matrix = cairo_matrix_t()
    }
    
    @inline(__always)
    public init(scale: (x: Double, y: Double)) {
        self.init()
        cairo_matrix_init_scale(&self.cairo_matrix, scale.x, scale.y)
    }
    
    @inline(__always)
    public init(rotation radians: Double) {
        
        self.init()
        
        cairo_matrix_rotate(&self.cairo_matrix, radians)
    }
    
    @inline(__always)
    public init(a: Double, b: Double, c: Double, d: Double, t: (x: Double, y: Double)) {
        
        self.init()
        
        cairo_matrix_init(&self.cairo_matrix, a, b, c, d, t.x, t.y)
    }
    
    // MARK: - Methods
    
    /// Applies rotation by radians to the transformation in matrix.
    /// The effect of the new transformation is to first rotate the coordinates by radians,
    /// then apply the original transformation to the coordinates.
    @inline(__always)
    public mutating func rotate(_ radians: Double) {
        
        cairo_matrix_rotate(&self.cairo_matrix, radians)
    }
    
    /// Changes `matrix` to be the inverse of its original value.
    /// Not all transformation matrices have inverses; if the matrix collapses points together (it is degenerate),
    /// then it has no inverse and this function will fail.
    @inline(__always)
    public mutating func inverse() {
        
        cairo_matrix_invert(&self.cairo_matrix)
    }
    
    @inline(__always)
    public mutating func invert() {
        
        cairo_matrix_invert(&self.cairo_matrix)
    }
    
    /// Multiplies the affine transformations in `a` and `b` together and stores the result in result.
    /// The effect of the resulting transformation is to first apply the transformation in `a` to the coordinates
    /// and then apply the transformation in `b` to the coordinates.
    @inline(__always)
    public mutating func multiply(a: Matrix, b: Matrix) {
        
        var copy = (a: a.cairo_matrix, b: b.cairo_matrix)
        
        cairo_matrix_multiply(&self.cairo_matrix, &copy.a, &copy.b)
    }
    
    @inline(__always)
    public mutating func scale(x: Double, y: Double) {
        
        cairo_matrix_scale(&self.cairo_matrix, x, y)
    }
    
    /// Applies a translation by `x , y` to the transformation in matrix .
    /// The effect of the new transformation is to first translate the coordinates by `x` and `y`,
    /// then apply the original transformation to the coordinates.
    @inline(__always)
    public mutating func translate(x: Double, y: Double) {
        
        cairo_matrix_translate(&self.cairo_matrix, x, y)
    }
}

extension Matrix {

    public var xx: Double {
        @inline(__always)
        get {
            return self.cairo_matrix.xx
        }
        @inline(__always)
        set {
            self.cairo_matrix.xx = newValue
        }
    }

    public var yx: Double {
        @inline(__always)
        get {
            return self.cairo_matrix.yx
        }
        @inline(__always)
        set {
            self.cairo_matrix.yx = newValue
        }
    }

    public var xy: Double {
        @inline(__always)
        get {
            return self.cairo_matrix.xy
        }
        @inline(__always)
        set {
            self.cairo_matrix.xy = newValue
        }
    }

    public var yy: Double {
        @inline(__always)
        get {
            return self.cairo_matrix.yy
        }
        @inline(__always)
        set {
            self.cairo_matrix.yy = newValue
        }
    }

    public var x0: Double {
        @inline(__always)
        get {
            return self.cairo_matrix.x0
        }
        @inline(__always)
        set {
            self.cairo_matrix.x0 = newValue
        }
    }

    public var y0: Double {
        @inline(__always)
        get {
            return self.cairo_matrix.y0
        }
        @inline(__always)
        set {
            self.cairo_matrix.y0 = newValue
        }
    }

    @inline(__always)
    public init(xx: Double, yx: Double, xy: Double, yy: Double, x0: Double, y0: Double) {
        self.cairo_matrix = cairo_matrix_t(xx: xx, yx: yx, xy: xy, yy: yy, x0: x0, y0: y0)
    }
}
