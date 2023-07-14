
#!/bin/bash

################################
#Initial
################################
#base dir, tmp
SYSD=$(pwd)
CONFD=${SYSD}/CONFIG
tmp=${SYSD}/TEMP/tmp

settingsd="/Users/tahi/zwv/svc_bs_developer/settings/hmt"
config_settings=${SYSD}/settings3
echo $settingsd


while read line
do
  skip=0
  
  srs=`echo $line | awk '{print $2}'`
  repo=`echo $line | awk '{print $1}'`
  svc=`echo $repo | awk -F'-' '{print $2}'`
  env=`echo $repo | awk -F'-' '{print $3}'`
  compo=`echo $repo \
  | sed -e 's/hmt\-svc*//' \
  | sed -e 's/^[0-9]\{1,3\}//' \
  | sed -e 's/\-dev//' \
  | sed -e 's/\-stg//' \
  | sed -e 's/\-prd//'`

  if [ "$compo" = "b" ]; then
    appli=boarding
  elif [ "$compo" = "k" ]; then
    appli=keel
  elif [ "$compo" = "c" ]; then
    appli=cabin
  elif [ "$compo" = "cg" ]; then
    appli=cargo
  elif [ "$compo" = "a" ]; then
    appli=asker
  elif [ "$compo" = "n" ]; then
    appli=newest
  elif [ "$compo" = "t" ]; then
    appli=transit
  elif [ "$compo" = "p" ]; then
    appli=p1
  else
    skip=1
  fi

  if [ "$srs" = "v1" ]; then
    master_branch=master_v1
    production=release/production_1.1.13
  else
    master_branch=master_v2
    production=release/production_2.0.4
  fi
 
  force_skip=`echo $line | awk '{print $3}'`
  if [ "${force_skip}" = "skip" ]; then
    skip=1
  fi
  
  echo "---------------------"
  echo $line
  echo $skip

  if [ $skip -eq 0 ]; then 
    
    cp ./root.json $settingsd/$repo/$appli/config
    
    (cd $settingsd/$repo/$appli/config && \
    git checkout $master_branch && \
    grep -i -l '###APPLI###' ./root.json | xargs sed -i.bak "s|###APPLI###|${appli}|g")
    (cd $settingsd/$repo/$appli/config && \
    rm -f root.json.bak)

    (cd $settingsd/$repo/$appli/config && \
    grep -i -l '###SVC###' ./root.json | xargs sed -i.bak "s|###SVC###|${svc}|g")
    (cd $settingsd/$repo/$appli/config && \
    rm -f root.json.bak)
    
    (cd $settingsd/$repo/$appli/config && \
    grep -i -l '###ENV###' ./root.json | xargs sed -i.bak "s|###ENV###|${env}|g")
    (cd $settingsd/$repo/$appli/config && \
    rm -f root.json.bak)

    (cd $settingsd/$repo/$appli/config && \
    grep -i -l '###SERIES###' ./root.json | xargs sed -i.bak "s|###SERIES###|${srs}|g")
    (cd $settingsd/$repo/$appli/config && \
    rm -f root.json.bak)

    (cd $settingsd/$repo && \
    git checkout $master_branch && \
    mv $settingsd/$repo/$appli/* $settingsd/$repo/)
    
    (cd $settingsd/$repo && \
    rm -rf $appli)

    (cd $settingsd/$repo && \
    git checkout $master_branch && \
    git add -A && \
    git commit -m "add series. and delete compo dir" && \
    git push)

    (cd $settingsd/$repo && \
    git checkout $production && \
    git merge $master_branch && \
    git push)
    
  fi
done << FILE
`cat $config_settings`
FILE
