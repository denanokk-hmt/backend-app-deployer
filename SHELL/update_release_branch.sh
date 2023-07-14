
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp
. SHELL/error_chk.sh || exit 1


################################
#Update release branch source code
################################
#
# already souce branch chekcout & pull
#
UPDATE_RELEASE_BRANCH() {
  colored "2;35" "\n ============Update release branch start==================\n"

  SOURCE_BRANCH=`cat $tmp-source_branch`
  RELEASE_SERVICE_V=`cat $tmp-release_service_v`
  RELEASE_COMPO_V=`cat $tmp-release_compo_v`

  #delete service dir in config 
  (cd ${RELEASED}/config && \
  ls | grep -i -v common | grep -i -v config | grep -i -v root | xargs rm -rf)
  ERR_CHK " ${RELEASED}:: config dir クリーンアップ"
    
  #delete service linkage in data
  (cd ${RELEASED} && \
  rm -rf data/*)
  ERR_CHK " ${RELEASED}:: data dirクリーンアップ"
  
  #rsync builds(source code)
  (cd ${RELEASED} && \
  rsync -r --exclude='node_modules/' --exclude='.git/' ${BUILDSD}/ ./)
  ERR_CHK "【buid-->release】${APPLI} source code 同期(rsync)"

  #rsync config
  (cd ${RELEASED} && \
  rsync -r ${SETTINGSD}/config/ config/)
  ERR_CHK "【settings-->${RELEASED}】${SVR} config dir 同期(rsync)"
  
  #rsync cloudbuild.yaml
  (cd ${RELEASED} && \
  rsync ${SETTINGSD}/cloudbuild.yaml cloudbuild.yaml)
  ERR_CHK "【settings-->${RELEASED}】Cloud Build Yaml 同期(rsync)"
  
  #version injection
  _VERSION_INJECTION || exit 1

  #deploy unixtime injection
  _DEPLOY_UNIXTIME_INJECTION || exit 1

  #create dummy commit file, 
  (cd ${RELEASED} && \
  echo "created at ${TIME}" > ./dummy_commit)
  DUMMY=`cat ${RELEASED}/dummy_commit`
 
}


################################
#Version injection to dockerfile
################################
#
_VERSION_INJECTION() {
  colored "2;35" "\n ============Version injection start==================\n"

  #rsync dockerfile & version injection
  REPLACE_V=${RELEASE_COMPO_V}
  colored "2;35" "Set component version":$REPLACE_V

  #injection compo version
  (cd ${RELEASED} && \
  grep -i -l '###VERSION###' ./Dockerfile | xargs sed -i.bak "s|###VERSION###|${REPLACE_V}|g")
  (cd ${BUILDSD} && \
  rm -f Dockerfile.bak)
  ERR_CHK "  Dockerfile replase vesion."

}

################################
#Deploy unixtime injection to dockerfile
################################
#
_DEPLOY_UNIXTIME_INJECTION() {
  colored "2;35" "\n ============Deploy unixtime injection start==================\n"
  
  deploy_unixtime=`date +%s`
  
  #injection
  (cd ${RELEASED} && \
  grep -i -l '###DEPLOY_UNIXTIME###' ./Dockerfile | xargs sed -i.bak "s|###DEPLOY_UNIXTIME###|${deploy_unixtime}|g")
  (cd ${BUILDSD} && \
  rm -f Dockerfile.bak)
  ERR_CHK "  Dockerfile replase deploy unixtime."

}

