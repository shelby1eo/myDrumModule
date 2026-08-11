#!/usr/bin/env bash


mkdir stm32mp15-demo
cd stm32mp15-demo
mkdir stm32mp1_distrib_oss
mkdir zephy_rpmsg_multi_services


export YOCTO_VER=scarthgap
cd stm32mp1_distrib_oss
mkdir -p layers/meta-st

git clone https://git.yoctoproject.org/git/poky layers/poky
cd layers/poky
git checkout -b WORKING origin/$YOCTO_VER
cd -

git clone https://github.com/openembedded/meta-openembedded.git layers/meta-openembedded
cd layers/meta-openembedded
git checkout -b WORKING origin/$YOCTO_VER
cd -

git clone https://github.com/STMicroelectronics/meta-st-stm32mp-oss.git layers/meta-st/meta-st-stm32mp-oss
cd layers/meta-st/meta-st-stm32mp-oss
git checkout -b WORKING origin/$YOCTO_VER
cd -
