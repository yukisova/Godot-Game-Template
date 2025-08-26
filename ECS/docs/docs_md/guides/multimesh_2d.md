### MultiMeshInstance2D 使用与 MeshInstance2D 对比

本示例场景展示了在 2D 中如何使用 MultiMeshInstance2D 进行高效的批量渲染，并与逐个创建 MeshInstance2D 节点的方式进行对比。

- **场景路径**: `scene/launcher/test/test_multimesh_2d.tscn`
- **脚本**: `scene/launcher/test/test_multimesh_2d.gd`

#### 运行与交互
- **0**: 同时显示 MultiMesh 与 Mesh 节点
- **1**: 仅显示 MultiMeshInstance2D
- **2**: 仅显示 MeshInstance2D 节点
- **Enter/Space (ui_accept)**: 重新随机生成实例
- **Delete (ui_text_delete_next)**: 清空实例

屏幕左上角会显示实例数量与 FPS，用于粗略观察两种方式的性能差异（实例数量升高时差异更明显）。

#### 如何使用 MultiMeshInstance2D
1. 创建 `MultiMeshInstance2D` 节点。
2. 构建一个基础 `Mesh`（如 `QuadMesh` 或 `CircleMesh`）。
3. 创建并配置 `MultiMesh`：
   - `transform_format = MultiMesh.TRANSFORM_2D`
   - `color_format = MultiMesh.COLOR_8BIT`（如需每实例颜色）
   - `mesh = 你的 Mesh`
   - `instance_count = 实例数`
4. 对每个实例调用：
   - `set_instance_transform_2d(i, Transform2D(...))`
   - `set_instance_color(i, Color(...))`（可选）
5. 将 `MultiMesh` 赋给 `MultiMeshInstance2D.multimesh`。

示例脚本中使用随机位置、旋转与缩放，并设置了每实例颜色，方便观察。

#### 与 MeshInstance2D 的区别与取舍
- **渲染效率**: MultiMeshInstance2D 通过 GPU Instancing 一次性绘制大量相同 Mesh 的实例，极大减少 Draw Calls；而成千上万个 `MeshInstance2D` 节点会产生大量节点与绘制开销。
- **每实例属性**: MultiMesh 支持每实例 `Transform` 与 `Color`；若需要更多自定义数据，可使用 `custom_data_format` 并在着色器中读取。
- **脚本与节点功能**: MultiMesh 的实例不是节点，无法各自挂脚本、信号或独立的子树；如果需要逐个实例具有复杂行为、碰撞体或独立生命周期，使用单独的 `MeshInstance2D`（或实体预制体）更合适。
- **材质**: MultiMesh 所有实例共享同一 `Mesh/Material` 资源；想要完全不同的材质/纹理需要拆分为多个 MultiMesh 或使用纹理图集与实例数据在着色器端区分。

#### 示例中的可配置项
- `instance_count`: 实例数量
- `use_circle_mesh`: 切换 `QuadMesh` 与 `CircleMesh`
- `primitive_size`: 基础图元尺寸
- `random_seed`: 固定随机种子，便于对比

#### 何时使用 MultiMeshInstance2D
- 地图中大量重复装饰、粒子般的简易几何体、海量子弹/特效的纯渲染版本等。
- 需要极致渲染性能且单个实例无需节点化行为时。

#### 何时使用 MeshInstance2D
- 每个实例都需要独立脚本、动画、碰撞、交互或复杂的节点组合时。


