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
            guard fillColor != oldValue else { return }
            layer?.backgroundColor = fillColor.cgColor
        }
    }
    
    /// 边框颜色
    public var borderColor: NSColor = .black.withAlphaComponent(0.3) {
        didSet {
            // 只有当颜色真正改变时才更新
            guard borderColor != oldValue else { return }
            updateBorder()
        }
    }
    
    /// 边框宽度
    public var borderWidth: CGFloat = 1 {
        didSet {
            guard borderWidth != oldValue else { return }
            updateBorder()
        }
    }
    
    /// 圆角
    public var cornerRadius: CGFloat = .greatestFiniteMagnitude {
        didSet {
            guard cornerRadius != oldValue else { return }
            updateCornerRadius()
        }
    }
    
    /// 焦点环样式（默认 `.default`）
    public var customFocusRingType: NSFocusRingType = .default {
        didSet { focusRingType = customFocusRingType }
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
    
    
    /// 是否正在编辑（拥有第一响应者）
    private(set) var isEditing: Bool = false {
        didSet {
            guard isEditing != oldValue else { return }
            DispatchQueue.main.async { [weak self] in
                self?.updateBorder()
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
  
    
    // MARK: - 监听焦点变化
    
    // 成为第一响应者
    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        isEditing = result && self.window?.firstResponder == self.currentEditor()
        return result
    }
    // 辞去第一响应者
    public override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        isEditing = false   // 失去第一响应者时总是设为非编辑状态
        return result
    }
    
    // MARK: - 当控件添加到 window 时刷新边框
    public override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        // 移除旧通知，防止重复
        NotificationCenter.default.removeObserver(self, name: NSWindow.didResignKeyNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSWindow.didBecomeKeyNotification, object: nil)
        
        // 只在有窗口时添加监听
        guard let window = self.window else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey(_:)),
                                               name: NSWindow.didResignKeyNotification, object: window)
        // 监听窗口成为 key
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(_:)),
                                               name: NSWindow.didBecomeKeyNotification, object: window)
    }
    
    
    /// 重写 `cancelOperation` 方法，当按下 ESC 键时调用
    ///
    /// 通过将窗口的 `firstResponder` 设为 `nil` 来取消焦点。
    /// 该方法在用户按下 ESC 键时被触发，使搜索框失去焦点。
    public override func cancelOperation(_ sender: Any?) {
        self.window?.makeFirstResponder(nil)
        // 结束编辑状态，恢复边框颜色
        if isEditing {
            isEditing = false
#if DEBUG
            print("🔸 LCSearchField lost editing because ESC pressed")
#endif
        }
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
        focusRingType = customFocusRingType  // 初始化焦点坏
        (cell as? NSTextFieldCell)?.drawsBackground = false
        
        wantsLayer = true
        layer?.masksToBounds = true
        
        // 先设置所有属性
        layer?.cornerRadius = cornerRadius
        layer?.backgroundColor = fillColor.cgColor
        
        isEditing = false // 确保初始状态为非编辑
        
        // 最后统一更新一次
        updateBorder()
        updateCornerRadius()
    }
    
    
    /// 更新边框
    private func updateBorder() {
        layer?.borderWidth = borderWidth
#if DEBUG
        print("更新边框: isEditing=\(isEditing), 颜色=\(isEditing ? "蓝色" : "默认")")
#endif
        // 编辑、非编辑状态设置不同的颜色
        layer?.borderColor = isEditing ? NSColor.controlAccentColor.cgColor : borderColor.cgColor
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


//MARK: - Handle notifcation
extension LCSearchField {
    
    // 处理窗口失去焦点通知，- 当应用窗口不再是活动窗口（失去键盘焦点）时调用
    @objc private func windowDidResignKey(_ no: Notification) {
        // 窗口失去焦点时，搜索框应该恢复非编辑状态
        isEditing = false
    }

    // 处理窗口获得焦点通知 ，- 当应用窗口成为活动窗口（获得键盘焦点）时调用
    @objc private func windowDidBecomeKey(_ no: Notification) {
        // 窗口获得焦点时，检查搜索框是否是当前编辑者
        isEditing = self.window?.firstResponder == self.currentEditor()
    }
    
}
