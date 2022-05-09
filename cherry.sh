#!/bin/sh
#目的快速遴选多条提交记录并提交到指定分支
#####################################config start#################################
#源分支，从这个分支merge内容
srcBranch="master"

#目标分支,向这个分支merge内容
dstBranch="target_branch"

#工程的git目录
repoDir="E:\project"

tag=$1
committag=$2

if [ ! $tag ];then
	echo "./cherry.sh  \"T753186|T753186|...\" \"T753188\""
	echo "./cherry.sh  \"原分支单号1|单号2|...\" \"新分支单号\""
	exit 1
fi

cd $repoDir
echo "当前目录:`pwd`"


echo -e "当前分支是:\033[33m `git rev-parse --abbrev-ref HEAD`\033[0m"
#echo "分支`git rev-parse --abbrev-ref HEAD`执行reset"
git reset --hard  > /dev/null
#echo "分支`git rev-parse --abbrev-ref HEAD`执行pull"
git pull --rebase> /dev/null

#先切换到src分支获取最新的commit logs
git checkout $srcBranch > /dev/null
echo -e "当前分支是:\033[33m `git rev-parse --abbrev-ref HEAD`\033[0m"
#echo "分支`git rev-parse --abbrev-ref HEAD`执行reset"
git reset --hard  > /dev/null
#echo "分支`git rev-parse --abbrev-ref HEAD`执行pull"
git pull --rebase> /dev/null



echo -e "\033[33m 分支提交记录 \033[0m"
commitList=`git log --pretty=format:"%s _split %h" | grep -E  $tag | awk -F "split" '{print$2}' |awk '{a[NR]=$1} END{for(i=NR;i>0;i--){printf(i==1?a[i]:a[i]" ")}}'`

for i in $commitList; do
	#| awk -F "split" '{print$1 $2}'
	echo -e "\033[35m  $i \033[0m"
done


#切回到dst分支
cd $repoDir
git checkout $dstBranch > /dev/null
echo -e "当前分支是:\033[33m `git rev-parse --abbrev-ref HEAD`\033[0m"
echo "分支`git rev-parse --abbrev-ref HEAD`执行pull"
git pull --rebase> /dev/null

tempMergeFile=mergelog_temp.txt
i=0
newArr={}
hashArr=(${commitList})
git log  --pretty=format:"%s_split%h"|grep "merge_from_master"> $tempMergeFile

echo -e "\033[33m 过滤前${#hashArr[@]}条记录 \033[0m"

echo "过滤合并记录"

for hash in ${hashArr[@]}  
do  
	
	#是否可以合并
	bool=true
	while read line
	do
    	oldList=`echo $line |awk -F "merge_from_master:" '{print$2}' |awk -F "]" '{print$1}'`
    	if [[ $oldList =~ $hash ]]
		then
   			bool=false	
		fi
	done < $tempMergeFile

	if [ "$bool" = true ]
	then
   		newArr[$i]=$hash
   		let i++
	else
		echo -e "\033[35m$hash已经被合并\033[0m"
	fi
done


echo -e "\033[33m 需要合并$i条记录 \033[0m"

if [ $i == 0 ]
then
   echo "结束"
   exit 1
fi

#合并工具备份文件 false
git config --global mergetool.keepBackup false
for newhash in ${newArr[@]}  
do  
	echo "$newhash"
	#cherry—pick
	git cherry-pick -n $newhash
	cherryPickCode=$?
    if [ $cherryPickCode -ne 0 ] ; then
        echo "手动解决冲突"
        git mergetool
    fi
done

echo -e "\033[33m 合并完成 \033[0m"

if [ ! $committag ];then
	echo "目标单号未填写"
	echo -e "请按格式手动添加本地合并记录:\033[31m [merge][新单号][merge_from_master:${newArr[*]}][日志]\033[0m"
	echo "结束"
	exit 1
fi

rm -rf $tempMergeFile
git commit -m "[merge][$committag][merge_from_master:$newArr]"
echo -e "\033[33m 提交日志：[add][$committag][merge_from_master:${newArr[*]}] \033[0m"
echo "结束"

