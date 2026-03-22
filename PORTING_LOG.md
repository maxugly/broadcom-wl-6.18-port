# Broadcom-WL Porting Journal: Target Kernel 6.18 (XanMod)

This journal tracks the evolution of the Broadcom-WL porting effort. It is maintained chronologically to preserve the architectural decisions, "nuclear" workarounds, and surgical fixes applied throughout the project.

---

## [2026-03-22] Phase 1: Foundation & Modernization
... (Previous Milestones preserved) ...

---

## [2026-03-22] Phase 4: The Symbol Duel & Linker Stability

### Milestone 16: The Linker's Precision (FAILED)
- **Problem:** `ld.lld: error: ... unclosed quote`.
- **Reason:** Incorrectly used `-T` (linker script) flag for a binary object.

### Milestone 17: The Kbuild Shipped Protocol (FAILED)
- **Problem:** `modpost` error: `./lib/.wlc_hybrid.o.cmd: No such file or directory`.
- **Reason:** Kbuild's internal `modpost` stage requires `.cmd` tracking for every object in the `wl-y` list, which is incompatible with binary blobs in subdirectories without complex Kbuild integration.

### Milestone 18: The Void Mirror (The Surgical Link)
- **Context:** Derived from Void Linux reference patches.
- **Action:** 
  - Completely removed `lib/wlc_hybrid.o` from the `wl-y` object list.
  - Injected the binary blob directly into the final module link using `LDFLAGS_wl.o`.
  - **Correction:** Used the raw path without the `-T` flag to ensure the linker treats it as a relocatable object, not a script.
- **Logic:** This "Hollows out" the module tracking—Kbuild only sees our compiled C files, but the linker silently pulls in the "Rebel Blob" at the last millisecond. This resolves both the "Duplicate Symbol" duel and the "Modpost" `.cmd` file siege.

---

## Current Build Status
- [x] **Source Compilation:** 100% complete.
- [x] **Objtool Bypass:** 100% success.
- [x] **Metadata Compliance:** 100% success.
- [ ] **Final Module Link:** Attempting the "Void Mirror" linker bypass.
