
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp
. SHELL/error_chk.sh || exit 1


################################
#SET VERSIONS
################################
#
SET_VERSIONS() {

  colored "2;35" "\n ============Set Vesions start=================="

  major_v=`cat $tmp-major_v`
  format="7;33"
  
  #get latest service version & compo version from hmt-release-versions
  (cd ${VERSIONSD} && \
  git pull)
  ERR_CHK " git pull hmt-release-versions." 
  cat ${VERSIONSD}/${SERIES}/service > $tmp-latest_service_v
  cat ${VERSIONSD}/${SERIES}/${APPLI} > $tmp-latest_compo_v

  #get remote prodcution branch from release
  (cd ${RELEASED} && \
  git branch -a | grep -i origin/release/production_${major_v} | tail -n5) > $tmp-remote_production_branch_list
  cat $tmp-remote_production_branch_list 

  cat $tmp-remote_production_branch_list \
  | awk -F'_' '{print $2}' | sed -e s/^*\ // | sort -V > $tmp-remote_production_branch
  ERR_CHK " 【release】git branch -a | grep -i origin/release/production_${major_v}"

  #echo "\n"

  #get remote tag from release
  (cd ${RELEASED} && \
  git ls-remote --tags) | grep -i refs/tags/${MAJOR_V}. | tail -n5 > $tmp-ls_remoto_tags
  cat $tmp-ls_remoto_tags
  ERR_CHK "【release】 git ls-remote --tag."

  #get latest version from versions
  cat $tmp-latest_service_v > $tmp-compare_service_v
  cat $tmp-latest_compo_v > $tmp-compare_compo_v

  #get latest version from branch
  cat $tmp-remote_production_branch | tail -n1 >> $tmp-compare_service_v
  cat $tmp-ls_remoto_tags | tail -n1 | awk '{print $2}' | awk -F'/' '{print $3}' >> $tmp-compare_compo_v

  #compare version  
  cat $tmp-compare_service_v | sort -V | tail -n1 > $tmp-latest_service_v
  cat $tmp-compare_compo_v | sort -V | tail -n1 > $tmp-latest_compo_v
  
  latest_service_v=`cat $tmp-latest_service_v`
  latest_compo_v=`cat $tmp-latest_compo_v`

  #hmt-release-versions rewrite (always)
  echo ${latest_service_v} > ${VERSIONSD}/${SERIES}/service 
  echo ${latest_compo_v} > ${VERSIONSD}/${SERIES}/${APPLI} 
  
  #hmt-release-versions compare & update
  (cd ${VERSIONSD} && \
  git status -s) > $tmp-git_status_versions
  if [ -z `cat $tmp-git_status_versions` ]; then
    :
  else
    (cd ${VERSIONSD} && \
    git add -A && \
    git commit -m "versions update. ${TIME} 【service:`cat latest_service_v`】【compo:`cat latest_compo_v`】" && \
    git push)
    ERR_CHK " 【versions】 hmt-release-versions update."
  fi

}


################################
#VERSION GET
################################
#
#
GET_VERSION() {

  colored "2;35" "\n ============Get Vesion start=================="

  format="7;36"

  #latest service version
  colored $format "latest_service_V:`cat $tmp-latest_service_v`"
  
  #major, minor service version
  cat $tmp-latest_service_v \
  | awk -F'.' '{str = sprintf("%d.%d", $1, $2); print str}' > $tmp-major_minor_v

  #major service version
  cat $tmp-major_minor_v | cut -d'.' -f1 > $tmp-major_v

  #minor service version
  cat $tmp-major_minor_v | cut -d'.' -f2 > $tmp-minor_v

  #tiny service version
  cat $tmp-latest_service_v | cut -d'.' -f3 > $tmp-tiny_v

  #major component version
  cat $tmp-latest_compo_v | cut -d'_' -f1 | cut -d'.' -f1 > $tmp-latest_compo_major_v

  #minor component version
  cat $tmp-latest_compo_v | cut -d'_' -f1 | cut -d'.' -f2 > $tmp-latest_compo_minor_v

  #tiny component version
  cat $tmp-latest_compo_v | cut -d'_' -f1 | cut -d'.' -f3 > $tmp-latest_compo_tiny_v

  #get latest component patch version
  cat $tmp-latest_compo_v | cut -d'_' -f3 > $tmp-latest_compo_patch_v
  
  #get latest component service version
  echo `cat $tmp-major_v`.`cat $tmp-minor_v` > $tmp-latest_compo_service_v

  colored $format "latest_component_V:`cat $tmp-latest_compo_v`\n\n"
}

################################
#VERSION SET
################################
# version up example
#[pattern example]
# [select_srv]  [select_compo]  [Service] [component]
#                                 2.0.4   2.0.2_k_1_2.0
# latest:0      now:0             2.0.4   2.0.2_k_1_2.0
# latest:0      latest:1          2.0.4   2.0.2_k_2_2.0
# latest:0      new:2             2.0.4   2.0.3_k_1_2.0
# latest:0      minor:3           2.0.4   2.1.0_k_1_2.0
# new:1         now:0             2.0.5   2.0.2_k_1_2.0
# new:1         latest:1          2.0.5   2.0.2_k_2_2.0
# new:1         new:2             2.0.5   2.0.3_k_1_2.0
# new:1         minor:3           2.0.5   2.1.0_k_1_2.0
# minor:2       now:0             2.1.0   2.0.2_k_1_2.1
# minor:2       latest:1          2.1.0   2.0.2_k_2_2.1
# minor:2       new:2             2.1.0   2.0.3_k_1_2.1
# minor:2       minor:3           2.1.0   2.1.0_k_1_2.1
#
SET_VERSION() {
  colored "2;35" "\n ============Set Vesion start=================="
  
  format="7;32"

  #set release component version
  if [ "${ENV}" = "dev" ] ||  [ "${ENV}" = "stg" ]; then
    
    #set service version::latest
    cat $tmp-latest_service_v > $tmp-release_service_v
    
    #set componet version::nobody
    cat $tmp-latest_compo_v | cut -d'_' -f1 > $tmp-release_compo_v
    
  elif [ "${ENV}" = "prd" ]; then

    ########################
    #Set Service version

    if [ "${SELECT_SRV}" = "0" ]; then
      #-->service version stay now
      cat $tmp-latest_service_v > $tmp-release_service_v

    elif [ "${SELECT_SRV}" = "1" ]; then
      #-->minor stay now
      #-->tiny v up
      tiny_v=`cat $tmp-tiny_v`
      tiny_v=$((tiny_v + 1))
      echo "`cat $tmp-major_minor_v`.${tiny_v}" > $tmp-release_service_v
    
    elif [ "${SELECT_SRV}" = "2" ]; then
      #-->minor v up
      #-->tiny ini=0
      minor_v=`cat $tmp-minor_v`
      minor_v=$((minor_v + 1))
      echo "`cat $tmp-major_v`.${minor_v}.0" > $tmp-release_service_v
    
    elif [ "${SELECT_SRV}" = "3" ]; then
      #-->major v up
      #-->minor ini=0
      #-->tiny ini=0
      major_v=`cat $tmp-major_v`
      major_v=$((major_v + 1))
      echo $major_v.0.0 > $tmp-release_service_v
    fi

    ########################
    #Set Component version

    if [ "${SELECT_COMPO}" = "0" ]; then
      #-->component version stay now
      cat $tmp-latest_compo_v | cut -d'_' -f1 > $tmp-release_compo_v
      patch=`cat $tmp-latest_compo_patch_v`
    
    elif [ "${SELECT_COMPO}" = "1" ]; then
      #-->minor version stay now
      #-->tiny version stay now
      #-->patch version up
      cat $tmp-latest_compo_v | cut -d'_' -f1 > $tmp-release_compo_v
      patch=`cat $tmp-latest_compo_patch_v`
      patch=$((patch + 1))

    elif [ "${SELECT_COMPO}" = "2" ]; then
      #-->minor stay now
      #-->tiny v up
      #-->patch init=0
      tiny_v=`cat $tmp-latest_compo_tiny_v`
      tiny_v=$((tiny_v + 1))
      echo "`cat $tmp-latest_compo_v | awk -F'.' '{print $1 "." $2}'`.${tiny_v}" > $tmp-release_compo_v
      patch=0
    
    elif [ "${SELECT_COMPO}" = "3" ]; then
      #-->minor v up
      #-->tiny ini=0
      #-->patch init=0
      minor_v=`cat $tmp-latest_compo_minor_v`
      minor_v=$((minor_v + 1))
      echo "`cat $tmp-latest_compo_major_v`.${minor_v}.0" > $tmp-release_compo_v
      patch=0

    elif [ "${SELECT_COMPO}" = "4" ]; then
      #-->major v up
      #-->minor ini=0
      #-->tiny ini=0
      #-->patch init=0
      major_v=`cat $tmp-latest_compo_major_v`
      major_v=$((major_v + 1))
      echo "${major_v}.0.0" > $tmp-release_compo_v
      patch=0
    fi

  else
    echo 'Sorry.'
    exit 0
  fi

  #set release compo version
  if [ "${ENV}" = "prd" ]; then
    service_v=`cat $tmp-release_service_v`
    service_v=${service_v%.*}
    echo "`cat $tmp-release_compo_v`_${COMPO}_${patch}_$service_v" > $tmp-release_compo_v
  fi
  
  #set results
  colored $format "SERVICE_RELEASE_V:`cat $tmp-release_service_v`\n
COMPONENT_RELEASE_V:`cat $tmp-release_compo_v`"
}

