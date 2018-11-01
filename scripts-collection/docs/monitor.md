
### 系统监控脚本

#### 分解说明

```
PATH=`pwd` # 或 PATH=$(pwd)
echo $PATH
```

+ 参数说明
$1表示第一个参数，$2 表示第二个参数，$#表示参数个数


getopts：可以获取用户在命令下的参数，然后根据不同的参数进行不同的操作。使用方法为 `getopts option_string variable`，
option_string 是指字符串，会逐个匹配，variable 每次匹配成功的选项。


```
#! /bin/bash
while getopts ivh name # getopts 有三个参数，分别执行安装，查看版本，帮助说明
do
        case $name in
          i)iopt=1;;
          v)vopt=1;;
          h)hopt=1;;
         *)echo "Invalid arg";;
        esac
done


```

这个脚本主要有 `-ivh` 三个参数，分别执行安装脚本，查看版本，帮助说明，你也可以添加自己想要的参数。如果不加参数，默认执行系统的监控命令并打印到屏幕上。


#### 将脚本添加到环境的目录里，通过终端就可以执行命令

```
if [[ ! -z $iopt ]] #如果iopt非空则执行
then
{
wd=$(pwd)
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
#basename命令会删掉所有的前缀包括最后一个slash（‘/’）字符，然后将字符串显示出来
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
#scriptname就是tecmint_monitor.sh的地址
su -c "cp $scriptname /usr/bin/monitor" root && echo "Congratulations! Script Installed, now run monitor Command" || echo "Installation failed"
}
fi

```


#### 参数 v
查看脚本的版本，版权等信息

```
if [[ ! -z $vopt ]]
then
{
echo -e "tecmint_monitor version 0.1\nReleased Under Apache 2.0 License"
}
fi

```

#### 参数 h
添加帮助信息
```
if [[ ! -z $hopt ]]
then
{
echo -e " -i                                Install script"
echo -e " -v                                Print version information and exit"
echo -e " -h                                Print help (this information) and exit"
}
fi
```

#### 提取信息设置变量

```
clear

unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage
# unset命令用于删除已定义的shell变量（包括环境变量）和shell函数。
# 关于unset更多的信息可以查看http://www.runoob.com/linux/linux-comm-unset.html
# 定义变量 tecreset
tecreset=$(tput sgr0)

# 查看是否可以连网
ping -c 1 www.baidu.com &> /dev/null && echo -e '\E[32m'"Internet: $tecreset Connected" || echo -e '\E[32m'"Internet: $tecreset Disconnected"
# '\E[32m' 将打印的信息设置为绿色
# 查看系统的类型
os=$(uname -o)
echo -e '\E[32m'"Operating System Type :" $tecreset $os

# 查看系统的版本和名称
###################################
OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`

GetVersionFromFile()
{
    VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
}


```

```
if [ "${OS}" = "SunOS" ] ; then
    OS=Solaris
    ARCH=`uname -p`
    OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
# uname命令用于打印当前系统相关信息（内核版本号、硬件架构、主机名称和操作系统类型等）。
elif [ "${OS}" = "AIX" ] ; then
    OSSTR="${OS} `oslevel` (`oslevel -r`)"
#AIX是IBM开发的一套类UNIX操作系统
elif [ "${OS}" = "Linux" ] ; then
    KERNEL=`uname -r`
    if [ -f /etc/redhat-release ] ; then
        DIST='RedHat'
        PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
#sed通常用来匹配一个或多个正则表达式的文本进行处理,可以查看http://coolshell.cn/articles/9104.html
    elif [ -f /etc/SuSE-release ] ; then
        DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
        REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/mandrake-release ] ; then
        DIST='Mandrake'
        PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/debian_version ] ; then
        DIST="Debian `cat /etc/debian_version`"
        REV=""

    fi
    if ${OSSTR} [ -f /etc/UnitedLinux-release ] ; then
        DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
    fi

    OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"

fi

```
监控系统的各种信息，并打印到屏幕


```
查看操作系统版本
echo -e '\E[32m'"OS Version :" $tecreset $OSSTR 
# 查看系统的类型
architecture=$(uname -m)
echo -e '\E[32m'"Architecture :" $tecreset $architecture

# 查看内核的版本
kernelrelease=$(uname -r)
echo -e '\E[32m'"Kernel Release :" $tecreset $kernelrelease

# 查看主机名
echo -e '\E[32m'"Hostname :" $tecreset $HOSTNAME

# 查看内网地址
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP :" $tecreset $internalip

# 查看外网地址
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"External IP : $tecreset "$externalip

# 查看DNS
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e '\E[32m'"Name Servers :" $tecreset $nameservers 

# 查看登陆的用户
who>/tmp/who
echo -e '\E[32m'"Logged In users :" $tecreset && cat /tmp/who 

# 查看系统内存使用情况
free -h | grep -v + > /tmp/ramcache
echo -e '\E[32m'"Ram Usages :" $tecreset
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[32m'"Swap Usages :" $tecreset
cat /tmp/ramcache | grep -v "Mem"

# 查看磁盘使用情况
df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
echo -e '\E[32m'"Disk Usages :" $tecreset 
cat /tmp/diskusage

# 查看系统的负载情况
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e '\E[32m'"Load Average :" $tecreset $loadaverage

# 查看系统的运行时间
tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e '\E[32m'"System Uptime Days/(HH:MM) :" $tecreset $tecuptime

# 删除上面使用的变量，释放资源
unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage

# 删除临时文件
rm /tmp/who /tmp/ramcache /tmp/diskusage
}


```

