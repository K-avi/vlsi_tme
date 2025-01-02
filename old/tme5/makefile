
TARGET_EXEC:=shifter_tb



DEP_EXEC:=exec.vhdl
SRC_EXEC:=exec_tb.vhdl

DEP_ADDER:=adder32b.vhdl
DEP_FIFO:=fifo_72b.vhdl
DEP_ALU:=alu.vhdl
DEP_SHIFTER:=shifter.vhdl

CC:=ghdl
FLAGS:= -v -fsynopsys --std=08
EFLAGS:=-e 
AFLAGS:=-a
RFLAGS:=-r

all: $(TARGET_EXEC)

$(TARGET_EXEC): $(SRC_EXEC)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_ADDER)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_ALU)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_FIFO)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_EXEC)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_SHIFTER)
	$(CC) $(AFLAGS) $(FLAGS)  $(SRC_EXEC)
	$(CC) $(EFLAGS) $(FLAGS)  exec_tb
	$(CC) $(RFLAGS) $(FLAGS)  exec_tb


clean:
	rm -f *.cf *.o $(TARGET_ALU) $(TARGET_ADDER) $(TARGET_SHIFTER)