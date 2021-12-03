;#define MyAppName "Zeugwerk_Framework_App"
;#define MyAppVersion "0.0.0.0"
#define MyAppPublisher "Zeugwerk GmbH"
#define MyAppURL "https://www.zeugwerk.at/"
#define Tc3Root "C:\TwinCAT\3.1"

[Setup]
AppId={{2B58B6B5-D0CA-4DB1-8205-9C0EF54041B6}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
;AppSupportURL={#MyAppURL}
;AppUpdatesURL={#MyAppURL}
CreateAppDir=yes
DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
OutputBaseFilename={#MyAppName}_setup_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
DisableDirPage=no
UsePreviousAppDir=no
VersionInfoCompany=#{MyAppPublisher}
VersionInfoProductName=#{MyAppName}
;SetupIconFile=C:\Users\matth\Zeugwerk\Zeugwerk - Business\iaf\Logo\Logo.png
CloseApplications=force
RestartApplications=True

[Types]
Name: "full"; Description: "Full installation"; Flags: iscustom
Name: "servicetool"; Description: "Servicetool only"

[CustomMessages]
PLC=Plc
LaunchPLC=(Re)start PLC
Servicetool=Servicetool
LaunchServicetool=Start Servicetool
ConnectToServicetool=Open servicetool in browser

[Run]
Filename: {app}\tc3routertool\tc3routertool.exe; Description: {cm:LaunchPLC,{cm:PLC}}; Flags: waituntilterminated postinstall skipifsilent
Filename: {app}\tc3servicetool\tc3servicetool.Server.exe; Description: {cm:LaunchServicetool,{cm:Servicetool}}; Flags: nowait postinstall skipifsilent
Filename: http://localhost; Description: {cm:ConnectToServicetool,{cm:Servicetool}}; Flags: postinstall shellexec

[Components]
Name: "PLC"; Description: "PLC"; Types: full servicetool; Flags: fixed
Name: "PLC\TwinCAT"; Description: "Target TwinCAT"; Flags: fixed; Types: full
Name: "PLC\TwinCAT\TC3_1_4024_22"; Description: "3.1.4024.22"; Flags: exclusive; Types: full
Name: "PLC\TwinCAT\TC3_1_4024_12"; Description: "3.1.4024.12"; Flags: exclusive; Types: full

Name: "PLC\Variant"; Description: "Target Variant"; Flags: fixed; Types: full
Name: "PLC\Variant\default"; Description: "Simulation"; Flags: exclusive; Types: full
Name: "Servicetool"; Description: "Servicetool"; Flags: fixed; Types: full servicetool

[Files]
Source: "..\..\tc3routertool\*"; DestDir: "{app}\tc3routertool"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tc3servicetool\*"; DestDir: "{app}\tc3servicetool"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: servicetool
Source: "..\..\doc\html\*"; DestDir: "{app}\tc3servicetool\wwwroot\doc\html"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: servicetool
Source: "..\..\plc_TC3.1.4024.22_default\*"; DestDir: "{app}\plc\plc_TC3.1.4024.22_default\"; Flags: ignoreversion recursesubdirs;
Source: "..\..\plc_TC3.1.4024.12_default\*"; DestDir: "{app}\plc\plc_TC3.1.4024.12_default\"; Flags: ignoreversion recursesubdirs;

[Icons]
Name: "{#Tc3Root}\Target\StartUp\tc3servicetool"; Filename: "{app}\tc3servicetool\tc3servicetool.Server.exe"

[CODE]
procedure DirectoryCopy(SourcePath, DestPath: string);
var
  FindRec: TFindRec;
  SourceFilePath: string;
  DestFilePath: string;
begin
  if FindFirst(SourcePath + '\*', FindRec) then
  begin
    try
      repeat
        if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
        begin
          SourceFilePath := SourcePath + '\' + FindRec.Name;
          DestFilePath := DestPath + '\' + FindRec.Name;
          if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
          begin
            if FileCopy(SourceFilePath, DestFilePath, False) then
            begin
              Log(Format('Copied %s to %s', [SourceFilePath, DestFilePath]));
            end
              else
            begin
              Log(Format('Failed to copy %s to %s', [SourceFilePath, DestFilePath]));
            end;
          end
            else
          begin
            if DirExists(DestFilePath) or CreateDir(DestFilePath) then
            begin
              Log(Format('Created %s', [DestFilePath]));
              DirectoryCopy(SourceFilePath, DestFilePath);
            end
              else
            begin
              Log(Format('Failed to create %s', [DestFilePath]));
            end;
          end;
        end;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end
    else
  begin
    Log(Format('Failed to list %s', [SourcePath]));
  end;
end;


procedure CurStepChanged(CurStep: TSetupStep);
var
  SelectedTwinCAT : string;
  SelectedVariant : string;
begin
  { Install after installation, as then the application folder exists already }
  if CurStep = ssPostInstall then
  begin

	if WizardIsComponentSelected('PLC\TwinCAT\TC3_1_4024_22') then
    begin
      SelectedTwinCAT := 'TC3.1.4024.22'
    end;
	if WizardIsComponentSelected('PLC\TwinCAT\TC3_1_4024_12') then
    begin
      SelectedTwinCAT := 'TC3.1.4024.12'
    end;
	

    if WizardIsComponentSelected('PLC\Variant\default') then
    begin
      SelectedVariant := 'default'
    end;

    if DirExists('{#Tc3Root}\Boot') or CreateDir('{#Tc3Root}\Boot') then
    begin
      if DirExists('{#Tc3Root}\Boot\Plc') or CreateDir('{#Tc3Root}\Boot\Plc') then
      begin
        DirectoryCopy(ExpandConstant('{app}\plc\plc_'+SelectedTwinCAT+'_'+SelectedVariant+'\TwinCAT RT (x64)\Plc'), ExpandConstant('{#Tc3Root}\Boot\Plc'))
        FileCopy(ExpandConstant('{app}\plc\plc_'+SelectedTwinCAT+'_'+SelectedVariant+'\TwinCAT RT (x64)\CurrentConfig.xml'), ExpandConstant('{#Tc3Root}\Boot\CurrentConfig.xml'), False)
      end;
    end;
  end;
end;