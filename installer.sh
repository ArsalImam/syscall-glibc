
DIR=$(pwd)
KERNEL_DIR=$(pwd)/kernel
KERNEL_VER=$(uname -r | cut -d '-' -f1)
KERNEL_MAJOR_VER=$(echo $KERNEL_VER | cut -d '.' -f1)

function setupKernel() {

    PACKAGE_NAME=linux-$(echo $KERNEL_VER | awk -F. -v OFS=. '{$NF += 1 ; print}')

    wget https://www.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR_VER.x/$PACKAGE_NAME.tar.gz && \
    tar -xvf $PACKAGE_NAME.tar.gz -C. && \ 
    rm  -rf $PACKAGE_NAME  && \ 
    mv $DIR/$PACKAGE_NAME $KERNEL_DIR
}

if ! [ -d $KERNEL_DIR ]; then
  setupKernel
fi

