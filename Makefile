PACKAGE_VERSION="0.1.14"
CC=			gcc
CFLAGS=		-g -Wall -O3 #-m64 #-arch ppc
DFLAGS=		-D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -D_USE_KNETFILE -DPACKAGE_VERSION=\\\"${PACKAGE_VERSION}\\\"
DWGSIM_AOBJS = src/dwgsim_opt.o src/mut.o src/contigs.o src/regions_bed.o \
			   src/mut_txt.o src/mut_bed.o src/mut_vcf.o src/mut_input.o src/dwgsim.o
DWGSIM_EVAL_AOBJS = src/dwgsim_eval.o \
					samtools/knetfile.o \
					samtools/bgzf.o samtools/kstring.o samtools/bam_aux.o samtools/bam.o samtools/bam_import.o samtools/sam.o samtools/bam_index.o \
					samtools/bam_pileup.o samtools/bam_lpileup.o samtools/bam_md.o samtools/razf.o samtools/faidx.o samtools/bedidx.o \
					samtools/bam_sort.o samtools/sam_header.o samtools/bam_reheader.o samtools/kprobaln.o samtools/bam_cat.o

PROG=		dwgsim dwgsim_eval
INCLUDES=	-I.
SUBDIRS=	samtools . 
CLEAN_SUBDIRS=	samtools src
LIBPATH=

.SUFFIXES:.c .o

.c.o:
		$(CC) -c $(CFLAGS) $(DFLAGS) $(INCLUDES) $< -o $@

all-recur lib-recur clean-recur cleanlocal-recur install-recur:
		@target=`echo $@ | sed s/-recur//`; \
		wdir=`pwd`; \
		list='$(SUBDIRS)'; for subdir in $$list; do \
			cd $$subdir; \
			$(MAKE) CC="$(CC)" DFLAGS="$(DFLAGS)" CFLAGS="$(CFLAGS)" \
				INCLUDES="$(INCLUDES)" LIBPATH="$(LIBPATH)" $$target || exit 1; \
			cd $$wdir; \
		done;

all:$(PROG)

.PHONY:all lib clean cleanlocal
.PHONY:all-recur lib-recur clean-recur cleanlocal-recur install-recur

dwgsim:lib-recur $(DWGSIM_AOBJS)
	$(CC) $(CFLAGS) -o $@ $(DWGSIM_AOBJS) -lm -lz -lpthread

dwgsim_eval:lib-recur $(DWGSIM_EVAL_AOBJS)
	$(CC) $(CFLAGS) -o $@ $(DWGSIM_EVAL_AOBJS) -Lsamtools -lm -lz -lpthread

cleanlocal:
		rm -vfr gmon.out *.o a.out *.exe *.dSYM razip bgzip $(PROG) *~ *.a *.so.* *.so *.dylib; \
		wdir=`pwd`; \
		list='$(CLEAN_SUBDIRS)'; for subdir in $$list; do \
			if [ -d $$subdir ]; then \
				cd $$subdir; \
				pwd; \
				rm -vfr gmon.out *.o a.out *.exe *.dSYM razip bgzip $(PROG) *~ *.a *.so.* *.so *.dylib; \
				cd $$wdir; \
			fi; \
		done;

clean:cleanlocal-recur

dist:clean
	if [ -f dwgsim-${PACKAGE_VERSION}.tar.gz ]; then \
        rm -rv dwgsim-${PACKAGE_VERSION}.tar.gz; \
	fi; \
	if [ -f dwgsim-${PACKAGE_VERSION}.tar ]; then \
        rm -rv dwgsim-${PACKAGE_VERSION}.tar; \
	fi; \
	if [ -d dwgsim-${PACKAGE_VERSION} ]; then \
        rm -rv dwgsim-${PACKAGE_VERSION}; \
	fi; \
    mkdir dwgsim-${PACKAGE_VERSION}; \
	cp -r INSTALL LICENSE Makefile README scripts src dwgsim-${PACKAGE_VERSION}/.; \
	tar -vcf dwgsim-${PACKAGE_VERSION}.tar dwgsim-${PACKAGE_VERSION}; \
	gzip -9 dwgsim-${PACKAGE_VERSION}.tar; \
	rm -rv dwgsim-${PACKAGE_VERSION};

test:
	if [ -d tmp ]; then rm -r tmp; fi
	/bin/bash testdata/test.sh
