## @editing: Sora [br]
## @describe: 创建画布基类 - UI界面的通用创建容器
##
## 该基类为所有动态创建的UI界面提供统一的基础框架：
## - 标准化的窗口生命周期管理
## - 统一的窗口关闭信号接口
## - 可扩展的UI创建模式
##
## 主要功能：
## - 提供窗口关闭的标准信号
## - 作为各种弹窗和设置界面的基类
## - 支持动态创建和销毁的UI管理
##
## 使用场景：
## - 设置面板的基类
## - 对话框界面的基类
## - 弹出式UI组件的基类
## - 模态窗口的统一管理
##
## 信号机制：
## - window_closed: 通知外部窗口已关闭
## - 支持链式事件处理和清理
class_name CreationCanvas
extends Control

#region 窗口信号

## 窗口关闭信号
## 当UI界面被关闭时发出，用于通知父级进行清理
@warning_ignore("unused_signal")
signal window_closed

#endregion
