# Makefile

# 设置TOP文件
TOP := $(basename $(notdir $(firstword $(wildcard *.v)))) )

# 编译所有的 .v 文件
VFILES := $(wildcard *.v)

# 默认目标
all: compile

# 编译命令
compile:
	@echo "Compiling files..."
	vlog $(VFILES)

# 设置仿真目标
sim:
	@if [ "$(words $(MAKECMDGOALS))" -ne 1 ]; then \
		echo "Error: You must specify exactly one parameter for the top module."; \
		exit 1; \
	fi
	@echo "Running simulation with vsim -c $(firstword $(MAKECMDGOALS))..."
	vsim -c $(firstword $(MAKECMDGOALS))

# 设置另一种仿真目标
SIM:
	@if [ "$(words $(MAKECMDGOALS))" -ne 1 ]; then \
		echo "Error: You must specify exactly one parameter for the top module."; \
		exit 1; \
	fi
	@echo "Running simulation with vsim $(firstword $(MAKECMDGOALS))..."
	vsim $(firstword $(MAKECMDGOALS))

# 清理命令
clean:
	@echo "Cleaning..."
	# rm -rf work
