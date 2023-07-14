
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp

################################
#Args validation
################################
#
VALIDATION_ARGS() {
  param="7;33"
  if [ -z "$1" ]; then
    colored $param "[VAILD ERR] You do not set ticket no."
    exit 0
  fi
  if [ -z "$2" ]; then
    colored $param "[VAILD ERR] You do not set server code."
    exit 0
  fi
}

################################
#Args validation
################################
#
VALIDATION_DIR_REWRITE() {
  colored "2;35" "\n ============validation dir & rewrite start=================="

  SETTINGSD=`cat $tmp-settingsd`
  BUILDSD=`cat $tmp-buildsd`
  RELEASED=`cat $tmp-released`
  VERSIONSD=`cat $tmp-versiond`

  #check settings dir
  if [ -e "${SETTINGSD}/hmt-${SVR}-${ENV}" ]; then
    echo ${SETTINGSD}/hmt-${SVR}-${ENV} > $tmp-settingsd
    SETTINGSD=`cat $tmp-settingsd`
    colored "2;32" "  settings dir:"${SETTINGSD}
  else
    echo "\nSorry. Cannot find the settings dir.\n"
    exit 0
  fi

  #check builds source dir
  if [ -e "${BUILDSD}/${SERIES}-${APPLI}" ]; then
    echo ${BUILDSD}/${SERIES}-${APPLI} > $tmp-buildsd
    BUILDSD=`cat $tmp-buildsd`
    colored "2;32" "  builds dir:"${BUILDSD}
  else
    echo "\nSorry. Cannot find the builds dir.\n"
    exit 0
  fi

  #check release dir
  if [ -e "${RELEASED}/release-hmt-${SERIES}-${APPLI}" ]; then
    echo ${RELEASED}/release-hmt-${SERIES}-${APPLI} > $tmp-released
    RELEASED=`cat $tmp-released`
    colored "2;32" "  release dir:"${RELEASED}
  else
    echo "\nSorry. Cannot find the release dir.\n"
    exit 0
  fi

  #check versions dir
  if [ -e "${VERSIONSD}/hmt-release-versions" ]; then
    echo ${VERSIONSD}/hmt-release-versions > $tmp-versiond
    VERSIONSD=`cat $tmp-versiond`
    colored "2;32" "  versions dir:"${VERSIONSD}
  else
    echo "\nSorry. Cannot find the versions dir.\n"
    exit 0
  fi

}
