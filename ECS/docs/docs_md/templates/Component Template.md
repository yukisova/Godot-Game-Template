---
title: "{{title}}"
author: "{{author:Sora}}"
date: "{{date:YYYY-MM-DD}}"
tags: 
  - Component
  - 
aliases:
  - 
cssclass: "component"
---

# {{title}}

## 📋 基本信息

- **文件路径**: `component/{{folder}}/{{file}}.gd`
- **继承关系**: `IComponent → {{component_class}}`
- **功能描述**: {{description}}

## ⚙️ 配置参数

```gdscript
## 组件基础配置
@export var component_name: String = "{{component_name}}"

## 组件特定配置
{{component_config}}
```

## 🔗 依赖关系

- **依赖组件**: {{dependencies}}
- **协作组件**: {{collaborations}}
- **扩展系统**: {{extensions}}

## 🔧 API接口

```gdscript
## 组件初始化
func component_init() -> void:
    super.component_init()
    {{init_code}}

## 组件重置
func component_reset() -> void:
    super.component_reset()
    {{reset_code}}

## 组件特定方法
{{api_methods}}
```

## 📝 使用示例

```gdscript
## 基本使用示例
var {{component_var}} = {{component_class}}.new()
{{usage_example}}
```

## 📊 性能注意事项

{{performance_notes}}

## 🔗 Related Components

{{related_components}}

---

## 📝 Notes

> [!info] 组件说明
> {{component_notes}}

> [!tip] 使用建议
> {{usage_tips}}

---

#Component #{{tag_category}} #ECS
