# libzr_board

libzr 的 Zephyr 板级定义集合（HWMv2）。每个板子只描述 **硬件本身**（MCU、时钟、
引脚、外设），不包含任何 app 或机器相关的路径。

## 目录结构

```
libzr_board/
├── boards/
│   ├── DJI_A/DJI_A_DEFAULT/
│   │   ├── board.yml
│   │   ├── board.cmake
│   │   ├── Kconfig.DJI_A_DEFAULT
│   │   ├── DJI_A_DEFAULT_defconfig
│   │   ├── DJI_A_DEFAULT.dts
│   │   ├── DJI_A_DEFAULT.yaml
│   │   ├── README.md
│   │   └── support/openocd.cfg
│   ├── DJI_C/DJI_C_DEFAULT/
│   └── DM_MC02/DM_MC02_DEFAULT/
└── README.md
```

`BOARD_ROOT` 指向本仓库根目录即可，Zephyr 会递归查找 `boards/**/board.yml`。

## 板子列表

| 板名 | MCU | Flash | 控制台 | 说明 |
| --- | --- | --- | --- | --- |
| `DJI_A_DEFAULT` | STM32F427IIH6 | 2 MB | USART2 | 6 路串口、2 路 CAN、3 路 SPI、2 路 ADC、DAC |
| `DJI_C_DEFAULT` | STM32F407IGH6 | 1 MB | USART6 | 3 路串口、2 路 CAN、2 路 SPI、2 路 I2C |
| `DM_MC02_DEFAULT` | STM32H723VGT6 | 1 MB | UART7 | 8 路串口（含 2 路 RS485）、3 路 FDCAN |

详细引脚见各板目录下的 `README.md`。

## 在 app 中接入

app 的 `CMakeLists.txt` 在 `find_package(Zephyr)` **之前**设置 `BOARD_ROOT`：

```cmake
cmake_minimum_required(VERSION 3.20.0)

set(LIBZR_DIR "${CMAKE_CURRENT_SOURCE_DIR}/libzr" CACHE PATH "libzr 子模块")

list(APPEND ZEPHYR_EXTRA_MODULES "${LIBZR_DIR}")
list(APPEND BOARD_ROOT          "${LIBZR_DIR}/libzr_board")

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(<你的 app>)

target_sources(app PRIVATE src/main.c)
```

两处路径都相对 app 自身推导，不含机器信息，可以直接提交。

也可以不修改 CMakeLists，构建时从命令行传入（必须是绝对路径）：

```sh
west build -b DJI_A_DEFAULT -d build . \
  -- -DBOARD_ROOT=$PWD/libzr/libzr_board
```

## 编译示例

```sh
# 在 app 根目录
west build -b DJI_A_DEFAULT   -d build/dji_a   .
west build -b DJI_C_DEFAULT   -d build/dji_c   .
west build -b DM_MC02_DEFAULT -d build/dm_mc02 .
```

## 烧录 / 调试

三块板默认都使用 **CMSIS-DAP + SWD**，配置文件在各板的
`support/openocd.cfg`，`west flash` / `west debug` 会自动发现：

```sh
west flash
west debug
```

使用 JLink 时：

```sh
west flash --runner jlink
```

| 板子 | JLink 器件 | OpenOCD target |
| --- | --- | --- |
| `DJI_A_DEFAULT` | `STM32F427II` | `target/stm32f4x.cfg` |
| `DJI_C_DEFAULT` | `STM32F407IG` | `target/stm32f4x.cfg` |
| `DM_MC02_DEFAULT` | `STM32H723VG` | `target/stm32h7x.cfg` |

## 新增板子

1. 在 `boards/<系列>/<板名>/` 下创建：
   - `board.yml`：`name`、`full_name`、`vendor: libzr`、`socs`
   - `Kconfig.<板名>`：`select SOC_<型号>`
   - `<板名>_defconfig`：MPU、串口、控制台、GPIO
   - `<板名>.dts`：引用 SoC 与 pinctrl dtsi，配置时钟与外设
   - `<板名>.yaml`：`ram` / `flash` / `supported`
   - `board.cmake`、`support/openocd.cfg`
2. 用 `hello_world` 编译验证：

```sh
west build -b <板名> -d build/check \
  zephyr/samples/hello_world -- \
  -DBOARD_ROOT=/绝对路径/libzr/libzr_board
```

3. 板名区分大小写，构建时原样传入 `-b`。

## 注意

- 引脚映射来自 `BetaRobot/cubemx` 与 `BetaRobot/bsp/bsp_map`，CubeMX 工程仅作为参考，
  本仓库不依赖它。
- 设备树中所有按键暂按 **低有效 + 内部上拉** 处理；若硬件相反，把
  `GPIO_ACTIVE_LOW` 改为 `GPIO_ACTIVE_HIGH`。
- APP 负责串口波特率、CAN 位时序等运行时参数，板级设备树只负责引脚与时钟。
