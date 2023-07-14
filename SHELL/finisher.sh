
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp
. SHELL/error_chk.sh || exit 1


################################
#Git commit & push
################################
#
#
FINISHER() {
  
#  #get latest commit from buildsd
#  (cd ${BUILDSD} && \
#  git log -n1 --date=short --no-merges --pretty=format:"%h %cd %s (@%cn)") > $tmp-builds_commitid
#  COMMIT=$(cat $tmp-builds_commitid | awk '{print $1}')
#  ERR_CHK "【builds】Get builds last commit"
    

  #Update source code
  if [ "${ENV}" != 'prd' ]; then
    commit_msg="${TICKET} ${APPLI} ${SVR} commit:${COMMIT}"
  else
    commit_msg="${TICKET} ${APPLI} ${SVR} ${RELEASE_COMPO_V} commit:${COMMIT}"
  fi

  colored "2;35" " ============Git push start==================\n" 

  #git add & commit, comment using latest commit id
  (cd ${RELEASED} && \
  git add -A && \
  git commit -m "${commit_msg}")
  ERR_CHK "【release】 Git commit to local branch"

  #git push
  (cd ${RELEASED} && \
  git push -u origin ${RELEASE_BRANCH_NAME})
  ERR_CHK "【release】 Git push branch::${RELEASE_BRANCH_NAME}"
  
  if [ "${ENV}" = "prd" ]; then  

    if [ "${SELECT_SRV}" = "latest" -a "${SELECT_COMPO}" = "now" ]; then
      :
    else
      colored "2;35" "\n ============Git tag start prd==================\n"

      #git tag to settings
      (cd ${SETTINGSD} && \
      git tag "${RELEASE_COMPO_V}" && \
      git push origin ${RELEASE_COMPO_V}) 
      ERR_CHK "【settings】 git tag to settings."
      
      #git tag to builds
      (cd ${BUILDSD} && \
      git tag "${RELEASE_COMPO_V}" && \
      git push origin ${RELEASE_COMPO_V}) 
      ERR_CHK "【builds】 git tag to builds."
      
      #git tag to release
      (cd ${RELEASED} && \
      git tag "${RELEASE_COMPO_V}" && \
      git push origin ${RELEASE_COMPO_V}) 
      ERR_CHK "【release】 git tag to release."

      #hmt-release-versions update
      echo ${RELEASE_SERVICE_V} > ${VERSIONSD}/${SERIES}/service 
      echo ${RELEASE_COMPO_V} > ${VERSIONSD}/${SERIES}/${APPLI} 
      (cd ${VERSIONSD} && \
      git add -A && \
      git commit -m "${commit_msg}" && \
      git push)
      ERR_CHK "【versions】git commit & push release version."
    fi
  fi
}
