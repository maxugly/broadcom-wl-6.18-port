# Broadcom 802.11abg Networking Device Driver Makefile
# Targeting Kernel 6.18+ (XanMod)

# Nuclear option: Disable objtool by overriding its command
cmd_objtool := :
objtool-enabled := n
OBJECT_FILES_NON_STANDARD := y
KBUILD_OBJTOOL := 0
KBUILD_NO_OBJTOOL := 1

ifneq ($(KERNELRELEASE),)

  # Disable objtool for every specific object path just in case
  OBJECT_FILES_NON_STANDARD_wl.o := y
  OBJECT_FILES_NON_STANDARD_src/shared/linux_osl.o := y
  OBJECT_FILES_NON_STANDARD_src/wl/sys/wl_linux.o := y
  OBJECT_FILES_NON_STANDARD_src/wl/sys/wl_iw.o := y
  OBJECT_FILES_NON_STANDARD_src/wl/sys/wl_cfg80211_hybrid.o := y

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
  
  # Reduce objtool strictness if it still runs
  ccflags-y += -fno-stack-protector -Wno-date-time

  ifeq ($(APIFINAL),CFG80211)
    ccflags-y += -DUSE_CFG80211
  endif

  ifeq ($(APIFINAL),WEXT)
    ccflags-y += -DUSE_IW
  endif

  # Object files
  obj-m += wl.o
  wl-y := src/shared/linux_osl.o \
          src/wl/sys/wl_linux.o \
          src/wl/sys/wl_iw.o \
          src/wl/sys/wl_cfg80211_hybrid.o

  ldflags-y += $(src)/lib/wlc_hybrid.o_shipped

else

# Build environment outside Kbuild
KBASE      ?= /lib/modules/$(shell uname -r)
KBUILD_DIR ?= $(KBASE)/build

all:
	$(MAKE) -C $(KBUILD_DIR) M=$(PWD) KBUILD_OBJTOOL=0 KBUILD_NO_OBJTOOL=1

clean:
	$(MAKE) -C $(KBUILD_DIR) M=$(PWD) clean

install:
	install -D -m 755 wl.ko $(KBASE)/kernel/drivers/net/wireless/wl.ko

endif
