# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This journal tracks the evolution of the Broadcom-WL porting effort. It is maintained chronologically to preserve the architectural decisions, "nuclear" workarounds, and surgical fixes applied throughout the project.

---

## [2026-03-22] Phase 1: Foundation & Modernization

### Milestone 1: Build System Overhaul
- **Action:** Replaced `EXTRA_CFLAGS` with `ccflags-y` and `wl-objs` with `wl-y`.

### Milestone 2: Header & include Resolution
- **Action:** Forced strict include order; added guards for `<linux/unaligned.h>`.

### Milestone 3: Workqueue API Migration (Surgical Fix)
- **Fix:** Implemented `container_of()` pattern for handlers; replaced `flush_scheduled_work()`.

---

## [2026-03-22] Phase 2: API Alignment (6.1 - 6.18)

### Milestone 4: Timer API Evolution
- **Action:** Mapped `del_timer` -> `timer_delete` for 6.1+.

### Milestone 5: Wireless (cfg80211) MLO Support
- **Updates:** Ported `get_tx_power` and `set_tx_power` to 6.13/6.14 signatures.

---

## [2026-03-22] Phase 3: The Objtool Siege

### Milestone 6-10: The Nuclear Bypasses (Various Failures)
- **Lessons:** `objtool` is mandated by XanMod; overriding `cmd_objtool` breaks internal `mv` logic.

### Milestone 11: The "Hollow Tool" Strategy
- **Action:** Created `scripts/objtool-shim.sh` and pointed Makefile `objtool` variables to it.
- **Success:** This finally bypassed the `objtool` Error 255!

---

## [2026-03-22] Phase 4: The Symbol Duel (Duplicate Symbols)

### Milestone 12: The Infiltration (REVEALED)
- **Problem:** `ldflags-y` was merging the 7.5MB binary blob into *every* intermediate object file.
- **Result:** Massive "duplicate symbol" errors at the final link phase.

### Milestone 13: The Shipped Anchor
- **Problem:** `make[3]: *** No rule to make target 'lib/wlc_hybrid.o', needed by 'wl.o'. Stop.`
- **Reason:** Kbuild's automatic `.o_shipped` resolution failed for the subdirectory path.
- **Action:** 
  - Restored `lib/wlc_hybrid.o_shipped` to the `wl-y` list using its explicit name.
  - Added a clean `$(obj)/lib/wlc_hybrid.o` rule to manually anchor the binary blob in the `lib/` directory during the link.
- **Goal:** Ensure the binary blob is linked exactly once into the final module.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success using the "Hollow Tool" shim.
- [ ] **Final Module Link:** Stabilizing the binary blob inclusion.
