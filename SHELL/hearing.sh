
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp
. SHELL/error_chk.sh || exit 1



################################
#Read Appli
################################
ROOT_HEARING() {
  
  colored "2;35" "\n ============Root hearing start=================="

  #for search
  settingsd=`cat $tmp-settingsd`
  settingsd_name=`ls $settingsd | grep -i hmt-${SVR}-`
  
  #serach master branch
  (cd ${settingsd}/${settingsd_name} && \
  git branch | grep -i master | sed -e 's/*//g' | sed -e 's/ //g' > $tmp-settings_master_branch)

  cat $tmp-settings_master_branch
  #checkout settings master branch
  (cd ${settingsd}/${settingsd_name} && \
  git checkout `cat $tmp-settings_master_branch`)
  ERR_CHK " search master branch."
  
  #get root configuration
  cat $settingsd/$settingsd_name/config/root.json \
  | awk 'NR>1{a[++k]=$0}END{for(i=1;i<k;i++)print a[i]}' \
  | sed -e 's/"//g' \
  | sed -e 's/,//g' \
  | sed -e 's/ //g' \
  | sed -e 's/:/ /g' > $tmp-root
  #cat $tmp-root

  #internal validation
  svr=`cat $tmp-root | awk 'NR==2{print $2}'`
  if [ "${SVR}" != "${svr}" ]; then
    colored "7;33" "[VAILD ERR] Please check server code. not match in settings dir."
    exit 0
  fi

  #set basement vars  
  APPLI=`cat $tmp-root | awk 'NR==1{print $2}'`
  ENV=`cat $tmp-root | awk 'NR==3{print $2}'`
  [ "${ENV}" = "pre" ] && ENV=prd || ENV=${ENV}
  SERIES=`cat $tmp-root | awk 'NR==4{print $2}'`
  MAJOR_V=`echo ${SERIES} | sed -e 's/v//'`

  $results
  colored "7;35" "settings dir:$settingsd"
  colored "7;35" "appli:$APPLI"
  colored "7;35" "environment:${ENV}"
  colored "7;35" "series:${SERIES}"
  colored "7;35" "major_v:${MAJOR_V}"
  
  #set compo 
  if [ ${APPLI} = 'boarding' ]; then
    COMPO=b
  elif [ ${APPLI} = 'cabin' ]; then
    COMPO=c
  elif [ ${APPLI} = 'keel' ]; then
    COMPO=k
  elif [ ${APPLI} = 'newest' ]; then
    COMPO=n
  elif [ ${APPLI} = 'asker' ]; then
    COMPO=a
  elif [ ${APPLI} = 'p1' ]; then
    COMPO=p
  elif [ ${APPLI} = 'cargo' ]; then
    COMPO=cg
  elif [ ${APPLI} = 'transit' ]; then
    COMPO=t
  elif [ ${APPLI} = 'catwalk' ]; then
    COMPO=cw
  elif [ ${APPLI} = 'marshaller' ]; then
    COMPO=ms
  elif [ ${APPLI} = 'tugcar' ]; then
    COMPO=tc
  elif [ ${APPLI} = 'wish' ]; then
    COMPO=ws
  elif [ ${APPLI} = 'gyroscope' ]; then
    COMPO=gy
  else
    echo 'Sorry.'
    exit 0
  fi
  
  #tmp
  echo ${ENV} > $tmp-emv
  echo ${APPLI} > $tmp-appli
  echo ${COMPO} > $tmp-compo
  echo ${SERIES} > $tmp-series
  echo ${MAJOR_V} > $tmp-major_v

  #care dev
  if [ "${ENV}" = 'dev' ]; then
    colored "1;33" "\nClean up(NOBODY)? or Create TESTER?\n 1:NOBODY\n 2:TESTER\n 3:cancel"
    read input
    if [ $input = '1' ]; then
      colored $selected "$input:NOBODY"
      echo "NOBODY" > $tmp-nobody
    elif [ $input = '2' ]; then
      colored $selected "$input:TESTER"
      echo "TESTER" > $tmp-nobody
    else
      echo 'Sorry.'
      exit 0
    fi
  else
    echo "" > $tmp-nobody
  fi

echo ${ENV} > $tmp-env

}


################################
#version
################################
VERSION_HEARING() {
  
  colored "2;35" "\n ============Get Vesion start=================="
  
  #get latest service version & compo version from hmt-release-versions
  (cd ${VERSIONSD} && \
  git pull)
  ERR_CHK " git pull hmt-release-versions." 
  cat ${VERSIONSD}/${SERIES}/service > $tmp-latest_service_v
  cat ${VERSIONSD}/${SERIES}/${APPLI} > $tmp-latest_compo_v

  #Case differet minor vesion service & compo
  if [ `cat $tmp-major_v` -eq `cat $tmp-latest_compo_major_v` ]; then
    if [ `cat $tmp-minor_v` -gt `cat $tmp-latest_compo_minor_v` ]; then
      #now not using...after??
      COMPO_FORCE_MINOR_V_UP=true
    fi
  fi

  #case dev 
  [ "${ENV}" = "dev" -o "${ENV}" = "stg" ] && return || :

  #service version hearing
  colored "1;33" "\nWhat is the Service version?\nnow service version:【`cat $tmp-latest_service_v`】\n \
  0:latest(stay now)\n \
  1:new(tiny version up)\n \
  2:minor version up\n \
  3:major version up\n \
  4:cancel"
  
  read input
  if [ $input = '0' ];then
    colored $selected "$input:latest(stay)"
  elif [ $input = '1' ];then
    colored $selected "$input:new(patch_v_up)"
  elif [ $input = '2' ];then
    colored $selected "$input:minor_v_up"
  elif [ $input = '3' ];then
    colored $selected "$input:major_v_up"
  else
    echo 'Sorry'
    exit 0
  fi
  SELECT_SRV=$input

  #component version hearing
  colored "1;33" "\nWhat is the Component version?\nnow component version:【`cat $tmp-latest_compo_v`】\n \
  0:now(stay now)\n \
  1:latest(patch version up)\n \
  2:new(tiny version up)\n \
  3:minor version up\n \
  4:major version up\n \
  5:cancel"
  
  read input
  if [ $input = '0' ];then
    colored $selected "$input:now(stay)"
  elif [ $input = '1' ];then 
    colored $selected "$input:latest(patch_v_up)"
  elif [ $input = '2' ];then
    colored $selected "$input:new(tiny_v_up)"
  elif [ $input = '3' ];then
    colored $selected "$input:minor_v_up"
  elif [ $input = '4' ];then
    colored $selected "$input:major_v_up"
  else
    echo 'Sorry'
    exit 0
  fi
  SELECT_COMPO=$input
 
}
