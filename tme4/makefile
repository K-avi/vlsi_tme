TARGET_ALU:=alu_tb
TARGET_ADDER:=adder32b_tb
TARGET_SHIFTER:=shifter_tb



DEP_ALU:=alu.vhdl
SRC_ALU:=alu_tb.vhdl

DEP_ADDER:=adder32b.vhdl
SRC_ADDER:=adder32b_tb.vhdl

DEP_SHIFTER:=shifter.vhdl
SRC_SHIFTER:=shifter_tb.vhdl

CC:=ghdl
FLAGS:= -v -fsynopsys --std=08
EFLAGS:=-e 
AFLAGS:=-a
RFLAGS:=-r

all: $(TARGET_ALU) $(TARGET_ADDER) $(TARGET_SHIFTER)

$(TARGET_ALU): $(SRC_ALU)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_ALU)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_ADDER)
	$(CC) $(AFLAGS) $(FLAGS)  $(SRC_ALU)
	$(CC) $(EFLAGS) $(FLAGS)  $(SRC_ALU)	
	$(CC) $(RFLAGS) $(FLAGS)  alu_tb

$(TARGET_ADDER): $(SRC_ADDER)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_ADDER)
	$(CC) $(AFLAGS) $(FLAGS)  $(SRC_ADDER)
	$(CC) $(EFLAGS) $(FLAGS)  $(SRC_ADDER)	
	$(CC) $(RFLAGS) $(FLAGS)  adder32b_tb

$(TARGET_SHIFTER): $(SRC_SHIFTER)
	$(CC) $(AFLAGS) $(FLAGS)  $(DEP_SHIFTER)
	$(CC) $(AFLAGS) $(FLAGS)  $(SRC_SHIFTER)
	$(CC) $(EFLAGS) $(FLAGS)  $(SRC_SHIFTER)	
	$(CC) $(RFLAGS) $(FLAGS)  shifter_tb

clean:
	rm -f *.cf *.o $(TARGET_ALU) $(TARGET_ADDER) $(TARGET_SHIFTER)