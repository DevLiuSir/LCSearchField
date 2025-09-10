//
//  NSTextField+Extension.swift
//  LCSearchField
//
//  Created by DevLiuSir on 2022/3/2.
//

import Foundation
import Cocoa


extension NSTextField {
    
    /// 当前文本框是否正在被编辑（拥有第一响应者焦点）
    var isBeingEdited: Bool {
        return self.window?.firstResponder == self.currentEditor()
    }
}
