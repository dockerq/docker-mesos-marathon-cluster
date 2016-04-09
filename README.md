#常见错误
- 每台机器后要配置`/etc/hosts`,加上`ip hostname`

# 原理图
- 基础设施层

![](http://7xo6ve.com1.z0.glb.clouddn.com/cluster-architecure.png)

这里用到了3台机器，host是主机，机器名为`test000`（下面简称“test000”）

`test001`是指用vagrant启动的虚拟机，机器名为test001（下面简称“test001”）

`test002`是指用vagrant启动的虚拟机，机器名为test002（下面简称“test002”）

- 应用层
![](http://7xo6ve.com1.z0.glb.clouddn.com/app-architecure.svg)

如图，把宿主机作为master，先安装[vagrant](https://www.vagrantup.com/downloads.html)和[virtualbox](https://www.virtualbox.org/wiki/Downloads)

# 依赖软件
- docker

因为所有的应用都是运行在docker容器中的，所以3台机器都需要安装docker，这里笔者使用的是`1.10.1-0~trusty`。使用mesos slave调度docker容器时，因为mesos slave运行在docker中，所以需要在**mesos slave镜像中也安装docker**并且docker的版本要和主机上的docker版本一直，否则会报奇怪的错误。

- ansible 2.0.0
- vagrant

用`vagrant`启动的虚拟机默认使用`vagrant`作为用户名。而ansible在与3台机器交互的时候要指定用户名，为了方便管理，**我的pc主机`test000`也要设置一个用户vagrant**

```
sudo useradd -m -s /bin/bash vagrant
sudo passwd vagrant
（输入密码）

su （切换到超级用户）
echo vagrant ALL=NOPASSWD:ALL >> /etc/sudoers
```
`echo vagrant ALL=NOPASSWD:ALL >> /etc/sudoers`这条命令使得vagrant用户执行`sudo`时不需要输入密码。这样做是因为：“vagrant启动的test001和test002机器上的vagrant sudo不需要输入密码，将3台机器统一方便下面`ansible脚本执行`”

- virtualbox
- ubuntu 14.04 64bit os

# 步骤
## setup node
使用vagrant新建两个node

node1 Vagrantfile：
```
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "test001"
  config.vm.network "public_network"
  config.vm.synced_folder "/publicdata/commondata", "/vagrant"

  config.vm.provider "virtualbox" do |v|
    v.name = "test01_vm"
        v.memory = 2048
        v.cpus = 1
  end
end
```

node2 Vagrantfile：
```
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "test002"
  config.vm.network "public_network"
  config.vm.synced_folder "/publicdata/commondata", "/vagrant"

  config.vm.provider "virtualbox" do |v|
    v.name = "test02_vm"
        v.memory = 2048
        v.cpus = 1
  end
end
```

**注意：**

- 为了方便共享文件，我设置了同步目录`config.vm.synced_folder "/publicdata/commondata", "/vagrant"`，`/publicdata/commondata`指host上的目录（你需要把它设置成你自己的，或者直接去掉这个设置），`/vagrant`指虚拟机中的目录。[详情参考这里](https://www.vagrantup.com/docs/synced-folders/basic_usage.html)
- 运行`vagrant up`就会启动并初始化一个vm，因为我设置的`网络模式为公网`，这里会有一个选项让你选择`桥接`到那个网卡（public network模式下会有这个选项），这里选择一定要让test000，test001和test002都在同一个网段里。

## ansible初始化和部署
### 安装
- 这里介绍的是ubuntu：14.04下比较方便的安装方法

```
sudo apt-get update
sudo apt-get install python-setuptools
sudo easy_install ansible
```

### 配置脚本
**注意：**运行ansible脚本前需要先配置ansible。

下面是我的ansible脚本主目录：
```
adolph@dev:blog01$ tree -L 2
.
├── ansible.cfg
├── group_vars
│   └── all
├── hosts
├── main.yml
└── roles
    ├── init
    ├── master
    └── slaves
```
ansible.cfg的配置很简单，如下：
```
[defaults]
host_key_checking=False
remote_user = vagrant
```

[ansible脚本地址](https://github.com/DHOPL/docker-mesos-marathon-cluster/tree/master/ansible-scripts)

```
git clone
cd docker-mesos-marathon-cluster/ansible-scripts
修改hosts中的ip
sudo ansible-playbook -i hosts main.yml
```

运行结束后在浏览器输入test000的ip（我这里是192.168.10.130）对应的mesos和marathon的地址：

- mesos: 192.168.10.130:5050
- marathon: 192.168.10.130:8080
如果无法访问检查`防火墙设置`

## demo
- 浏览mesos和marathon页面

![](http://7xo6ve.com1.z0.glb.clouddn.com/demo01.gif)

- 使用marathon在mesos上部署2048

![](http://7xo6ve.com1.z0.glb.clouddn.com/demo02.gif)


## 相关资料
- [docker mesos master image](https://github.com/DHOPL/docker-mesos)
- [docker marathon image](https://github.com/DHOPL/docker-marathon)
- [docker mesos slave image](https://github.com/DHOPL/mesos_slave)
- [docker zookeeper image](https://github.com/DHOPL/docker-zookeeper)

## 改进
1. 设置mesos参数，使得运行在mesos上的容器挂掉之后在设置的时间内删除挂掉的容器
2. 研究marathon的`health care`机制，看看为什么运行的容器拿不到健康状态
3. 添加对每个虚拟机的监控功能
4. 基础镜像是`ubuntu:14.04`，镜像体积太大了，对于想zookeeper这样的简单镜像，可以改为使用alpine作为基础镜像重新构建镜像
