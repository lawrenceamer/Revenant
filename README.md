[<img src="https://img.shields.io/badge/join-telegram-blue">](https://t.me/join0xsp)
[<img src="https://img.shields.io/badge/build%20with-Lazarus-red.svg">](https://www.lazarus-ide.org/)
[<img align="right" src="https://i.imgur.com/WYDtCyG.gif" height="400" width="400">]()
[<img src="https://img.shields.io/badge/join-discord-orange">](https://discord.gg/Xsdxxkm)
[<img src="https://img.shields.io/twitter/follow/zux0x3a?label=follow&style=social">](https://twitter.com/zux0x3a)

# Revenant
 
Considered as a reliable method for remotely accessing systems via the Server Message Block (SMB) protocol for both joined and non-joined domain computers. Used to execute command and payloads into other computers.
- Establish an SMB connection into the chosen Driver Share.
- Copy the desired payload and pushing it in to share. ( any Writeable share driver )
- Using Lateral movement technique to execute a payload by tasking scheduling (OLE Objects)

In general, this tool will allow both users and administrators to push malicious payloads into compromised shares while using the Task Scheduling interface (OLE) to execute uploaded binaries or scripts,the tool commonly used to move east-west (Lateral Movement ) between joined domain computers.

[<img src="https://i.imgur.com/MStuaeF.png">]()
 ## features 
 
- undetectable by AV.
- upload executable files or scripts into any writeable share. 
- moving laterally under the radar with some enhancement in Task Scheduling Library taskschd.dll 
- supports all windows operating systems.
- supports automatic exploitation or custom data and time task scheduling.
## usage 

```
-h --remote hostname or IP Address.
-u --valid username for authentication
-p --valid account password 
-d --specify Domain name FQDN
-s --share folder or driver e.g c,d,admin,user,uploads..etc
-c --select local payload as executable format or script to upload into target host
-t --[OPTIONAL] use this option in order to run the payload at specific date and time
Example: Z:\home\zux0x3a\Revenant\project1.exe -h host -u test -p "admini" -d "0xsp" -s share -c payload.[EXE,BAT,VBS]
 
Manual Task: Z:\home\zux0x3a\Revenant\project1.exe -h host -u test -p "admini" -d "0xsp" -s share -c payload.[EXE,BAT,VBS] -t (2020\09\11 13:00:00)

```
## Community 

the project developed by Lawrence amer with much thanks to Lazarus Forums for imported Libraries to make this tool much powerful.
for more upcoming research please make sure to bookmark 0xsp.com as your favorite site. 

 
 
 
