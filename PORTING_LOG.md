# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This log tracks the architectural changes and bug fixes applied during the porting of the hybrid Broadcom-WL driver from legacy 2.6/3.x/4.x/5.x compatibility to the modern 6.18 XanMod kernel.

## Build Environment
- **Host:** Arch Linux (Logic/Planning)
- **Target:** antiX (HP Stream, 2GB RAM)
- **Compiler:** Clang 19 (LLVM=1)
- **Shared Filesystem:** NFS

---

## Technical Milestones

### 1. Build System Modernization
- **Makefile Overhaul:** Migrated from legacy `EXTRA_CFLAGS` and `wl-objs` to modern Kbuild `ccflags-y` and `wl-y`.
- **Objtool Bypass:** The Broadcom binary blob (`wlc_hybrid.o_shipped`) lacks modern stack annotations. We aggressively disabled `objtool` using `OBJECT_FILES_NON_STANDARD` for all object paths and `KBUILD_NO_OBJTOOL=1` to allow linking.

### 2. Header & Include Resolution
- **Include Order:** Reorganized includes in `wl_linux.c` to ensure kernel headers (like `linux/timer.h`) are processed before Broadcom's local headers to prevent redefinition conflicts.
- **Unaligned Access:** Added version guards for `<linux/unaligned.h>` (6.18+) vs `<asm/unaligned.h>` (legacy).

### 3. Workqueue API Migration
- **Signature Change:** Modern kernels require workqueue functions to accept `struct work_struct *` instead of custom pointers.
- **Container Recovery:** Replaced dangerous function type casts in `MY_INIT_WORK` with the `container_of()` macro pattern inside task handlers (`wl_start_txqwork`, `wl_dpc_rxwork`, etc.).
- **Specific Flushing:** Replaced deprecated system-wide `flush_scheduled_work()` with targeted `flush_work()` calls on specific driver work items.

### 4. Timer API Compatibility
- **Macro Guarding:** Added compatibility macros in `linuxver.h` for Kernel 6.1+, mapping legacy `del_timer` / `del_timer_sync` to the new `timer_delete` / `timer_delete_sync` names.
- **from_timer Logic:** Replaced `from_timer()` uses with direct `container_of()` to avoid macro expansion issues in complex include environments.

### 5. Wireless (cfg80211) API Updates
The `cfg80211_ops` structure underwent significant changes between 6.11 and 6.14 to support WiFi 7 MLO (Multi-Link Operation):
- **set_wiphy_params:** Updated to handle changed parameter types.
- **set_tx_power:** Updated signature to include `int radio_id` (6.14+).
- **get_tx_power:** Updated signature to include `int radio_idx` and `unsigned int link_id` (6.13+).
- **Array Bounds Fix:** Used pointer arithmetic/temporary pointers to access TIM IE data, bypassing strict `-Warray-bounds` checks on modern Clang.

---

## Status: Linking Phase
- [x] All C sources compiling
- [x] Headers resolved
- [x] Preprocessor balance verified
- [ ] Final Module Link (`wl.ko`)
