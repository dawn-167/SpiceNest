# SpiceNest 内容编写规范

> 本文档定义 SpiceNest 六大内容库的 JSON 格式规范和编写要求。
> 产品层面的规格见 [SPECIFICATION.md](../SPECIFICATION.md)。

---

## 一、总体原则

### 1.1 内容质量

- **准确**：所有内容必须经过实际验证，不能有错误
- **精炼**：查询助手不是教程，每句话都要有信息量，不啰嗦
- **清晰**：语言通俗易懂，专业术语保留英文原名
- **实用**：内容要能解决实际问题，不是空泛的理论
- **一致**：相同类型的内容保持一致的格式和风格
- **可复制**：所有指令、代码、公式示例都要能直接复制到 LTspice 使用

### 1.2 语言风格

- 中文为主，专业术语保留英文原名（如 `.tran`、`MOSFET`、`VAF`）
- 语气简洁直接，像同事在告诉你答案，不是老师在讲课
- 避免使用"显然"、"简单"、"容易"等词
- 步骤描述用祈使句（"添加..."、"设置..."、"输入..."）
- 重要提示用"注意"、"提示"、"警告"等标识
- 不写"本教程将教你..."这类教程式语言

### 1.3 版本适配

- 内容基于 LTspice XVII（当前最新版本）
- 如果某个功能在不同版本有差异，在注意事项中标注适用版本
- 不使用截图（查询助手纯文本），所有内容用文字和代码描述

### 1.4 内容格式

- 所有内容使用 JSON 格式存储
- 编码：UTF-8
- 缩进：2 空格
- 字段名：camelCase
- 字符串值：中文描述，专业术语保留英文

---

## 二、统一索引格式（index.json）

所有内容的基础信息统一在 `index.json` 中，用于搜索和列表展示。

### 2.1 文件结构

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
    }
  ]
}
```

### 2.2 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 唯一标识，格式：`<类型>-<名称>`，全小写，连字符分隔 |
| type | String | ✅ | 内容类型：command / parameter / error / formula / tip / topology |
| title | String | ✅ | 英文原名（如 `.tran`、`IS`、`Time step too small`） |
| chineseTitle | String | ✅ | 中文译名（如"瞬态仿真"、"反向饱和电流"） |
| summary | String | ✅ | 一句话摘要，搜索结果展示，不超过 40 个中文字 |
| tags | Array<String> | ✅ | 搜索标签，包含中英文同义词、缩写、相关术语，至少 3 个 |
| related | Array<String> | ⬜ | 关联内容的 id 列表，没有则空数组 |

### 2.3 id 命名规范

| 类型 | 格式 | 示例 |
|------|------|------|
| 仿真指令 | `command-<指令名>` | command-tran, command-ac, command-step |
| 元器件参数 | `param-<元器件类型>-<参数名>` | param-bjt-is, param-mosfet-vto |
| 常见错误 | `error-<错误名简称>` | error-time-step-too-small, error-singular-matrix |
| 公式速算 | `formula-<公式名>` | formula-rc-lowpass-cutoff, formula-inverting-gain |
| 操作技巧 | `tip-<技巧名简称>` | tip-add-third-party-model, tip-export-waveform |
| 电路拓扑 | `topology-<拓扑名>` | topology-inverting-amplifier, topology-rc-lowpass |

### 2.4 tags 编写要求

- 必须包含：英文原名、中文译名、常见缩写/别名
- 建议包含：相关术语、使用场景关键词
- 全部小写（英文）
- 至少 3 个，建议 5-8 个
- 不要重复 title 和 chineseTitle 中已有的完整词（但可以包含部分匹配）

**示例：**
```json
{
  "id": "command-tran",
  "title": ".tran",
  "chineseTitle": "瞬态仿真",
  "tags": ["tran", "瞬态", "时域", "时间仿真", "transient", "tstop", "tmax", "tstart"]
}
```

---

## 三、仿真指令编写规范

### 3.1 文件位置

- 每个指令一个单独文件：`content/commands/<id>.json`
- 例如：`content/commands/command-tran.json`

### 3.2 JSON 格式

```json
{
  "id": "command-tran",
  "syntax": [
    ".tran <tstop>",
    ".tran <tstart> <tstop>",
    ".tran <tstart> <tstop> <tmax>",
    ".tran <tstart> <tstop> <tmax> <tstep>"
  ],
  "parameters": [
    {
      "name": "tstop",
      "description": "仿真停止时间",
      "required": true,
      "defaultValue": null
    },
    {
      "name": "tstart",
      "description": "开始保存数据的时间，之前的数据不保存但仍仿真",
      "required": false,
      "defaultValue": "0"
    },
    {
      "name": "tmax",
      "description": "最大时间步长，限制仿真器的最大步长",
      "required": false,
      "defaultValue": "自动"
    },
    {
      "name": "tstep",
      "description": "起始时间步长建议值",
      "required": false,
      "defaultValue": "自动"
    }
  ],
  "examples": [
    {
      "code": ".tran 10m",
      "description": "仿真 0~10ms"
    },
    {
      "code": ".tran 1m 10m",
      "description": "仿真 0~10ms，但只保存 1ms 之后的数据"
    },
    {
      "code": ".tran 0 10m 1u",
      "description": "仿真 0~10ms，限制最大时间步长为 1us"
    }
  ],
  "notes": [
    "tmax 设置过小会导致仿真变慢，但可以提高精度",
    "tstart 之前的时间仍然会仿真，只是不保存数据，用于跳过初始瞬态",
    "如果仿真报错 'Time step too small'，可以尝试增大 tmax"
  ],
  "related": ["command-step", "command-meas", "command-ic", "command-options", "error-time-step-too-small"]
}
```

### 3.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 与 index.json 中的 id 一致 |
| syntax | Array<String> | ✅ | 语法形式，按参数从少到多排列，参数用尖括号包裹 |
| parameters | Array | ✅ | 参数说明列表 |
| examples | Array | ✅ | 示例列表，至少 3 个 |
| notes | Array<String> | ✅ | 注意事项列表，至少 1 条 |
| related | Array<String> | ✅ | 关联内容 id 列表 |

### 3.4 编写要求

#### syntax
- 按参数从少到多排列（最简形式在前）
- 参数用尖括号 `< >` 包裹，如 `<tstop>`
- 可选参数用方括号 `[ ]` 包裹（在语法行中），如 `[tmax]`
- 指令名保留前面的点号，如 `.tran`

#### parameters
- 按语法中的顺序排列
- description 要说明参数的作用，不只是翻译
- required 指示是否必填
- defaultValue 为默认值，没有则填 null，自动则填 "自动"

#### examples
- 至少 3 个，从简单到复杂
- code 是可直接复制到 LTspice 的完整指令
- description 用一句话说明这个示例做什么
- 包含最常用的使用场景

#### notes
- 至少 1 条，建议 2-4 条
- 内容包括：常见坑、使用建议、与其他指令的关系、版本差异
- 每条不超过 2 句话

---

## 四、元器件参数编写规范

### 4.1 文件位置

- 按元器件类型分文件：`content/parameters/<componentType>.json`
- 文件内容是该类型所有参数的数组
- 例如：`content/parameters/bjt.json`、`content/parameters/mosfet.json`

### 4.2 JSON 格式

```json
[
  {
    "id": "param-bjt-is",
    "componentType": "bjt",
    "name": "IS",
    "chineseName": "反向饱和电流",
    "description": "PN结的反向饱和电流，决定了晶体管的导通特性。IS 越大，相同 Vbe 下的集电极电流越大。",
    "typicalRange": "1e-16 ~ 1e-12 A",
    "defaultValue": "1e-16",
    "effect": "IS 增大 → 相同 Vbe 下 Ic 增大 → 晶体管更容易导通；IS 减小 → 需要更大的 Vbe 才能达到相同 Ic",
    "example": ".model MyNPN NPN(IS=1e-14 BF=200)",
    "related": ["param-bjt-bf", "param-bjt-vaf", "param-bjt-ise", "command-model"]
  }
]
```

### 4.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 唯一标识，格式 param-<类型>-<参数名> |
| componentType | String | ✅ | 元器件类型：bjt / mosfet / jfet / diode / opamp / passive / source |
| name | String | ✅ | 参数英文原名，大小写与 LTspice 一致 |
| chineseName | String | ✅ | 中文译名 |
| description | String | ✅ | 含义说明，1-3 句话，说清楚这个参数是做什么的 |
| typicalRange | String | ✅ | 典型值范围，带单位 |
| defaultValue | String | ✅ | LTspice 中的默认值，没有则填 "无" |
| effect | String | ✅ | 影响说明，参数变大/变小分别会怎样 |
| example | String | ✅ | 在 LTspice 中设置这个参数的完整示例，可复制 |
| related | Array<String> | ✅ | 关联内容 id 列表 |

### 4.4 编写要求

#### name
- 严格按照 LTspice 中的拼写（大小写敏感）
- 不要自己编造参数名
- 如果有别名，在 description 中说明

#### description
- 第一句话说清楚参数是什么
- 后续可以补充物理意义或作用
- 不要太技术化，有电路基础的人能看懂

#### typicalRange
- 给出常见的取值范围
- 用科学计数法（如 1e-16 ~ 1e-12 A）
- 如果不同类型的元器件范围不同，分别说明

#### effect
- 必须说明参数变大时会怎样
- 必须说明参数变小时会怎样
- 可以补充对仿真精度/收敛性/速度的影响
- 用箭头 → 表示因果关系，简洁明了

#### example
- 给出完整的 `.model` 语句或元器件属性设置
- 可以包含其他相关参数，展示这个参数在实际模型中的用法
- 必须能直接复制到 LTspice 使用

### 4.5 元器件类型参数覆盖范围

#### BJT 晶体管（必选参数，约 40 个）
IS, BF, VAF, BR, VAR, ISC, ISE, NK, NR, NE, NC, RB, RC, RE, RBM, IRB, CJE, CJC, CJS, VJE, VJC, VJS, MJE, MJC, MJS, TF, TR, XTF, ITF, VTF, PTF, XTB, EG, XTI, KF, AF, FC, TNOM

#### MOSFET（必选参数，约 35 个）
L, W, VTO, KP, GAMMA, PHI, LAMBDA, RD, RS, RG, RDS, CBD, CBS, CJ, MJ, PB, JS, TOX, NSUB, UO, UCRIT, UEXP, RSH, NSS, TPG, JSS, KF, AF, FC, TNOM

#### JFET（约 15 个）
VTO, BETA, LAMBDA, RD, RS, RG, CGS, CGD, PB, IS, M, N, KF, AF, FC, TNOM

#### 二极管（约 25 个）
IS, N, RS, IKF, EG, XTI, CJO, VJ, M, FC, TT, BV, IBV, IBL, IBR, NB, LB, VB, KF, AF, FFE, TNOM

#### 运算放大器（约 10 个）
开环增益(Aol), 单位增益带宽(GBW), 压摆率(SR), 输入失调电压(Vos), 输入偏置电流(Ib), 共模抑制比(CMRR), 电源抑制比(PSRR), 输出电阻(Ro), 输入电压噪声, 输入电流噪声

#### 无源器件（RLC）
- 电阻：阻值, 精度, 温度系数, 功率, 封装
- 电容：容值, 精度, 耐压, 温度系数, 等效串联电阻(ESR), 封装
- 电感：感值, 精度, 直流电阻(DCR), 饱和电流, 自谐频率(SRF), 封装

#### 电压源/电流源
- DC, AC, TRAN（PULSE/SINE/EXP/PWL/SFFM）参数说明

---

## 五、常见错误编写规范

### 5.1 文件位置

- 所有错误在一个文件中：`content/errors/common-errors.json`
- 文件内容是错误对象的数组

### 5.2 JSON 格式

```json
[
  {
    "id": "error-time-step-too-small",
    "errorPattern": "Time step too small",
    "category": "convergence",
    "title": "时间步长过小",
    "cause": "电路存在刚性问题（stiff），数值收敛困难。常见于理想开关、理想二极管、陡峭波形、高 Q 值谐振电路。仿真器不断减小时间步长以尝试收敛，最终达到下限。",
    "solutions": [
      "添加最小电导：在仿真指令中添加 .options gmin=1e-12",
      "检查理想开关或二极管，添加寄生参数（如 1pF 电容）减缓状态突变",
      "增大最大时间步长：.tran 0 10m 1u（最后一个参数是 tmax）",
      "使用 .ic 命令设置合理的初始条件，帮助收敛",
      "尝试 .options cshunt=1e-15，为每个节点添加小电容到地"
    ],
    "copyableCommands": [
      ".options gmin=1e-12 cshunt=1e-15",
      ".tran 0 10m 1u"
    ],
    "related": ["command-tran", "command-options", "command-ic", "tip-convergence-troubleshooting"]
  }
]
```

### 5.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 唯一标识，格式 error-<错误名简称> |
| errorPattern | String | ✅ | LTspice 报错信息原文，用于模糊匹配 |
| category | String | ✅ | 错误类别：convergence / structure / parameter / syntax / file / model |
| title | String | ✅ | 简短的中文错误名称，不超过 10 个字 |
| cause | String | ✅ | 原因分析，2-4 句话，说清楚为什么会出现这个错误 |
| solutions | Array<String> | ✅ | 解决方案列表，按优先级排序（先试最简单的），至少 3 条 |
| copyableCommands | Array<String> | ✅ | 可复制的修复指令列表，没有则空数组 |
| related | Array<String> | ✅ | 关联内容 id 列表 |

### 5.4 编写要求

#### errorPattern
- 严格按照 LTspice 的报错信息原文
- 大小写不敏感（匹配时会处理）
- 可变部分可以省略或用通用描述（匹配时用包含匹配）

#### category
- convergence：收敛问题（Time step too small, Gmin step failed 等）
- structure：电路结构问题（Singular matrix, Node floating, Node not defined, Duplicate device name 等。命名重复也归此类，因为本质是电路结构冲突）
- parameter：参数错误（Unknown parameter, Value out of range 等）
- syntax：语法错误（Syntax error, Missing expression 等）
- file：文件错误（File not found, Library not found 等）
- model：模型错误（Unknown device, Model not found, Subcircuit not found 等）

#### cause
- 详细说明错误产生的原因
- 可以分点列出可能的原因（但用段落描述）
- 要准确，不能误导用户
- 2-4 句话，不要太长

#### solutions
- 按优先级排序（先试最简单、最常用的）
- 每条是一个完整的、可操作的步骤
- 如果需要修改仿真指令，给出完整的可复制代码
- 说明适用场景（可选，在步骤中用括号说明）
- 至少 3 条，建议 3-5 条

#### copyableCommands
- 列出解决方案中涉及的可直接复制的仿真指令
- 每条是完整的指令行
- 用户可以直接复制到 LTspice 原理图中
- 如果解决方案不涉及指令修改，则为空数组

---

## 六、公式速算编写规范

### 6.1 文件位置

- 所有公式在一个文件中：`content/formulas/formulas.json`
- 文件内容是公式对象的数组

### 6.2 JSON 格式

```json
[
  {
    "id": "formula-rc-lowpass-cutoff",
    "formula": "fc = 1 / (2 × π × R × C)",
    "variables": [
      {
        "name": "fc",
        "description": "截止频率",
        "unit": "Hz"
      },
      {
        "name": "R",
        "description": "电阻值",
        "unit": "Ω"
      },
      {
        "name": "C",
        "description": "电容值",
        "unit": "F"
      }
    ],
    "calculator": {
      "inputs": [
        {
          "name": "R",
          "defaultValue": 10000,
          "unit": "Ω",
          "unitOptions": ["Ω", "kΩ", "MΩ"]
        },
        {
          "name": "C",
          "defaultValue": 1.0e-7,
          "unit": "F",
          "unitOptions": ["pF", "nF", "μF", "mF"]
        }
      ],
      "outputName": "fc",
      "outputUnit": "Hz",
      "outputUnitOptions": ["Hz", "kHz", "MHz"]
    },
    "description": "RC 低通滤波器的截止频率，即增益下降到 -3dB（0.707 倍）时的频率。",
    "related": ["formula-rc-time-constant", "formula-rc-highpass-cutoff", "topology-rc-lowpass", "tip-filter-design"]
  }
]
```

### 6.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 唯一标识，格式 formula-<公式名> |
| formula | String | ✅ | 公式表达式，纯文本，用 × 表示乘号，π 表示圆周率 |
| variables | Array | ✅ | 公式中所有变量的说明 |
| calculator | Object | ✅ | 计算器配置，如果不需要计算器则填 null |
| description | String | ✅ | 公式说明，1-2 句话，说清楚这个公式算什么、什么意思 |
| related | Array<String> | ✅ | 关联内容 id 列表 |

### 6.4 calculator 配置说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| inputs | Array | ✅ | 输入变量配置列表 |
| outputName | String | ✅ | 输出变量名 |
| outputUnit | String | ✅ | 输出默认单位 |
| outputUnitOptions | Array<String> | ✅ | 输出可选单位列表 |

#### inputs 每项

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | String | ✅ | 变量名，与 formula 中的变量名一致 |
| defaultValue | Number | ✅ | 默认值，使用标准单位（Ω, F, H, Hz 等，不用前缀） |
| unit | String | ✅ | 默认显示单位 |
| unitOptions | Array<String> | ✅ | 可选单位列表，用户可切换 |

### 6.5 编写要求

#### formula
- 用纯文本表示，不要用 LaTeX
- 乘号用 ×，除号用 /，幂用 ^（或直接写）
- 圆周率用 π
- 下标用普通文字（如 fc, Vbe），不用特殊格式
- 公式要清晰，变量名和 description 中的一致

#### variables
- 列出公式中出现的所有变量（包括输出变量）
- 每个变量有名称、说明、单位
- 按公式中出现的顺序排列

#### calculator
- 常用公式必须配置计算器
- 非常用或复杂公式可以不配置（calculator: null）
- 输入变量的 defaultValue 用标准单位（如电阻用 Ω，不用 kΩ；电容用 F，不用 nF）
- unitOptions 要包含常用的前缀单位（如 Ω, kΩ, MΩ）
- 输出单位也要有可选单位（如 Hz, kHz, MHz）
- **重要**：添加新公式时，必须在 CalculatorService 中添加对应的计算函数，否则计算器无法工作

#### description
- 第一句话说清楚这个公式算什么
- 可以补充物理意义（如截止频率是 -3dB 点）
- 1-2 句话，不要太长

---

## 七、操作技巧编写规范

### 7.1 文件位置

- 所有技巧在一个文件中：`content/tips/tips.json`
- 文件内容是技巧对象的数组

### 7.2 JSON 格式

```json
[
  {
    "id": "tip-add-third-party-model",
    "scenario": "厂商提供了 .lib / .mod / .cir 模型文件，需要在 LTspice 中使用",
    "steps": [
      {
        "step": 1,
        "description": "将模型文件放到工程目录，或 LTspice 的 lib/sub 目录下",
        "command": null
      },
      {
        "step": 2,
        "description": "在原理图中按 F2 放置元器件，选择需要的器件类型",
        "command": null
      },
      {
        "step": 3,
        "description": "双击元器件，在 Value 栏填入模型名（与 .model 或 .subckt 定义的名称一致）",
        "command": null
      },
      {
        "step": 4,
        "description": "添加 .include 或 .lib 指令指向模型文件",
        "command": ".include \"mymodel.lib\""
      },
      {
        "step": 5,
        "description": "运行仿真，确认模型被正确加载（如果报错 'Unknown device' 说明模型名不匹配）",
        "command": null
      }
    ],
    "copyableCommands": [
      ".include \"mymodel.lib\"",
      ".lib \"mymodel.lib\" NPN_Model"
    ],
    "notes": [
      "模型文件名和路径不要包含中文或空格，否则可能加载失败",
      ".lib 可以指定子电路名（只加载指定模型），.include 包含文件全部内容",
      "部分厂商提供的 PSpice 模型需要修改语法（如 .ends 改为 .ends）才能在 LTspice 中使用"
    ],
    "related": ["command-include", "command-lib", "command-model", "command-subckt", "error-unknown-device"]
  }
]
```

### 7.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 唯一标识，格式 tip-<技巧名简称> |
| scenario | String | ✅ | 适用场景，一句话说明什么时候用这个技巧 |
| steps | Array | ✅ | 操作步骤列表，按顺序排列 |
| copyableCommands | Array<String> | ✅ | 可复制指令列表，没有则空数组 |
| notes | Array<String> | ✅ | 注意事项列表，至少 1 条 |
| related | Array<String> | ✅ | 关联内容 id 列表 |

### 7.4 steps 每项

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| step | Number | ✅ | 步骤号，从 1 开始 |
| description | String | ✅ | 步骤说明，祈使句，说清楚做什么 |
| command | String | ⬜ | 该步骤涉及的可复制指令，没有则填 null |

### 7.5 编写要求

#### scenario
- 一句话说明这个技巧解决什么问题、什么时候用
- 让用户看到场景就知道是不是自己需要的
- 不要太宽泛

#### steps
- 步骤数量控制在 3-7 步（太多说明技巧太复杂，可以拆分）
- 每步只做一件事
- 用祈使句（"将..."、"按..."、"双击..."、"添加..."）
- 菜单项用 > 分隔（如"选择 File > Open"）
- 按钮名、菜单名、参数名用普通文字（JSON 中不用代码格式，但可以用引号标注）
- 如果该步骤涉及输入指令，在 command 字段给出完整可复制代码

#### copyableCommands
- 列出技巧中涉及的所有可直接复制的指令
- 每条是完整的指令行
- 用户可以直接复制到 LTspice 原理图中
- 如果技巧不涉及指令，则为空数组

#### notes
- 至少 1 条，建议 2-3 条
- 内容包括：常见坑、注意事项、版本差异、进阶提示
- 每条不超过 2 句话

---

## 八、电路拓扑编写规范

### 8.1 文件位置

- 所有拓扑在一个文件中：`content/topologies/topologies.json`
- 文件内容是拓扑对象的数组

### 8.2 JSON 格式

```json
[
  {
    "id": "topology-inverting-amplifier",
    "category": "op-amp",
    "title": "反相放大器",
    "chineseTitle": "反相放大器",
    "description": "运放反相输入放大电路，输出与输入反相。利用虚短虚断原理，增益由反馈电阻和输入电阻的比值决定。",
    "formulas": [
      "增益 Av = -Rf / Rin",
      "输入阻抗 ≈ Rin",
      "输出阻抗 ≈ 0（理想运放）",
      "带宽 = 单位增益带宽 / |Av|"
    ],
    "designTips": [
      "Rin 通常取 1k~100kΩ（常用 10kΩ）",
      "Rf 根据增益计算，Av=-10 时取 100kΩ",
      "同相端接平衡电阻 Rb = Rin // Rf（可选，减小输入偏置电流影响）",
      "增益不要超过 100，否则带宽和噪声性能变差",
      "Rin 太小会增加前级负载，太大则增加噪声"
    ],
    "ascSnippet": "X1 out 0 in 0 opamp\nR1 in N1 10k\nR2 N1 out 100k\nR3 0 N1 9.1k ; 平衡电阻（可选）\n.model opamp opamp(Aol=100k GBW=1meg)",
    "applications": ["信号放大", "电平移动", "加法电路基础", "有源滤波"],
    "difficulty": "基础",
    "related": ["topology-noninverting-amplifier", "topology-differential-amplifier", "topology-summing-amplifier", "formula-inverting-gain", "param-opamp-gbw"]
  }
]
```

### 8.3 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | ✅ | 唯一标识，格式 topology-<拓扑名> |
| category | String | ✅ | 分类：basic / op-amp / power / signal / interface |
| title | String | ✅ | 英文名称（或通用名称） |
| chineseTitle | String | ✅ | 中文名称 |
| description | String | ✅ | 电路说明，2-3 句话，说清楚这个电路做什么、工作原理 |
| formulas | Array<String> | ✅ | 关键公式列表，至少 1 条 |
| designTips | Array<String> | ✅ | 设计要点/取值建议列表，至少 2 条 |
| ascSnippet | String | ✅ | 最小 .asc 片段，可复制到 LTspice 原理图中使用 |
| applications | Array<String> | ✅ | 应用场景列表，至少 2 个 |
| difficulty | String | ✅ | 难度：入门 / 基础 / 进阶 / 高级 |
| related | Array<String> | ✅ | 关联内容 id 列表 |

### 8.4 编写要求

#### description
- 第一句话说清楚这个电路是做什么的
- 后续补充工作原理（关键原理，如虚短虚断）
- 2-3 句话，不要太长

#### formulas
- 列出这个电路最关键的公式
- 用纯文本表示（同公式库规范）
- 至少 1 条，建议 2-4 条
- 包含增益/频率/阻抗等关键参数

#### designTips
- 给出元器件取值建议（常用范围、典型值）
- 说明设计 trade-off（如增益和带宽的关系）
- 包含常见坑和注意事项
- 至少 2 条，建议 3-5 条
- 每条是一个完整的建议，不超过 2 句话

#### ascSnippet
- 最小可运行的 LTspice 原理图片段
- 使用 LTspice 的网表格式（.asc 文件本质是网表）
- 包含必要的元器件和模型定义
- 可以直接复制到 LTspice 原理图中（通过 Edit > Paste 或直接粘贴）
- 添加注释说明关键部分（用 ; 开头）
- 不要包含仿真指令（用户自己添加），除非是这个拓扑必须的

#### applications
- 列出这个电路常用的应用场景
- 每个场景用一个短语
- 至少 2 个，建议 3-5 个

#### difficulty
- 入门：基础电路，初学者一看就懂
- 基础：需要一定电路基础，常用电路
- 进阶：需要较深的电路知识，复杂电路
- 高级：需要专业知识，特殊应用电路

### 8.5 拓扑分类

| 分类 | 说明 | 示例 |
|------|------|------|
| basic | 基础电路 | 分压、RC滤波、LC谐振、电流镜、差分对 |
| op-amp | 运算放大器电路 | 反相/同相/差分放大器、比较器、振荡器 |
| power | 电源电路 | 线性稳压、恒流源、Buck/Boost |
| signal | 信号发生电路 | 方波/三角波/锯齿波发生器 |
| interface | 接口电路 | RC复位、上电延时、电平转换、光耦隔离 |

---

## 九、内容审核清单

发布前，每条内容都要经过以下审核：

### 9.1 通用审核（所有类型）
- [ ] id 命名规范，全局唯一
- [ ] type 正确
- [ ] title 和 chineseTitle 准确
- [ ] summary 精炼，不超过 40 字
- [ ] tags 至少 3 个，覆盖中英文同义词
- [ ] related 的 id 都存在（无死链）
- [ ] JSON 格式正确，无语法错误
- [ ] 无错别字和语法错误
- [ ] 专业术语准确
- [ ] 无个人隐私信息

### 9.2 仿真指令审核
- [ ] 语法形式完整，从简到繁排列
- [ ] 每个参数都有说明
- [ ] 示例至少 3 个，可直接复制
- [ ] 注意事项至少 1 条
- [ ] 语法与 LTspice 官方文档一致

### 9.3 参数词典审核
- [ ] 参数名拼写正确（与 LTspice 一致，大小写敏感）
- [ ] 中文译名准确
- [ ] 含义解释清楚
- [ ] 典型值范围正确
- [ ] 默认值正确
- [ ] 影响说明包含变大和变小两种情况
- [ ] 示例正确可复制

### 9.4 错误库审核
- [ ] 错误信息与 LTspice 报错一致
- [ ] 错误类别正确
- [ ] 原因分析准确
- [ ] 解决方案至少 3 条，按优先级排序
- [ ] 解决方案经过实际验证
- [ ] 可复制指令正确

### 9.5 公式审核
- [ ] 公式表达式正确
- [ ] 变量说明完整
- [ ] 计算器配置正确（输入/输出/单位）
- [ ] 默认值合理
- [ ] 单位选项覆盖常用前缀
- [ ] CalculatorService 中有对应的计算函数（重要！）
- [ ] 计算结果经过手动验证

### 9.6 技巧审核
- [ ] 适用场景明确
- [ ] 步骤 3-7 步，每步只做一件事
- [ ] 步骤描述清晰可操作
- [ ] 所有步骤经过实际操作验证
- [ ] 可复制指令正确
- [ ] 注意事项至少 1 条

### 9.7 拓扑审核
- [ ] 电路说明准确
- [ ] 关键公式正确
- [ ] 设计建议合理
- [ ] .asc 片段能在 LTspice 中正常打开
- [ ] .asc 片段能正常仿真（添加仿真指令后）
- [ ] 应用场景准确
- [ ] 难度标注合理

---

## 十、版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v0.1 | 2026-08-27 | 初始内容编写规范（教程导向，Markdown格式） |
| v0.2 | 2026-08-27 | 重写为查询助手内容规范（JSON格式，六大内容库） |
| v0.3 | 2026-08-27 | PLAN_REVIEW 修订：错误 category 补充 Duplicate device name → structure 映射说明 |

---

*SpiceNest 内容编写规范 · 准确、精炼、可复制*
