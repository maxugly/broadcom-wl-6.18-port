# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This journal tracks the evolution of the Broadcom-WL porting effort. It is maintained chronologically to preserve the architectural decisions, "nuclear" workarounds, and surgical fixes applied throughout the project.

---

## [2026-03-22] Phase 1: Foundation & Modernization
... (Previous Milestones preserved) ...

---

## [2026-03-22] Phase 4: The Symbol Duel & Linker Stability

### Milestone 16: The Linker's Precision (FAILED)
- **Problem:** `ld.lld: error: ././lib/wlc_hybrid.o_shipped:35940: unclosed quote`.
- **Reason:** Using `LDFLAGS_wl.o := -T ...` told the linker to treat the binary blob as a **linker script**. The linker then tried to parse the binary data as text, failing immediately when it hit a byte that looked like an unclosed quote.

### Milestone 17: The Kbuild Shipped Protocol
- **Discovery:** In recent Kbuild, the cleanest way to include a pre-compiled blob without duplication is to use the `$(obj)/%.o: $(src)/%.o_shipped` rule, but we must ensure it is added to `wl-y` correctly and that `targets` includes it to generate the necessary `.cmd` files.
- **Action:** 
  - Restored `lib/wlc_hybrid.o` to the `wl-y` list.
  - Added `$(obj)/lib/wlc_hybrid.o: $(src)/lib/wlc_hybrid.o_shipped FORCE` with the `$(call if_changed,shipped)` command.
  - Added `targets += lib/wlc_hybrid.o`.
  - Removed the problematic `LDFLAGS_wl.o` override.
- **Refinement:** Added `MODULE_DESCRIPTION` to `wl_linux.c` earlier to avoid modpost warnings.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success.
- [x] **Metadata Compliance:** 100% success.
- [ ] **Final Module Link:** Synchronizing the Kbuild shipped object protocol.
