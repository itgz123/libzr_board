# Copyright (c) 2026 libzr
# SPDX-License-Identifier: Apache-2.0

# 默认 runner 为 OpenOCD + CMSIS-DAP；support/openocd.cfg 会被自动发现。
# 第一个 include 的 runner 成为默认，因此 openocd 必须放在最前面。
include(${ZEPHYR_BASE}/boards/common/openocd-stm32.board.cmake)

board_runner_args(jlink "--device=STM32F427II" "--speed=4000")
include(${ZEPHYR_BASE}/boards/common/jlink.board.cmake)
