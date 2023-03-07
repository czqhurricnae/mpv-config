#output a run.sh that real cut and concat the file
#use ffmpeg,thanks for its developer
if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ]
then
	echo "please input paramenter:\$1[time_pairs_txt],\$2[src_media_file],\$3[out_save_path]"
	exit 2
fi

time_pairs_txt=$1 # txt file that contain time suits for trim
## 格式: local file: ~/super_star.mp4 | web file: http[s]://cdn.ali.upcs.com/hud/zzz_yyyy_mm.mp4?a=b&c=222 | m388 ts: http[s]://cdn.ali.upcs.com/hud/zzz_yyyy/mm/m3u8?a=b&c=222
input=$2 # 待处理视频完整路径
#input=${input//' '/'\ '}
input=`printf %q "$input"`
output='date "+%Y_%m_%d_%H_%M_%S"' # 剪辑后输出文件名前缀
dir_name=.cut_video  # 用于临时使用的目录
dir_path=$3 # 剪辑后输出文件保存目录
sh_dir=$4  # 脚本工作路径
IFS=$'/' f=($2) # 对待处理视频的完整路径进行/分割
file_name=${f[${#f[*]}-1]}  # /后分割得到文件名称

## add by likey
## 参考: https://blog.csdn.net/weixin_30363981/article/details/97631778
http_schemal="http:" https_schemal="https:"
echo "----------begin:----------"
echo "input name:$input"
echo "file name:$file_name"

## 如果请求web网页资源,并为http或https协议
# if [[ $input == *$http_schemal* || $input == *$https_schemal* ]]
if [[ $input =~ "$http_schemal" || $input =~ "$https_schemal" ]]
then
    echo "request web resource!"

	## 添加referer
	referer_str=$''
	if [[ $input =~ "iqiyi.com" ]]
	then
		# referer_str="-headers Referer:https://www.iqiyi.com/"
		echo ">>>暂未对爱奇艺设置referer!"
	elif [[ $input =~ "bilivideo.cn" ]]
	then
		referer_str="-headers Referer:https://www.bilibili.com/"
		echo ">>>已经添加到 B 站:referer!"
	else
		# referer_str='-headers Referer:https://www.xxxx.com/'
		echo ">>>input输入流的站点未识别!"
	fi
	echo $referer_str

	##  丢弃包括?后的内容
	file_name=${file_name%%\?*}
	## \r\n分割headers中多个参数,不然有警告:No trailing CRLF found in HTTP header. Adding it.
	st_headers=$referer_str ## 要用正则换成每次对应请求的域名,这里暂时直接写死了,因为除了B站,其它站点似乎不受影响
	st_user_agent=$'-user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.76 " '
	# st_user_agent_m=$' -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36 " '
else
    echo "request local resource!"
	st_headers=$''
	st_user_agent=$''
	st_user_agent_m=$''
fi

## 如文件名不含.号,则不是本地文件和远程文件直链,而是网页ts视频流
if [[ $file_name != *$'.'* ]]
then
	echo "hint: maybe online stream, please use you-get tool to get a direct remote media file [mp4|flv|...] ......."
	## 设置返回视频格式为mp4及指定一个最终的合并文件名,更改后缀名为mp4不然m3u8下载的多个ts流无法合并转换成功
	file_format=$"mp4"
	file_name=$"m3u8_out_compact.mp4"
## 如果请求文件是.m3u8后缀,更改后缀名为mp4不然可能无法转换成功
elif [[ $file_name == *$'.m3u8'*  || $file_name == *$'.m4s'* || $file_name == *$'.ts'* ]]
then
	file_format=$"mp4"
	file_name="${file_name}.mp4"
else
	## 带文件后缀(非.mu38流)的真实视频地址
	echo "direct file name: $file_name"
fi

#file_name=${file_name//' '/'\ '}
IFS=$'.' t=($file_name)
file_format=${t[${#t[*]}-1]}
echo  "file name:$file_name, file format:$file_format"

# cat $time_pairs_txt | while read line
# do
# 	 IFS=',' seg=($line)
# 	 left=${seg[0]}
# 	 right=${seg[1]}
# 	 echo "left:$left,right:$right"
# done
echo "dir_path for save_file:$dir_path"

## add by likey 设置视频统一的输出路径,不然默认会放置在本地文件同目录下,(注意:Web网页请求时地址要处理,不然报错,因为传入的目录是一长串网址)
dir_path=$'/Users/c/Downloads/mpv-www-gen'

eval cd "$sh_dir"
echo "sh_dir for script:`pwd` "
echo "cd \"$dir_path\"" > run.sh
echo "mkdir $dir_name" >> run.sh


IFS=$'\n' a=(`eval cat $time_pairs_txt`)
num=${#a[@]}
for  i  in  ${!a[@]};do
	IFS=',' seg=(${a[i]})
	left=${seg[0]}
	right=${seg[1]}
	duration=$(echo "scale=2;$right-$left" |bc)
	# echo "[$i]left:$left,right:$right"
	#gen a new run.sh
	# if [ $i = 0 ]
	# then
	# 	echo "echo \"file 'clip$i.mkv'\" >>$dir_name/concat.txt" >run.sh
	# fi
	echo "ffmpeg $st_headers $st_user_agent -i $input -ss $left -t $duration $dir_name/clip$i.$file_format" >>run.sh
	#echo "ffmpeg -y -accurate_seek -ss $left  -t $duration -i $input -c  copy -avoid_negative_ts 1 $dir_name/clip$i.$file_format" >>run.sh

	echo "echo \"file 'clip$i.$file_format'\" >>$dir_name/concat.txt" >>run.sh

done

# if [ $num == 1 ]
# then
#    echo "cp mode"
#    #echo "cp clip0.mkv ../"\`$output\`"_cat_$file_name" >>run.sh
# else
#    echo "concat mode"
#    #echo "ffmpeg -f concat -i $dir_name/concat.txt -c copy "\`$output\`"_cat_$file_name" >>run.sh
# fi
## 如果只提取了单段视频,直接拷贝至放置目录,否则要用ffmpeg合并一次
if [ $num == 1 ]
then
   echo "only single clip extract, use cp mode"
   echo "cp $dir_name/clip0.$file_format \"\`$output\`_cut_$file_name\"" >>run.sh
else
   echo "multi clip extracts, use concat mode"
   echo "ffmpeg -f concat -i $dir_name/concat.txt -c copy \"\`$output\`_cut_$file_name\"" >>run.sh
fi

echo "rm -rf $dir_name" >>run.sh
echo "echo script_dir:`pwd`" >>run.sh
echo "echo -----ok!-----" >>run.sh
chmod +x run.sh
echo "-----run.sh has generated!-----"
