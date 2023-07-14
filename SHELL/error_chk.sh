
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp

################################
#Error Check
################################
ERR_CHK() {

  if [ -e $tmp-bash_version ]; then
    bash_version=`cat $tmp-bash_version`
  else
    bash_version=3
  fi

  STATUS="${PIPESTATUS[@]}"
  for s in ${STATUS}; do
    if [ ${s} -eq 0 ]; then
      :
    else
      if [ $bash_version -lt 4 ]; then
        echo "\033[1;31mErr:$@\033[0m"
        echo "\033[1;30;41mExec stop.\033[0m"
      else
        echo -e "\e[1;31mErr\e[m"
        echo -e "\e[1;30;41mExec stop.\e[m"
      fi
      exit 0
    fi
  done
  
  if [ $bash_version -lt 4 ]; then
    echo "\033[1;32;40m$1 is Green.\033[0m"
  else
    echo -e "\e[1;32;40m$1 is Green.\e[m"
  fi

  return
}
