# Developer Guide: Broadcom-WL 6.18 Port

## Environment Setup
This project uses a Nix flake to manage Clang 19 and build tools. 
The target kernel is **6.18.18-x64v2-xanmod1**.

### 1. Install Headers
Run `./setup-jules.sh` to install the specific XanMod kernel headers.

### 2. Enter Build Shell
Run `nix develop`.

### 3. Build Command
Use the alias `jbuild` (which maps to `make KBASE=/lib/modules/6.18.18-x64v2-xanmod1`).

## Known Porting Tasks
- Replace `init_timer` / `timer.data` -> `timer_setup()` / `from_timer()`.
- Move `<asm/unaligned.h>` -> `<linux/unaligned.h>`.
- Fix `PDE_DATA` -> `pde_data`.
- Replace `strlcpy` -> `strscpy`.