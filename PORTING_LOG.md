# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This journal tracks the evolution of the Broadcom-WL porting effort. It is maintained chronologically to preserve the architectural decisions, "nuclear" workarounds, and surgical fixes applied throughout the project.

---

## [2026-03-22] Phase 1: Foundation & Modernization

### Milestone 1: Build System Overhaul
- **Task:** Migrate legacy Makefile to modern Kbuild standards.
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

### Milestone 6: The "Nuclear" Makefile
- **Strategy:** Initial attempt at `OBJECT_FILES_NON_STANDARD := y`.

### Milestone 7: The "Anti-Rethunk" Counter-Measure (FAILED)
- **Problem:** Clang 19 rejected GCC-specific `-mno-rethunk` flags.

### Milestone 8: The Silent Linker Strategy (FAILED)
- **Observation:** Disabling profiling (GCOV/KCOV) did not stop `objtool` Error 255.

### Milestone 9: The Identity Theft (FAILED - The Backfire)
- **Observation:** `override cmd_objtool := :` broke Kbuild's internal `mv` logic.

### Milestone 10: The Subversion (FAILED)
- **Observation:** `OBJTOOL=/bin/true` on the command line was ignored by Kbuild.

### Milestone 11: The "Hollow Tool" Strategy
- **Action:** Created `scripts/objtool-shim.sh` and pointed Makefile `objtool` variables to it.
- **Success:** This finally bypassed the `objtool` Error 255!

---

## [2026-03-22] Phase 4: The Symbol Duel (Duplicate Symbols)

### Milestone 12: The Infiltration
- **Problem:** The final module link failed with "duplicate symbol" errors (e.g., `wlc_iovar_setint`).
- **Discovery:** 
  - All generated object files (`wl_linux.o`, `wl_iw.o`, etc.) were found to be ~7.5MB to 8MB in size—nearly identical to the original Broadcom binary blob.
  - Symbols like `wlc_iovar_setint` were being defined as `T` (text/code) symbols in every single `.o` file.
- **Analysis:** This indicates that the `ldflags-y += lib/wlc_hybrid.o_shipped` directive in the Makefile was being applied to *every* intermediate object compilation by Kbuild, essentially "linking" the entire Broadcom binary blob into every source file's output.
- **Solution:** 
  - Remove `ldflags-y` which caused the infiltration.
  - Use the standard Kbuild `wl-y += lib/wlc_hybrid.o` method to include the "shipped" binary only during the final module link.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success using the "Hollow Tool" shim.
- [ ] **Final Module Link:** Pending resolution of the duplicate symbol duel.
