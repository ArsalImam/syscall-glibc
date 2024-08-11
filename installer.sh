#!/bin/bash

DIR=$(pwd)
KERNEL_DIR=$(pwd)/kernel
SYSCALLS_DIR=$(pwd)/kernel/syscall-ipc
KERNEL_VER=$(uname -r | cut -d '-' -f1)
KERNEL_MAJOR_VER=$(echo $KERNEL_VER | cut -d '.' -f1)

function setupKernel() {
  PACKAGE_NAME=linux-$(echo $KERNEL_VER | awk -F. -v OFS=. '{$NF += 1 ; print}')

  wget https://www.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VER.x/$PACKAGE_NAME.tar.gz
  tar -xvf $PACKAGE_NAME.tar.gz -C.
  rm -rf $PACKAGE_NAME.tar.gz
  mv $DIR/$PACKAGE_NAME $KERNEL_DIR
}

function setupSystemCalls() {
  cd $KERNEL_DIR
  
  git clone https://github.com/ArsalImam/syscall-ipc


  echo "add these system calls to the kernel's system call table. \n \
  systemcall names: create_queue, delete_queue, msg_send, msg_receive, msg_ack \n \
  This usually involves editing a file like arch/x86/entry/syscalls/syscall_64.tbl \n \
  and run the script again with sh ./installer.sh 500 501 502 503 504 505"

  cd $DIR
}

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


# if ! [ -d $KERNEL_DIR ]; then
#   setupKernel
# fi