## 对象池,基于子弹池进行改造
extends ISystem

@export var tempPrefabs: Dictionary[String, PackedScene] ## 需要生成的预制体
var pools: Dictionary[String, Array] = {}
var initialSize = 20



#// 子弹池
#using Godot;
#using System.Collections.Generic;
#
#// 子弹池的要求：子弹发射正常，同时子弹要求同时
#public partial class TempEntityPool : Node, ISystem
#{
	#[Export] private Godot.Collections.Dictionary<BulletType, PackedScene> _bulletPrefabs; //子弹预制体
	#private Dictionary<BulletType, Queue<IBullet>> _pools = new(); // 子弹池队列
	#private int _initialSize = 20; // 最大数量
	#private Node entityTempContainer => GetTree().CurrentScene.GetNode<Node>("EntityTempContainer");
#
	#private IBullet CreateBullet(BulletType type) // 初始化的时候创建子弹
	#{
		#var instance = _bulletPrefabs[type].Instantiate<IBullet>(); // 实例化子弹
		#instance.bulletType = type;
		#entityTempContainer.AddChild(instance as Node); // 将实例化的子弹加入节点内，但是不到需要使用的时候绝不会进行释放
		#(instance as Node).ProcessMode = Node.ProcessModeEnum.Disabled; // 设置进程模式为
		#(instance as CanvasItem).Hide();
		#return instance;
	#}
#
	#public IBullet Get(BulletType type) // 获取子弹
	#{
		#if (_pools[type].Count == 0) // 如果没有创建子弹，则新建子弹
		#{
			#return CreateBullet(type);
		#}
#
		#var bullet = _pools[type].Dequeue(); // 获取子弹后将子弹从待用队列内移出
		#(bullet as Node).ProcessMode = Node.ProcessModeEnum.Inherit; // 
		#(bullet as CanvasItem).Show();
		#return bullet;
	#}
#
	#public void Return(IBullet bullet) // 子弹用完之后回归
	#{
		#var node = bullet as CanvasItem;
		#node.ProcessMode = ProcessModeEnum.Disabled;
		#node.Hide();
		#_pools[bullet.bulletType].Enqueue(bullet);
	#}
#
	#public void Initialize()
	#{
		#foreach (var kvp in _bulletPrefabs.Keys) // 针对每一个可能的子弹，设计对应的对象池
		#{
			#var queue = new Queue<IBullet>(); // 队列
			#for (int i = 0; i < _initialSize; i++)
			#{
				#var bullet = CreateBullet(kvp); // 每一个子弹创建十个预制对象
				#queue.Enqueue(bullet);
			#}
			#_pools.Add(kvp, queue);
		#}
	#}
#
	#public void Update() {}
#
#}
#
#public enum BulletType 
#{
	#PistolNormal,
	#ShotgunNormal,
	#MachineNormal,
	#Round,
	#Ammo,
	#Shell,
	#Ice,
	#Laser
#}
