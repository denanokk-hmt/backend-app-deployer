
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp
. SHELL/error_chk.sh || exit 1


################################
#CLOUD BUILD Check
################################
#
#
_CLOUD_BUILDS_CHECK() {
  
  rm -f $tmp-cloud_build_deploy_stop > /dev/null
  rm -f $tmp-cloud_build_deploy_go > /dev/null

  limit=9
  stop_word=WORKING
  #stop_word=SUCCESS

  #get working status counts in cloudbuilds
  work=`gcloud builds list | grep -i ${stop_word} | awk 'END{print NR}'`
  echo $work > $tmp-cloud_builds_working
  ERR_CHK " get gcloud builds working list." 
  
  count=`cat $tmp-cloud_builds_working`

  if [ ${count} -lt $limit ]; then
    echo "GO" > $tmp-cloud_build_deploy_go
  else
    echo "STOP" > $tmp-cloud_build_deploy_stop
    colored "1;31" " Now too much building. Please wait a min...."
  fi

}


################################
#WAITING LOOPER
################################
WAITING_LOOPER() {
  counter=0
  while [ "${counter}" -lt 30 ]
  do
    _CLOUD_BUILDS_CHECK || exit 1
    if [ -e $tmp-cloud_build_deploy_stop ]; then
      sleep 60
    elif [ -e $tmp-cloud_build_deploy_go ]; then
      #colored "2;33" " Please wait 20sec."
      #sleep 20
      break
    fi
    let counter++
  done
}

