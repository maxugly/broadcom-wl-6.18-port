# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This journal tracks the evolution of the Broadcom-WL porting effort. It is maintained chronologically to preserve the architectural decisions, "nuclear" workarounds, and surgical fixes applied throughout the project.

---

## [2026-03-22] Phase 1: Foundation & Modernization
... (Previous Milestones preserved) ...

---

## [2026-03-22] Phase 4: The Symbol Duel & Linker Stability

### Milestone 12: The Infiltration (REVEALED)
- **Problem:** `ldflags-y` merged the binary blob into every intermediate object.

### Milestone 13: The Shipped Anchor
- **Action:** Attempted manual `cp` rule for `lib/wlc_hybrid.o`.

### Milestone 14: The Reference Guard (Void Linux Analysis)
- **Actions:** Added `MODULE_DESCRIPTION()`; attempted Kbuild `shipped` rule.

### Milestone 15: The Linker's Truce (FAILED)
- **Problem:** `ldflags-y` proved to be too global in modern XanMod Kbuild, continuing to cause "duplicate symbol" errors by merging the blob into every `.o` file (verified by file size bloat).

### Milestone 16: The Linker's Precision
- **Discovery:** In modern Kbuild, `ldflags-y` is added to almost every command line. For composite modules, we must use target-specific flags.
- **Action:** 
  - Replaced `ldflags-y` with `LDFLAGS_wl.o`.
  - This ensures the Broadcom binary blob (`wlc_hybrid.o_shipped`) is ONLY seen during the final link of `wl.o`, and not during the compilation of `wl_linux.c` or `wl_cfg80211_hybrid.c`.
- **Goal:** Eliminate duplicate symbols while maintaining `modpost` compatibility.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success.
- [x] **Metadata Compliance:** 100% success.
- [ ] **Final Module Link:** Isolating the binary blob link phase.
