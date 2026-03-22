import re

# 1. Patch src/wl/sys/wl_linux.c
with open('broadcom-wl-6.18-port/src/wl/sys/wl_linux.c', 'r') as f:
    content = f.read()

# Replace PDE_DATA with pde_data
content = content.replace('PDE_DATA', 'pde_data')

# Replace <asm/unaligned.h> with <linux/unaligned.h>
content = content.replace('<asm/unaligned.h>', '<linux/unaligned.h>')

# Replace init_timer
timer_setup_code = """
static void
wl_timer(struct timer_list *tl)
{
	wl_timer_t *t = from_timer(t, tl, timer);"""

old_timer_code = """static void
wl_timer(
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 15, 0)
		struct timer_list *tl
#else
		ulong data
#endif
) {
	wl_timer_t *t =
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 15, 0)
		from_timer(t, tl, timer);
#else
		(wl_timer_t *)data;
#endif"""
content = content.replace(old_timer_code, timer_setup_code)

timer_init_code = """
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4, 15, 0)
	timer_setup(&t->timer, wl_timer, 0);
#else
	init_timer(&t->timer);
	t->timer.data = (ulong) t;
	t->timer.function = wl_timer;
#endif"""
content = content.replace(timer_init_code, "\ttimer_setup(&t->timer, wl_timer, 0);")

with open('broadcom-wl-6.18-port/src/wl/sys/wl_linux.c', 'w') as f:
    f.write(content)

# 2. Patch Makefile
with open('broadcom-wl-6.18-port/Makefile', 'r') as f:
    makefile = f.read()

makefile = "CC ?= clang-19\n" + makefile

with open('broadcom-wl-6.18-port/Makefile', 'w') as f:
    f.write(makefile)
