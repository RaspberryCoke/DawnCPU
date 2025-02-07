# 指令内存
初始化为NOP指令：0x10
# 赋值操作
irmovq 0x2 %rdx               %rdx=2   
30 F2 02 00 00 00 00 00 00 00
irmovq 0x1 %rcx               %rcx=1
30 F1 01 00 00 00 00 00 00 00
irmovq 0x3 %rbx               %rbx=3
30 F3 03 00 00 00 00 00 00 00
irmovq 0x90 %rsp(.4)          %rsp=0x90
30 f4 90 00 00 00 00 00 00 00
irmovq 0x8 %r8                %r8=0x8
30 F8 08 00 00 00 00 00 00 00
irmovq 0x21 %r9               %r9=0x21
30 f9 21 00 00 00 00 00 00 00
irmovq 0x4 %r14               %r14=0x4
30 fe 21 00 00 00 00 00 00 00
rrmovq %r8 %r10               %r10=%r8=0x8     
20 8A
rrmovq %rcx %r11              %r11=%rcx=0x1      
20 1B
rrmovq %rdx %r12              %r12=%rdx=0x2      
20 2C
rrmovq %rbx %r13              %r13=%rbx=0x3      
20 3D


# 计算
addq %r8 %r10                 %r10=%r8+%r10=0x10
60 8A

subq  %r8 %r10                %r10=%r10-%r8=0x8
61 8A
jle  0x300(error)
71 00 03 00 00 00 00 00 00

subq  %r8 %r10                %r10=%r10-%r8=0
61 8A
jne  0x300(error)
74 00 03 00 00 00 00 00 00

xorq %r12(=2) %rdx(=2)        %rdx=0
63 C2
jne  0x300(error)
74 00 03 00 00 00 00 00 00

andq %r14(=4) %rbx(=3)        %rbx=0
62 E3
jne  0x300(error)
74 00 03 00 00 00 00 00 00

# push pop
pushq (rA=)%r12=2  (rB=F)     %rsp=0x88,M[0x88]=%r12=2 --
a0 Cf
popq (rA=)%rax(.0=0) (rB=F)     %rax=M[0x88]=2,%rsp=0x90
b0 0f
xorq %r12(=2) %rax(=2)        %rax=0
63 C0
jne  0x300(error)
74 00 03 00 00 00 00 00 00

# 访存
rmmovq %r13(=3) (%rdx(.2)(=0)+8)   rmmovq ra D(rb) M[0x8]=3
40 D2 08 00 00 00 00 00 00 00
mrmovq (%rdx(.2)(=0)+8) %rbx(.3)     mrmovq D(rb) ra  %rbx=M[0x8]=3
50 32 08 00 00 00 00 00 00 00
xorq %r13(=3) %rbx(=3)        %rbx=0
63 D3
jne  0x300(error)             (9字节)
74 00 03 00 00 00 00 00 00


# 跳转
subq %rax %rbx  %rbx=%rbx-%rax=0-0=0
61 03
jg=76 0x300(error)            (9字节)
76 00 03 00 00 00 00 00 00
jl=2 0x300(error)            (9字节)
72 00 03 00 00 00 00 00 00
je=73 0x60=96                (9字节) # 跳转到call ret
73 60 00 00 00 00 00 00 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00

---从0x60=96开始
# call ret 地址0x60
call=80 0x120                 (9字节)
80 20 01 00 00 00 00 00 00


# ret到这里，jmp到正常退出
jmp=70 0x100                  (9字节)
70 00 01 00 00 00 00 00 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00




# 正常退出：地址 0x100
hlt=00  {instr_mem[256]=8'h00;}
hlt=00
hlt=00
hlt=00
hlt=00


---从0x120=288开始
# 执行多个XOR指令后ret 地址0x80，
# 通过是否执行XOR来判断是否正确执行
XOR %rax %rax   {instr_mem[288]=8'h63;}
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
XOR %rax %rax
63 00
ret=90  
90
jmp 0x300(error)              ret失败
70 00 03 00 00 00 00 00 00


# 错误处理：地址 0x300
//nop=10
instr_mem[768]=8'h10;  注意：0x300=768
注：不需要写，因为内存初始化为0x10.