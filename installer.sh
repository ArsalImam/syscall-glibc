#!/bin/bash

DIR=$(pwd)
KERNEL_SPECS_DIR=$DIR/kernel-specs

INSTALLTION_DIR=~/dsrpt
KERNEL_DIR=$INSTALLTION_DIR/kernel
LIBC_DIR=$INSTALLTION_DIR/glibc

SYSCALLS_DIR=$KERNEL_DIR/dsrpt/

KERNEL_VER=$(uname -r | cut -d '-' -f1)
KERNEL_MAJOR_VER=$(echo $KERNEL_VER | cut -d '.' -f1)

function setupKernel() {
  PACKAGE_NAME=linux-$KERNEL_VER #$(echo $KERNEL_VER | awk -F. -v OFS=. '{$NF += 1 ; print}')

  wget https://www.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VER.x/$PACKAGE_NAME.tar.gz
  tar -xvf $PACKAGE_NAME.tar.gz -C.
  #rm -rf $PACKAGE_NAME.tar.gz
  mv $DIR/$PACKAGE_NAME $KERNEL_DIR
}

function setupSystemCalls() {
  
  mkdir $SYSCALLS_DIR

  cp $KERNEL_SPECS_DIR/dsrpt.c $SYSCALLS_DIR
  echo "obj-y := dsrpt.o" > $SYSCALLS_DIR/Makefile
    
  patch $KERNEL_DIR/Kbuild $KERNEL_SPECS_DIR/Kbuild.diff
  patch $KERNEL_DIR/Makefile $KERNEL_SPECS_DIR/MainMakefile.diff
  patch $KERNEL_DIR/include/linux/syscalls.h $KERNEL_SPECS_DIR/syscall.h.diff 

  patch $KERNEL_DIR/include/uapi/asm-generic/unistd.h $KERNEL_SPECS_DIR/unistd.h.diff 
  patch $KERNEL_DIR/arch/x86/entry/syscalls/syscall_32.tbl $KERNEL_SPECS_DIR/syscall_32.tbl.diff
  patch $KERNEL_DIR/arch/x86/entry/syscalls/syscall_64.tbl $KERNEL_SPECS_DIR/syscall_64.tbl.diff 

  rm -rf $KERNEL_DIR/.config
  cp /boot/config-$(uname -r) $KERNEL_DIR/
  mv $KERNEL_DIR/config-$(uname -r) $KERNEL_DIR/.config
}

function setupLibC() {
  git clone https://sourceware.org/git/glibc.git $LIBC_DIR

  cd $LIBC_DIR
  git stash
  git checkout "glibc-$(ldd --version | awk '/ldd/{print $NF}')"
  cd $DIR

  LIBC_SRC=$LIBC_DIR/sysdeps/unix/sysv/linux/
  LIBC_SRC_FILE=$LIBC_SRC/dsrpt-syscall.c

  cp $DIR/dsrpt-syscall-wrapper.c $LIBC_SRC
  mv $LIBC_SRC/dsrpt-syscall-wrapper.c $LIBC_SRC_FILE

  echo "$(echo -n "#define SYS_create_queue $1"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  echo "$(echo -n "#define SYS_delete_queue $2"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  echo "$(echo -n "#define SYS_msg_send $3"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  echo "$(echo -n "#define SYS_msg_receive $4"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  echo "$(echo -n "#define SYS_msg_ack $5"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  
  if grep -R "dsrpt" $LIBC_SRC/Makefile
  then
    echo "makefile already configured"
  else
    echo "sysdep_routines += dsrpt-syscall" >> $LIBC_SRC/Makefile
  fi
#  cp $DIR/dsrpt-syscall.h $LIBC_SRC/include/
  patch $LIBC_DIR/include/unistd.h ./unistd.h.patch 
}

mkdir $INSTALLTION_DIR

if ! [ -d $KERNEL_DIR ]; then
  setupKernel
fi

if ! [ -d $SYSCALLS_DIR ]; then
  setupSystemCalls
fi

# if ! [ -d $LIBC_DIR ]; then
# fi

#setupLibC "$@"

echo "setting up prerequisites"

#kernel
cd $KERNEL_DIR

apt-get install gcc libncurses5-dev bison flex libssl-dev libelf-dev bc dwarves
apt-get update
apt-get upgrade


make oldconfig
make -j $(nproc)
make -j $(nproc) modules_install
make install

#apt-get install libnsl-dev libnss3-dev

#cd $LIBC_DIR
#mkdir ../glibc-build
#cd ../glibc-build
#../glibc/configure --prefix=/usr 

## export CFLAGS="$CFLAGS -Wno-error=attributes -O2 -D_FORTIFY_SOURCE=1"
#make CFLAGS="-Wno-error=attributes  -O2 -D_FORTIFY_SOURCE=1" -j$(nproc) 
#make CFLAGS="-Wno-error=attributes  -O2 -D_FORTIFY_SOURCE=1" install
