
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

config_settings=${SYSD}/builds2

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
  
  if [ "$srs" = "v1" ]; then
    if [ "$repo" = "boarding" ]; then  
      tag=$b1
    elif [ "$repo" = "keel" ]; then
      tag=$k1
    elif [ "$repo" = "asker" ]; then
      tag=$a1
    elif [ "$repo" = "newest" ]; then
      tag=$n1
    elif [ "$repo" = "p1" ]; then
      tag=$p1
    else
      skip=1
    fi
  else
    if [ "$repo" = "boarding" ]; then
      tag=$b2
    elif [ "$repo" = "keel" ]; then
      tag=$k2
    elif [ "$repo" = "cabin" ]; then
      tag=$c2
    elif [ "$repo" = "cargo" ]; then
      tag=$cg2
    elif [ "$repo" = "asker" ]; then
      tag=$a2
    elif [ "$repo" = "newest" ]; then
      tag=$n2
    elif [ "$repo" = "transit" ]; then
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
    
    develop_r=release/develop_${srs}_NOBODY
    staging_r=release/staging_$srs

    develop_s=develop/master_$srs
    staging_s=staging/master_$srs


    for i in 1 2
    do
      if [ $i -eq 1 ]; then
        path=$buildd/$repo
      else
        path=$released$repo
      fi
      echo $path

      echo " -------master------"
      #master
      (cd $path && \
      git checkout $old_master_branch && \
      git pull && \
      git checkout -b $new_master_branch)
      (cd $path && \
      git push -u origin $new_master_branch)
 
      echo " -------develop------"
      #develop r
      (cd $path && \
      git checkout $new_master_branch && \
      git pull && \
      git checkout -b $develop_r)
      (cd $path && \
      git push -u origin $develop_r)
  
      #develop s
      (cd $path && \
      git checkout $new_master_branch && \
      git pull && \
      git checkout -b $develop_s)
      (cd $path && \
      git push -u origin $develop_s)
  
      echo " -------staging------"
      #staging_r
      (cd $path && \
      git checkout $develop_s && \
      git pull && \
      git checkout -b $staging_r)
      (cd $path && \
      git push -u origin $staging_r)
  
      #staging_s
      (cd $path && \
      git checkout $develop_s && \
      git pull && \
      git checkout -b $staging_s)
      (cd $path && \
      git push -u origin $staging_s)
  
  
      echo " -------production------"
      #produtcion
      (cd $path && \
      git checkout $new_master_branch && \
      git pull && \
      git checkout -b $production)
      (cd $path && \
      git push -u origin $production)
  
      #tag in production
      (cd $path && \
      git checkout $production && \
      git tag $tag && \
      git push -u origin $tag)

    done
  fi
done << FILE
`cat $config_settings`
FILE
