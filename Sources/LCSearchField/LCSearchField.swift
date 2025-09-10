//
//  LCSearchField.swift
//  LCSearchField
//
//  Created by DevLiuSir on 2022/3/2.
//

import Cocoa



/// 自定义搜索框子类，用于控制边框等 UI
public final class LCSearchField: NSSearchField {
    
    // MARK: - 可自定义属性
    /// 填充颜色
    public var fillColor: NSColor = .clear {
        didSet {
            layer?.backgroundColor = fillColor.cgColor
        }
    }
    /// 边框颜色
    public var borderColor: NSColor = .black.withAlphaComponent(0.3) {
        didSet {
            updateBorder()
        }
    }
    /// 边框宽度
    public var borderWidth: CGFloat = 1 {
        didSet {
            updateBorder()
        }
    }
    /// 圆角
    public var cornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            updateCornerRadius()
        }
    }
    
    /// 占位符颜色
    public var placeholderColor: NSColor? {
        get {
            guard let attr = self.placeholderAttributedString else { return nil }
            var range = NSRange(location: 0, length: 0)
            return attr.attribute(.foregroundColor, at: 0, effectiveRange: &range) as? NSColor
        }
        set {
            let placeholderText = self.placeholderString ?? ""
            let attrStr = newValue
                .map { NSAttributedString(string: placeholderText, attributes: [.foregroundColor: $0]) } ??
            NSAttributedString(string: placeholderText)
            self.placeholderAttributedString = attrStr
        }
    }
    
    /// 放大镜颜色 - 浅色模式
    public var searchIconColorLight: NSColor = .black {
        didSet { updateSearchIcon() }
    }
    
    /// 放大镜颜色 - 深色模式
    public var searchIconColorDark: NSColor = .white {
        didSet { updateSearchIcon() }
    }
    
    /// 是否隐藏搜索按钮（放大镜）
    public var isHiddenSearchIcon: Bool = false {
        didSet {
            if let cell = cell as? NSSearchFieldCell {
                cell.searchButtonCell = isHiddenSearchIcon ? nil : NSSearchFieldCell().searchButtonCell
                needsDisplay = true
            }
        }
    }
    
    
    /// 备份搜索框原始放大镜图标
    private var originalSearchImage: NSImage?
    
    
    // MARK: - 初始化
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        replaceCell()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        replaceCell()
        commonInit()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        replaceCell()
        commonInit()
    }
  
/*
    // 加了系统的focusRingType = .default，就不需要根据焦点绘制边框了
    // MARK: - 监听焦点变化
    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        LCLogKit.debug("🔹 LCSearchField 成为第一响应者 -> \(ok)")
        updateBorder()
        return ok
    }
    
    override func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        LCLogKit.debug("🔹 LCSearchField 辞去第一响应者 -> \(ok)")
        updateBorder()
        return ok
    }
*/
    
    // MARK: - 当控件添加到 window 时刷新边框
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateBorder()
    }
    
    
    /// 重写 `cancelOperation` 方法，当按下 ESC 键时调用
    ///
    /// 通过将窗口的 `firstResponder` 设为 `nil` 来取消焦点。
    /// 该方法在用户按下 ESC 键时被触发，使搜索框失去焦点。
    public override func cancelOperation(_ sender: Any?) {
        self.window?.makeFirstResponder(nil)
    }
    
    
    /** ----------- 当系统外观（浅色 / 深色模式）发生变化时调用 ----------- */
    // 当系统外观（Light / Dark 模式）发生变化时被调用
    // 适合在此方法中更新界面的颜色、图标等外观相关内容
    public override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        
        // 根据浅/深色模式，设置边框颜色
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        borderColor = isDark ? NSColor.white.withAlphaComponent(0.3) : NSColor.black.withAlphaComponent(0.3)
        
        // 更新边框显示
        updateBorder()
        
        // 更新搜索按钮放大镜
        updateSearchIcon()
        
        // 触发重绘
        needsDisplay = true
    }
    
    
    /// 用自定义 cell 替换默认 NSSearchFieldCell
    private func replaceCell() {
        if let old = self.cell as? NSSearchFieldCell {
            let custom = LCSearchFieldCell(textCell: old.stringValue)
            custom.placeholderString = old.placeholderString
            // 设置搜索图片的比例
            custom.searchButtonCell?.imageScaling = .scaleNone
            custom.font = old.font
            
            // ✅ 关键：复制 target/action
            /**
             -  由于我们自定义了 NSSearchFieldCell，如果不手动设置 target 和 action，
             - 搜索栏的文字变化事件将不会触发 @IBAction 或 action 方法。
             - 因此必须把旧 cell 的 target/action 赋值给新 cell，才能保证搜索响应正常。
             */
            custom.target = old.target
            custom.action = old.action
            
            self.cell = custom
        }
    }
    
    private func commonInit() {
        isBezeled = false
        isBordered = false
        isEditable = true
        focusRingType = .default
        delegate = self
        (cell as? NSTextFieldCell)?.drawsBackground = false
        
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = cornerRadius
        layer?.backgroundColor = fillColor.cgColor
        
        updateBorder()
        updateCornerRadius()
    }
    

    
    /// 更新边框
    private func updateBorder() {
        if isBeingEdited {
            layer?.borderWidth = borderWidth
            // 暂时不使用强调色
//            layer?.borderColor = NSColor.controlAccentColor.cgColor
            layer?.borderColor = borderColor.cgColor
#if DEBUG
            print("--输入状态----")
#endif
        } else {
            layer?.borderWidth = borderWidth
            layer?.borderColor = borderColor.cgColor
#if DEBUG
            print("不是输入状态")
#endif
        }
    }
    
    /// 更新圆角
    private func updateCornerRadius() {
        let r = cornerRadius.isFinite ? cornerRadius : bounds.height / 2
        layer?.cornerRadius = min(bounds.height / 2, r)
    }
   
    
    
    /// 更新`搜索框左侧`的`放大镜图标`
    ///
    /// - 根据当前系统外观（浅色 / 深色模式）选择对应的颜色：
    /// - 如果 `searchIconColor` 有设置，则对原始图标进行着色并替换显示；
    /// - 如果 `searchIconColor` 为 `nil`，则恢复原始默认图标。
    /// - 注意：图标的着色是通过将原图作为模板（`isTemplate = true`）后重新绘制实现的。
    private func updateSearchIcon() {
        // 1. 获取 searchButtonCell（即放大镜图标所在的按钮 Cell）
        guard let cell = self.cell as? NSSearchFieldCell,
              let btnCell = cell.searchButtonCell else { return }

        // 2. 仅在第一次调用时备份原始图标，用于后续恢复
        if originalSearchImage == nil {
            originalSearchImage = btnCell.image?.copy() as? NSImage
        }
        
        // 3. 根据系统外观选择颜色
        let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let colorToUse = isDark ? searchIconColorDark : searchIconColorLight
        // 4. 对原图进行模板着色
        if let src = originalSearchImage {
            src.isTemplate = true
            btnCell.image = src.withTintColor(colorToUse)
        }
        // 5. 请求重绘，确保界面立即刷新显示最新的图标
        needsDisplay = true
    }
    
    
    
    
}


//MARK: - NSSearchFieldDelegate
extension LCSearchField: NSSearchFieldDelegate {
    
    // 开始编辑
    public func controlTextDidBeginEditing(_ obj: Notification) {
//        updateBorder()
    }
    
    // 结束编辑
    public func controlTextDidEndEditing(_ obj: Notification) {
//        updateBorder()
    }
    
}
