#!/bin/bash

DIR=$(pwd)

KERNEL_SPECS_DIR=$DIR/kernel-specs
GLIBC_SPECS_DIR=$DIR/glibc-specs

INSTALLTION_DIR=$DIR/../dsrpt
KERNEL_DIR=$INSTALLTION_DIR/kernel
LIBC_DIR=$INSTALLTION_DIR/glibc

SYSCALLS_DIR=$KERNEL_DIR/dsrpt/

function setupKernel() {
  KERNEL_VER=$(uname -r | cut -d '-' -f1)
  KERNEL_MAJOR_VER=$(echo $KERNEL_VER | cut -d '.' -f1)

  PACKAGE_NAME=linux-$KERNEL_VER #$(echo $KERNEL_VER | awk -F. -v OFS=. '{$NF += 1 ; print}')

  wget https://www.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VER.x/$PACKAGE_NAME.tar.gz
  tar -xvf $PACKAGE_NAME.tar.gz -C.
  rm -rf $PACKAGE_NAME.tar.gz
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

  mkdir -p $LIBC_DIR
  
  GLIBC_DSRPT_SRC=dsrpt-syscall.c
  GLIBC_DSRPT_OBJ=libdsrpt.so

  cp $GLIBC_SPECS_DIR/$GLIBC_DSRPT_SRC $LIBC_DIR/

  gcc -shared -o $LIBC_DIR/$GLIBC_DSRPT_OBJ -fPIC $LIBC_DIR/$GLIBC_DSRPT_SRC
  mv $LIBC_DIR/$GLIBC_DSRPT_OBJ /usr/local/lib/
  ldconfig

  gcc $DIR/client.c -o $DIR/client -libdsrpt
  chmod +x $DIR/client


  # LIBC_VER=$(ldd --version | awk '/ldd/{print $NF}')
  # LIBC_PACKAGE_NAME=glibc-$LIBC_VER

  # wget https://ftp.gnu.org/gnu/glibc/$LIBC_PACKAGE_NAME.tar.gz
  # tar -xvf $LIBC_PACKAGE_NAME.tar.gz -C.
  # mv $DIR/$LIBC_PACKAGE_NAME $LIBC_DIR

  # LIBC_SRC=$LIBC_DIR/sysdeps/unix/sysv/linux/
  # LIBC_SRC_FILE=$LIBC_SRC/dsrpt-syscall.c

  # cp $DIR/dsrpt-syscall-wrapper.c $LIBC_SRC
  # mv $LIBC_SRC/dsrpt-syscall-wrapper.c $LIBC_SRC_FILE

  # echo "$(echo -n "#define SYS_create_queue $1"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  # echo "$(echo -n "#define SYS_delete_queue $2"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  # echo "$(echo -n "#define SYS_msg_send $3"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  # echo "$(echo -n "#define SYS_msg_receive $4"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  # echo "$(echo -n "#define SYS_msg_ack $5"; echo ""; cat $LIBC_SRC_FILE)" > $LIBC_SRC_FILE
  
  # if grep -R "dsrpt" $LIBC_SRC/Makefile
  # then
  #   echo "makefile already configured"
  # else
  #   echo "sysdep_routines += dsrpt-syscall" >> $LIBC_SRC/Makefile
  # fi
  # patch $LIBC_DIR/include/unistd.h ./unistd.h.patch 
}

mkdir $INSTALLTION_DIR

if ! [ -d $KERNEL_DIR ]; then
   setupKernel
fi

if ! [ -d $SYSCALLS_DIR ]; then
  setupSystemCalls
fi

if ! [ -d $LIBC_DIR ]; then
  setupLibC
fi





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




# apt-get install build-essential gcc libncurses5-dev bison flex libssl-dev libelf-dev bc dwarves
# apt-get update
# apt-get upgrade
# apt-get build-dep glibc

# mkdir -p $LIBC_DIR/glibc-build
# cd $LIBC_DIR/glibc-build

# export glibc_install="$(pwd)/install"
# ../configure --prefix "$glibc_install"

# make -j `nproc`
# make install -j `nproc`






## export CFLAGS="$CFLAGS -Wno-error=attributes -O2 -D_FORTIFY_SOURCE=1"
#make CFLAGS="-Wno-error=attributes  -O2 -D_FORTIFY_SOURCE=1" -j$(nproc) 
#make CFLAGS="-Wno-error=attributes  -O2 -D_FORTIFY_SOURCE=1" install




