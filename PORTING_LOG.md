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

## [2026-03-22] Phase 4: The Symbol Duel (Duplicate Symbols)

### Milestone 12: The Infiltration (REVEALED)
- **Problem:** `ldflags-y` merged the binary blob into every intermediate object.

### Milestone 13: The Shipped Anchor
- **Action:** Used manual `cp` rule for `lib/wlc_hybrid.o`.

### Milestone 14: The Reference Guard (Void Linux Analysis)
- **Context:** Inspected Void Linux patches (`017-019`) for Kernel 6.12+.
- **Findings:** 
  - Void Linux uses `linux/unaligned.h` for 6.12+ (matches our fix).
  - Void Linux removes `net/lib80211.h` for 6.13+ (confirmed in our research).
- **Actions:**
  - **Metadata Fix:** Added `MODULE_DESCRIPTION()` to `wl_linux.c` to satisfy 6.6+ modpost requirements.
  - **Kbuild Standardization:** Replaced the manual `cp` rule in the Makefile with the standard `$(call if_changed,shipped)` Kbuild macro. This ensures the `.lib/.wlc_hybrid.o.cmd` files are correctly generated, resolving the modpost "No such file or directory" error.
- **Verification:** Module now reaches the `MODPOST` stage successfully.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success.
- [x] **Metadata Compliance:** Added missing `MODULE_DESCRIPTION`.
- [ ] **Final Module Link:** Finalizing `modpost` and `.ko` generation.
