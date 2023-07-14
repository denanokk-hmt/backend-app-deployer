# run & color

################################
#3は文字色
#4は背景色になります。 
#
#Color
#0  Black
#1  Red
#2  Green
#3  Yellow
#4  Blue
#5  Magenda
#6  Cyan
#
#format
#  normal=0
#　bold=1
#  dark=2
#  under_line=4
#　blink=5
#　reverse=7
#　invisible=8


################################
#
colored() {
  
  #check bash version
  if [ -e $tmp-bash_version ]; then
    bash_version=`cat $tmp-bash_version`
  else
    bash_version=3
  fi
  
  #off
  if [ $bash_version -lt 4 ]; then
    COLOR_OFF="\033[m"
  fi
  
  settings=$1  

  shift
  if [ $bash_version -lt 4 ]; then
    echo "\033[${settings}m$@\033[0"
    echo $COLOR_OFF
  else
    echo -e "\e[${settings}m$@\e[m"
  fi


  return 0
}

################################
# $1 view words
# $2 view type
#   s1:big sub
#   s2:middle sub
#   s3:small sub
#   Warning
#   Error
#
colored2() {
  
  if [ -e $tmp-bash_version ]; then
    bash_version=`cat $tmp-bash_version`
  else
    bash_version=3
  fi
  
  #args
  type=$1
  shift
  words=$1
  shift
  format=$1  
  shift
  color=$1
  shift

  #off
  if [ $bash_version -lt 4 ]; then
    COLOR_OFF="\033[m"
  else
    COLOR_OFF="\e[m"
  fi

  #set color subject
  if [ $type = "s0" ]; then
    format=5
    color=32
  elif [ $type = "s1" ]; then
    format=7
    color=32
  elif [ $type = "s2" ]; then
    format=4
    color=32
  elif [ $type = "s3" ]; then
    format=1
    color=36
  
  #set color error
  elif [ $type = "e0" ]; then
    format=5
    color=31
  elif [ $type = "e1" ]; then
    format=7
    color=31
  elif [ $type = "e2" ]; then
    format=4
    color=31
  elif [ $type = "e3" ]; then
    format=1
    color=31
  
  #set color warning
  elif [ $type = "w0" ]; then
    format=5
    color=31
  elif [ $type = "w1" ]; then
    format=7
    color=31
  elif [ $type = "w2" ]; then
    format=4
    color=31
  elif [ $type = "w3" ]; then
    format=1
    color=31
  fi

  if [ $bash_version -lt 4 ]; then
    echo "\033[${format};${color}m${words}\033[0m"
  else
    echo -e "\e[${format};${color}m${words}\e[m"
  fi

  echo $COLOR_OFF
  return 0
}




COLOR_TESTER() {

  colored 0 31 [LOGGING]
  colored 1 31 [LOGGING]
  colored 2 31 [LOGGING]
  colored 4 31 [LOGGING]
  colored 5 31 [LOGGING]
  colored 7 31 [LOGGING]
  
  colored 1 32 [LOGGING]
  colored 2 32 [LOGGING]
  colored 4 32 [LOGGING]
  colored 5 32 [LOGGING]
  colored 7 32 [LOGGING]
  
  colored 1 33 [LOGGING]
  colored 2 33 [LOGGING]
  colored 4 33 [LOGGING]
  colored 5 33 [LOGGING]
  colored 7 33 [LOGGING]
  
  colored 1 34 [LOGGING]
  colored 2 34 [LOGGING]
  colored 4 34 [LOGGING]
  colored 5 34 [LOGGING]
  colored 7 34 [LOGGING]
  
  colored 1 35 [LOGGING]
  colored 2 35 [LOGGING]
  colored 4 35 [LOGGING]
  colored 5 35 [LOGGING]
  colored 7 35 [LOGGING]



}
