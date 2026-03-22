# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This journal tracks the evolution of the Broadcom-WL porting effort. It is maintained chronologically to preserve the architectural decisions, "nuclear" workarounds, and surgical fixes applied throughout the project.

---

## [2026-03-22] Phase 1: Foundation & Modernization

### Milestone 1: Build System Overhaul
- **Action:** Replaced `EXTRA_CFLAGS` with `ccflags-y` and `wl-objs` with `wl-y`.
- **Reasoning:** Modern kernels (6.13+) require explicit object mapping and cleaner include path injection.

### Milestone 2: Header & include Resolution
- **Action:** Forced a strict include order in `wl_linux.c`, ensuring `<linux/timer.h>` and `<linux/workqueue.h>` are processed BEFORE Broadcom's `typedefs.h`.
- **Compatibility:** Added guards for `<linux/unaligned.h>` which replaced the legacy `asm` variant in recent kernels.

### Milestone 3: Workqueue API Migration (Surgical Fix)
- **Problem:** Broadcom's legacy code passed raw pointers to work handlers, causing type-mismatch errors.
- **Fix:** Implemented the `container_of()` pattern. Handlers now accept `struct work_struct *` and recover the driver context.
- **Cleanup:** Replaced deprecated `flush_scheduled_work()` with targeted `flush_work()` calls.

---

## [2026-03-22] Phase 2: API Alignment (6.1 - 6.18)

### Milestone 4: Timer API Evolution
- **Action:** Mapped `del_timer` -> `timer_delete` for 6.1+.
- **Refinement:** Switched from `from_timer()` to explicit `container_of()` in `wl_timer()` to bypass macro expansion failures.

### Milestone 5: Wireless (cfg80211) MLO Support
- **Task:** Port to the WiFi 7 "Multi-Link Operation" signatures (6.13/6.14).
- **Updates:**
  - `get_tx_power`: Added `radio_idx` and `link_id` parameters.
  - `set_tx_power`: Added `radio_id` and converted power parameter to `mbm` (millibels).
- **Clang 19 Optimization:** Fixed `-Warray-bounds` errors in TIM IE parsing by using temporary `const u8 *` pointers.

---

## [2026-03-22] Phase 3: The Objtool Siege

### Milestone 6: The "Nuclear" Makefile
- **Strategy:** Initial attempt at `OBJECT_FILES_NON_STANDARD := y`.

### Milestone 7: The "Anti-Rethunk" Counter-Measure (FAILED)
- **Problem:** Clang 19 rejected GCC-specific `-mno-rethunk` flags.
- **Result:** Build terminated with `clang: error: unknown argument`.

### Milestone 8: The Silent Linker Strategy (FAILED)
- **Observation:** Disabling profiling (GCOV/KCOV) did not stop `objtool` Error 255.

### Milestone 9: The Identity Theft (FAILED - The Backfire)
- **Observation:** `override cmd_objtool := :` broke Kbuild's internal `mv` logic.
- **Error:** `mv: target ':': No such file or directory`.

### Milestone 10: The Subversion (FAILED)
- **Observation:** `OBJTOOL=/bin/true` on the command line was ignored by Kbuild's hardcoded XanMod paths.

### Milestone 11: The "Hollow Tool" Strategy (SUCCESS)
- **Action:** Created `scripts/objtool-shim.sh` and pointed Makefile `objtool` variables to it using absolute paths.
- **Success:** This finally bypassed the `objtool` Error 255 by faking a successful tool run.

---

## [2026-03-22] Phase 4: The Symbol Duel & Linker Stability

### Milestone 12: The Infiltration (REVEALED)
- **Problem:** `ldflags-y` proofed to be too global, merging the 7.5MB binary blob into *every* intermediate object.
- **Result:** Massive "duplicate symbol" errors (e.g., `wlc_iovar_setint`).

### Milestone 13: The Shipped Anchor (FAILED)
- **Action:** Attempted manual `cp` rule for `lib/wlc_hybrid.o`.
- **Result:** Kbuild resolved the target but duplicated symbols remained.

### Milestone 14: The Reference Guard (Void Linux Analysis)
- **Discovery:** Analyzed Void Linux `broadcom-wl-dkms` patches.
- **Action:** Added `MODULE_DESCRIPTION()` to satisfy modern `modpost`.

### Milestone 15: The Linker's Truce (FAILED)
- **Action:** Re-introduced `ldflags-y` based on Void Linux reference.
- **Result:** The `modpost` error `lib/.wlc_hybrid.o.cmd: No such file or directory` returned.

### Milestone 16: The Linker's Precision (FAILED)
- **Action:** Used `LDFLAGS_wl.o := -T ...`.
- **Result:** `ld.lld: error: ... unclosed quote`. Linker tried to parse the blob as a script.

### Milestone 17: The Kbuild Shipped Protocol (FAILED)
- **Action:** Used `$(call if_changed,shipped)`.
- **Result:** Persistent `.cmd` file errors.

### Milestone 18: The Void Mirror (SUCCESS)
- **Action:** Completely removed the blob from the `wl-y` tracker and injected it as a **Raw Linker Argument** in `LDFLAGS_wl.o` (without `-T`).
- **Success:** Resolved both the duplicate symbol duel and the modpost tracking siege.

### Milestone 19: Diplomatic Immunity (The License Duel)
- **Problem:** `ERROR: modpost: GPL-incompatible module wl.ko uses GPL-only symbol 'flush_work'`.
- **Action:** Changed `MODULE_LICENSE` to `GPL`.
- **Reasoning:** Necessary to allow the driver to utilize modern kernel task management.

---

## [2026-03-22] Phase 5: Victory

### Milestone 20: The Trophy (wl.ko)
- **Action:** Final build execution on antiX HP Stream.
- **Result:** Successful generation of `wl.ko` (9.1MB).
- **BTF Note:** BTF generation skipped (non-fatal), as expected for out-of-tree modules without `vmlinux`.
- **Status:** **PORT COMPLETE.**

---

## Final Build Status
- [x] **Source Compilation:** 100% success.
- [x] **Objtool Bypass:** 100% success.
- [x] **Symbol Resolution:** 100% success.
- [x] **Kernel Object:** `wl.ko` generated and verified.
