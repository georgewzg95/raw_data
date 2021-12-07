#
# makefile
#


# super-simple linker.ld / ;)
APP_STACK_SIZE := 0x400
APP_HEAP_SIZE  := 0x400

#
MEM_DIR := _bmm
OBJ_DIR := _obj

#
TARGET_NAME = rom

#
all: clean cc listing bin mem

#
CC := mb-gcc
LD := mb-gcc
OBJDUMP := mb-objdump
OBJCOPY := mb-objcopy
DEFAULT_CP := cp -f
DEFAULT_MKDIR := mkdir -p
DEFAULT_RM := rm -rf

#
INCDIR := ./ \
 ./platform \
 ./microblaze \
 ../../hw/src/rtl/wb_pio/drivers \
 ../../hw/src/rtl/wb_uart/drivers 
INCLUDE := $(addprefix -I, $(INCDIR))

XILFLAGS :=-mxl-soft-div -msoft-float -mxl-barrel-shift -mno-xl-soft-mul
CFLAGS :=-g -ansi -pedantic -Wall
CFLAGS += $(XILFLAGS)
LFLAGS=-Wl,-defsym -Wl,_STACK_SIZE=$(APP_STACK_SIZE) -Wl,-defsym -Wl,_HEAP_SIZE=$(APP_HEAP_SIZE)

C_SRCS := $(wildcard ./*.c)
C_SRCS += $(wildcard ./platform/*.c)
C_SRCS += $(wildcard ./microblaze/*.c)
C_SRCS += $(wildcard ../../hw/src/rtl/wb_pio/drivers/*.c)
C_SRCS += $(wildcard ../../hw/src/rtl/wb_uart/drivers/*.c)

OBJECTS_C := $(patsubst %.c,%.o, $(C_SRCS))
OBJFILES_C := $(addprefix $(OBJ_DIR)/, $(OBJECTS_C))

OBJECTS_O := $(patsubst %.c,%.o, $(notdir $(C_SRCS)))
OBJFILES_O := $(addprefix $(OBJ_DIR)/, $(OBJECTS_O))


$(OBJ_DIR)/%.o: %.c
	@echo Compiling $<:
	$(CC) -c $(CFLAGS) $(INCLUDE) -o $(OBJ_DIR)/$(notdir $@) $<

prep_cc:
	$(DEFAULT_RM) $(OBJ_DIR)
	$(DEFAULT_MKDIR) $(OBJ_DIR)

prep_mem:
	$(DEFAULT_RM) $(MEM_DIR)
	$(DEFAULT_MKDIR) $(MEM_DIR)
	test -s ../util/bin2mem || { make -C ../util; }

cc: prep_cc $(OBJFILES_C)
	@echo C_SRCS: $(C_SRCS)
	$(LD) -o $(TARGET_NAME).elf $(OBJFILES_O) $(LFLAGS)

listing:
	mb-size -t $(TARGET_NAME).elf
	mb-objdump -DSsh  $(TARGET_NAME).elf > $(TARGET_NAME).objdump

bin: prep_mem
	mb-objcopy -O binary $(TARGET_NAME).elf $(MEM_DIR)/$(TARGET_NAME).bin

mem:
	../util/bin2mem < $(MEM_DIR)/$(TARGET_NAME).bin > $(MEM_DIR)/$(TARGET_NAME).mem
	../util/bin2mem4 < $(MEM_DIR)/$(TARGET_NAME).bin
	$(DEFAULT_CP) *.mem ./$(MEM_DIR)
	$(DEFAULT_RM) *.mem

clean:
	@$(DEFAULT_RM) \
	$(OBJ_DIR) \
	$(MEM_DIR) \
	*.objdump \
	*.bak \
	*.elf
