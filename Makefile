# 编译所有的 .v 文件
VFILES := $(wildcard *.v)

# 默认目标
all: compile

# 编译命令
compile:
	@echo "Compiling files..."
	vlog $(VFILES)
	@echo "Starting simulation with str= top_single_module2 ."
	@vsim -c top_single_module2 -do "run -all; exit"


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
