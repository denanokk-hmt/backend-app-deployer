
#!/bin/bash

################################
#Initial
################################
#base dir, tmp
SYSD=$(pwd)
CONFD=${SYSD}/CONFIG
tmp=${SYSD}/TEMP/tmp

buildd="/Users/tahi/zwv/svc_bs_developer/builds/hmt"
released="/Users/tahi/zwv/svc_bs_developer/release/release-hmt-"

config_settings=${SYSD}/builds


while read line
do
  skip=0
  
  srs=`echo $line | awk '{print $2}'`
  repo=`echo $line | awk '{print $1}'`
  
 
  force_skip=`echo $line | awk '{print $3}'`
  if [ "${force_skip}" = "skip" ]; then
    skip=1
  fi
  
  echo "---------------------"
  echo $line
  echo $skip

  if [ $skip -eq 0 ]; then 
    if [ "$srs" = "v1" ]; then
      old_master_branch=master
      new_master_branch=master_v1
      production=release/production_1.1.13
    else
      old_master_branch=master_2.0.0
      new_master_branch=master_v2
      production=release/production_2.0.4
    fi
    
    develop_r=release/develop_${srs}_NOBODY
    staging_r=release/staging_$srs

    develop_s=develop/master_$srs
    staging_s=staging/master_$srs


    for i in 1 2
    do
      path=$released$repo
      echo $path

      echo " -------develop------"
      #develop r
      (cd $path && \
      git checkout $new_master_branch && \
      git branch -D $develop_r)
      (cd $path && \
      git push -u origin :$develop_r)
  
      #develop s
      (cd $path && \
      git checkout $new_master_branch && \
      git pull && \
      git branch -D $develop_s)
      (cd $path && \
      git push -u origin :$develop_s)
  
      echo " -------staging------"
      #staging_r
      (cd $path && \
      git checkout $develop_s && \
      git pull && \
      git branch -D $staging_r)
      (cd $path && \
      git push -u origin :$staging_r)
  
      #staging_s
      (cd $path && \
      git checkout $develop_s && \
      git pull && \
      git branch -D $staging_s)
      (cd $path && \
      git push -u origin :$staging_s)

    done
  fi
done << FILE
`cat $config_settings`
FILE
