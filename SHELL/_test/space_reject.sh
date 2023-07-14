SYSD=$(pwd)
tmp=${SYSD}/TEMP/tmp

################################
#Space reject 2 array
################################
SPACE_REJECT() {

  if [ -f $1 ]; then
    :
  else
    echo "nothing strings. arg1."
    return
  fi
  
  strings=`cat $1`
  echo $strings
  echo $strings | awk '
    BEGIN{
      i = 0 
    }
    {
      arr[ i ] = $1 
      i++
    }
    END{
        for (i = 0; i < length(arr); i++ ) {
            printf "%s," , arr[ i ]
        }
    }
  '

  return
}
