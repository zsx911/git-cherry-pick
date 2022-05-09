# git-cherry-pick
Quick cherry pick of multi-line commit
#目的快速遴选多条提交记录并提交到指定分支


#默认已经配置好git的ssh公钥免密登录

step 1：
  编辑脚本
  a、源分支：根据【源分之单号】获取提交记录
  b、目标分支：合并的目标分支
  c、工程目录

step 2:
     #遴选包含“T753186” “T753186”文本的提交记录  
	a： ./cherry.sh "T753186|T753186|..."    
   
    #or  遴选包含“T753186” “T753186”文本的提交记录  并以T753188单号提交到本地
    b：./cherry.sh "T753186|T753186|..." "T753188"
   