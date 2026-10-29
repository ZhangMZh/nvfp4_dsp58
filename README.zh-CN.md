# Versal DSP58 NVFP4 Dot16

[English](README.md)

使用 **4 个 DSP58＋4 路 LUT 乘法函数**，每块处理 16 对 E2M1 输入，计算精确整数：

\[
Q=\sum_{i=0}^{15}q(a_i)q(b_i),\qquad q(x)=2x_{\mathrm{E2M1}}
\]

E2M1 原始点积为 `Q/4`。NVFP4 块级/全局缩放及跨块累加由外部实现。

## 数据通路

正幅值映射为 `q={0,1,2,3,4,6,8,12}`，正负零均映射到整数零。
`Q ∈ [-2304,2304]`，使用 signed 13 位精确表示。

| DSP | 原生 INT8 Dot3 下标 | LUT 下标 | 寄存结果 |
| --- | --- | --- | --- |
| 0 | 0、1、2 | 3 | `S0` |
| 1 | 4、5、6 | 7 | `S0+S1` |
| 2 | 8、9、10 | 11 | `S0+S1+S2` |
| 3 | 12、13、14 | 15 | `Q` |

`Sg` 是第 `g` 组四项乘积之和。第四项用六位地址查表得到八位无符号幅值 `m`。
令符号异或为 `s`，设置 `C=sign_extend(({0,m}) XOR {9{s}})`、`CARRYIN=s`，
由 DSP 加法器完成带符号乘积。四路 LUT 函数不等于四个物理 LUT。

归约使用完整的 58 位 PCOUT→PCIN 级联，无 P 反馈。首颗 DSP 的 OPMODE 为
`0x185`，其余为 `0x195`；均采用 `AREG=BREG=PREG=1`、`CREG=CARRYINREG=MREG=0`。
C/符号输入使用与 AREG/BREG 对齐的 10 位 fabric 寄存器；该安排及禁用 SRL 提取
用于解决本次 V80 配置的 hold 时序问题。

解码寄存、DSP 输入寄存及四级 PREG 级联构成六级流水，各组输入额外对齐 0/1/2/3 拍。
输出背压冻结整个核心；输入气泡继续推进以排空末项。同步复位丢弃在途块。

## 接口

| 模块 | 用途 |
| --- | --- |
| `nvfp4_dot16` | 带 CE 和输入/输出 valid 的计算核心 |
| `nvfp4_dot16_axis` | 独立 RTL AXI4-Stream IP 顶层 |
| `nvfp4_dot16_rtl` | HLS RTL 黑盒的 FIFO 适配器 |
| `nvfp4_dot16_hls` | HLS AXI4-Stream 集成示例 |

原生 AXIS 顶层使用 `ap_clk` 和同步高有效 `ap_rst`：

- 输入 `s_axis_tdata[127:0]={b[63:0],a[63:0]}`，各向量元素 `i` 占 `[4*i+:4]`。
- 输出 `m_axis_tdata[15:0]`，将 signed `Q[12:0]` 符号扩展至 16 位。
- `tvalid && tready` 完成一次传输；阻塞期间保持 valid/data。无 TLAST 或 AXI-Lite。
- 无阻塞时输入/输出握手相隔六拍，连续块 II=1。

HLS API 见 [nvfp4_dot16.hpp](hls/include/nvfp4_dot16.hpp)：一次黑盒调用消费一个
`hls::stream<ap_uint<128>>` 元素，产生一个 `hls::stream<ap_int<16>>` 元素。
构建脚本生成并注册 blackbox JSON；`model.cpp` 提供 C 仿真行为。

HLS 示例通过两个深度为 2 的内部 FIFO 及 DATAFLOW 入口/出口任务连接黑盒，使用
`ap_ctrl_none` 并关闭 start-token propagation，以 FIFO 握手控制末项排空。
生成的 AXIS 顶层使用低有效 `ap_rst_n`，包含额外接口缓冲，不实例化 `nvfp4_dot16_axis`。

## 构建与目录

参考测试需要 Python 3.9+ 和 Make。硬件流程需要配置好的 Vivado/Vitis 2025.1、
GCC 及工具自带的 UNISIM 库。

```sh
make test
make rtl-sim rtl-impl rtl-ip
make hls-csim hls-synth hls-cosim hls-ip
make ip-check
make dist
```

默认 `BUILD_DIR=build`、`PART=xcv80-lsva4737-2MHP-e-S`、`CLOCK_NS=3.333333`。
不同配置使用不同构建目录；不要在同一目录并发运行同一 target。
`ip-check` 需要先生成两份 IP。

| 目录 | 内容 |
| --- | --- |
| `rtl/{src,tb,scripts}` | RTL、计分板测试、Vivado 实现/打包 |
| `hls/{include,src,tb,scripts}` | C++ API/模型/封装、测试、Vitis 流程 |
| `tests/`、`scripts/` | 整数参考、单元测试、构建入口 |
| `build/` | 生成的日志、报告、源码哈希记录及交付物 |

输出位于 `BUILD_DIR`：

- RTL IP：`rtl-ip/nvfp4_dot16_axis.zip`
- HLS IP：`hls-ip/project/solution/impl/ip/nvfp4_org_hls_nvfp4_dot16_hls_1_0.zip`
- 源码包：`dist/nvfp4_dsp58-source.tar.gz`

`ip-check` 将 IP 搬到独立目录，检查文件引用及手写 RTL 哈希，再经 IP Catalog 导入并实现。
HLS Tcl 包含仅在本进程生效的 2025.1 导出兼容处理，不修改工具安装。
源码包不包含生成文件或 AMD 库。

## 验证

12,560 个黄金块覆盖各位置的全部输入对、正负零、极值、抵消及固定种子随机输入。
RTL/FIFO/HLS AXIS 计分板检查延迟、II=1、背压、排空和复位；FIFO 测试另含 CE 暂停。
HLS C 仿真及随机暂停协同仿真使用同一组黄金向量。

2026-10-29，Vivado/Vitis 2025.1、默认 V80 器件的验收结果：

| 实现 | DSP58 | LUT | FF | Setup 裕量 | Hold 裕量 | AXIS 延迟 | II |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 原生 RTL AXIS | 4 | 119 | 436 | 1.523 ns | 0.004 ns | 6 拍 | 1 |
| HLS AXIS 示例 | 4 | 323 | 1024 | 1.049 ns | 0.003 ns | 10 拍 | 1 |

资源取自布局布线报告，延迟为无阻塞握手实测；HLS 数值包含 FIFO 和 AXIS 寄存器切片。
时序使用 3.333333 ns 周期，setup/hold 用户 uncertainty 各为 100 ps。
OOC 验收覆盖内部路径，外部接口时序由集成工程约束；未包含板上测试。

两份迁移后的 IP 均通过布线、DSP 模式/级联及内部时序检查，无未解析黑盒、未约束内部端点、
DRC Error 或 Critical Warning。保留普通 CREG/MREG 流水建议及 OOC 外部无负载提示。
报告和各 target 的通过/失败记录位于 `BUILD_DIR`。

## 许可

采用 [MIT](LICENSE) 许可证。
