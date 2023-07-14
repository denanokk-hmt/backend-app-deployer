
#!/bin/bash

################################
#Initial
################################
#base dir, tmp
SYSD=$(pwd)
CONFD=${SYSD}/CONFIG
tmp=${SYSD}/TEMP/tmp

settingsd="/Users/tahi/zwv/svc_bs_developer/settings/hmt"
config_settings=${SYSD}/settings2
echo $settingsd

b1=1.1.12_b_1
k1=1.1.12_k_1
a1=1.1.12_a_1
n1=1.1.10_n_1
p1=1.1.10_p_1

b2=2.0.6_b_1
k2=2.0.5_k_1
c2=2.0.1_c_1
cg2=2.0.1_cg_1
a2=2.0.6_a_1
n2=2.0.2_n_1
t2=2.0.2_t_1


while read line
do
  skip=0
  
  srs=`echo $line | awk '{print $2}'`
  repo=`echo $line | awk '{print $1}'`
  compo=`echo $repo \
  | sed -e 's/hmt\-svc*//' \
  | sed -e 's/^[0-9]\{1,3\}//' \
  | sed -e 's/\-dev//' \
  | sed -e 's/\-stg//' \
  | sed -e 's/\-prd//' \
  `
  if [ "$srs" = "v1" ]; then
    if [ "$compo" = "b" ]; then  
      tag=$b1
    elif [ "$compo" = "k" ]; then
      tag=$k1
    elif [ "$compo" = "a" ]; then
      tag=$a1
    elif [ "$compo" = "n" ]; then
      tag=$n1
    elif [ "$compo" = "p" ]; then
      tag=$p1
    else
      skip=1
    fi
  else
    if [ "$compo" = "b" ]; then
      tag=$b2
    elif [ "$compo" = "k" ]; then
      tag=$k2
    elif [ "$compo" = "c" ]; then
      tag=$c2
    elif [ "$compo" = "cg" ]; then
      tag=$cg2
    elif [ "$compo" = "a" ]; then
      tag=$a2
    elif [ "$compo" = "n" ]; then
      tag=$n2
    elif [ "$compo" = "t" ]; then
      tag=$t2
    else
      skip=1
    fi
  fi
 
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

    echo $old_master_branch
    echo $new_master_branch
    echo $production
    echo $settingsd/$repo
    
    #checkout new_master_branch
    (cd $settingsd/$repo && \
    git checkout $old_master_branch && \
    git pull && \
    git checkout -b $new_master_branch)

    #push new master branch
    (cd $settingsd/$repo && \
    git push -u origin $new_master_brancih)


    #checkout release branch
    (cd $settingsd/$repo && \
    git checkout $new_master_branch && \
    git checkout -b $production)

    #push new production
    (cd $settingsd/$repo && \
    git push -u origin $production)


    #tag in production
    (cd $settingsd/$repo && \
    git checkout $production && \
    git tag $tag && \
    git push -u origin $tag)

  fi
done << FILE
`cat $config_settings`
FILE
