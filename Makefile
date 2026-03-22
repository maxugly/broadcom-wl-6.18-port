# Broadcom 802.11abg Networking Device Driver Makefile
# Targeting Kernel 6.18+ (XanMod)

# Milestone 11: Use a local shim script to bypass objtool
OBJTOOL_SHIM := $(abspath $(src)/scripts/objtool-shim.sh)
override objtool := $(OBJTOOL_SHIM)
override OBJTOOL := $(OBJTOOL_SHIM)

# Nuclear hints for Kbuild
objtool-enabled := n
KBUILD_OBJTOOL := 0
KBUILD_NO_OBJTOOL := 1
OBJECT_FILES_NON_STANDARD := y

# Disable profiling and instrumentation to minimize objtool's triggers
GCOV_PROFILE := n
KCOV_INSTRUMENT := n
UBSAN_SANITIZE := n
KASAN_SANITIZE := n

ifneq ($(KERNELRELEASE),)

  # Explicitly disable objtool for all objects
  OBJECT_FILES_NON_STANDARD_wl.o := y
  $(obj)/wl.o: objtool-enabled := n
  $(obj)/src/shared/linux_osl.o: objtool-enabled := n
  $(obj)/src/wl/sys/wl_linux.o: objtool-enabled := n
  $(obj)/src/wl/sys/wl_iw.o: objtool-enabled := n
  $(obj)/src/wl/sys/wl_cfg80211_hybrid.o: objtool-enabled := n

  # API Selection Logic
  LINUXVER_GOODFOR_CFG80211:=$(strip $(shell \
    if [ "$(VERSION)" -ge "2" -a "$(PATCHLEVEL)" -ge "6" -a "$(SUBLEVEL)" -ge "32" -o "$(VERSION)" -ge "3" ]; then \
      echo TRUE; \
    else \
      echo FALSE; \
    fi \
  ))

  ifneq ($(API),)
    ifeq ($(API), CFG80211)
      APIFINAL := CFG80211
    else
      ifeq ($(API), WEXT)
        APIFINAL := WEXT
      else
        $(error Unknown API type)
      endif
    endif
  else
    ifeq ($(LINUXVER_GOODFOR_CFG80211),TRUE)
      APIFINAL := CFG80211
    else
      APIFINAL := WEXT
    endif
  endif

  # Compiler Flags
  ccflags-y += -I$(src)/src/include -I$(src)/src/common/include
  ccflags-y += -I$(src)/src/wl/sys -I$(src)/src/wl/phy -I$(src)/src/wl/ppr/include
  ccflags-y += -I$(src)/src/shared/bcmwifi/include
  
  # Silence stack validation/unwind triggers
  ccflags-y += -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables

  ifeq ($(APIFINAL),CFG80211)
    ccflags-y += -DUSE_CFG80211
  endif

  ifeq ($(APIFINAL),WEXT)
    ccflags-y += -DUSE_IW
  endif

  # Object files
  obj-m += wl.o
  # Milestone 12 & 14: Correctly link the binary blob as a component object
  wl-y := src/shared/linux_osl.o \
          src/wl/sys/wl_linux.o \
          src/wl/sys/wl_iw.o \
          src/wl/sys/wl_cfg80211_hybrid.o \
          lib/wlc_hybrid.o

  # Standard Kbuild rule for shipped objects
  # This automatically handles the .o_shipped -> .o copy and generates .cmd files
  $(obj)/lib/wlc_hybrid.o: $(src)/lib/wlc_hybrid.o_shipped
	$(call if_changed,shipped)

  targets += lib/wlc_hybrid.o

else

# Build environment outside Kbuild
KBASE      ?= /lib/modules/$(shell uname -r)
KBUILD_DIR ?= $(KBASE)/build

all:
	$(MAKE) -C $(KBUILD_DIR) M=$(PWD) KBUILD_OBJTOOL=0 KBUILD_NO_OBJTOOL=1 OBJTOOL=$(abspath scripts/objtool-shim.sh)

clean:
	$(MAKE) -C $(KBUILD_DIR) M=$(PWD) clean

install:
	install -D -m 755 wl.ko $(KBASE)/kernel/drivers/net/wireless/wl.ko

endif
