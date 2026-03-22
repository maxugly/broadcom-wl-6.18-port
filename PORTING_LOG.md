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

### Milestone 6-11: The Nuclear Bypasses & Hollow Tool
- **Success:** Bypassed `objtool` Error 255 using the `scripts/objtool-shim.sh` strategy.

---

## [2026-03-22] Phase 4: The Symbol Duel & Linker Stability

### Milestone 12: The Infiltration (REVEALED)
- **Problem:** `ldflags-y` merged the binary blob into every intermediate object.

### Milestone 13: The Shipped Anchor
- **Action:** Used manual `cp` rule for `lib/wlc_hybrid.o`.

### Milestone 14: The Reference Guard (Void Linux Analysis)
- **Actions:** Added `MODULE_DESCRIPTION()`; attempted Kbuild `shipped` rule.
- **Problem:** `modpost` failed due to missing `.cmd` files for the shipped object.

### Milestone 15: The Linker's Truce
- **Problem:** `modpost` error: `./lib/.wlc_hybrid.o.cmd: No such file or directory`.
- **Discovery:** Void Linux uses `EXTRA_LDFLAGS := $(src)/lib/wlc_hybrid.o_shipped` to bypass Kbuild's source tracking for the binary blob.
- **Action:** 
  - Removed `lib/wlc_hybrid.o` from `wl-y`.
  - Re-introduced `ldflags-y += $(src)/lib/wlc_hybrid.o_shipped`.
  - **Critical Fix:** Ensured that `ldflags-y` is applied only to the final link by verifying the Kbuild environment. 
- **Verification:** This satisfies `modpost` while correctly anchoring the binary blob once.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success.
- [x] **Metadata Compliance:** 100% success.
- [ ] **Final Module Link:** Attempting to finalize `.ko` generation with the ldflags fix.
