# DJI_A_DEFAULT

libzr DJI_A 飞控板的 Zephyr HWMv2 板级定义。

| 项目 | 值 |
| --- | --- |
| MCU | STM32F427IIH6 (UFBGA176) |
| Flash | 2 MB |
| SRAM | 192 KB + 64 KB CCM |
| 晶振 | HSE 12 MHz |
| SYSCLK | 168 MHz (AHB 168 / APB1 42 / APB2 84) |
| 控制台 | USART2 (PD5/PD6, 115200 8N1) |
| 调试 | SWD；`support/openocd.cfg` 为 CMSIS-DAP 配置 |

## 编译

app 的 `CMakeLists.txt` 已设置 `BOARD_ROOT` 时：

```sh
west build -b DJI_A_DEFAULT -d build .
```

单独指定板级目录时：

```sh
west build -b DJI_A_DEFAULT -d build . \
  -- -DBOARD_ROOT=/绝对路径/libzr/libzr_board
```

## 烧录 / 调试

```sh
west flash                    # openocd + CMSIS-DAP
west flash --runner jlink     # JLink，器件 STM32F427II
west debug                    # openocd + gdb
```

RTT 日志（`support/openocd_rtt.cfg`，telnet 端口 8888）：

```sh
openocd -f boards/DJI_A/DJI_A_DEFAULT/support/openocd_rtt.cfg
```

## 引脚分配

### 串口

| 外设 | TX | RX | 用途 |
| --- | --- | --- | --- |
| USART1 | PB6 | PB7 | SBUS 接收 (100000 8E1) |
| USART2 | PD5 | PD6 | 控制台 / 通用 (921600 8N1) |
| USART3 | PD8 | PD9 | 通用 (921600 8N1) |
| UART7 | PE8 | PE7 | 图传 / 裁判系统 (921600 8N1) |
| UART8 | PE1 | PE0 | 通用 (921600 8N1) |
| USART6 | PG14 | PG9 | 四针串口 (921600 8N1) |

### CAN

| 外设 | RX | TX |
| --- | --- | --- |
| CAN1 | PD0 | PD1 |
| CAN2 | PB12 | PB13 |

### SPI / I2C

| 外设 | 引脚 | 用途 |
| --- | --- | --- |
| SPI1 | SCK PB3, MOSI PA7 | OLED（只发） |
| SPI4 | SCK PE12, MISO PE5, MOSI PE6, NSS PE4 | IMU 等 |
| SPI5 | SCK PF7, MISO PF8, MOSI PF9, NSS PF6 | 扩展 |
| I2C2 | SCL PF1, SDA PF0 | IST8310 |

### ADC / DAC

| 外设 | 通道 |
| --- | --- |
| ADC1 | IN8 PB0, IN9 PB1, IN10 PC0, IN11 PC1, IN12 PC2, IN13 PC3, IN14 PC4, IN15 PC5 |
| ADC3 | IN14 PF4, IN15 PF5, IN8 PF10 |
| DAC1 | OUT1 PA4, OUT2 PA5 |

### PWM

| 定时器 | 通道 |
| --- | --- |
| TIM1 | CH1 PA8, CH2 PA9, CH3 PE13, CH4 PE14 |
| TIM2 | CH1 PA0, CH2 PA1, CH3 PA2, CH4 PA3 |
| TIM3 | CH2 PB5（加热） |
| TIM4 | CH1 PD12, CH2 PD13, CH3 PD14, CH4 PD15 |
| TIM5 | CH1 PH10, CH2 PH11, CH3 PH12, CH4 PI0 |
| TIM8 | CH1 PI5, CH2 PI6, CH3 PI7, CH4 PI2 |
| TIM12 | CH1 PH6（蜂鸣器 4 kHz） |

### GPIO / USB

| 信号 | 引脚 |
| --- | --- |
| USER_KEY | PB2 |
| OLED_KEY | PA6 |
| OLED_DC / OLED_RST | PB9 / PB10 |
| MPU6500_INT | PB8 |
| IST8310_RSTN / DRDY | PE2 / PE3 |
| LED_R / LED_G | PE11 / PF14 |
| SD_EXTI | PE15 |
| LASER | PG13 |
| POWER_EN1..4 | PH2 / PH3 / PH4 / PH5 |
| DAC_EXTI | PI9 |
| USB OTG FS | DM PA11, DP PA12 |

设备树中的按键按低有效、内部上拉处理；若硬件相反请改为 `GPIO_ACTIVE_HIGH`。
