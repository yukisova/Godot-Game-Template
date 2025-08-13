# 栈溢出递归问题修复报告

## 问题描述
用户报告了`Stack overflow (stack size: 1024). Check for infinite recursion in your script.`错误，定位到static_map中的溢出错误。

## 根本原因分析
发现了两个相互调用形成的无限递归循环：

### 1. StaticMap中的递归循环
```gdscript
# 原始问题代码：
@export_range(0, 1) var time: float:
    set(value):
        time = value  # ❌ 再次调用setter
        filter_changed.emit(time)

func time_change_filter(point: float):
    time = point  # ❌ 触发setter
    map_filter.color = filter_gradient.gradient.sample(time)

# 在_enter_tree中：
filter_changed.connect(time_change_filter)  # ❌ 信号连接
```

### 2. 时间子系统的循环调用
```gdscript
# SSTimeLoop中：
var real_time: int:
    set(v):
        real_time = v % 1440
        time_updated.emit(real_time)
        # ❌ 通过信号调用StaticMap.filter_changed
        if SMapData.current_map:
            SMapData.current_map.filter_changed.emit(real_time / 1440.0)
```

### 递归调用链
1. SSTimeLoop.real_time setter → 发出信号
2. StaticMap.filter_changed信号 → time_change_filter()
3. time_change_filter() → 设置time属性
4. StaticMap.time setter → 发出filter_changed信号
5. 回到步骤2，形成无限循环

## 修复方案

### 1. 修复StaticMap的递归问题
```gdscript
# ✅ 修复后的代码：
@export_range(0, 1) var time: float:
    set(value):
        if time != value:  # 避免重复设置
            time = value
            # 直接更新滤镜，避免信号循环
            _update_filter(time)

# 移除信号连接，改为直接方法调用
func time_change_filter(point: float):
    # 直接更新滤镜，不通过time属性setter避免循环
    _update_filter(point)

# 新增内部方法，避免递归
func _update_filter(time_value: float):
    if map_filter and filter_gradient:
        map_filter.color = filter_gradient.gradient.sample(time_value)
        print("地图滤镜: 时间更新为 ", time_value)
```

### 2. 修复时间子系统的循环调用
```gdscript
# ✅ 修复后的代码：
var real_time: int:
    set(v):
        var new_time = v % 1440
        if real_time != new_time:  # 避免重复更新
            real_time = new_time
            time_updated.emit(real_time)
            # 直接调用地图的滤镜更新方法，避免信号循环
            if SMapData.current_map:
                SMapData.current_map.time_change_filter(real_time / 1440.0)
```

### 3. 移除不必要的信号
```gdscript
# 移除了StaticMap中的filter_changed信号，因为不再需要
# signal filter_changed(point: float)  # ❌ 已移除
```

## 修复效果

1. **消除递归循环**：改为直接方法调用，避免信号循环
2. **添加重复检查**：通过值比较避免不必要的更新
3. **提高性能**：减少信号开销，直接方法调用更高效
4. **增强稳定性**：消除栈溢出风险，系统更加稳定

## 验证方法

1. 运行游戏，观察是否还有栈溢出错误
2. 检查昼夜循环是否正常工作
3. 确认时间系统和地图滤镜同步正常
4. 验证性能是否有所改善

## 注意事项

- 此修复保持了原有的功能逻辑
- 昼夜循环和时间系统功能不受影响
- 如需要恢复信号机制，需要设计防递归保护
- 建议在类似的setter中始终添加值变化检查

## 相关文件

- `/resource/node_template/map/static_map.gd`
- `/system/s_blackboard/sub_system/ss_time_loop/ss_time_loop.gd`

修复完成时间：$(date)






