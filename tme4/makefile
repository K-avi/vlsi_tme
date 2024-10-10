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
CFLAGS:=-e -v  --std=08

BFLAGS:=-a -v --std=08

all: $(TARGET_ALU) $(TARGET_ADDER) $(TARGET_SHIFTER)




$(TARGET_ALU): $(SRC_ALU)
	$(CC) $(CFLAGS) $(DEP_ALU)
	$(CC) $(CFLAGS) $(SRC_ALU)

$(TARGET_ADDER): $(SRC_ADDER)
	$(CC) $(BFLAGS) $(DEP_ADDER)
	$(CC) $(BFLAGS) $(SRC_ADDER)
	$(CC) $(CFLAGS) adder32b_tb


$(TARGET_SHIFTER): $(SRC_SHIFTER)
	$(CC) $(BFLAGS) $(DEP_SHIFTER)
	$(CC) $(BFLAGS) $(SRC_SHIFTER)

clean:
	rm -f *.cf *.o $(TARGET_ALU) $(TARGET_ADDER) $(TARGET_SHIFTER)