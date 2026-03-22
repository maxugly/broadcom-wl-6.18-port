# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This log provides a granular technical breakdown of the architectural changes required to bring the Broadcom-WL hybrid driver into the WiFi 7 / WiFi 8 era (Kernel 6.18+).

## Technical Deep-Dive

### 1. The Workqueue Paradigm Shift (Kernel 5.15+)
- **Signature Migration:** Changed function prototypes (e.g., `wl_start_txqwork`) from `void fn(wl_task_t *task)` to `void fn(struct work_struct *work)`.
- **Object Recovery:** Utilized `container_of(work, wl_task_t, work)` to retrieve the parent structure safely.
- **Flushing Logic:** Migrated from deprecated `flush_scheduled_work()` to explicit `flush_work(&wl->task.work)`.

### 2. Timer API Evolution (Kernel 6.1+)
- **Compatibility Layer:** Added macros in `linuxver.h` to map `del_timer` to `timer_delete` for kernels >= 6.1.0.
- **Context Access:** Fixed `container_of` usage for timers to ensure correct structure layout recovery.

### 3. cfg80211 MLO & Radio-Awareness (Kernel 6.11 - 6.14)
- **`get_tx_power` (6.13+):** Updated signature to `(struct wiphy*, struct wireless_dev*, int radio_idx, unsigned int link_id, int* dbm)`.
- **`set_tx_power` (6.14+):** Updated signature to use `int mbm` (millibels-milliwatt) and `int radio_id`.
- **Bounds Checking:** Resolved `-Warray-bounds` errors in TIM IE processing by using explicit pointer arithmetic.

### 4. The Objtool "Nuclear" Saga (Persistent Error 255)
- **Challenge:** The legacy Broadcom blob (`wlc_hybrid.o_shipped`) contains unannotated intra-function calls (e.g., in `aes_cbc_encrypt_pad`) that trigger `objtool` validation failures at the final module link phase.
- **Nuclear Strategy:** 
    - Overrode `cmd_objtool := :` in the Makefile to neutralize the command.
    - Set `objtool-enabled := n`, `KBUILD_OBJTOOL := 0`, and `KBUILD_NO_OBJTOOL := 1`.
    - Applied `OBJECT_FILES_NON_STANDARD := y` to all component objects.
- **Status:** Despite these overrides, Kbuild on XanMod 6.18 continues to trigger `objtool` at the `LD [M] wl.o` step. This indicates that `objtool` is mandated by the kernel's top-level module linking rules when certain security/tracing features are enabled.

---

## Current Build Status
- **Source Compilation:** 100% (All .o files generated successfully).
- **Linking Status:** Blocked by `objtool` Error 255 during `wl.o` creation.
- **Next Step:** Investigation into forcing `OBJTOOL=/bin/true` in the environment or patching the kernel build scripts if the binary bypass remains elusive.
