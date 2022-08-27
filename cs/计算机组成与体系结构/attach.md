```mermaid
graph LR
计算机组成与体系结构 --> 发展历史
发展历史 --> x[1.硬件集成度\storedProgramComputer\ISA\总线\微处理器]
发展历史 --> A(2.RISC\ILP\Cache) 
A === A1(CISC指令集太复杂\研发成本高)
A === A2(RISC降低CPU复杂度\降低功耗)
A === A3(ILP基于RISC应用更先进的体系结构技术)
A === A4(VLIW兼容性差\指令集升级困难\放弃乱序执行)

发展历史 --> A5(3.DLP\TLP\RLP)

计算机组成与体系结构 --> B(计算平台的Flynn分类法)

B --> SISD:标准的冯诺伊曼结构,04年以前的早期体系结构就是实现了ILP的SISD
B --> MISD(MISD:加解密等特殊场景\无商用案例)
B --> SIMD(SIMD:DLP对应的实现架构,汇编调用\数据模型不灵活)
B --> MIMD(MIMD:TLP\RLP对应的实现架构,实现难度大)

计算机组成与体系结构 --> C(storeProgramComputer)
C --> 硬件结构
硬件结构 --> yjjg(CPU即ALU\Register\控制器\片内互连部件+MEM+IO+系统互联部件)
C --> 取指和执行
取指和执行 --> 指令
指令 === 操作码
操作码 === czm(CPU与MEM交互\CPU与IO交互\数据处理\跳转控制)
指令 === 地址码
取指和执行 --> 指令周期(指令周期:执行1条指令的时间,包含取址\执行\中断周期)
指令周期 --> C1(机器周期或CPU周期以CPU访问一次内存的时间为基准)
C1 --> 机器周期包含多个时钟周期
C --> 中断与IO:中断解决IO速度和CPU相差太大的问题

计算机组成与体系结构 --> ccsb(存储设备:存储位置\分层结构\存储介质\易失性\存取方式)

计算机组成与体系结构 --> srsc(输入输出:IO模块与IO寻址\IO操作技术\IO处理器)

计算机组成与体系结构 --> cache

计算机组成与体系结构 --> ILP

计算机组成与体系结构 --> DLP

计算机组成与体系结构 --> TLP
TLP --> tlps(CacheCoherent\MemoryConsistencyModel)

计算机组成与体系结构 --> xnzb(性能指标:机器字长\运算速度\主存大小\外部设备容量与存取速度)

```
