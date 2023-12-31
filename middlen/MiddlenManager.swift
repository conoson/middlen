//
//  middlenManager.swift
//  middlen
//
//  Created by Kwon on 2023/09/21.
//

import Cocoa

class MiddlenManager: NSObject {
    private static var eventTap: CFMachPort? = nil
    
    static func start(){
        if eventTap != nil {
            debugPrint("MiddlenManager is already started")
            return
        }
        debugPrint("MiddlenManager start")
        //        let eventMask =
        //        (1 << CGEventType.leftMouseDown.rawValue) |
        //        (1 << CGEventType.leftMouseUp.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            //eventsOfInterest: CGEventMask(eventMask),
            eventsOfInterest: NSEvent.EventTypeMask.gesture.rawValue,
            callback: {
                proxy, type, cgEvent, userInfo in
                return MiddlenManager.eventHandler(proxy: proxy, eventType: type, cgEvent: cgEvent, userInfo: userInfo)
            },
            userInfo: nil
        ) else {
            debugPrint("Failed to create event tap")
            return
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    //    func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    //        switch type {
    //        case .leftMouseDown:
    //            // 좌클릭 다운 이벤트를 감지하면 미들클릭 다운으로 변환
    //            let middleClickDown = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: event.location, mouseButton: .center)
    //            middleClickDown?.post(tap: .cghidEventTap)
    //            return nil // 원래의 좌클릭 다운 이벤트를 중단
    //
    //        case .leftMouseUp:
    //            // 좌클릭 업 이벤트를 감지하면 미들클릭 업으로 변환
    //            let middleClickUp = CGEvent(mouseEventSource: nil, mouseType: .otherMouseUp, mouseCursorPosition: event.location, mouseButton: .center)
    //            middleClickUp?.post(tap: .cghidEventTap)
    //            return nil // 원래의 좌클릭 업 이벤트를 중단
    //
    //        default:
    //            break
    //        }
    //        return Unmanaged.passRetained(event)
    //    }
    
    private static func eventHandler(proxy: CGEventTapProxy, eventType: CGEventType, cgEvent: CGEvent, userInfo: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        if eventType.rawValue == NSEvent.EventType.gesture.rawValue, let nsEvent = NSEvent(cgEvent: cgEvent) {
            if touchEventHandler(nsEvent) != nil {
                return Unmanaged.passUnretained(cgEvent)
            } else {
                return nil
            }
        } else if (eventType == .tapDisabledByUserInput || eventType == .tapDisabledByTimeout) {
            debugPrint("MiddlenManager tap disabled", eventType.rawValue)
            if eventTap == nil {
                print("eventTap is nil")
                return Unmanaged.passUnretained(cgEvent)
                
            }
            CGEvent.tapEnable(tap: eventTap!, enable: true)
        }
        return Unmanaged.passUnretained(cgEvent)
    }
    
    private static func touchEventHandler(_ nsEvent: NSEvent) -> NSEvent? {
        
        let touches = nsEvent.allTouches()
        
        guard touches.count == 3 else { return nsEvent }
        if !touches.allSatisfy({$0.phase != .moved}) { return nsEvent }
        
        var stationaryTouches = [NSTouch]()
        var beganTouches = [NSTouch?]()
        var endedTouches = [NSTouch?]()
        
        for touch in touches {
            switch touch.phase {
            case .stationary:
                stationaryTouches.append(touch)
            case .began:
                beganTouches.append(touch)
            case .ended:
                endedTouches.append(touch)
            default:
                break
            }
        }
        
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let location = NSEvent.mouseLocation
        let correctedY = screenHeight - location.y
        let cgPoint = CGPoint(x: location.x, y: correctedY)
        
        if stationaryTouches.count == 2 {
            if beganTouches.count != 0 {
                
            } else if endedTouches.count != 0 {
                //미들클릭 다운으로 변환
                let middleClickDown = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: cgPoint, mouseButton: .center)
                middleClickDown?.post(tap: .cghidEventTap)
                //미들클릭 업으로 변환
                let middleClickUp = CGEvent(mouseEventSource: nil, mouseType: .otherMouseUp, mouseCursorPosition: cgPoint, mouseButton: .center)
                middleClickUp?.post(tap: .cghidEventTap)
                return nil
            }
        } else  {
            if beganTouches.count == 2 {//미들클릭 다운으로 변환
                let middleClickDown = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: cgPoint, mouseButton: .center)
                middleClickDown?.post(tap: .cghidEventTap)
                return nil
            } else if endedTouches.count == 2 {
                let middleClickDown = CGEvent(mouseEventSource: nil, mouseType: .otherMouseDown, mouseCursorPosition: cgPoint, mouseButton: .center)
                middleClickDown?.post(tap: .cghidEventTap)
                return nil
            }
        }
        
        return nsEvent
    }
}
