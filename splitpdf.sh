#!/bin/bash 
####
#  dependency: mupdf package and pdfjam
#  run as  splitpdf input.pdf

input=$1

echo "**************************PDF SPLIT*****************************"

echo $input


x=`mutool info  -M $input |grep "(1 "|awk '{print $(NF-2)}'`
y=`mutool info  -M $input |grep "(1 "|awk '{print $(NF-1)}'`
echo "raw pdf size in pts: $x $y"

rawpage=`mutool info $input|grep Pages:|awk '{print $NF}'`
if [ $rawpage -gt 1 ] ; then 
   echo "exit: more than 1 page in the doc"
   exit
fi
#backup
cp $input .${input}.bk   

px=8.5  #letter size x in inch 
py=11   #letter size y in inch
letter_ratio=`echo  $py/$px|bc -l`
pt2cm=0.0352778

tmppage=`echo $x $y $letter_ratio|awk '{printf "%.2f",$2/$1/$3}'`


page=`echo $tmppage/1|bc`
rpage=`echo $tmppage $page|awk '{printf "%.2f", $1-$2}'`

echo tmppage=$tmppage int_page=$page deci_page=$rpage

if [ "x$SPLIT_TIGHT" = "xYES" ] || [ "x$SPLIT_TIGHT" = "xyes" ] ; then
  st=`echo "$rpage/$page > 0.2"|bc -l`
  echo "extra page ratio=" `echo $rpage/$page|bc -l`
else 
  st=`echo "$rpage > 0.05"|bc -l`
fi
echo $st
#page=$((page+st))

 if [ $st -ge 1 ]; then 
    page=$((page+1))
    extra_y=`echo "$x*$page*$letter_ratio-$y"|bc -l`
    extra_y_cm=`echo "$extra_y*$pt2cm"|bc -l`
    printf "adding trailing white space %.2f cm\n"  $extra_y_cm
#   convert -size ${x}x${newy} xc:white canvas.pdf
#   convert canvas.pdf $input  -composite tmp.pdf 
    pdfjam --fitpaper true --trim "0cm -${extra_y_cm}cm 0cm 0cm" $input -o tmp.pdf >& /dev/null
    mv tmp.pdf $input
 fi

mutool poster -y $page $input tmp.pdf
pdfjam --fitpaper true --trim "-1cm -1cm -1cm -1cm" tmp.pdf -o $input >& /dev/null
rm tmp.pdf




printf "****************************************************************\n\n"

# mv tmp.pdf $input

