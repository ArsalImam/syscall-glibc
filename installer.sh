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

  git clone https://github.com/ArsalImam/syscall-ipc
}

if ! [ -d $KERNEL_DIR ]; then
  setupKernel
fi

cd $KERNEL_DIR

if ! [ -d $SYSCALLS_DIR ]; then
  setupSystemCalls
fi
