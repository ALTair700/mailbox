SHELL := /bin/bash

PWD = $(shell pwd)

INCDIR_PREFIX =-incdir
LIB_FLAG = -v


ifndef AQ_BMC_DESIGN_MAILBOX_DIR
  AQ_BMC_DESIGN_MAILBOX_DIR:=$(abspath $(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
endif
include $(AQ_BMC_DESIGN_MAILBOX_DIR)/config.mk
include $(AQ_BMC_DESIGN_MAILBOX_DIR)/simfiles.mk
 
clean:
	rm -rf $(PWD)/xcelium.d
	rm -rf $(PWD)/.simvision
	rm -rf $(PWD)/waves.shm
	rm xrun.history
	rm xrun.key
	rm xrun.log
  
 
run_pem_mailbox_tests: list
	xrun \
	-64bit \
	-v93 \
	-sv \
	-timescale 1ns/10ps -notimingchecks \
	-access +rwc \
	-disable_sem2009 \
	-gui \
	-defineall AES128 \
	-f rtl.lst	\
	$(INCDIR)	\
	$(TESTBENCH_FILES)


.PHONY: list
list:
	@echo " -= Create RTL-list =- "
	@rm -f rtl.lst
	@for var in $(RTL_DEF); do echo +define+$$var >> rtl.lst; done
	@for var in $(RTL_INC); do echo +incdir+$$var >> rtl.lst; done
	@for var in $(RTL_SRC); do echo $$var >> rtl.lst; done 

