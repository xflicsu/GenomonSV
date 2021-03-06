#! /bin/sh
#$ -S /bin/sh
#$ -cwd

:<<_COMMENT_OUT_
    script for creating merged nonmatched normal control data
    the input ${CONTROLLIST} is tab-delimited file where the 1st colum is the label of samples
    and the 2nd column is the path for the individual junction list file
_COMMENT_OUT_

source ./config.sh

CONTROLLIST=$1
OUTPUT=$2

# :<<_COMMENT_OUT_

IFS=$'\t'
echo -n > ${OUTPUT}.temp
while read line
do
    tsvList=(`echo "$line"`)
    sample=${tsvList[0]}
    path=${tsvList[1]}

    echo $sample

    echo "python simplifyJunc.py $path $sample >> ${OUTPUT}.temp"
    python simplifyJunc.py $path $sample >> ${OUTPUT}.temp
    check_error $?
 
done < ${CONTROLLIST}

echo "sort -k1,1 -k2,2n -k4,4 -k5,5n ${OUTPUT}.temp > ${OUTPUT}.temp.sort"
sort -k1,1 -k2,2n -k4,4 -k5,5n ${OUTPUT}.temp > ${OUTPUT}.temp.sort
check_error $?

# _COMMENT_OUT_

echo "python organizeControl.py ${OUTPUT}.temp.sort | sort -k1,1 -k2,2n -k4,4 -k5,5n - > ${OUTPUT}"
python organizeControl.py ${OUTPUT}.temp.sort | sort -k1,1 -k2,2n -k4,4 -k5,5n - > ${OUTPUT}
check_error $?

echo "bgzip -f ${OUTPUT} > ${OUTPUT}.gz"
bgzip -f ${OUTPUT} > ${OUTPUT}.gz
check_error $?

echo "tabix -p bed -f ${OUTPUT}.gz"
tabix -p bed -f ${OUTPUT}.gz
check_error $?


# rm -rf ${OUTPUT}.temp
# rm -rf ${OUTPUT}.temp.sort

