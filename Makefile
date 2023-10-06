# var
MODULE = $(notdir $(CURDIR))
CORES  = $(shell grep proc /proc/cpuinfo| wc -l)

# dirs
CWD  = $(CURDIR)
SRC  = $(CWD)/src
TMP  = $(CWD)/tmp
HOST = $(CWD)/host
ROOT = $(CWD)/root
GZ   = $(HOME)/gz

# tool
CURL = curl -L -o

# version
BINUTILS_VER = 2.41
GCC_VER      = 13.2.0
GMP_VER      = 6.2.1
MPFR_VER     = 4.2.1
MPC_VER      = 1.3.1
SYSLINUX_VER = 6.03

# package
BINUTILS = binutils-$(BINUTILS_VER)
GCC      = gcc-$(GCC_VER)
GMP      = gmp-$(GMP_VER)
MPFR     = mpfr-$(MPFR_VER)
MPC      = mpc-$(MPC_VER)
SYSLINUX = syslinux-$(SYSLINUX_VER)

BINUTILS_GZ = $(BINUTILS).tar.xz
GCC_GZ      = $(GCC).tar.xz
GMP_GZ      = $(GMP).tar.gz
MPFR_GZ     = $(MPFR).tar.xz
MPC_GZ      = $(MPC).tar.gz
SYSLINUX_GZ = $(SYSLINUX).tar.xz

# build
.PHONY: gcclibs0 gmp0 mpfr0 mpc0
gcclibs0: gmp0 mpfr0 mpc0

CFG_CCLIBS  = configure --prefix=$(HOST) --disable-shared
CFG_CCLIBS += --with-gmp=$(HOST)

gmp0: $(HOST)/lib/libgmp.a
$(HOST)/lib/libgmp.a: $(SRC)/$(GMP)/README
	rm -rf $(TMP)/gmp ; mkdir $(TMP)/gmp ; cd $(TMP)/gmp ;\
	$(SRC)/$(GMP)/$(CFG_CCLIBS) &&\
	$(MAKE) -j$(CORES) && $(MAKE) install

mpfr0: $(HOST)/lib/libmpfr.a
$(HOST)/lib/libmpfr.a: $(SRC)/$(MPFR)/README
	rm -rf $(TMP)/mpfr ; mkdir $(TMP)/mpfr ; cd $(TMP)/mpfr ;\
	$(SRC)/$(MPFR)/$(CFG_CCLIBS) &&\
	$(MAKE) -j$(CORES) && $(MAKE) install

# src
.PHONY: src
src: $(SRC)/$(BINUTILS)/README.md $(SRC)/$(GCC)/README.md \
	 $(SRC)/$(GMP)/README $(SRC)/$(MPFR)/README.md $(SRC)/$(MPC)/README.md \
	 $(SRC)/$(SYSLINUX)/README.md

$(SRC)/$(GMP)/README: $(GZ)/$(GMP_GZ)
	cd $(SRC) ; tar zx < $< && mv GMP-$(GMP_VER) $(GMP) ; touch $@

# rule
$(SRC)/%/README.md: $(GZ)/%.tar.xz
	cd $(SRC) ; xzcat $< | tar x && touch $@
$(SRC)/%/README.md: $(GZ)/%.tar.gz
	cd $(SRC) ;  zcat $< | tar x && touch $@

# install
.PHONY: install update gz
install: gz
	$(MAKE) update
update:
	sudo apt update
	sudo apt install -yu `cat apt.txt`
gz: \
	$(GZ)/$(BINUTILS_GZ) $(GZ)/$(GCC_GZ) \
	$(GZ)/$(GMP_GZ) $(GZ)/$(MPFR_GZ) $(GZ)/$(MPC_GZ) \
	$(GZ)/$(SYSLINUX_GZ)
	ls -la $^

$(GZ)/$(BINUTILS_GZ):
	$(CURL) $@ https://ftp.gnu.org/gnu/binutils/$(BINUTILS_GZ)
$(GZ)/$(GCC_GZ):
	$(CURL) $@ http://mirror.linux-ia64.org/gnu/gcc/releases/$(GCC)/$(GCC_GZ)

$(GZ)/$(GMP_GZ):
	$(CURL) $@ https://github.com/alisw/GMP/archive/refs/tags/v$(GMP_VER).tar.gz
$(GZ)/$(MPFR_GZ):	
	$(CURL) $@ https://www.mpfr.org/mpfr-current/$(MPFR_GZ)
$(GZ)/$(MPC_GZ):
	$(CURL) $@ https://ftp.gnu.org/gnu/mpc/$(MPC_GZ)

$(GZ)/$(SYSLINUX_GZ):
	$(CURL) $@ https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/$(SYSLINUX_GZ)
