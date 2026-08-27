# SpiceNest 产品规格说明

> 版本：0.3 | 日期：2026-08-27
> 状态：规划中，待实际使用验证后迭代

---

## 一、产品定位

### 1.1 一句话定义

**SpiceNest 是一个随时随地可查的 LTspice 参考助手**——全局热键一按就出，输入关键词秒出结果，查完就走，不耽误仿真。

### 1.2 解决的核心问题

| 用户痛点 | 现有方案的不足 | SpiceNest 的解法 |
|---------|--------------|-----------------|
| 仿真指令记不住语法 | 翻官方帮助太慢，网上搜结果杂 | 一搜即出完整语法 + 可复制示例 |
| 元器件参数看不懂 | 只有参数名，不知道什么意思、取什么值 | 每个参数带含义、典型值、影响说明 |
| 报错了不知道怎么办 | 报错信息英文，搜不到解决方案 | 粘贴报错直接匹配原因和解决步骤 |
| 公式算起来麻烦 | 每次手算或开计算器 | 内置公式计算器，输入数值直接出结果 |
| 常用电路忘了怎么搭 | 从零画浪费时间 | 拓扑速查，公式 + 取值建议 + 最小片段 |
| 操作技巧记不住 | 每次都要重新摸索 | 技巧卡片，3-5 步说清楚怎么做 |

### 1.3 与 KeyHub 的关系

| 维度 | KeyHub | SpiceNest |
|------|--------|-----------|
| 定位 | 多软件快捷键速查 | LTspice 专属参考助手 |
| 核心问题 | "快捷键是什么" | "这个怎么用、什么意思、怎么办" |
| 内容形式 | 快捷键卡片、指令列表 | 参考卡片（语法/参数/错误/公式/技巧/拓扑） |
| 覆盖范围 | 多软件（LTspice/Altium/KiCad 等） | 只做 LTspice，做深做透 |
| 关系 | 互补 | 互补 |

**互通场景：**
- 在 SpiceNest 查参数时，需要查 LTspice 快捷键 → 跳 KeyHub
- 在 KeyHub 看到 LTspice 指令，想看详细用法 → 跳 SpiceNest

### 1.4 设计原则

1. **查完就走**：不做教程、不做长文，结果卡片精炼到一眼能看完
2. **搜索优先**：打开就是搜索框，不搞多级菜单导航
3. **可复制**：所有指令、代码、公式示例一键复制
4. **离线可用**：所有数据本地存储，不联网
5. **与 Nexus 一致**：遵循 Nexus 规范，体验和 KeyHub 统一

---

## 二、目标用户与使用场景

### 2.1 用户画像

**1. 电子工程师（日常使用）**
- 有电路基础，经常用 LTspice 做仿真
- 需求：查指令语法、参数含义、报错解决、公式计算
- 痛点：记不住所有指令参数，每次查官方文档太慢

**2. 学生（偶尔使用）**
- 做课程设计/毕业设计用 LTspice
- 需求：入门操作技巧、常用电路拓扑、基础公式
- 痛点：老师没教过，网上资料零散

**3. 嵌入式开发者（特定场景）**
- 需要仿真电源、信号调理等电路
- 需求：电源拓扑、运放电路、滤波器设计公式
- 痛点：不常做仿真，每次都要重新学

### 2.2 使用场景

- **写仿真指令时**：忘了 `.tran` 的参数顺序，一搜就出
- **设置元器件模型时**：BJT 的 `VAF` 是什么意思？典型值多少？
- **仿真报错时**：复制 "Time step too small"，直接出解决方案
- **算电路参数时**：RC 滤波截止频率是多少？输入 R 和 C 直接算
- **搭电路时**：反相放大器增益怎么算？电阻怎么取？
- **忘了操作时**：怎么添加第三方模型？怎么导出波形数据？

---

## 三、核心功能模块

### 3.1 模块一：全局搜索（核心入口）

**打开应用 = 打开搜索框**，输入关键词实时出结果。

#### 搜索特性

- **实时搜索**：输入即搜，无需回车
- **模糊匹配**：支持中英文混合、拼音、缩写
  - 输入 `tran` → 匹配 `.tran` 指令 + "Time step too small" 错误
  - 输入 `增益` → 匹配运放参数 + 反相/同相放大器拓扑 + `.meas` 测增益
  - 输入 `vaf` → 匹配 BJT 的 VAF 参数
- **结果分组**：按内容类型分组展示（指令/参数/错误/公式/技巧/拓扑）
- **搜索历史**：最近 10 条搜索记录，打开默认显示
- **键盘操作**：上下键选择结果，回车查看详情，ESC 关闭窗口

#### 搜索结果页布局

```
┌─────────────────────────────────────────┐
│ 🔍 [tran................]               │  ← 搜索框
├─────────────────────────────────────────┤
│ 📋 仿真指令 (2)                          │
│   ┌─────────────────────────────────┐   │
│   │ .tran — 瞬态仿真                  │   │
│   │ 语法: .tran tstart tstop [tmax [tstep]]│   │
│   │ 示例: .tran 0 10m 1u    [复制]   │   │
│   └─────────────────────────────────┘   │
│   .trans — （无此指令，你是想说 .tran?） │
├─────────────────────────────────────────┤
│ ⚠️ 常见错误 (1)                          │
│   ┌─────────────────────────────────┐   │
│   │ Time step too small — 时间步长过小 │   │
│   │ 原因: 电路刚性问题，收敛困难        │   │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

### 3.2 模块二：仿真指令库

覆盖 LTspice 所有常用仿真指令，每个指令一张卡片。

#### 指令清单

| 分类 | 指令 | 说明 |
|------|------|------|
| 基本分析 | `.op` | 直流工作点分析 |
| | `.tran` | 瞬态仿真 |
| | `.ac` | 交流小信号扫描 |
| | `.dc` | 直流扫描 |
| | `.noise` | 噪声分析 |
| | `.four` | 傅里叶分析 |
| 参数扫描 | `.step` | 参数扫描（线性/对数/列表） |
| | `.temp` | 温度扫描 |
| 测量 | `.meas` | 自动测量参数 |
| 初始条件 | `.ic` | 设置初始条件 |
| | `.nodeset` | 设置节点电压猜测值 |
| 输出控制 | `.save` | 保存指定变量 |
| | `.plot` | 绘图控制 |
| | `.print` | 输出控制 |
| 模型与子电路 | `.model` | 定义元器件模型 |
| | `.subckt` / `.ends` | 子电路定义 |
| | `.include` | 包含文件 |
| | `.lib` | 加载库文件 |
| 仿真选项 | `.options` | 设置仿真选项（reltol, gmin, itl 等） |
| | `.probe` | 探针设置 |
| 其他 | `.global` | 全局节点 |
| | `.param` | 定义参数 |
| | `.func` | 定义函数 |
| | `.wave` | 波形定义 |

#### 指令卡片结构

```
┌─────────────────────────────────────────┐
│ .tran — 瞬态仿真                          │
│ 计算电路在指定时间范围内的时域响应          │
├─────────────────────────────────────────┤
│ 语法                                      │
│ .tran <tstop>                            │
│ .tran <tstart> <tstop>                   │
│ .tran <tstart> <tstop> <tmax>            │
│ .tran <tstart> <tstop> <tmax> <tstep>    │
├─────────────────────────────────────────┤
│ 参数说明                                   │
│ tstop  — 仿真停止时间（必填）              │
│ tstart — 开始保存数据的时间（默认 0）       │
│ tmax   — 最大时间步长（默认自动）           │
│ tstep  — 起始时间步长（默认自动）           │
├─────────────────────────────────────────┤
│ 示例                                      │
│ .tran 10m              仿真 0~10ms      │
│ .tran 1m 10m           跳过前 1ms        │
│ .tran 0 10m 1u         限制最大步长 1us  │
│                         [全部复制]         │
├─────────────────────────────────────────┤
│ 相关指令: .step  .meas  .ic  .options    │
│ 相关错误: Time step too small             │
└─────────────────────────────────────────┘
```

---

### 3.3 模块三：元器件参数词典

按元器件类型分类，每个参数一张卡片。

#### 覆盖的元器件类型

| 类型 | 参数数量（预计） | 关键参数 |
|------|----------------|---------|
| BJT 晶体管 | 40+ | IS, BF, VAF, BR, VAR, ISC, ISE, NK, NR, NE, NC, RB, RC, RE, CJE, CJC, TF, TR, XTF, ITF, VTF, EG, XTI, KF, AF, TNOM |
| MOSFET | 35+ | L, W, VTO, KP, GAMMA, PHI, LAMBDA, RD, RS, RG, CBD, CBS, CJ, TOX, NSUB, UO, KF, AF, TNOM |
| JFET | 15+ | VTO, BETA, LAMBDA, RD, RS, RG, CGS, CGD, PB, IS, KF, AF, TNOM |
| 二极管 | 25+ | IS, N, RS, IKF, EG, XTI, CJO, VJ, M, FC, TT, BV, IBV, NB, KF, AF, TNOM |
| 运算放大器 | 10+ | 开环增益、单位增益带宽、压摆率、输入失调电压、输入偏置电流、共模抑制比、电源抑制比、输出电阻、噪声 |
| 电阻 | 5 | 阻值、精度、温度系数、功率、封装 |
| 电容 | 6 | 容值、精度、耐压、温度系数、等效串联电阻、封装 |
| 电感 | 6 | 感值、精度、直流电阻、饱和电流、自谐频率、封装 |
| 电压源 | 8 | DC, AC, TRAN（PULSE/SINE/EXP/PWL/SFFM） |
| 电流源 | 5 | DC, AC, TRAN, 行为源 |

#### 参数卡片结构

```
┌─────────────────────────────────────────┐
│ IS — 反向饱和电流 (BJT)                   │
├─────────────────────────────────────────┤
│ 含义                                      │
│ PN 结的反向饱和电流，决定了晶体管的导通特性。│
│ IS 越大，相同 Vbe 下的集电极电流越大。      │
├─────────────────────────────────────────┤
│ 典型值: 1e-16 ~ 1e-12 A                  │
│ 默认值: 1e-16 A                           │
├─────────────────────────────────────────┤
│ 影响说明                                   │
│ IS ↑ → 相同 Vbe 下 Ic ↑ → 更容易导通       │
│ IS ↓ → 需要更大的 Vbe 才能达到相同 Ic      │
├─────────────────────────────────────────┤
│ 示例                                      │
│ .model MyNPN NPN (IS=1e-14 BF=200)      │
│                         [复制]             │
├─────────────────────────────────────────┤
│ 相关参数: BF  VAF  ISE  ISC               │
│ 相关指令: .model                           │
└─────────────────────────────────────────┘
```

---

### 3.4 模块四：错误排查库

常见仿真报错，输入错误信息直接匹配。

#### 错误清单（预计 25+）

| 错误信息 | 类别 |
|---------|------|
| Time step too small | 收敛问题 |
| Singular matrix | 电路结构问题 |
| Node ... is floating | 电路结构问题 |
| Unknown parameter | 参数错误 |
| Unknown device | 模型错误 |
| Gmin step failed | 收敛问题 |
| Source stepping failed | 收敛问题 |
| Iteration limit reached | 收敛问题 |
| Duplicate device name | 命名错误 |
| Node ... is not defined | 电路结构问题 |
| Value out of range | 参数错误 |
| Missing expression | 语法错误 |
| Syntax error | 语法错误 |
| File not found | 文件错误 |
| Library ... not found | 文件错误 |
| Subcircuit ... not found | 模型错误 |
| Model ... not found | 模型错误 |
| Temperature out of range | 参数错误 |
| Frequency out of range | 参数错误 |
| Matrix is singular | 电路结构问题 |
| Convergence problem | 收敛问题 |
| ... | ... |

#### 错误卡片结构

```
┌─────────────────────────────────────────┐
│ ⚠️ Time step too small                    │
│ 时间步长过小                               │
├─────────────────────────────────────────┤
│ 原因                                      │
│ 电路存在刚性问题（stiff），数值收敛困难。   │
│ 常见于理想开关、理想二极管、陡峭波形、      │
│ 高 Q 值谐振电路。                          │
├─────────────────────────────────────────┤
│ 解决方案                                   │
│ 1. 添加最小电导: .options gmin=1e-12      │
│ 2. 检查理想开关/二极管，添加寄生参数        │
│ 3. 增大最大时间步长: .tran 0 10m 1u       │
│ 4. 用 .ic 设置合理的初始条件               │
│ 5. 尝试 .options cshunt=1e-15             │
├─────────────────────────────────────────┤
│ 可复制指令                                 │
│ .options gmin=1e-12 cshunt=1e-15         │
│                         [复制]             │
├─────────────────────────────────────────┤
│ 相关指令: .tran  .options  .ic             │
│ 相关教程: 收敛问题排查技巧                  │
└─────────────────────────────────────────┘
```

---

### 3.5 模块五：公式速算库

常用电路公式，每个公式带一个小计算器。

#### 公式清单

| 分类 | 公式 | 说明 |
|------|------|------|
| RC 电路 | 时间常数 τ = R×C | RC 充放电 |
| | 低通截止频率 fc = 1/(2πRC) | RC 低通滤波 |
| | 高通截止频率 fc = 1/(2πRC) | RC 高通滤波 |
| RL 电路 | 时间常数 τ = L/R | RL 充放电 |
| | 截止频率 fc = R/(2πL) | RL 滤波 |
| LC 电路 | 谐振频率 f0 = 1/(2π√(LC)) | LC 谐振 |
| | 品质因数 Q = (1/R)×√(L/C) | 串联 RLC |
| | 品质因数 Q = R×√(C/L) | 并联 RLC |
| 运放电路 | 反相放大器增益 = -Rf/Rin | 反相放大 |
| | 同相放大器增益 = 1+Rf/Rg | 同相放大 |
| | 差分放大器增益 = Rf/Rin | 差分放大 |
| | 加法器输出 = -Rf×(V1/R1+V2/R2) | 加法电路 |
| | 积分器输出 = -(1/(R×C))×∫Vin dt | 积分电路 |
| | 微分器输出 = -R×C×(dVin/dt) | 微分电路 |
| | 电压跟随器增益 = 1 | 缓冲器 |
| 电源电路 | 线性稳压输出 = Vref×(1+R2/R1) | 可调稳压 |
| | Buck 输出 = Vin×D | 降压（连续模式） |
| | Boost 输出 = Vin/(1-D) | 升压（连续模式） |
| | Buck-Boost 输出 = -Vin×D/(1-D) | 升降压 |
| | 电感纹波 ΔI = (Vin-Vout)×D/(L×f) | Buck 电感纹波 |
| | 输出纹波 ΔV = ΔI/(8×C×f) | Buck 输出纹波（ESR=0） |
| 滤波器 | 一阶 RC 滚降 = -20 dB/dec | 一阶 |
| | 二阶 LC 滚降 = -40 dB/dec | 二阶 |
| | 截止频率 -3dB 点 | 通用 |
| 分压与电流 | 分压输出 = V×R2/(R1+R2) | 电阻分压 |
| | 电流镜输出 = Iin×(W2/W1) | MOS 电流镜 |
| | 欧姆定律 I = V/R | 基础 |
| 功耗与热 | 功耗 P = V×I | 基础 |
| | 电阻功耗 P = I²R = V²/R | 电阻 |
| | 结温 Tj = Ta + P×RθJA | 热计算 |
| 单位换算 | 常用前缀换算（u/n/p/f/m/k/meg/g） | 通用 |

#### 公式卡片结构（带计算器）

```
┌─────────────────────────────────────────┐
│ RC 低通滤波截止频率                        │
├─────────────────────────────────────────┤
│ 公式: fc = 1 / (2 × π × R × C)           │
├─────────────────────────────────────────┤
│ 计算器                                    │
│ R = [10____] kΩ                          │
│ C = [100___] nF                          │
│ ─────────────────────────                  │
│ fc = 159.15 Hz                            │
├─────────────────────────────────────────┤
│ 符号说明                                   │
│ R — 电阻值（Ω）                           │
│ C — 电容值（F）                           │
│ fc — 截止频率（Hz），增益下降到 -3dB 的点  │
├─────────────────────────────────────────┤
│ 相关拓扑: RC 低通滤波                      │
│ 相关公式: RC 时间常数  RC 高通截止频率      │
└─────────────────────────────────────────┘
```

---

### 3.6 模块六：操作技巧库

不是教程，是一问一答的技巧卡片，3-5 步说清楚。

#### 技巧清单（预计 30+）

| 分类 | 技巧 |
|------|------|
| 模型与库 | 怎么添加第三方元器件模型（.model / .lib） |
| | 怎么做子电路（.subckt） |
| | 怎么从厂商 SPICE 模型导入 |
| | 怎么查看和编辑内置模型 |
| 仿真控制 | 怎么用行为源（B 源） |
| | 怎么设置初始条件（.ic） |
| | 怎么做参数扫描（.step） |
| | 怎么做温度扫描（.temp） |
| | 怎么用 .meas 自动测量 |
| | 怎么优化电路参数（.step + .meas） |
| | 怎么设置仿真选项（.options）加速收敛 |
| 波形与数据 | 怎么画任意表达式的波形（V(out)*I(R1)） |
| | 怎么导出波形数据为 CSV / TXT |
| | 怎么测量幅值、频率、上升时间 |
| | 怎么测相位裕度和增益裕度 |
| | 怎么显示多个波形的差值 |
| | 怎么保存和恢复波形配置 |
| 原理图编辑 | 怎么批量修改元器件参数 |
| | 怎么对齐和排列元器件 |
| | 怎么使用层次化设计（Hierarchy） |
| | 怎么添加注释和标签 |
| | 怎么复制粘贴电路块 |
| 高级技巧 | 怎么用蒙特卡洛分析（Monte Carlo） |
| | 怎么做最坏情况分析（Worst Case） |
| | 怎么用数字器件（Digital） |
| | 怎么仿真开关电源（SMPS） |
| | 怎么做噪声分析（.noise） |
| | 怎么用傅里叶分析（.four） |
| 常见问题 | 仿真不收敛怎么办（通用排查步骤） |
| | 波形有毛刺/振荡怎么办 |
| | 仿真速度太慢怎么加速 |
| | 结果和理论计算不一致怎么排查 |

#### 技巧卡片结构

```
┌─────────────────────────────────────────┐
│ 怎么添加第三方元器件模型                    │
├─────────────────────────────────────────┤
│ 适用场景: 厂商提供了 .lib / .mod / .cir 文件 │
├─────────────────────────────────────────┤
│ 步骤                                      │
│ 1. 将模型文件放到工程目录或 LTspice 的 lib 目录 │
│ 2. 在原理图中按 F2 放置元器件，选择 "Other" │
│ 3. 双击元器件，在 Value 栏填入模型名        │
│ 4. 添加 .include 或 .lib 指令指向模型文件   │
│    .include "mymodel.lib"                  │
│ 5. 运行仿真，确认模型被正确加载              │
├─────────────────────────────────────────┤
│ 可复制指令                                 │
│ .include "mymodel.lib"                    │
│ .lib "mymodel.lib" NPN_Model              │
│                         [复制]             │
├─────────────────────────────────────────┤
│ 注意事项                                   │
│ • 模型文件名和路径不能有中文或空格           │
│ • .lib 可以指定子电路名，.include 包含全部   │
│ • 部分厂商模型需要修改 .ends 等语法才能用     │
├─────────────────────────────────────────┤
│ 相关指令: .include  .lib  .model  .subckt  │
│ 相关错误: Unknown device  Model not found   │
└─────────────────────────────────────────┘
```

---

### 3.7 模块七：电路拓扑速查

常用电路拓扑，公式 + 取值建议 + 最小片段。

#### 拓扑清单（预计 25+）

| 分类 | 拓扑 |
|------|------|
| 基础电路 | 电阻分压 |
| | RC 低通滤波 |
| | RC 高通滤波 |
| | LC 串联谐振 |
| | LC 并联谐振 |
| | 电流镜（BJT） |
| | 电流镜（MOS） |
| | 差分对 |
| 运放电路 | 反相放大器 |
| | 同相放大器 |
| | 电压跟随器（缓冲器） |
| | 差分放大器 |
| | 加法电路 |
| | 减法电路 |
| | 积分电路 |
| | 微分电路 |
| | 比较器（开环） |
| | 比较器（带滞回/施密特触发） |
| | 文氏桥正弦波振荡器 |
| | 多谐振荡器 |
| 电源电路 | 线性稳压（78xx 系列） |
| | 可调线性稳压（LM317） |
| | 基准电压源（TL431） |
| | 恒流源（BJT） |
| | 恒流源（运放） |
| | Buck 降压转换器 |
| | Boost 升压转换器 |
| | Buck-Boost 升降压转换器 |
| 信号发生 | 方波发生器（555 定时器） |
| | 三角波发生器 |
| | 锯齿波发生器 |
| 接口电路 | RC 复位电路 |
| | 上电延时电路 |
| | 电平转换电路 |
| | 光耦隔离电路 |

#### 拓扑卡片结构

```
┌─────────────────────────────────────────┐
│ 反相放大器                                │
│ 运放反相输入放大电路，输出与输入反相        │
├─────────────────────────────────────────┤
│ 关键公式                                  │
│ 增益 Av = -Rf / Rin                       │
│ 输入阻抗 ≈ Rin                            │
│ 输出阻抗 ≈ 0（理想运放）                   │
│ 带宽 = 单位增益带宽 / |Av|                │
├─────────────────────────────────────────┤
│ 取值建议                                   │
│ Rin: 1k ~ 100kΩ（常用 10k）              │
│ Rf: 根据增益计算，Av=-10 时取 100k        │
│ 平衡电阻 Rb = Rin // Rf（接同相端到地）    │
│ • 增益不要超过 100，否则带宽和噪声变差      │
│ • Rin 太小会增加前级负载，太大增加噪声      │
├─────────────────────────────────────────┤
│ 最小 .asc 片段（可复制到 LTspice）         │
│ X1 out 0 in 0 opamp                       │
│ R1 in N1 10k                              │
│ R2 N1 out 100k                            │
│ R3 0 N1 9.1k ; 平衡电阻（可选）            │
│ .model opamp opamp (Aol=100k GBW=1meg)   │
│                         [复制]             │
├─────────────────────────────────────────┤
│ 应用场景: 信号放大、电平移动、加法器基础     │
│ 相关公式: 反相放大器增益                    │
│ 相关拓扑: 同相放大器  差分放大器  加法电路   │
└─────────────────────────────────────────┘
```

---

### 3.8 辅助功能

#### 收藏与历史

- **收藏**：常用卡片收藏，打开默认显示收藏列表
- **最近查看**：最近 20 条查看记录
- **搜索历史**：最近 10 条搜索记录
- 数据存在本地 UserDefaults，不联网

#### 单位换算工具

- 内置常用前缀换算（u/n/p/f/m/k/meg/g）
- 特别提醒：LTspice 中 `m` 是毫（1e-3），`meg` 才是兆（1e6）——这是最常见的易错点
- 可在搜索框直接输入 "1u" 或 "单位换算" 调出

#### 与 KeyHub 互通

- 卡片底部的"相关快捷键"链接 → 跳 KeyHub 并搜索
- KeyHub 中 LTspice 指令的"查看详情" → 跳 SpiceNest 并搜索
- 通过 URL Scheme 实现：
  - `nexus-spicenest://search?q=.tran`
  - `nexus-keyhub://search?q=ltspice`

---

## 四、交互设计

### 4.1 窗口形态

遵循 Nexus 规范，参考 KeyHub：

| 特性 | 规格 |
|------|------|
| 窗口类型 | 浮动置顶（NSPanel 或 NSWindow + .floating） |
| 背景 | 毛玻璃（NSVisualEffectView, .material = .popover） |
| 圆角 | 12pt |
| 宽度 | 固定 560pt（比 KeyHub 宽一点，因为内容更多） |
| 高度 | 可纵向拉升，400 ~ 3000pt |
| 标题栏 | 透明，隐藏标题文字 |
| 主题色叠加 | 淡橙色/琥珀色 alpha 0.12（SpiceNest 主题色） |
| 失去焦点 | 自动隐藏（可选，用户可设置） |

### 4.2 页面结构

**单窗口，两级导航：**

1. **首页（搜索页）**：搜索框 + 搜索历史 + 收藏 + 快速分类入口
2. **详情页**：点击搜索结果 → 显示完整卡片详情 → 返回按钮回首页

不搞侧边栏、不搞多级菜单，搜索是唯一主入口。

### 4.3 首页布局

```
┌─────────────────────────────────────────┐
│  SpiceNest (Impact 艺术字)               │
│  ⚡ LTspice 参考助手                      │
│  唤出/隐藏: [Ctrl]+[Option]+[S]          │
│                                         │
│  ┌─────────────────────────────────────┐ │
│  │ 🔍 搜索指令、参数、报错、公式…         │ │
│  └─────────────────────────────────────┘ │
│                                         │
│  快速分类:                                │
│  [📋指令] [📖参数] [⚠️错误] [🧮公式] [💡技巧] [🔌拓扑] │
│                                         │
│  ⭐ 收藏 (3)                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │ .tran 语法 │ │ 反相放大器 │ │ Time step│ │
│  └──────────┘ └──────────┘ └──────────┘ │
│                                         │
│  🕐 最近搜索                              │
│  • .ac  • VAF  • 截止频率  • 收敛        │
└─────────────────────────────────────────┘
```

### 4.4 详情页布局

```
┌─────────────────────────────────────────┐
│ ‹ 返回                                    │
├─────────────────────────────────────────┤
│  [完整卡片内容]                            │
│  ...                                      │
│  ...                                      │
├─────────────────────────────────────────┤
│ ⭐ 收藏   🔗 复制全部   ↗ 打开 KeyHub 查快捷键 │
└─────────────────────────────────────────┘
```

### 4.5 键盘交互

| 操作 | 快捷键 |
|------|--------|
| 唤出/隐藏窗口 | 全局 `Ctrl+Option+S`（可自定义） |
| 搜索框聚焦 | 打开窗口自动聚焦 / `Cmd+F` |
| 选择上/下一个结果 | ↑ / ↓ |
| 打开选中结果 | Enter |
| 返回上一页 | Esc / Backspace |
| 快速分类切换 | `Cmd+1` ~ `Cmd+6`（指令/参数/错误/公式/技巧/拓扑） |
| 复制当前卡片内容 | Cmd+C（详情页） |
| 收藏/取消收藏 | Cmd+D（详情页） |
| 关闭窗口 | Esc（首页） |

---

## 五、数据模型

### 5.1 统一内容项（ContentItem）

所有内容类型共享基础字段，搜索时统一检索：

```swift
struct ContentItem: Codable {
    let id: String              // 唯一标识，如 "command-tran", "param-bjt-is"
    let type: ContentType       // 内容类型
    let title: String           // 标题（英文原名）
    let chineseTitle: String    // 中文译名
    let summary: String         // 一句话摘要，搜索结果展示
    let tags: [String]          // 搜索标签（中英文同义词、缩写）
    let related: [String]       // 关联内容的 id 列表
}

enum ContentType: String, Codable {
    case command     // 仿真指令
    case parameter   // 元器件参数
    case error       // 常见错误
    case formula     // 公式速算
    case tip         // 操作技巧
    case topology    // 电路拓扑
}
```

### 5.2 各类型详情模型

#### 指令详情（CommandDetail）

```swift
struct CommandDetail: Codable {
    let id: String
    let syntax: [String]        // 语法形式（支持多种）
    let parameters: [ParamDef]  // 参数说明
    let examples: [Example]     // 示例
    let notes: [String]         // 注意事项
}

struct ParamDef: Codable {
    let name: String            // 参数名
    let description: String     // 说明
    let required: Bool          // 是否必填
    let defaultValue: String?   // 默认值
}

struct Example: Codable {
    let code: String            // 示例代码
    let description: String     // 说明
}
```

#### 参数详情（ParameterDetail）

```swift
struct ParameterDetail: Codable {
    let id: String
    let componentType: String   // 元器件类型（bjt/mosfet/jfet/diode/opamp/resistor...）
    let description: String     // 含义说明
    let typicalRange: String    // 典型值范围
    let defaultValue: String    // 默认值
    let effect: String          // 影响说明（调大调小会怎样）
    let example: String         // 设置示例
}
```

#### 错误详情（ErrorDetail）

```swift
struct ErrorDetail: Codable {
    let id: String
    let errorPattern: String    // 匹配模式（支持模糊匹配）
    let category: String        // 错误类别（收敛/结构/参数/语法/文件）
    let cause: String           // 原因分析
    let solutions: [String]     // 解决方案（编号列表）
    let copyableCommands: [String] // 可复制的修复指令
}
```

#### 公式详情（FormulaDetail）

```swift
struct FormulaDetail: Codable {
    let id: String
    let formula: String         // 公式表达式（纯文本）
    let description: String     // 公式说明（算什么、什么意思）
    let variables: [Variable]   // 变量说明
    let calculator: Calculator? // 计算器配置（null 表示无计算器）
}

struct Variable: Codable {
    let name: String            // 变量名
    let description: String     // 说明
    let unit: String            // 单位
}

struct Calculator: Codable {
    let inputs: [CalcInput]     // 输入变量
    let outputName: String      // 输出变量名
    let outputUnit: String      // 输出单位
    // 注意：计算逻辑在 CalculatorService 中按 formulaId 硬编码，不支持自定义表达式
}

struct CalcInput: Codable {
    let name: String            // 变量名
    let defaultValue: Double    // 默认值
    let unit: String            // 单位
    let unitOptions: [String]   // 可选单位（如 Ω/kΩ/MΩ）
}
```

#### 技巧详情（TipDetail）

```swift
struct TipDetail: Codable {
    let id: String
    let scenario: String        // 适用场景
    let steps: [TipStep]        // 操作步骤
    let copyableCommands: [String] // 可复制指令
    let notes: [String]         // 注意事项
}

struct TipStep: Codable {
    let step: Int               // 步骤号
    let description: String     // 说明
    let command: String?        // 该步骤涉及的指令（可选）
}
```

#### 拓扑详情（TopologyDetail）

```swift
struct TopologyDetail: Codable {
    let id: String
    let category: String        // 分类（basic/op-amp/power/signal/interface）
    let difficulty: String      // 难度（入门/基础/进阶/高级）
    let description: String     // 电路说明
    let formulas: [String]      // 关键公式
    let designTips: [String]    // 取值建议/设计要点
    let ascSnippet: String      // 最小 .asc 片段（可复制）
    let applications: [String]  // 应用场景
}
```

---

## 六、内容存储结构

### 6.1 目录结构

所有内容以 JSON 文件存储在 `Resources/content/` 目录，应用启动时加载到内存。

```
Resources/
└── content/
    ├── index.json              # 所有内容的基础索引（ContentItem 列表，用于搜索）
    ├── commands/
    │   ├── command-tran.json
    │   ├── command-ac.json
    │   ├── command-dc.json
    │   ├── command-op.json
    │   ├── command-step.json
    │   ├── command-meas.json
    │   └── ...
    ├── parameters/
    │   ├── bjt.json            # BJT 所有参数（一个文件，数组）
    │   ├── mosfet.json
    │   ├── jfet.json
    │   ├── diode.json
    │   ├── opamp.json
    │   ├── passive.json        # RLC
    │   └── sources.json        # 电压源/电流源
    ├── errors/
    │   └── common-errors.json  # 所有错误（一个文件，数组）
    ├── formulas/
    │   └── formulas.json       # 所有公式（一个文件，数组）
    ├── tips/
    │   └── tips.json           # 所有技巧（一个文件，数组）
    └── topologies/
        └── topologies.json     # 所有拓扑（一个文件，数组）
```

### 6.2 index.json 格式

```json
{
  "version": "0.1",
  "last_updated": "2026-08-27",
  "items": [
    {
      "id": "command-tran",
      "type": "command",
      "title": ".tran",
      "chineseTitle": "瞬态仿真",
      "summary": "计算电路在指定时间范围内的时域响应",
      "tags": ["tran", "瞬态", "时域", "时间", "transient", "tstop", "tmax"],
      "related": ["command-step", "command-meas", "error-time-step-too-small"]
    },
    {
      "id": "param-bjt-is",
      "type": "parameter",
      "title": "IS",
      "chineseTitle": "反向饱和电流",
      "summary": "PN结的反向饱和电流，决定晶体管导通特性",
      "tags": ["IS", "反向饱和电流", "饱和电流", "bjt", "晶体管", "saturation current"],
      "related": ["param-bjt-bf", "param-bjt-vaf", "command-model"]
    }
  ]
}
```

### 6.3 内容加载逻辑

1. 应用启动时，读取 `index.json` 到内存（搜索索引）
2. 详情文件按需加载：用户点击某个结果时，根据 `id` 和 `type` 读取对应 JSON 文件
3. 参数/错误/公式/技巧/拓扑使用数组文件，加载后按 `id` 查找
4. 指令使用单独文件（因为内容较长）
5. 所有内容加载后缓存，避免重复读文件

---

## 七、技术架构

### 7.1 技术选型

遵循 Nexus 规范，参考 KeyHub：

| 项 | 选择 | 说明 |
|----|------|------|
| 平台 | macOS 13.0+ | 遵循 Nexus 最低版本要求 |
| 语言 | Swift 5 | 纯 Swift |
| UI 框架 | AppKit（纯代码布局） | 参考 KeyHub，不用 SwiftUI/Storyboard/XIB |
| 构建工具 | swiftc + build.sh | 遵循 Nexus 标准构建脚本 |
| 数据格式 | JSON | 结构化内容，Codable 解析 |
| 搜索 | 内存过滤（NSPredicate / 自定义匹配） | 数据量小，本地内存搜索足够 |
| 第三方依赖 | 无 | 遵循 Nexus 零外部依赖原则 |
| 热键 | Carbon API（NXHotKeyManager） | CommonKit 封装 |
| 窗口 | NSWindow + NSVisualEffectView（NXWindowStyle） | CommonKit 封装 |
| 菜单栏 | NSStatusItem（NXStatusItem） | CommonKit 封装 |

### 7.2 模块划分

```
Sources/
├── main.swift                  # 入口（3 行）
├── App/
│   └── AppDelegate.swift       # 应用主体：窗口、页面路由、菜单栏、热键、URL Scheme
├── Models/
│   ├── ContentItem.swift       # 统一内容项模型
│   ├── CommandDetail.swift     # 指令详情
│   ├── ParameterDetail.swift   # 参数详情
│   ├── ErrorDetail.swift       # 错误详情
│   ├── FormulaDetail.swift     # 公式详情
│   ├── TipDetail.swift         # 技巧详情
│   └── TopologyDetail.swift    # 拓扑详情
├── Services/
│   ├── ContentLoader.swift     # 内容加载（JSON 读取、索引构建）
│   ├── SearchService.swift     # 搜索服务（模糊匹配、分组）
│   ├── FavoritesService.swift  # 收藏与历史（UserDefaults）
│   └── CalculatorService.swift # 公式计算器求值
├── Views/
│   ├── SearchFieldView.swift   # 搜索框
│   ├── SearchResultView.swift  # 搜索结果列表（分组展示）
│   ├── ContentCardView.swift   # 内容卡片（通用，适配所有类型）
│   ├── DetailView.swift        # 详情页容器
│   ├── HomeView.swift          # 首页（搜索框 + 收藏 + 历史）
│   ├── CalculatorView.swift    # 公式计算器组件
│   ├── CopyableCodeView.swift  # 可复制代码块
│   └── CommonViews.swift       # 辅助视图（分隔线、标签等）
└── Common/                     # Nexus CommonKit（按需引入）
    ├── NXCommon.swift
    ├── NXHotKeyManager.swift
    ├── NXURLScheme.swift
    ├── NXWindowStyle.swift
    ├── NXStatusItem.swift
    └── NXPixelUtils.swift
```

### 7.3 关键设计决策

#### 决策1：纯代码布局，不用 Storyboard/XIB

**原因**：
- 窗口样式特殊（毛玻璃、透明标题栏、固定宽度），代码控制更灵活
- 无 Xcode 项目文件，`swiftc` 直接编译，构建简单
- 参考 KeyHub 的成功实践

#### 决策2：数据驱动，内容与代码完全分离

**原因**：
- 所有内容存在 JSON 文件，新增/修改内容不需要改 Swift 代码
- 应用启动时加载索引，详情按需读取
- 未来可以支持用户导入自定义内容

#### 决策3：AppKit 而非 SwiftUI

**原因**：
- 参考 KeyHub，AppKit 对浮动窗口、毛玻璃、自定义视图的控制更精细
- SwiftUI 在 macOS 上对某些高级特性支持不够完善
- 团队已有 AppKit 经验（KeyHub）

#### 决策4：单例 AppDelegate 管理页面状态

**原因**：
- 应用规模小（一个窗口，首页+详情页两级）
- 不引入 ViewModel/Coordinator 等额外抽象，保持简单
- 参考 KeyHub 的实践

#### 决策5：内存搜索，不引入搜索框架

**原因**：
- 内容总量预计 200-300 条，全部加载到内存也只有几百 KB
- 简单的字符串匹配 + 标签匹配足够，不需要 SQLite 或全文搜索引擎
- 零依赖，符合 Nexus 规范

### 7.4 数据流

```
应用启动
  → ContentLoader 读取 index.json → 构建搜索索引（内存）
  → 显示首页（搜索框 + 收藏 + 历史）

用户输入关键词
  → SearchService 搜索索引 → 按 type 分组 → 显示结果列表

用户点击结果
  → ContentLoader 按需读取详情 JSON → 显示详情页

用户复制代码
  → NSPasteboard 写入剪贴板

用户收藏
  → FavoritesService 写入 UserDefaults

用户点击"跳 KeyHub"
  → NXURLScheme.openApp(appId: "keyhub", action: "search", params: ["q": keyword])

收到 URL Scheme 唤起
  → application(_:open:) → NXURLScheme.parse → 显示窗口 → 执行搜索
```

---

## 八、UI 设计规范

### 8.1 主题色

SpiceNest 主题色：**琥珀色/橙色**（#FF9500 系），象征"火花"和"能量"，与电路/电子主题契合。

- 菜单栏图标：SF Symbol `bolt`（闪电），isTemplate
- 主题色叠加层：`NSColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 0.12)`
- 强调色：系统橙色（controlAccentColor 或自定义 #FF9500）

### 8.2 字体

- 标题（SpiceNest Logo）：Impact，类似 KeyHub 风格
- 卡片标题：系统字体 Bold，16pt
- 正文：系统字体 Regular，13pt
- 代码/指令：SF Mono / Menlo，12pt
- 标签/辅助文字：系统字体 Regular，11pt，灰色

### 8.3 卡片样式

- 背景：不透明（避免非 Retina 屏字体模糊，参考 KeyHub 踩坑记录）
- 圆角：10pt
- 阴影：轻微投影
- 悬停：上浮 3pt + 橙色描边发光 + 手型光标
- 内边距：16pt

### 8.4 代码块样式

- 背景：深色（类似 Xcode 深色主题）
- 圆角：6pt
- 字体：SF Mono，12pt
- 右上角复制按钮
- 悬停时复制按钮高亮

### 8.5 图标

使用 SF Symbol，统一风格：

| 内容类型 | 图标 |
|---------|------|
| 仿真指令 | `terminal` / `chevron.left.forwardslash.chevron.right` |
| 元器件参数 | `slider.horizontal.3` |
| 常见错误 | `exclamationmark.triangle` |
| 公式速算 | `function` / `sum` |
| 操作技巧 | `lightbulb` |
| 电路拓扑 | `circle.grid.2x2` |

---

## 九、Nexus 合规

### 9.1 应用身份

| 项 | 值 |
|----|-----|
| 应用显示名 | SpiceNest |
| 内部标识 | spicenest |
| 分类 | tool（工具类） |
| Bundle ID | com.nexus.tool.spicenest |
| URL Scheme | nexus-spicenest |
| 主题色 | #FF9500（琥珀色） |
| 全局热键 | Ctrl+Option+S（默认，可自定义） |
| 菜单栏图标 | SF Symbol `bolt` |
| 最低 macOS | 13.0 |

### 9.2 必须遵守的 Nexus 规范

- [ ] LSUIElement = true，无 Dock 图标
- [ ] 全局热键唤出窗口
- [ ] 菜单栏图标（NSStatusItem）
- [ ] 菜单栏包含"Nexus 应用"子菜单
- [ ] 注册 URL Scheme `nexus-spicenest://`
- [ ] 实现 `application(_:open:)` 接收 URL 唤起
- [ ] 唤起后显示窗口
- [ ] Bundle ID 格式 `com.nexus.tool.spicenest`
- [ ] 标准目录结构（Sources/App/Models/Views/Services/Common）
- [ ] build.sh 标准构建脚本
- [ ] nexus.json 配置文件
- [ ] CHANGELOG.md 更新日志
- [ ] 无个人隐私信息
- [ ] CommonKit 组件按需引入，不直接修改

### 9.3 CommonKit 组件引入清单

| 组件 | 是否引入 | 用途 |
|------|---------|------|
| NXCommon | ✅ | 元信息、应用分类枚举 |
| NXHotKeyManager | ✅ | 全局热键 |
| NXURLScheme | ✅ | 跨应用通信（与 KeyHub 互通） |
| NXWindowStyle | ✅ | 毛玻璃浮动窗口 |
| NXStatusItem | ✅ | 菜单栏图标和菜单 |
| NXPixelUtils | ✅ | 像素对齐（非 Retina 屏适配） |

### 9.4 URL Scheme 支持的操作

| 操作 | URL 格式 | 说明 |
|------|----------|------|
| 唤起应用 | `nexus-spicenest://` | 显示窗口 |
| 搜索 | `nexus-spicenest://search?q=.tran` | 显示窗口并执行搜索 |
| 打开内容 | `nexus-spicenest://open?id=command-tran` | 显示窗口并打开指定内容详情 |

---

## 十、隐私与安全

- 所有内容本地存储，不联网上传
- 不收集用户使用数据
- 不包含用户个人信息
- 收藏和历史存在本地 UserDefaults
- 不请求不必要的系统权限
- 公式计算器在本地求值，不发送数据
- 模板片段仅包含电路结构，不包含敏感数据

---

## 十一、版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-08-27 | 初始规格（教程导向） |
| v0.2 | 2026-08-27 | 重写为查询助手导向，六大内容库，搜索驱动 |
| v0.3 | 2026-08-27 | PLAN_REVIEW 修订：统一文件名前缀/alpha/快捷键/数据模型，删除重复错误条目，计算器改硬编码，合规清单改空勾 |

---

*SpiceNest · 随时随地，一搜即得*
