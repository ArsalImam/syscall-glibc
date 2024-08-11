#!/bin/bash

DIR=$(pwd)
INSTALLTION_DIR=~/dsrpt

KERNEL_DIR=$INSTALLTION_DIR/kernel
LIBC_DIR=$INSTALLTION_DIR/glibc

SYSCALLS_DIR=$KERNEL_DIR/dsrpt-syscall/

KERNEL_VER=$(uname -r | cut -d '-' -f1)
KERNEL_MAJOR_VER=$(echo $KERNEL_VER | cut -d '.' -f1)

function setupKernel() {
  PACKAGE_NAME=linux-$(echo $KERNEL_VER | awk -F. -v OFS=. '{$NF += 1 ; print}')

  wget https://www.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VER.x/$PACKAGE_NAME.tar.gz
  tar -xvf $PACKAGE_NAME.tar.gz -C.
  rm -rf $PACKAGE_NAME.tar.gz
  mv $DIR/$PACKAGE_NAME $KERNEL_DIR
}

function setupLibC() {
  git clone https://sourceware.org/git/glibc.git $LIBC_DIR

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
}

function setupSystemCalls() {
  
  mkdir $SYSCALLS_DIR

  cp $DIR/dsrpt-syscall.c $SYSCALLS_DIR
  echo "obj-y := dsrpt-syscall.o" > $SYSCALLS_DIR/Makefile
  echo "obj-y += dsrpt-syscall/" >> $KERNEL_DIR/Kbuild
  
  patch $KERNEL_DIR/include/linux/syscalls.h ./syscall.h.patch 

  printf "add these system calls to the kernel's system call table. \n \
  systemcall names: create_queue, delete_queue, msg_send, msg_receive, msg_ack \n \
  This usually involves editing the files arch/x86/entry/syscalls/syscall_64.tbl \n \
  548     common  dsrpt-syscall   sys_create_queue \n \
  549     common  dsrpt-syscall   sys_delete_queue \n \
  550     common  dsrpt-syscall       sys_msg_send \n \
  551     common  dsrpt-syscall    sys_msg_receive \n \
  552     common  dsrpt-syscall        sys_msg_ack \n \
  and run the script again with sh ./installer.sh 500 501 502 503 504 505"

  cp /boot/config-$(uname -r) $KERNEL_DIR/.config

}

if ! [ -d $INSTALLTION_DIR ]; then
  mkdir $INSTALLTION_DIR
fi

if ! [ -d $KERNEL_DIR ]; then
  setupKernel
fi

if ! [ -d $SYSCALLS_DIR ]; then
  setupSystemCalls
fi

if [ "$#" -ne 5 ]; then
  echo "Provide the list of syscall numbers"
  exit 1
fi


if ! [ -d $LIBC_DIR ]; then
  setupLibC
fi

echo "setting up prerequisites"

#kernel
cd $KERNEL_DIR

make olddefconfig
make -j $(nproc)
make -j $(nproc) modules_install
make install


cd $LIBC_DIR
mkdir ../glibc-build
cd ../glibc-build
../glibc/configure --prefix=/usr
make -j$(nproc)