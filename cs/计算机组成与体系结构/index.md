# 计算机组成与体系结构

```mermaid
graph LR
计算机组成与体系结构 --> 发展历史
发展历史 --> 1.硬件集成度\storedProgramComputer\ISA\总线\微处理器
发展历史 --> A(2.RISC\ILP\Cache)
A === CISC指令集太复杂\研发成本高
A === RISC降低CPU复杂度\降低功耗
A === ILP基于RISC应用更先进的体系结构技术\应用cache优化机制
A === VLIW兼容性差\指令集升级困难\放弃乱序执行
发展历史 --> 3.DLP\TLP\RLP

计算机组成与体系结构 --> B(计算平台的Flynn分类法)
B --> SISD:标准的冯诺伊曼结构,04年以前的早期体系结构就是实现了ILP的SISD
B --> MISD:加解密等特殊场景\无商用案例
B --> SIMD:DLP对应的实现架构,汇编调用\数据模型不灵活
B --> MIMD:TLP\RLP对应的实现架构,实现难度大

计算机组成与体系结构 --> C(storeProgramComputer)
C --> 硬件结构 --> CPU即ALU\Register\控制器\片内互连部件+MEM+IO+系统互联部件
C --> 取指和执行 --> 指令
指令 === 操作码 === CPU与MEM交互\CPU与IO交互\数据处理\跳转控制
指令 === 地址码
取指和执行 --> 指令周期(指令周期:执行1条指令的时间,包含取址\执行\中断周期)
指令周期 --> 机器周期或CPU周期以CPU访问一次内存的时间为基准 --> 机器周期包含多个时钟周期
C --> 中断与IO:中断解决IO速度和CPU相差太大的问题

计算机组成与体系结构 --> 存储设备:存储位置\分层结构\存储介质\易失性\存取方式

计算机组成与体系结构 --> 输入输出:IO模块与IO寻址\IO操作技术\IO处理器

计算机组成与体系结构 --> cache
cache --> 缓存读机制:先读cache再读主存
cache --> 缓存写机制:命中时同时更新+未命中时写主存/命中时写回+未命中时主存调入cache
cache --> 缓存替换算法:最优替换/FIFO/Random/LRU/Clock
cache --> 存储结构:TAG+Dirty+Valid+data
cache --> 映射方式:直接/全关联/k路组关联
cache --> 三级缓存设计:L1/L2/L3
cache --> 缓存优化:WayPrediction/PipelineCache/多组缓存/Non-blockingCache/CriticalWordFirst/EarlyRestart/合并写缓冲区/硬件预取/软件预取/编译器优化

计算机组成与体系结构 --> ILP(ILP:主要基于Pipeline与循环级并行)
ILP --> 依靠硬件来帮助动态发现和开发井行:硬件动态调度即乱序执行+多发射/超标量+分支预测+推测 === 商业上较成功
ILP --> 依靠软件技术在编译时静态发现并行:软件静态调度即展开循环+多发射VLIW

计算机组成与体系结构 --> DLP === 向量体系结构/多媒体SIMD指令集扩展/图形处理单元GPU

计算机组成与体系结构 --> TLP
TLP --> SMT/HT
TLP --> SMP
SMP === 体系架构:UMA/NUMA
SMP === 实现方式:CMP/多socket
TLP --> P(TLP面临的问题和解决方案)
P --> CacheCoherent(CacheCoherent:解决多处理器场景下各个处理器本地Cache导致的数据多副本问题)
CacheCoherent === 总线窃取 === MESI
CacheCoherent === 基于目录的协议
P --> MemoryConsistencyModel
MemoryConsistencyModel === 导致指令执行顺序变动的编译器/硬件优化
MemoryConsistencyModel === 写原子性StoreAtomicity问题,即处理器的写操作是否同时被所有处理器看到

计算机组成与体系结构 --> 性能指标:机器字长\运算速度\主存大小\外部设备容量与存取速度

```
[01.前言-CA_CO_微机原理与接口](01.前言-CA_CO_微机原理与接口.md)

[02.体系结构的发展1-早期时代](02.体系结构的发展1-早期时代.md)

[03.体系结构的发展2-RISC_ILP_Cache](03.体系结构的发展2-RISC_ILP_Cache.md)

[04.体系结构的发展3-DLP_TLP_RLP](04.体系结构的发展3-DLP_TLP_RLP.md)

[05.计算平台的Flynn分类法md](05.计算平台的Flynn分类法md.md)

[06.体系结构研究对象-ISA](06.体系结构研究对象-ISA.md)

[07.StoredProgramComputer-结构与功能](07.StoredProgramComputer-结构与功能.md)

[08.StoredProgramComputer-指令的取和执行](08.StoredProgramComputer-指令的取和执行.md)

[09.StoredProgramComputer-中断与IO](09.StoredProgramComputer-中断与IO.md)

[10.StoredProgramComputer-系统互连_总线](10.StoredProgramComputer-系统互连_总线.md)

[11.存储设备-概述](11.存储设备-概述.md)

[12.存储设备-RAM](12.存储设备-RAM.md)

[13.存储设备-ROM](13.存储设备-ROM.md)

[14.存储设备-磁盘](14.存储设备-磁盘.md)

[15.存储设备-磁盘接口](15.存储设备-磁盘接口.md)

[16.存储设备-磁盘-访问优化](16.存储设备-磁盘-访问优化.md)

[17.存储设备-磁盘阵列RAID](17.存储设备-磁盘阵列RAID.md)

[18.输入输出-IO模块与IO寻址](18.输入输出-IO模块与IO寻址.md)

[19.输入输出-IO操作技术](19.输入输出-IO操作技术.md)

[20.输入输出-IO通道和IO处理器](20.输入输出-IO通道和IO处理器.md)

[21.cache原理-时间空间的局部性](21.cache原理-时间空间的局部性.md)

[22.cache原理-缓存的读与写](22.cache原理-缓存的读与写.md)

[23.cache原理-缓存替换算法](23.cache原理-缓存替换算法.md)

[24.cache-存储结构与映射方式](24.cache-存储结构与映射方式.md)

[25.cache-三级缓存设计](25.cache-三级缓存设计.md)

[26.cache-缓存优化技术](26.cache-缓存优化技术.md)

[27.ILP-指令集并行](27.ILP-指令集并行.md)

[28.DLP-数据级并行](28.DLP-数据级并行.md)

[29.TLP-线程级并行](29.TLP-线程级并行.md)

[30.TLP-CacheCoherent](30.TLP-CacheCoherent.md)

[31.TLP-MemoryModel](31.TLP-MemoryModel.md)

[32.性能指标-机器字长与OS位数](32.性能指标-机器字长与OS位数.md)

[33.性能指标-衡量计算机性能的因素](33.性能指标-衡量计算机性能的因素.md)

