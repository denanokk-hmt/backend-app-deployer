#!/bin/bash

################################
#Initial
################################

#base dir, tmp
SYSD=$(pwd)
CONFD=${SYSD}/CONFIG
tmp=${SYSD}/TEMP/tmp

#colored
explain="4;36"
selected="7;35"

#set up tmp
[ -d ./TEMP ] && rm -f $tmp-* || mkdir ${SYSD}/TEMP

#color
. SHELL/colored.sh || exit 1

#bash version
bash --version | awk 'NR==1{print $4}' | cut -d'.' -f1 > $tmp-bash_version

colored "7;35;42" "\\n\\n     ■■■■ WhatYa Deployer script start ■■■■      "


##############################
cat << HELP_EOF > $(pwd)/TEMP/tmp-help
#
# build hmt update script
# command kubectl set image action 
#
# 引数
#   $1:req:チケット番号(exp:WHAT-1, WSD-1,)
#   $2:req:サーバーコード(exp:svc, svc,)
#   $3:req:メジャー(exp: v1 or v2)
#   $4:req:バージョン(exp:
#     新しいバージョン(tiny):自動設定-->"new"と入力
#     新しいバージョン(minor):既存2.0.*-->"2.1"と入力
#     最新バージョン:自動設定-->"latest"と入力
#     過去バージョン:メジャー、マイナータイニーを入力-->exp: "2.0.1"と入力
HELP_EOF
HELP=`echo $@ | grep -i -e "--help"`
if [ -n "${HELP}" ]; then
  cat $(pwd)/TEMP/tmp-help
  exit 0
fi


################################
#Basic
################################
LANG=ja_JP.UTF-8
TIME=$(date +%Y%m%d).$(date +%H%M%S) 


################################
#Set up default sub shell
colored $explain "Set up default sub shell"
################################
. SHELL/error_chk.sh || exit 1
. SHELL/validation.sh || exit 1
. SHELL/hearing.sh || exit 1
. SHELL/version.sh || exit 1
. SHELL/checkout_branch.sh || exit 1
. SHELL/update_release_branch.sh || exit 1
. SHELL/waiting_looper.sh || exit 1
. SHELL/finisher.sh || exit 1
ERR_CHK " sub shell instance."  


################################
#Validation
colored $explain "\nValidation"
################################
VALIDATION_ARGS $1 $2 $3 $4 || exit 1
ERR_CHK " validation."  


################################
#Arguments
################################
TICKET=$1
SVR=$2
#SERIES=${3:-v2}
ARG_V=$4
echo $ARG_V > $tmp-arg_v


################################
#Directories settings
colored $explain "\nDirectories settings"
################################
#set base dir from CONFIG
cat ${CONFD}/config | awk '$1=="settings_dir" {print $2}' > $tmp-settingsd
cat ${CONFD}/config | awk '$1=="builds_dir" {print $2}' > $tmp-buildsd
cat ${CONFD}/config | awk '$1=="release_dir" {print $2}' > $tmp-released
cat ${CONFD}/config | awk '$1=="version_dir" {print $2}' > $tmp-versiond
ERR_CHK " directories settings."  


################################
#Search & set settings dir
################################
settingsd=`cat $tmp-settingsd`
#v1からv2かをサーバーコードでgrepして、引き当たる方をsettingsのDirとして設定
settings_repo=`grep ${SVR} -rl $settingsd/hmt-v* | awk 'NR==1{print}' | sed -e "s|$settingsd/||g" | cut -d'/' -f1`
echo `cat $tmp-settingsd`/$settings_repo > $tmp-settingsd


################################
#Cloud build check
colored $explain "\nCluod build check"
################################
WAITING_LOOPER


################################
#Job start
colored "5;32;44" "\n===Job start==="
echo "\n"
################################
ROOT_HEARING


################################
#Set dir & validation
colored $explain "\nSet dir & validation"
################################
VALIDATION_DIR_REWRITE || exit 1
ERR_CHK " set dir & validation."  


################################
#Get & Set version
colored $explain "\nGet & Set version"
################################
SET_VERSIONS || exit 1
GET_VERSION || exit 1
VERSION_HEARING || exit 1
SET_VERSION || exit 1


################################
#Confirmation
################################
colored "1;33" "\n\n
=========================================
■ Ticket:-------------${TICKET}
■ Appli:--------------${APPLI}
■ Server_code:--------${SVR}
■ Environment:--------${ENV}
■ Service_version:----`cat $tmp-release_service_v`
■ Component_version:--`cat $tmp-release_compo_v`
========================================="
colored "1;33" "この内容でビルド＆デプロイを開始しますか?\n(1:Yes/2:No)"
read input
if [ $input = '1' ]; then
  colored $selected "デプロイを開始します。"
else
  echo 'Sorry.'
  exit 0
fi
echo "\n"


################################
#Create release branch
colored $explain "\nCreate release branch"
################################
CHECKOUT_BRANCH release no-push


################################
#Update source code
colored $explain "\nUpdate source code"
################################
UPDATE_RELEASE_BRANCH || exit 1


################################
#Update source code
colored $explain "\nGit push"
################################
FINISHER || exit 1


colored "1;35" "\n\n
=========================================
■ Ticket:-------------${TICKET}
■ Appli:--------------${APPLI}
■ Server_code:--------${SVR}
■ Environment:--------${ENV}
■ Service_version:----`cat $tmp-release_service_v`
■ Component_version:--`cat $tmp-release_compo_v`
■ Time:---------------`date "+%Y/%m/%d %H:%M:%S"`
========================================="
colored "1;32" "All Green."
colored "1;35:42" "Cloud Build Triggerd!!"

exit 0
