import Foundation

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformFont = UIFont
public typealias PlatformView = UIView
public typealias PlatformScrollView = UIScrollView
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformFont = NSFont
public typealias PlatformView = NSView
public typealias PlatformScrollView = NSScrollView
#endif