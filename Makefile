# 编译所有的 .v 文件
VFILES := $(wildcard *.v)
VFILES += $(wildcard fetch/*.v)          # 添加 fetch 文件夹下的所有 .v 文件
VFILES := $(filter-out old_Single_cycle_CPU_files/*.v, $(VFILES))  # 排除 old 文件夹下的所有 .v 文件

# 默认目标
all: compile

# 编译命令
compile:
	@echo "Compiling files..."
	vlog $(VFILES)
	@echo "Starting simulation with str= top_five_module ."
	@vsim -c top_five_module -do "run -all; exit"


# # 目标是 sim，依赖于传递给 make 的 str
# sim: $(str)
# 	@echo "Starting simulation with str=${str}"
# 	@vsim -c ${str} -do "run -all; exit"
# #; exit"

# # 通过 make 命令传递 str 的值
# $(str):
# 	@echo "Assigning value to str: ${str}"
# 	@echo ${str}


# 清理命令
clean:
	@echo "Cleaning..."
# rm -rf work
