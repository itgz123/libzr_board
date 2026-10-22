# DJI_C_DEFAULT

libzr DJI_C 飞控板的 Zephyr HWMv2 板级定义。

| 项目 | 值 |
| --- | --- |
| MCU | STM32F407IGH6 (UFBGA176) |
| Flash | 1 MB |
| SRAM | 128 KB + 64 KB CCM |
| 晶振 | HSE 12 MHz |
| SYSCLK | 168 MHz (AHB 168 / APB1 42 / APB2 84) |
| 控制台 | USART6 (PG14/PG9, 115200 8N1) |
| 调试 | SWD；`support/openocd.cfg` 为 CMSIS-DAP 配置 |

## 编译

app 的 `CMakeLists.txt` 已设置 `BOARD_ROOT` 时：

```sh
west build -b DJI_C_DEFAULT -d build .
```

单独指定板级目录时：

```sh
west build -b DJI_C_DEFAULT -d build . \
  -- -DBOARD_ROOT=/绝对路径/libzr/libzr_board
```

## 烧录 / 调试

```sh
west flash                    # openocd + CMSIS-DAP
west flash --runner jlink     # JLink，器件 STM32F407IG
west debug                    # openocd + gdb
```

RTT 日志（`support/openocd_rtt.cfg`，telnet 端口 8888）：

```sh
openocd -f boards/DJI_C/DJI_C_DEFAULT/support/openocd_rtt.cfg
```

## 引脚分配

### 串口

| 外设 | TX | RX | 用途 |
| --- | --- | --- | --- |
| USART1 | PA9 | PB7 | 图传 / 裁判系统 (921600 8N1) |
| USART3 | PC10 | PC11 | SBUS 接收 (100000 8E1) |
| USART6 | PG14 | PG9 | 控制台 / vofa |

### CAN

| 外设 | RX | TX |
| --- | --- | --- |
| CAN1 | PD0 | PD1 |
| CAN2 | PB5 | PB6 |

### SPI / I2C

| 外设 | 引脚 | 用途 |
| --- | --- | --- |
| SPI1 | SCK PB3, MISO PB4, MOSI PA7 | BMI088 |
| SPI2 | SCK PB13, MISO PB14, MOSI PB15, NSS PB12 | 扩展 |
| I2C2 | SCL PF1, SDA PF0 | 扩展 |
| I2C3 | SCL PA8, SDA PC9 | 扩展 |

### ADC

| 外设 | 通道 |
| --- | --- |
| ADC3 | IN8 PF10 |

### PWM

| 定时器 | 通道 |
| --- | --- |
| TIM1 | CH1 PE9, CH2 PE11, CH3 PE13, CH4 PE14 |
| TIM3 | CH3 PC8（激光） |
| TIM4 | CH3 PD14（蜂鸣器 4 kHz） |
| TIM5 | CH1 PH10（LED_B）, CH2 PH11（LED_G）, CH3 PH12（LED_R） |
| TIM8 | CH1 PC6, CH2 PI6, CH3 PI7 |
| TIM10 | CH1 PF6（加热） |

### GPIO / USB

| 信号 | 引脚 |
| --- | --- |
| USER_KEY | PA0 |
| BMI088_CS_ACCEL / CS_GYRO | PA4 / PB0 |
| BMI088_INT_ACCEL / INT_GYRO | PC4 / PC5 |
| IST8310_DRDY / RSTN | PG3 / PG6 |
| USB OTG FS | DM PA11, DP PA12 |

设备树中的按键按低有效、内部上拉处理；若硬件相反请改为 `GPIO_ACTIVE_HIGH`。
