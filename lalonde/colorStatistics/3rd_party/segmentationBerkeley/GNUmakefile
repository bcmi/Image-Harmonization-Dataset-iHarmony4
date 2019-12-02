# use gmake!

# the order of the subdirectories matters
subdirs := Util CSA++ Filters Dataset Textons \
		Gradients Detectors Benchmark

# pass make directives to subdirectories
SHELL := sh
%:
	@for i in $(subdirs); do \
	  (cd $$i && $(MAKE) $@) || break; \
	done

# eof
