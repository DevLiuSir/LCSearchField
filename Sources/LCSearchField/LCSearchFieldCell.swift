//
//  LCSearchFieldCell.swift
//  LCSearchField
//
//  Created by DevLiuSir on 2022/3/2.
//

import Cocoa


/// 自定义 NSSearchFieldCell，用于控制文字与放大镜位置，支持垂直居中
final class LCSearchFieldCell: NSSearchFieldCell {

    /// `左边文字`与`放大镜`的额外`水平间距`
    var textLeftInset: CGFloat = 0
    
    /// 放大镜按钮的水平偏移量
    var searchButtonOffsetX: CGFloat = 0
    
    // MARK: - 文字区域

    /// 返回搜索框中文本的绘制区域
    /// 1. 水平偏移 textLeftInset
    /// 2. 垂直居中，保证文字不靠上
    override func searchTextRect(forBounds rect: NSRect) -> NSRect {
        var textRect = super.searchTextRect(forBounds: rect)

        // 水平偏移
        textRect.origin.x += textLeftInset
        textRect.size.width -= textLeftInset

        // 垂直居中
        if let f = self.font {
            let fontHeight = f.ascender + abs(f.descender)
            textRect.origin.y = rect.origin.y + (rect.height - fontHeight) / 2
            textRect.size.height = fontHeight
        }
        return textRect
    }

    
    //MARK: -  清除按钮
/*
    override func cancelButtonRect(forBounds rect: NSRect) -> NSRect {
        var btnRect = super.cancelButtonRect(forBounds: rect)
        // 垂直居中
        btnRect.origin.y = rect.origin.y + (rect.height - btnRect.height) / 2
        return btnRect
    }
*/
    
    
    // MARK: - 放大镜按钮区域

    /// 返回搜索框中放大镜按钮的绘制区域
    /// 1. 可微调水平位置
    /// 2. 垂直居中
    override func searchButtonRect(forBounds rect: NSRect) -> NSRect {
        var btnRect = super.searchButtonRect(forBounds: rect)

        // 水平微调
        btnRect.origin.x += searchButtonOffsetX

        // 垂直居中
        btnRect.origin.y = rect.origin.y + (rect.height - btnRect.height) / 2

        return btnRect
    }

    // MARK: - 整体绘制区域

    /// 控制整个 cell 的绘制区域，包括文字和按钮
    /// 1. 水平偏移 textLeftInset
    /// 2. 垂直居中
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        var r = super.drawingRect(forBounds: rect)

        // 水平偏移
        r.origin.x += textLeftInset
        r.size.width -= textLeftInset

        // 垂直居中
        if let f = self.font {
            let fontHeight = f.ascender + abs(f.descender)
            r.origin.y = rect.origin.y + (rect.height - fontHeight) / 2
            r.size.height = fontHeight
        }
        return r
    }
    
    
    
    /// 重写方法，使用垂直居中的文本矩形框架来绘制文本
    ///
    /// - Parameters:
    ///   - cellFrame: 单元格的矩形框架
    ///   - controlView: 控制视图
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        /**
         使用 `insetBy(dx:dy:)` 为文本区域添加内边距：
         - dx: 水平内边距，避免文字贴边
         - dy: 垂直内边距，使文字、光标和占位符在编辑和非编辑状态下垂直居中
         */
        let insetRect = cellFrame.insetBy(dx: 5, dy: 5)
        super.drawInterior(withFrame: insetRect, in: controlView)
    }
    
    

    // MARK: - 编辑与选中处理

    /// 编辑文本时的绘制区域，保证文字垂直居中
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        let r = searchTextRect(forBounds: rect)
        super.edit(withFrame: r, in: controlView, editor: textObj, delegate: delegate, event: event)
    }

    /// 选中区域时的绘制范围，保证文字垂直居中
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        let r = searchTextRect(forBounds: rect)
        super.select(withFrame: r, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
}
