
#!/bin/bash

################################
#Initial
################################
#base dir, tmp
SYSD=$(pwd)
CONFD=${SYSD}/CONFIG
tmp=${SYSD}/TEMP/tmp

settingsd="/Users/tahi/zwv/svc_bs_developer/settings/hmt"
config_settings=${SYSD}/settings
echo $settingsd

while read line
do
  skip=0
  
  repo=`echo $line | awk '{print $1}'`
  srs=`echo $line | awk '{print $2}'`

  force_skip=`echo $line | awk '{print $3}'`
  if [ "${force_skip}" = "skip" ]; then
    skip=1
  fi
  
  echo "---------------------"
  echo $line
  echo $skip

  if [ $skip -eq 0 ]; then 
    if [ "$srs" = "v1" ]; then
      new_master_branch=master_v1
    else
      new_master_branch=master_v2
    fi

    #checkout release branch
    (cd $settingsd/$repo && \
    git checkout $new_master_branch && \
    git push -u origin $new_master_branch)

  fi
done << FILE
`cat $config_settings`
FILE
