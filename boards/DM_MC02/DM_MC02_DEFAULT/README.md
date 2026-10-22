# DM_MC02_DEFAULT

libzr DM_MC02 控制板的 Zephyr HWMv2 板级定义。

| 项目 | 值 |
| --- | --- |
| MCU | STM32H723VGT6 (LQFP100) |
| Flash | 1 MB |
| SRAM | 320 KB AXI + 128 KB DTCM + 64 KB ITCM + 32 KB D2 + 16 KB D3 |
| 晶振 | HSE 24 MHz |
| SYSCLK | 480 MHz (HCLK 240 / APB1..4 120) |
| FDCAN 内核时钟 | 120 MHz (PLL1_Q) |
| USB 内核时钟 | 48 MHz (PLL3_Q) |
| 控制台 | UART7 (PE8/PE7, 115200 8N1) |
| 调试 | SWD；`support/openocd.cfg` 为 CMSIS-DAP 配置 |

## 编译

app 的 `CMakeLists.txt` 已设置 `BOARD_ROOT` 时：

```sh
west build -b DM_MC02_DEFAULT -d build .
```

单独指定板级目录时：

```sh
west build -b DM_MC02_DEFAULT -d build . \
  -- -DBOARD_ROOT=/绝对路径/libzr/libzr_board
```

## 烧录 / 调试

```sh
west flash                    # openocd + CMSIS-DAP
west flash --runner jlink     # JLink，器件 STM32H723VG
west debug                    # openocd + gdb
```

RTT 日志（`support/openocd_rtt.cfg`，telnet 端口 8888）：

```sh
openocd -f boards/DM_MC02/DM_MC02_DEFAULT/support/openocd_rtt.cfg
```

## 引脚分配

### 串口

| 外设 | TX | RX | 用途 |
| --- | --- | --- | --- |
| USART1 | PA9 | PB7 | 通用 (921600 8N1) |
| USART2 | PD5 | PD6 | RS485 (DE PD4) |
| USART3 | PD8 | PD9 | RS485 (DE PB14) |
| UART5 | PC12 | PD2 | SBUS 接收 (100000 8E1) |
| UART7 | PE8 | PE7 | 日志 / 控制台 |
| UART8 | PE1 | PE0 | 扩展 (115200 8N1) |
| UART9 | PD15 | PD14 | 扩展 (115200 8N1) |
| USART10 | PE3 | PE2 | 扩展 (921600 8N1) |

### FDCAN

| 外设 | RX | TX |
| --- | --- | --- |
| FDCAN1 | PD0 | PD1 |
| FDCAN2 | PB5 | PB6 |
| FDCAN3 | PD12 | PD13 |

### SPI / I2C

| 外设 | 引脚 | 用途 |
| --- | --- | --- |
| SPI1 | SCK PB3, MISO PB4, MOSI PD7 | BMI088 |
| SPI2 | SCK PB13, MISO PC2_C, MOSI PC1 | 扩展 |
| I2C2 | SCL PB10, SDA PB11 | 扩展 |

### ADC

| 外设 | 通道 |
| --- | --- |
| ADC1 | INP4 PC4（电池电压） |

### PWM

| 定时器 | 通道 |
| --- | --- |
| TIM1 | CH1 PE9, CH3 PE13 |
| TIM2 | CH1 PA0, CH3 PA2 |
| TIM12 | CH2 PB15（蜂鸣器 4 kHz） |

### GPIO / USB

| 信号 | 引脚 |
| --- | --- |
| USER_KEY | PE14 |
| EX_KEY | PA15 |
| LCD_KEY1 / LCD_KEY2 | PA5 / PD10 |
| BMI088_CS_ACCEL / CS_GYRO | PC0 / PC3 |
| BMI088_INT_ACCEL / INT_GYRO | PE10 / PE12 |
| POWER_24V_EN1 / EN2 | PC14 / PC13 |
| POWER_5V_EN | PC15 |
| USB OTG HS | DM PA11, DP PA12 |

设备树中的按键按低有效、内部上拉处理；若硬件相反请改为 `GPIO_ACTIVE_HIGH`。
