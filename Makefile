# 编译所有的 .v 文件
VFILES := $(wildcard *.v)
VFILES += $(wildcard fetch/*.v)          # 添加 fetch 文件夹下的所有 .v 文件
VFILES := $(filter-out old_Single_cycle_CPU_files/*.v, $(VFILES))  # 排除 old 文件夹下的所有 .v 文件

# 默认目标
all: compile

# 编译命令
compile:
	@echo "Compiling files..." > runtime_log.txt
	vlog $(VFILES) >> runtime_log.txt 2>&1  # 将编译过程输出追加到 runtime_log.txt
	@echo "Starting simulation with str= test_writeback ." >> runtime_log.txt
	@vsim -c test_writeback -do "run -all; exit" >> runtime_log.txt 2>&1  # 将模拟输出追加到 runtime_log.txt
