
SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp
. SHELL/error_chk.sh || exit 1


################################
#Release branch create
# flow:
# CHECKOUT_BRANCH-->(_SET_DEVELOP_BRANCH_NAME)-->_GIT_CHECKOUT_RELEASE_BRANCH
#
# $1 kind("settings", "builds", "release")
# $2 nopush(null, "no-push")
#
################################
CHECKOUT_BRANCH() {
  colored "2;35" "\n ============Checkout branch start==================" 

  #set settings branch
  (cd ${SETTINGSD} && \
  git checkout master && \
  git pull)
  
  #set release branch name
  _SET_BRANCH_NAME || exit 1
  RELEASE_BRANCH_NAME=`cat $tmp-release_branch_name`
  colored "7;32" "RELEASE_BRANCH_NAME:"$RELEASE_BRANCH_NAME

  #release branch checkout
  _GIT_CHECKOUT_RELEASE_BRANCH || exit 1

  #case nobody::delete release/develop branch
  if [ "${NOBODY}" = "NOBODY" -o "${NOBODY}" = "TESTER" ]; then
    _GIT_DELETE_DEV_BRANCH
  fi

}


################################
#Set branch name
#
################################
#
_SET_BRANCH_NAME() {

  #get env
  ENV=`cat $tmp-env`
  
  #set release branch name
  if [ "${ENV}" = 'stg' ]; then
    echo release/staging > $tmp-release_branch_name
  elif [ "${ENV}" = 'prd' ]; then
    echo "release/production_`cat $tmp-release_service_v`" > $tmp-release_branch_name
  else
    NOBODY=`cat $tmp-nobody`
    if [ "${NOBODY}" = "TESTER" ]; then

      input=0
      while [ $input -eq 0 ]
      do
        echo "Name?"
        read input
        NAME=$input
        
        echo "When(from)? :yyyymmdd-hhmm"
        read input
        FROM=$input
        
        echo "When(to)? :yyyymmdd-hhmm"
        read input
        TO=$input

        colored "1;33" "\nAre you sure to make this branch?-->[develop_TESTER_${NAME}_${FROM}_${TO}]\n 1:yes\n 2:no\n another:cancel"        
        read input
        if [ $input = '1' ]; then
          colored "7;33" "1:yes" 
          echo release/develop_TESTER_${NAME}_${FROM}_${TO} > $tmp-release_branch_name
        elif [ $input = '2' ]; then
          input=0
        else
          echo "Sorry." 
          exit 0
        fi
      done 
    else
      echo release/develop_NOBODY > $tmp-release_branch_name
    fi
  fi
}


################################
#Git checkout release branch
################################
#
#
_GIT_CHECKOUT_RELEASE_BRANCH() {

  #var
  format="7;32"
  RELEASE_BRANCH_NAME=`cat $tmp-release_branch_name`

  #git source branch checkout & pull
  _GIT_SOURCE_BRANCH_CHECKOUT || exit 1

  colored "2;35" "\n ============Git checkout branch start==================" 

  #search local release branch
  (cd ${RELEASED} && \
  git branch | grep -i ${RELEASE_BRANCH_NAME} | sed -e s/^*\ // > $tmp-local_branch_chk)
  ERR_CHK "【release】${RELEASE_BRANCH_NAME} branch::exist check in local"

  #delete local release branch
  if [ -z $(cat $tmp-local_branch_chk) ]; then
    colored $format "${RELEASE_BRANCH_NAME}:localブランチなし"
  else
    colored $format "${RELEASE_BRANCH_NAME}:localブランチあり-->削除します。"
    (cd ${RELEASED} && \
    git checkout master && \
    git branch -D ${RELEASE_BRANCH_NAME})
    ERR_CHK "【release】${RELEASE_BRANCH_NAME} local branch::delete"
  fi

  #search remote release branch
  (cd ${RELEASED} && git fetch --prune)
  (cd ${RELEASED} && \
  git branch -a | grep -i ${RELEASE_BRANCH_NAME} | sed -e s/^*\ // > $tmp-remote-branch_chk)
  ERR_CHK "【release】${RELEASE_BRANCH_NAME} branch ::exist check in remote"
  
  #checkout release branch
  if [ -z $(cat $tmp-remote-branch_chk) ]; then
    colored $format "${RELEASE_BRANCH_NAME}::remoteブランチなし"
    colored "1;33" "\n【release】[${SOURCE_BRANCH}-->${RELEASE_BRANCH_NAME}] checkout します。\n 1:yes\n 2:cancel"
    read input
    
    #checkout new branch
    if [ $input = '1' ]; then
      (cd ${RELEASED} && \
      git checkout -b ${RELEASE_BRANCH_NAME})
      ERR_CHK "【release】${RELEASE_BRANCH_NAME} branch::checkout "
    else
      echo 'Sorry.'
      exit 0
    fi
  else
    colored $format "${RELEASE_BRANCH_NAME}::remoteブランチあり"
    
    #checkout branch
    (cd ${RELEASED} && \
    git checkout ${RELEASE_BRANCH_NAME} && \
    git pull)
    ERR_CHK "【release】${RELEASE_BRANCH_NAME} branch::checkout & pull"
  fi
}


################################
#Git source branch checkout
################################
#
# what is source branch?
# merge [source branch] --> [release branch]
# dev/TESTER--> some a worker branch you made
# dev/NOBODT--> develop
# stg--> staging
# prd--> master
#
_GIT_SOURCE_BRANCH_CHECKOUT() {
  colored "2;35" "\n  ============Git source branch checkout start=================="
  
  #set builds branch
  if [ "${ENV}" = 'dev' ]; then
    if [ "${NOBODY}" = "TESTER" ]; then

      #get local branch list
      (cd ${BUILDSD} && \
      git branch > $tmp-branches)
      ERR_CHK "【builds】${BUILDSD} ブランチ一覧を取得"
      
      #choice worker branch
      colored "0;36" "ローカルブランチの一覧を表示します。"
      cat $tmp-branches
      input=0
      while [ $input -eq 0 ] 
      do
        colored "1;33" "ソース元のブランチ名を入力してください。"
        read input
        SOURCE_BRANCH=$input
        input=0
        if [ -z "${SOURCE_BRANCH}" ]; then
          :
        else
          colored "1;33" "\nChosen source branch [${SOURCE_BRANCH}]. \nAre you sure? \n1:yes \n2:no \n3:cancel"
          read input
          if [ "$input" = "1" ]; then
            :
          elif [ "$input" = "2" ]; then
            echo "Please one more input source branch."
            input=0
          else
            echo 'Sorry'
            exit 0
          fi
        fi
      done
    else
      #for nobody source branch
      SOURCE_BRANCH=develop
    fi
  elif [ "${ENV}" = 'stg' ]; then
    SOURCE_BRANCH=staging
  elif [ "${ENV}" = 'prd' ]; then
      SOURCE_BRANCH=master 
  else
    echo 'Sorry.'
    exit 0
  fi
 
  #tmp source branch 
  echo ${SOURCE_BRANCH} > $tmp-source_branch
  colored "7;35" "SOURCE_BRANCH:"${SOURCE_BRANCH}

  #source branch checkout & pull
  (cd ${BUILDSD} && \
  git checkout ${SOURCE_BRANCH} && \
  git pull)
  ERR_CHK "【builds】${SOURCE_BRANCH} branch::checkout & pull"

  #get latest commit id from source branch
  (cd ${BUILDSD} && \
  git log -n1 --date=short --no-merges --pretty=format:"%h %cd %s (@%cn)") > $tmp-latest_commitid
  COMMIT=$(cat $tmp-latest_commitid | awk '{print $1}')
  ERR_CHK "【builds】Get last commit ${COMMIT}."
  
  #hanger branch checkout
  if [ -e "${BUILDSD}/hanger" ] && [ "${NOBODY}" != 'TESTER' ]; then
    if [ "${SOURCE_BRANCH}" = 'master' ] || [ "${SOURCE_BRANCH}" = 'staging' ] || [ "${SOURCE_BRANCH}" = 'develop' ]; then
      (cd ${BUILDSD}/hanger && \
      git checkout ${SOURCE_BRANCH} && \
      git pull)
      ERR_CHK "【builds/hanger】${SOURCE_BRANCH} branch::checkout & pull"
    fi
  fi
}


################################
#Git delete tester branch
################################
#
#
_GIT_DELETE_DEV_BRANCH() {
  colored "2;35" "\n ============Git delete tester branch start==================\n"

  #set gep branch name
  #NOBODY-->grep -i TESTER
  #TESTER-->grep -i NOBODY
  if [ "${NOBODY}" = "NOBODY" ]; then
    grep_branch=release/develop_TESTER_
  else
    grep_branch=release/develop_NOBODY
  fi

  #search local tester branch
  (cd ${RELEASED} && \
  git branch | grep -i ${grep_branch} | head -n1 > $tmp-local-tester-branch)

  #delete local tester branch
  BRANCH=`cat $tmp-local-tester-branch`
  if [ -z `echo ${BRANCH}` ]; then
    :
  else
    (cd ${RELEASED} && \
    git branch -D ${BRANCH})
    ERR_CHK "【release】${BRANCH} branch::delete local ${grep_branch} branch."
  fi

  #search remote tester branch
  (cd ${RELEASED} && \
  git branch -a | grep -i remotes/origin/${grep_branch} | \
  head -n1 | \
  sed -e 's/remotes\/origin\///' | \
  sed -e 's/ //g' > $tmp-remote-tester-branch)

  #delete remote tester branch
  BRANCH=`cat $tmp-remote-tester-branch`
  if [ -z `echo ${BRANCH}` ]; then
    :
  else
    (cd ${RELEASED} && \
    git push origin :${BRANCH})
    ERR_CHK "【release】${BRANCH} branch::delete remote ${grep_branch} branch."
  fi
}
