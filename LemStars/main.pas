unit Main;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, LCLType, Graphics, Dialogs, shlobj,
  Clipbrd, LCLIntf, ComCtrls, GL, OpenGLContext, StdCtrls, Menus, ExtCtrls,
  ActnList, IniFiles, process, LCLProc, MyUtils, Vector, Stars, Math, Constell,
  Lines, Stat, About, Info, Types, Find, View, Tools, Options, StrUtils, Brightness;

const texMilky = 0;  texFont = 1;
  CutoffZoom = 20; {px/°}

type

  { TMainForm }

  TMainForm = class(TForm)
    ActionBrightnessConv: TAction;
    ActionOptions: TAction;
    ActionImage: TAction;
    ActionTools: TAction;
    ActionRot: TAction;
    ActionZoom: TAction;
    ActionView: TAction;
    ActionFind: TAction;
    ActionCenter: TAction;
    ActionAbout: TAction;
    ActionSave: TAction;
    ActionConstell: TAction;
    ActionDouble: TAction;
    ActionNr: TAction;
    ActionNumber: TAction;
    ActionLines: TAction;
    ActionHide: TAction;
    ActionConstells: TAction;
    ActionList: TActionList;
    ApplicationProperties: TApplicationProperties;
    ExecProcess: TProcess;
    FontImage: TImage;
    ConstellNamesItem: TMenuItem;
    DistinguishItem: TMenuItem;
    ImageSettingsItem: TMenuItem;
    BlinkItem: TMenuItem;
    ImageOverviewItem: TMenuItem;
    MannumberedItem: TMenuItem;
    SelectConstellItem: TMenuItem;
    RemoveHighlightItem: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MilkyImage: TImage;
    MenuItem1: TMenuItem;
    DimOtherItem: TMenuItem;
    NotifyLabel: TStaticText;
    MoveTimer: TTimer;
    BlinkTimer: TTimer;
    ToolButton1: TToolButton;
    ToolButtonOptions: TToolButton;
    ToolButtonImage: TToolButton;
    ZoomTimer: TTimer;
    ToolButtonTools: TToolButton;
    ToolButton2: TToolButton;
    UnnumberedItem: TMenuItem;
    MilkyItem: TMenuItem;
    OpenGLBox: TOpenGLControl;
    ConstellCombo: TComboBox;
    GridItem: TMenuItem;
    ImageList: TImageList;
    N1: TMenuItem;
    Separator3: TToolButton;
    ConstellLinesItem: TMenuItem;
    Numbers0: TMenuItem;
    Numbers1: TMenuItem;
    Numbers2: TMenuItem;
    SouthUpItem: TMenuItem;
    NumberTaskDialog: TTaskDialog;
    HideTaskDialog: TTaskDialog;
    RotTimer: TTimer;
    ToolBar: TToolBar;
    Separator6: TToolButton;
    ToolButtonZoom: TToolButton;
    ToolButtonRot: TToolButton;
    ToolButtonFind: TToolButton;
    ToolButtonCenter: TToolButton;
    Separator1: TToolButton;
    Separator5: TToolButton;
    Separator4: TToolButton;
    Separator2: TToolButton;
    ToolButtonAbout: TToolButton;
    ToolButtonConstell: TToolButton;
    ToolButtonConstells: TToolButton;
    ToolButtonDouble: TToolButton;
    ToolButtonHide: TToolButton;
    ToolButtonLines: TToolButton;
    ToolButtonNr: TToolButton;
    ToolButtonNumber: TToolButton;
    ToolButtonSave: TToolButton;
    ToolButtonView: TToolButton;
    ViewPopup: TPopupMenu;
    procedure ActionBrightnessConvExecute(Sender: TObject);
    procedure ActionCenterExecute(Sender: TObject);
    procedure ActionImageExecute(Sender: TObject);
    procedure ActionOptionsExecute(Sender: TObject);
    procedure ActionToolsExecute(Sender: TObject);
    procedure ApplicationPropertiesShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
    procedure BlinkTimerTimer(Sender: TObject);
    procedure ConstellComboChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ImageSettingsItemClick(Sender: TObject);
    procedure MoveTimerTimer(Sender: TObject);
    procedure OpenGLBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OpenGLBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure OpenGLBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OpenGLBoxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure RemoveHighlightItemClick(Sender: TObject);
    procedure SelectConstellItemClick(Sender: TObject);
    procedure StarNrsClick(Sender: TObject);
    procedure RotTimerTimer(Sender: TObject);
    procedure ActionAboutExecute(Sender: TObject);
    procedure ActionConstellsExecute(Sender: TObject);
    procedure ActionFindExecute(Sender: TObject);
    procedure ActionHideExecute(Sender: TObject);
    procedure ActionLinesExecute(Sender: TObject);
    procedure ActionRotExecute(Sender: TObject);
    procedure ActionSaveExecute(Sender: TObject);
    procedure ActionStatExecute(Sender: TObject);
    procedure ActionNumberExecute(Sender: TObject);
    procedure OpenGLBoxPaint(Sender: TObject);
    procedure OpenGLBoxResize(Sender: TObject);
    procedure ActionViewExecute(Sender: TObject);
    procedure ActionZoomExecute(Sender: TObject);
    procedure ViewOptsClick(Sender: TObject);
    procedure ViewPopupPopup(Sender: TObject);
    procedure ZoomTimerTimer(Sender: TObject);
  private
    OpenGLInitialised, HideZeroesInStat, MouseMoved, UploadBackups, UploadJS, ToolsBoxLock, ConstellSearchAll: Boolean;
    FModified: Byte;
    OldX, OldY, LinesOpacity, ActiveLemConstell, ToolsBoxPage: Integer;
    WorkingDir, FStarDir, HostName, UserName, Password, UploadPath, ConstellSearch: string;
    AboutStrings: array[1..2] of string;
    TexIds: array[texMilky..texFont] of GLuint;
    ViewBox, FindBox, ToolsBox: TRect;
    Falpha0, Fdelta0, FZoom, Movealpha0, Movedelta0, MoveZoom0, MovealphaD, MovedeltaD, MoveZoomD, BrightnessConvM, BrightnessConvCI: Single;
    FStarList, FLinesList: TList;
    FLemConstells: TStringList;
    FHighlightStar: TStar;
    procedure SaveStars;
    function SaveText: string;
    procedure Setalpha0(S: Single);
    procedure Setdelta0(S: Single);
    procedure SetZoom(S: Single);
    procedure SetModified(B: Byte);
    procedure SetHighlightStar(S: TStar);
    function GetStar(Nr: Integer): TStar;
    function GetStarCount: Integer;
    function IsActiveLemConstell(Id: Integer): Boolean;
    function InitOpenGL: Boolean;
    procedure StarsAt(Strings: TStrings; X, Y: Integer; BayAndFlam: Boolean=True; LemAlso: Boolean=False);
  public
    property StarDir: string read FStarDir;
    property alpha0: Single read Falpha0 write Setalpha0;
    property delta0: Single read Fdelta0 write Setdelta0;
    property Zoom: Single read FZoom write SetZoom;
    property StarList: TList read FStarList;
    property LinesList: TList read FLinesList;
    property LemConstells: TStringList read FLemConstells;
    property Modified: Byte read FModified write SetModified;
    property HighlightStar: TStar read FHighlightStar write SetHighlightStar;
    property Star[Nr: Integer]: TStar read GetStar;
    property StarCount: Integer read GetStarCount;
    function ConstellName(Nr: Integer): string;
    procedure ConstellCenter(LemC: Byte; out calpha, cdelta: Single);
    procedure MoveTo(alpha1, delta1: Single);
    procedure ZoomTo(Zoom1: Single);
    procedure AssignConstells(Strings: TStrings; NumberConstells: Boolean = False);
    procedure ApplyLines;
  end;

var
  MainForm: TMainForm;
  GuideStar: TStar;

const
  CompileDate = {$I %DATE%};

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
const ShortMonthNames: TMonthNameArray = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
      glx: TTensor = (( 0.873437300833 , 0.444829527965,  0.198075673824),
                      (-0.483834538476 , 0.746982079405,  0.455984552836),
                      (-0.0548764146848, 0.494109769279, -0.867665900570));
var i, j: Integer;
    sl: TStringList;
    line: TLine;
    autoNr: Boolean;
    AppDataPath: Array[0..MaxPathLen] of Char;
    ini: TIniFile;
begin
  DefaultFormatSettings.DecimalSeparator:='.';
  DefaultFormatSettings.ShortMonthNames:=ShortMonthNames;
  Modified:=0;
  if not FileExists('LemStars.ini') then begin
    SHGetSpecialFolderPath(0, AppDataPath, CSIDL_LOCAL_APPDATA, False);
    WorkingDir:=AppDataPath;
    if Copy(WorkingDir, Length(WorkingDir), 1)<>'\' then WorkingDir+='\';
    WorkingDir+='LemStars\';
    ForceDirectories(WorkingDir);
  end;
  ini:=TIniFile.Create(WorkingDir+'LemStars.ini');
  FStarDir:=ini.ReadString('stars', 'dir', '');
  if not DirectoryExists(FStarDir) then begin
    SelectDirectory('Choose location of star databases', '', FStarDir);
    ini.WriteString('stars', 'dir', FStarDir);
  end;
  if Copy(FStarDir, Length(FStarDir), 1)<>'\' then FStarDir+='\';
  FStarList:=TList.Create;
  for i:=1 to 2 do LoadStars(StarList, AboutStrings[i], FStarDir+StarFiles[i]);
  for i:=0 to StarCount-1 do Star[i].P:=glx*Star[i].P;
  FLemConstells:=TStringList.Create;
  try LemConstells.LoadFromFile(WorkingDir+'ConstellList.txt') except end;
  if (LemConstells.Count>0) and (Pos('¤¤¤', LemConstells[0])=0) then for i:=0 to LemConstells.Count-1 do
    LemConstells[i]:=StringReplace(LemConstells[i], '¤', '¤¤', []);
  if LemConstells.Count=0 then LemConstells.Add(ListOfConstells);
  AssignConstells(ConstellCombo.Items, True);
  sl:=TStringList.Create;
  try sl.LoadFromFile(WorkingDir+'LemStars.txt') except end;
  autoNr:=False;
  for i:=0 to sl.Count-1 do begin
    j:=StrToIntDef(Copy(sl[i], 1, Pos('|', sl[i])-1), MaxInt);
    if sl[i]='' then autoNr:=True else if StarList.Count>j then with Star[j] do begin
      LemNr:=StrToInt64(Copy(sl[i], Pos('|', sl[i])+1, Pos(',', sl[i])-1-Pos('|', sl[i])));
      LemConstell:=StrToInt(Copy(sl[i], Pos(',', sl[i])+1, 255));
      if LemConstell=99 then AutoNumbered:=False else AutoNumbered:=autoNr;
    end;
  end;
  sl.Clear;
  FLinesList:=TList.Create;
  try sl.LoadFromFile(WorkingDir+'LemLines.txt') except end;
  for i:=0 to sl.Count-1 do begin
    j:=StrToIntDef(Copy(sl[i], 4, 255), MaxInt);
    if StarList.Count>j then begin
      line:=TLine.Create;
      line.LemConstell:=StrToInt(Copy(sl[i], 1, 2));
      line.LineTo:=Copy(sl[i], 3, 1)='|';
      line.Star:=Star[j];
      LinesList.Add(line);
    end;
  end;
  sl.Free;
  WindowState:=TWindowState(ini.ReadInteger('win', 'state', Ord(wsNormal)));
  if WindowState<>wsMaximized then WindowState:=wsNormal;
  if WindowState=wsNormal then begin
    Left:=ini.ReadInteger('win', 'left', 10);
    Top:=ini.ReadInteger('win', 'top', 10);
    Width:=ini.ReadInteger('win', 'width', Screen.Width-30);
    Height:=ini.ReadInteger('win', 'height', Screen.Height-40);
  end;
  alpha0:=ini.ReadFloat('main', 'alpha', 0);
  delta0:=ini.ReadFloat('main', 'delta', 0);
  Zoom:=ini.ReadFloat('main', 'zoom', CutoffZoom/3);
  ConstellCombo.ItemIndex:=Max(Min(ini.ReadInteger('main', 'constell', 0), ConstellCombo.Items.Count-1), 0);
  ConstellComboChange(nil);
  MilkyItem.Checked:=ini.ReadBool('main', 'milky', True);
  ConstellNamesItem.Checked:=ini.ReadBool('main', 'constells', True);
  ConstellLinesItem.Checked:=ini.ReadBool('main', 'lines', True);
  GridItem.Checked:=ini.ReadBool('main', 'grid', True);
  SouthUpItem.Checked:=ini.ReadBool('main', 'south', False);
  MannumberedItem.Checked:=ini.ReadBool('main', 'mannumbered', False);
  UnnumberedItem.Checked:=ini.ReadBool('main', 'unnumbered', False);
  DimOtherItem.Checked:=ini.ReadBool('main', 'hideother', True);
  DistinguishItem.Checked:=ini.ReadBool('main', 'distinguish', True);
  BlinkItem.Checked:=ini.ReadBool('main', 'blink', False);
  if BlinkItem.Checked then BlinkTimer.Enabled:=True;
  TMenuItem(FindComponent('Numbers'+IntToStr(Max(Min(ini.ReadInteger('main', 'numbers', 1), 2), 0)))).Checked:=True;
  ActionRot.Checked:=ini.ReadBool('main', 'rot', False);
  if ActionRot.Checked then RotTimer.Enabled:=True;
  ConstellSearch:=ini.ReadString('constell', 'search', '');
  ConstellSearchAll:=ini.ReadBool('constell', 'searchall', True);
  LinesOpacity:=ini.ReadInteger('lines', 'opacity', 255);
  HideZeroesInStat:=ini.ReadBool('stat', 'hide-0s', False);
  ViewBox.Left:=ini.ReadInteger('view', 'x', ToolButtonView.Left);
  ViewBox.Top:=ini.ReadInteger('view', 'y', 2*ToolButtonCenter.Width);
  FindBox.Left:=ini.ReadInteger('find', 'x', 1);
  FindBox.Top:=ini.ReadInteger('find', 'y', 2*ToolButtonCenter.Width);
  FindBox.Right:=ini.ReadInteger('find', 'w', 3*ConstellCombo.Width div 2);
  FindBox.Bottom:=ini.ReadInteger('find', 'h', 2*ConstellCombo.Width);
  BrightnessConvM:=ini.ReadFloat('brightness', 'm', 0);
  BrightnessConvCI:=ini.ReadFloat('brightness', 'CI', 0);
  ToolsBox.Left:=ini.ReadInteger('tools', 'x', ToolButtonTools.Left);
  ToolsBox.Top:=ini.ReadInteger('tools', 'y', 2*ToolButtonCenter.Width);
  ToolsBox.Right:=ini.ReadInteger('tools', 'w', 2*Screen.Width div 5);
  ToolsBox.Bottom:=ini.ReadInteger('tools', 'h', Screen.Height div 2);
  ToolsBoxPage:=ini.ReadInteger('tools', 'page', 0);
  ToolsBoxLock:=ini.ReadBool('tools', 'lock', True);
  UploadBackups:=ini.ReadBool('upload', 'do', False);
  UploadJS:=ini.ReadBool('upload', 'javascript', False);
  with ExecProcess do if ini.ReadBool('upload', 'show', False) then ShowWindow:=swoShow else ShowWindow:=swoHide;
  HostName:=ini.ReadString('upload', 'host', '');
  UserName:=ini.ReadString('upload', 'user', '');
  Password:=DecryptPwd(ini.ReadString('upload', 'password', ''), 34960119);
  UploadPath:=ini.ReadString('upload', 'path', '');
  ini.Free;
  OpenGLBoxResize(nil);
  OpenGLBox.Invalidate;
  NotifyLabel.Hide;
end;

function TMainForm.SaveText: string;
begin
  if Modified=0 then Result:='Nothing needs to be saved.' else begin
    Result:='Save changes to '+IfThen(Modified and $1 >0, 'constellations'+IfThen((Modified and $2 >0) and (Modified and $1C >0), ', ', ' and '))
      +IfThen(Modified and $2 >0, 'constellation lines and ')+IfThen(Modified and $1C >0, 'star numbers and ');
    Result:=Copy(Result, 1, Length(Result)-5);
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var i: Integer;
    ini: TIniFile;
begin
  if Modified>0 then case MessageDlg(SaveText+'?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: SaveStars;
    mrCancel: CloseAction:=caNone;
  end;
  if CloseAction=caFree then begin
    HighlightStar:=nil;
    ini:=TIniFile.Create(WorkingDir+'LemStars.ini');
    ini.WriteInteger('win', 'state', Ord(WindowState));
    if WindowState=wsNormal then begin
      ini.WriteInteger('win', 'left', Left);
      ini.WriteInteger('win', 'top', Top);
      ini.WriteInteger('win', 'width', Width);
      ini.WriteInteger('win', 'height', Height);
    end;
    ini.WriteFloat('main', 'alpha', alpha0);
    ini.WriteFloat('main', 'delta', delta0);
    ini.WriteFloat('main', 'zoom', Zoom);
    ini.WriteInteger('main', 'constell', ConstellCombo.ItemIndex);
    ini.WriteBool('main', 'milky', MilkyItem.Checked);
    ini.WriteBool('main', 'constells', ConstellNamesItem.Checked);
    ini.WriteBool('main', 'lines', ConstellLinesItem.Checked);
    ini.WriteBool('main', 'grid', GridItem.Checked);
    ini.WriteBool('main', 'south', SouthUpItem.Checked);
    ini.WriteBool('main', 'mannumbered', MannumberedItem.Checked);
    ini.WriteBool('main', 'unnumbered', UnnumberedItem.Checked);
    ini.WriteBool('main', 'hideother', DimOtherItem.Checked);
    ini.WriteBool('main', 'distinguish', DistinguishItem.Checked);
    ini.WriteBool('main', 'blink', BlinkItem.Checked);
    ini.WriteInteger('main', 'numbers', Ord(Numbers1.Checked)+2*Ord(Numbers2.Checked));
    ini.WriteBool('main', 'rot', ActionRot.Checked);
    ini.WriteString('constell', 'search', ConstellSearch);
    ini.WriteBool('constell', 'searchall', ConstellSearchAll);
    ini.WriteInteger('lines', 'opacity', LinesOpacity);
    ini.WriteBool('stat', 'hide-0s', HideZeroesInStat);
    if ViewBox.Left=-1000 then begin
      ini.WriteInteger('view', 'x', ViewForm.Left);
      ini.WriteInteger('view', 'y', ViewForm.Top);
    end;
    if FindBox.Left=-1000 then begin
      ini.WriteInteger('find', 'x', FindForm.Left);
      ini.WriteInteger('find', 'y', FindForm.Top);
      ini.WriteInteger('find', 'w', FindForm.Width);
      ini.WriteInteger('find', 'h', FindForm.Height);
    end;
    ini.WriteFloat('brightness', 'm', BrightnessConvM);
    ini.WriteFloat('brightness', 'CI', BrightnessConvCI);
    if ToolsBox.Left=-1000 then begin
      ini.WriteInteger('tools', 'x', ToolsForm.Left);
      ini.WriteInteger('tools', 'y', ToolsForm.Top);
      ini.WriteInteger('tools', 'w', ToolsForm.Width);
      ini.WriteInteger('tools', 'h', ToolsForm.Height);
      ini.WriteInteger('tools', 'page', ToolsForm.PageControl.ActivePage.PageIndex);
      ini.WriteBool('tools', 'lock', ToolsForm.LockButton.Down);
    end;
    ini.WriteBool('upload', 'do', UploadBackups);
    ini.WriteBool('upload', 'javascript', UploadJS);
    ini.WriteBool('upload', 'show', ExecProcess.ShowWindow=swoShow);
    ini.WriteString('upload', 'host', HostName);
    ini.WriteString('upload', 'user', UserName);
    ini.WriteString('upload', 'password', EncryptPwd(Password, 34960119));
    ini.WriteString('upload', 'path', UploadPath);
    ini.Free;
    OpenGLBox.OnPaint:=nil;
    for i:=StarCount-1 downto 0 do Star[i].Free;
    StarList.Free;
    LemConstells.Free;
    for i:=0 to LinesList.Count-1 do TLine(LinesList[i]).Free;
    LinesList.Free;
    glDeleteTextures(2, @TexIds);
  end;
end;

procedure TMainForm.StarsAt(Strings: TStrings; X, Y: Integer; BayAndFlam: Boolean=True; LemAlso: Boolean=False);
var i, j: Integer;
    m: array[0..15] of Single;
    rot: TTensor;
    base: TVector;
begin
  glGetFloatV(GL_Modelview_Matrix, @m);
  rot:=Inv(Tens(m[0], m[1], m[2],   m[4], m[5], m[6],   m[8], m[9], m[10]));
  base:=rot*Vect(2*X-OpenGLBox.Width, OpenGLBox.Height-2*Y, 0)/(Zoom*360/pi);
  for i:=StarCount-1 downto 1 do with Star[i] do if BrightEnough and (Angle(P-base, Col(rot, 3))<0.3/Zoom) then
    with Strings do for j:=0 to Count do if (j=Count) or (Lmag>TStar(Objects[j]).Lmag) then begin
      InsertObject(j, WriteName(BayAndFlam)+IfThen(LemAlso, ' • '+WriteLemName
        +'  ‖  mᵣ = '+WriteMag+' • mʟ = '+FloatToStrF(Lmag, ffFixed, 4, 2)), Star[i]);
      Break;
    end;
end;

procedure TMainForm.ApplicationPropertiesShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);
var sl: TStringList;
begin
  with HintInfo do if HintControl=OpenGLBox then begin
    with CursorPos do CursorRect:=Rect(X, Y, X+1, Y+1);
    sl:=TStringList.Create;
    StarsAt(sl, CursorPos.X, CursorPos.Y, False, True);
    HintStr:=sl.Text;
    Delete(HintStr, Length(HintStr)-1, 2);
    if sl.Count>0 then with TStar(sl.Objects[0]) do HintColor:=RGBtoColor(ColorR, ColorG, ColorB);
    sl.Free;
  end else if HintControl=ToolButtonSave then HintStr:=SaveText+' ('+ShortcutToText(ActionSave.ShortCut)+')';
end;

procedure TMainForm.SaveStars;
var i, p, q, sc: Integer;
    st, size: string;
    sl, php: TStringList;
    t: TDateTime;
    ci: TConstellInfo;
    starIds: array of Integer;
begin
  DefaultFormatSettings.DecimalSeparator:='.';
  sl:=TStringList.Create;
  php:=TStringList.Create;
  if Modified and $1 >0 then begin
    DeleteFile('ConstellList Backup.txt');
    RenameFile('ConstellList.txt', 'ConstellList Backup.txt');
    LemConstells.SaveToFile(WorkingDir+'ConstellList.txt');
  end;
  if Modified and $1C >0 then begin
    DeleteFile('LemStars Backup.txt');
    RenameFile('LemStars.txt', 'LemStars Backup.txt');
    for i:=1 to StarCount-1 do if not Star[i].AutoNumbered and ((Star[i].LemNr>0) or (Star[i].LemConstell>0)) then
      sl.Add(IntToStr(i)+'|'+IntToStr(Star[i].LemNr)+','+IntToStr(Star[i].LemConstell));
    sl.Add('');
    for i:=1 to StarCount-1 do if Star[i].AutoNumbered and ((Star[i].LemNr>0) or (Star[i].LemConstell>0)) then
      sl.Add(IntToStr(i)+'|'+IntToStr(Star[i].LemNr)+','+IntToStr(Star[i].LemConstell));
    sl.SaveToFile(WorkingDir+'LemStars.txt');
    sl.Clear;
  end;
  if Modified and $2 >0 then begin
    DeleteFile('LemLines Backup.txt');
    RenameFile('LemLines.txt', 'LemLines Backup.txt');
    for i:=0 to LinesList.Count-1 do begin
      st:=FormatFloat('00', TLine(LinesList[i]).LemConstell);
      if TLine(LinesList[i]).LineTo then st:=st+'|' else st:=st+'.';
      st:=st+IntToStr(StarList.IndexOf(TLine(LinesList[i]).Star));
      sl.Add(st);
    end;
    sl.SaveToFile(WorkingDir+'LemLines.txt');
  end;
  if UploadBackups or UploadJS then begin
    sl.Clear;
    sl.Add('ftp -s:upload.bat');
    sl.Add('goto done');
    sl.Add('open "'+HostName+'"');
    sl.Add(UserName);
    sl.Add(Password);
    st:=StringReplace(UploadPath, '/', '\', [rfReplaceAll])+IfThen(Copy(st, Length(st), 1)<>'\', '\');
    repeat
      p:=Pos('\', st);
      if p>0 then begin
        sl.Add('cd "'+Copy(st, 1, p-1)+'"');
        st:=Copy(st, p+1, 20000);
      end;
    until p=0;
    sl.Add('ascii');
    if UploadBackups then begin
      sl.Add('put "ConstellList.txt"');
      sl.Add('put "LemStars.txt"');
      sl.Add('put "LemLines.txt"');
    end;
    if UploadJS then begin
      sc:=0;
      SetLength(starIds, StarCount);
      for i:=0 to LinesList.Count-1 do with TLine(LinesList[i]) do starIds[StarList.IndexOf(Star)]:=-2;
      for i:=1 to StarCount-1 do with Star[i] do if (BrightEnough and (LemConstell<99)) or (starIds[i]=-2) then begin
        starIds[i]:=sc;
        Inc(sc);
      end else starIds[i]:=-1;
      {ConstellList}
      php.Add('<?php');
      php.Add('$modified = '''+FormatDateTime('d mmm yyyy', Now)+''';');
      php.Add('$starCount = '+IntToStr(sc)+';');
      php.Add('$constells = [');
      with LemConstells do for i:=1 to Count-1 do begin
        ci:=SplitConstellStr(StringReplace(Strings[i], '''', '’', [rfReplaceAll]), False);
        q:=1;
        repeat
          p:=PosEx('{{#', ci[4], q);
          if p>0 then begin
            q:=PosEx('|', ci[4], p+2);
            if q>0 then ci[4]:=Copy(ci[4], 1, p+1)+IntToStr(starIds[StrToIntDef(Copy(ci[4], p+3, q-p-3), 0)])+Copy(ci[4], q, MaxInt);
          end;
        until p=0;
        php.Add('['''+ci[0]+''','''+ci[1]+''','''+ci[2]+''','''+ci[3]+''','''+ci[4]+'''],');
      end;
      php.Add(']; ?>');
      try php.SaveToFile(WorkingDir+'constelllist.php') except end;
      sl.Add('put "constelllist.php"');
      {Star Database (can be changed from Star data checking tool)}
      php.Clear;
      php.Add('<?php');
      php.Add('$stars = [');
      for i:=1 to StarCount-1 do if starIds[i]>-1 then with Star[i] do php.Add(FloatToStrF(P[1], ffFixed, 1, 4)+','
                                                                              +FloatToStrF(P[2], ffFixed, 1, 4)+','
                                                                              +FloatToStrF(P[3], ffFixed, 1, 4)+',');
      php.Add('];');
      php.Add('$starColors = [');
      for i:=1 to StarCount-1 do if starIds[i]>-1 then with Star[i] do php.Add(IntToStr(ColorR)+','+IntToStr(ColorG)+','+IntToStr(ColorB)+',');
      php.Add('];');
      php.Add('$starSizes = [');
      for i:=1 to StarCount-1 do if starIds[i]>-1 then with Star[i] do begin
        size:=FloatToStrF(mag, ffFixed, 1, 2);
        if size='4.01' then size:=FloatToStrF(mag, ffFixed, 1, 5);
        php.Add(size+',');
      end;
      php.Add('];');
      php.Add('$starNames = [');
      for i:=1 to StarCount-1 do if starIds[i]>-1 then with Star[i] do php.Add(''''+WriteName(True, False, False)+''',');
      php.Add('];');
      {LemStars}
      php.Add('$starLemConstells = [');
      for i:=1 to StarCount-1 do if starIds[i]>-1 then with Star[i] do php.Add(IntToStr(LemConstell)+',');
      php.Add('];');
      php.Add('$starLemNumbers = [');
      for i:=1 to StarCount-1 do if starIds[i]>-1 then with Star[i] do php.Add(IntToStr(LemNr)+',');
      php.Add('];');
      {LemLines}
      php.Add('$constellLines = [');
      for i:=0 to LinesList.Count-1 do with TLine(LinesList[i]) do php.Add(IntToStr(starIds[StarList.IndexOf(Star)])+','+IntToStr(Ord(LineTo))+',');
      php.Add(']; ?>');
      try php.SaveToFile(WorkingDir+'stardata.php') except end;
      sl.Add('put "stardata.php"');
    end;
    sl.Add('bye');
    sl.Add(':done');
    sl.Add('del upload.bat');
    //sl.Add('del constelllist.php');   // doesn't delete anyway
    //sl.Add('del stardata.php');   // doesn't delete anyway
    t:=Now;
    repeat i:=FileCreate('upload.bat') until (i>-1) or (Now>t+0.001);
    FileClose(i);
    try sl.SaveToFile(WorkingDir+'upload.bat') except end;
    ExecProcess.Execute;
  end;
  sl.Free;
  php.Free;
  Modified:=0;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var a: Integer;
begin
  if (Shift-[ssAlt]=[ssShift]) and (Key in [VK_Left, VK_Right, VK_Up, VK_Down]) then begin
    if ssAlt in Shift then a:=1 else a:=10;
    case Key of
      VK_Left:  alpha0:=alpha0+a/480*pi;
      VK_Right: alpha0:=alpha0-a/480*pi;
      VK_Up:    delta0:=delta0+a/360*pi;
      VK_Down:  delta0:=delta0-a/360*pi;
    end;
    NotifyLabel.Caption:='Centre: '+CoordsToStr(alpha0, delta0);
    NotifyLabel.Show;
    MoveTimer.Enabled:=False;
    Key:=0;
  end else if (Shift-[ssAlt]=[ssCtrl]) and (Key in [VK_Up, VK_Down]) then begin
    Zoom:=Zoom*Exp((2*Ord(Key=VK_Up)-1)/IfThen(ssAlt in Shift, 100, 10));
    NotifyLabel.Caption:='Zoom: '+ZoomToStr(Zoom);
    NotifyLabel.Show;
    ZoomTimer.Enabled:=False;
    OpenGLBoxResize(nil);
    Key:=0;
  end else if (Shift=[ssAlt]) and (Key in [VK_M, VK_N, VK_L, VK_G, VK_S, VK_0..VK_2, VK_A, VK_U, VK_O, VK_D, VK_B, VK_I, VK_J]) then begin
    case Key of
      VK_M: ViewOptsClick(MilkyItem);
      VK_N: ViewOptsClick(ConstellNamesItem);
      VK_L: ViewOptsClick(ConstellLinesItem);
      VK_G: ViewOptsClick(GridItem);
      VK_S: ViewOptsClick(SouthUpItem);
      VK_0..VK_2: StarNrsClick(FindComponent('Numbers'+IntToStr(Key-VK_0)));
      VK_A: ViewOptsClick(MannumberedItem);
      VK_U: ViewOptsClick(UnnumberedItem);
      VK_O: ViewOptsClick(DimOtherItem);
      VK_D: ViewOptsClick(DistinguishItem);
      VK_B: ViewOptsClick(BlinkItem);
      VK_I: ImageSettingsItemClick(ImageSettingsItem);
      VK_J: ImageSettingsItemClick(ImageOverviewItem);
    end;
    Key:=0;
  end else if (Shift=[]) and (Key in [VK_0, VK_Numpad0]) then begin
    ConstellCombo.ItemIndex:=0;
    ConstellComboChange(nil);
  end else if (Shift=[]) and (Key=VK_Escape) then HighlightStar:=nil;
end;

procedure TMainForm.OpenGLBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  OldX:=X;
  OldY:=Y;
  MouseMoved:=False;
  NotifyLabel.Hide;
end;

procedure TMainForm.OpenGLBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var h: Boolean;
begin
  h:=False;
  if ssLeft in Shift then
    if ssCtrl in Shift then OpenGLBoxMouseWheel(Sender, Shift-[ssLeft, ssCtrl], 3*(OldY-Y), Point(X, Y), h) else begin
      alpha0:=alpha0+(X-OldX)/IfThen(ssAlt in Shift, 520, 52)/Zoom;
      delta0:=delta0+(Y-OldY)/IfThen(ssAlt in Shift, 520, 52)/Zoom;
      NotifyLabel.Caption:='Centre: '+CoordsToStr(alpha0, delta0);
      NotifyLabel.Show;
      MoveTimer.Enabled:=False;
    end;
  OldX:=X;
  OldY:=Y;
  MouseMoved:=True;
  if Shift=[] then NotifyLabel.Hide;
end;

procedure TMainForm.OpenGLBoxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button=mbLeft) and not MouseMoved then begin
    InfoForm.StarCombo.Items.Clear;
    StarsAt(InfoForm.StarCombo.Items, X, Y);
    with InfoForm do if StarCombo.Items.Count>0 then begin
      StarCombo.ItemIndex:=0;
      StarComboChange(nil);
      ShowModalPos(Mouse.CursorPos);
    end;
  end else if Button=mbRight then with ViewPopup do begin
    PopupComponent:=OpenGLBox;
    PopUp;
  end;
end;

procedure TMainForm.OpenGLBoxMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Zoom:=Zoom*Exp(WheelDelta/IfThen(ssAlt in Shift, 20000, 2000));
  NotifyLabel.Caption:='Zoom: '+ZoomToStr(Zoom);
  NotifyLabel.Show;
  ZoomTimer.Enabled:=False;
  OpenGLBoxResize(nil);
end;

{----------------------------------------------Draw-------------------------------------------------------------}

function TMainForm.InitOpenGL: Boolean;
var i, j, t: Integer;
    p: Pointer;
    tex: array[0..$200000] of GLuint;
begin
  Result:=OpenGLBox.MakeCurrent;
  if Result and not OpenGLInitialised then begin
    glEnable(GL_Point_Smooth);
    glHint(GL_Point_Smooth_Hint, GL_Nicest);
    glEnable(GL_Line_Smooth);
    glHint(GL_Line_Smooth_Hint, GL_Nicest);
    glLineWidth(1.2);
    glEnable(GL_Blend);
    glBlendFunc(GL_Src_Alpha, GL_One_Minus_Src_Alpha);
    glGenTextures(2, @TexIds);
    for t:=texMilky to texFont do begin
      glBindTexture(GL_Texture_2D, TexIds[t]);
      glTexParameterI(GL_Texture_2D, GL_Texture_Min_Filter, GL_Linear);
      glTexParameterI(GL_Texture_2D, GL_Texture_Mag_Filter, GL_Linear);
      if t=texMilky then for j:=0 to $3FF do begin
        p:=MilkyImage.Picture.Bitmap.ScanLine[j];
        for i:=0 to $7FF do tex[$400*i+j]:=LongWord((p+4*i)^) or $FF000000;
      end else for i:=0 to $FF do for j:=0 to $FF do tex[$100*i+j]:=($FF-Red(FontImage.Picture.Bitmap.Canvas.Pixels[i, j]))*$1000000+$00FFFFFF;
      glTexImage2D(GL_Texture_2D, 0, GL_RGBA, IfThen(t=texMilky, $400, $100), IfThen(t=texMilky, $800, $100), 0, GL_RGBA, GL_Unsigned_Byte, @tex);
    end;
    MilkyImage.Picture.Clear;
    FontImage .Picture.Clear;
    OpenGLInitialised:=True;
    OpenGLBoxResize(OpenGLBox);
  end;
end;

procedure TMainForm.OpenGLBoxPaint(Sender: TObject);
  procedure glVertexLDeg(r, alpha, delta: Single);
  begin
    alpha:=alpha/384*pi;
    delta:=delta/384*pi;
    glVertex3F(r*sin(alpha)*cos(delta), r*sin(delta), r*cos(alpha)*cos(delta));
  end;
const tilt = 0.4090465;
      fontsizes: array[1..2] of Single = (0.65, 0.475);
var i, j, k, l: Integer;
    hidesmall: Boolean;
    x, z, ma: Single;
    c, d: array['0'..'G'] of Single;
    s, t: array[1..2] of Single;
    m: array[0..15] of Single;
    ns: TList;
    st: string;
begin
  if InitOpenGL then begin
    glMatrixMode(gl_ModelView);
    glClearColor(0, 0, 0, 1);
    glClear(GL_Color_Buffer_Bit or GL_Depth_Buffer_Bit);
    glLoadIdentity;
    glTranslateF(0, 0, -2);
    glRotateF(delta0/pi*180, 1, 0, 0);
    glRotateF(alpha0/pi*180, 0, 1, 0);
    if SouthUpItem.Checked then glScaleF(-1, -1, 1);
    z:=Sqrt(Zoom/11);
    {Milky Way}
    if MilkyItem.Checked then begin
      glColor4F(1, 1, 1, 1/Zoom+0.45);
      glBindTexture(GL_Texture_2D, TexIds[texMilky]);
      glEnable(GL_Texture_2D);
      for i:=7 downto -8 do begin
        glBegin(GL_Quad_Strip);
          for j:=0 to 64 do begin
            glTexCoord2F((7-i)/16, j/64+0.25);  glVertexLDeg(1, 12*j, 24*(i+1));
            glTexCoord2F((8-i)/16, j/64+0.25);  glVertexLDeg(1, 12*j, 24* i   );
          end;
        glEnd;
      end;
      glDisable(GL_Texture_2D);
    end;
    {Grid}
    glColor3F(0.6, 0.3, 0.15);
    glBegin(GL_Lines);
      if GridItem.Checked then for i:=-192 to 192 do glVertex3F(sin(i/192*pi)*cos(tilt), -sin(i/192*pi)*sin(tilt), cos(i/192*pi));
    glEnd;
    if GridItem.Checked then for i:=0 to 15 do begin
      if i<>0 then glColor3F(0.5, 0.5, 0.5) else glColor3F(1, 1, 1);
      glBegin(GL_Line_Strip);
        for j:=-46 to 46 do glVertexLDeg(1, 48*i, 4*j);
      glEnd;
    end;
    if GridItem.Checked then for i:=-3 to 3 do begin
      if i<>0 then glColor3F(0.5, 0.5, 0.5) else glColor3F(1, 1, 1);
      glBegin(GL_Line_Strip);
        for j:=-48 to 48 do glVertexLDeg(1, 8*j, 48*i);
      glEnd;
    end;
    {Constellation lines}
    glBegin(GL_Line_Strip);
    if ConstellLinesItem.Checked then for i:=0 to LinesList.Count-1 do with TLine(LinesList[i]) do begin
      if not LineTo then begin
        glEnd;
        glBegin(GL_Line_Strip);
      end;
      glColor4F(0.25, 0.64, 0.47, (2*Ord(not DimOtherItem.Checked or IsActiveLemConstell(Star.LemConstell))+1)/3);
      glVertex3F(Star.P[1], Star.P[2], Star.P[3]);
    end;
    glEnd;
    if Assigned(LinesForm) then begin
      glColor3F(1, 0.5, 0.5);
      glBegin(GL_Line_Strip);
      for i:=0 to LinesForm.LinesListBox.Items.Count-1 do with TLine(LinesForm.LinesListBox.Items.Objects[i]) do begin
        if not LineTo then begin
          glEnd;
          glBegin(GL_Line_Strip);
        end;
        glVertex3F(Star.P[1], Star.P[2], Star.P[3]);
      end;
      glEnd;
    end;
    {Stars}
    for i:=1 to StarCount-1 do with Star[i] do if BrightEnough and (LemConstell<99) then begin
      glPointSize(Max(Lmag, 0.01)*z);
      glColor4F(ColorR/256, ColorG/256, ColorB/256, (3*Ord(not DimOtherItem.Checked or IsActiveLemConstell(LemConstell))+1)/4);
      glBegin(GL_Points);
        glVertex3F(P[1], P[2], P[3]);
      glEnd;
    end;
    if HighlightStar<>nil then with HighlightStar do begin
      glColor3F(0.75, 0.75, 0.75);
      glBegin(GL_Line_Strip);
        for i:=0 to 32 do glVertex3F(P[1]+sin(i*pi/16)/z/35, P[2]+cos(i*pi/16)/z/40, P[3]);
      glEnd;
      glBegin(GL_Line_Strip);
        for i:=0 to 32 do glVertex3F(P[1]+sin(i*pi/16)/z/35, P[2], P[3]+cos(i*pi/16)/z/35);
      glEnd;
      glBegin(GL_Line_Strip);
        for i:=0 to 32 do glVertex3F(P[1], P[2]+sin(i*pi/16)/z/35, P[3]+cos(i*pi/16)/z/35);
      glEnd;
    end;
    {Numbers}
    if not Numbers0.Checked then begin
      ns:=TList.Create;
      hidesmall:=Zoom<CutoffZoom;
      for i:=1 to StarCount-1 do with Star[i] do begin
        if magMax=20 then ma:=Lmag else ma:=LmagMax-2;
        if (ma>=3*Ord(hidesmall and not (((LemNr=0) or (LemConstell=0)) and UnnumberedItem.Checked)
          and not (not (AutoNumbered or (LemNr=0) or (LemConstell=0)) and MannumberedItem.Checked)))
            and IsActiveLemConstell(LemConstell) then ns.Add(Star[i]);
      end;
      if ConstellLinesItem.Checked then for i:=0 to LinesList.Count-1 do with TLine(LinesList[i]) do
        if IsActiveLemConstell(TLine(LinesList[i]).Star.LemConstell) and (ns.IndexOf(Star)=-1) then ns.Add(Star);
      for i:=$30 to $47 do begin
        c[Char(i)]:=25*(i-IfThen(i in [$30..$39], 48, 65))/$100;
        d[Char(i)]:=(60*Ord(i in [$41..$47])+120*Ord(Numbers2.Checked and (i<>$47)))/$100;
      end;
      for i:=1 to High(s) do s[i]:=fontsizes[i]/Zoom;
      for i:=1 to High(s) do t[i]:=0.25*s[i];
      glGetFloatV(GL_Modelview_Matrix, @m);
      glBindTexture(GL_Texture_2D, TexIds[texFont]);
      glEnable(GL_Texture_2D);
      glBegin(GL_Quads);
      for i:=0 to ns.Count-1 do with TStar(ns[i]) do begin
        if (LemNr=0) or (LemConstell=0) then begin
          glColor3F(1, 0.5, 0.5);
          st:='G';
        end else if LemConstell<99 then begin
          if AutoNumbered and DistinguishItem.Checked then glColor3F(0.5, 0.8, 0.8) else glColor3F(0.5, 0.5, 1);
          st:=IntToHex(LemNr, 0);
        end else st:='';
        if BlinkTimer.Enabled and (LemNr<>BlinkTimer.Tag) and (LemNr div 16<>BlinkTimer.Tag) then glColor3F(0.3, 0.3, 0.3);
        if magMax=20 then ma:=Lmag else ma:=LmagMax-2;
        l:=2-Ord(ma>=3);
        x:=ma/t[l]/exp(ln(Zoom)/3)/1000+0.15;
        for j:=0 to Length(st)-1 do for k:=0 to 1 do begin {drawing twice makes numbers clearer}
          glTexCoord2F(d[st[j+1]],         c[st[j+1]]);          glVertex3F(P[1]+s[l]*m[1]*0.3+t[l]*m[0]*(j+x),     P[2]+s[l]*m[5]*0.3+t[l]*m[4]*(j+x),     P[3]+s[l]*m[9]*0.3+t[l]*m[8]*(j+x));     {top left}
          glTexCoord2F(d[st[j+1]]+64/$100, c[st[j+1]]);          glVertex3F(P[1]-s[l]*m[1]*0.7+t[l]*m[0]*(j+x),     P[2]-s[l]*m[5]*0.7+t[l]*m[4]*(j+x),     P[3]-s[l]*m[9]*0.7+t[l]*m[8]*(j+x));     {btm left}
          glTexCoord2F(d[st[j+1]]+64/$100, c[st[j+1]]+22/$100);  glVertex3F(P[1]-s[l]*m[1]*0.7+t[l]*m[0]*(j+x+1.3), P[2]-s[l]*m[5]*0.7+t[l]*m[4]*(j+x+1.3), P[3]-s[l]*m[9]*0.7+t[l]*m[8]*(j+x+1.3)); {btm right}
          glTexCoord2F(d[st[j+1]],         c[st[j+1]]+22/$100);  glVertex3F(P[1]+s[l]*m[1]*0.3+t[l]*m[0]*(j+x+1.3), P[2]+s[l]*m[5]*0.3+t[l]*m[4]*(j+x+1.3), P[3]+s[l]*m[9]*0.3+t[l]*m[8]*(j+x+1.3)); {top right}
        end;
      end;
      glEnd;
      glDisable(GL_Texture_2D);
      ns.Free;
    end;
    {Constellation names}     // Constellation names (English/Lem je nach Display-Menü)
    {glPointSize(20);
    glBegin(GL_Points);
    if ConstellNamesItem.Checked then for i:=1 to ConstellCombo.Items.Count-1 do if IsActiveLemConstell(i) then begin
      ConstellCenter(i, calpha, cdelta);
      glVertex3F(-sin(calpha)*cos(cdelta), sin(cdelta), cos(calpha)*cos(cdelta));
    end;
    glEnd; }
    OpenGLBox.SwapBuffers;
  end;
end;

procedure TMainForm.OpenGLBoxResize(Sender: TObject);
begin
  if OpenGLInitialised and OpenGLBox.MakeCurrent then with OpenGLBox do begin
    glViewport(0, 0, Width, Height);
    glMatrixMode(GL_Projection);
    glLoadIdentity;
    glOrtho(-Width/(Zoom*360/pi), Width/(Zoom*360/pi), -Height/(Zoom*360/pi), Height/(Zoom*360/pi), 0.9, 2);
  end;
  if ViewForm<>nil then ViewForm.FormCreate(nil);
end;

{----------------------------------------------Buttons----------------------------------------------------}

procedure TMainForm.ActionSaveExecute(Sender: TObject);
begin
  SaveStars;
end;

procedure TMainForm.ConstellComboChange(Sender: TObject);
begin
  ActiveLemConstell:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
  ActionCenter.Enabled:=ConstellCombo.ItemIndex>0;
  OpenGLBox.Invalidate;
end;

procedure TMainForm.ActionCenterExecute(Sender: TObject);
var calpha, cdelta: Single;
begin
  if ConstellCombo.ItemIndex>0 then begin
    ConstellCenter(PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]), calpha, cdelta);
    MoveTo(calpha+IfThen(Sender=nil, pi/8), cdelta);
  end;
end;

procedure TMainForm.ActionZoomExecute(Sender: TObject);
begin
  ZoomTo(CutoffZoom-IfThen((Zoom>=CutoffZoom) or (Sender=ImageSettingsItem), 1/100));
end;

procedure TMainForm.ActionRotExecute(Sender: TObject);
begin
  ActionRot.Checked:=not ActionRot.Checked;
  RotTimer.Enabled:=ActionRot.Checked;
end;

procedure TMainForm.RotTimerTimer(Sender: TObject);
begin
  alpha0:=alpha0+1/72/Zoom;
end;

procedure TMainForm.ActionViewExecute(Sender: TObject);
begin
  if ViewBox.Left<>-1000 then begin
    ViewForm.Left:=ViewBox.Left;
    ViewForm.Top :=ViewBox.Top;
    ViewBox .Left:=-1000;
  end;
  ViewForm.Visible:=not ViewForm.Visible;
end;

procedure TMainForm.ViewOptsClick(Sender: TObject);
begin
  if Sender=SouthUpItem then begin
    alpha0:=-alpha0;
    delta0:=-delta0;
  end else if Sender=BlinkItem then with BlinkTimer do Enabled:=not Enabled;
  TMenuItem(Sender).Checked:=not TMenuItem(Sender).Checked;
  OpenGLBox.Invalidate;
end;

procedure TMainForm.BlinkTimerTimer(Sender: TObject);
begin
  BlinkTimer.Tag:=BlinkTimer.Tag mod 15 +1;
  OpenGLBox.Invalidate;
end;

procedure TMainForm.StarNrsClick(Sender: TObject);
begin
  if TMenuItem(Sender).Checked then Numbers0.Checked:=True else TMenuItem(Sender).Checked:=True;
  OpenGLBox.Invalidate;
end;

procedure TMainForm.ImageSettingsItemClick(Sender: TObject);
begin
  if ActionRot.Checked then ActionRotExecute(ActionRot);
  MilkyItem        .Checked:=True;
  ConstellLinesItem.Checked:=True;
  GridItem         .Checked:=True;
  SouthUpItem      .Checked:=False;
  if Sender=ImageSettingsItem then Numbers1.Checked:=True else Numbers0.Checked:=True;
  UnnumberedItem   .Checked:=False;
  DimOtherItem     .Checked:=Sender=ImageSettingsItem;
  DistinguishItem  .Checked:=False;
  BlinkItem        .Checked:=False;
  BlinkTimer       .Enabled:=False;
  ActionCenterExecute(ActionCenter);
  if Sender=ImageSettingsItem then ActionZoomExecute(Sender) else ZoomTo(CutoffZoom/5);
end;

procedure TMainForm.ViewPopupPopup(Sender: TObject);
var sl: TStringList;
    i: Integer;
begin
  SelectConstellItem .Visible:=ViewPopup.PopupComponent=OpenGLBox;
  RemoveHighlightItem.Visible:=ViewPopup.PopupComponent=OpenGLBox;
  MenuItem3          .Visible:=ViewPopup.PopupComponent=OpenGLBox;
  if ViewPopup.PopupComponent=OpenGLBox then begin
    sl:=TStringList.Create;
    StarsAt(sl, OldX, OldY);
    SelectConstellItem.Tag:=0;
    if sl.Count>0 then for i:=1 to ConstellCombo.Items.Count-1 do
      if TStar(sl.Objects[0]).LemConstell=PtrInt(ConstellCombo.Items.Objects[i]) then SelectConstellItem.Tag:=i;
    SelectConstellItem.Enabled:=(SelectConstellItem.Tag>0) or (ConstellCombo.ItemIndex>0);
    SelectConstellItem.Caption:=IfThen((ConstellCombo.ItemIndex=SelectConstellItem.Tag) or (SelectConstellItem.Tag=0), 'Uns', 'S')+'elect constellation '
      +IfThen(SelectConstellItem.Tag>0, ConstellCombo.Items[SelectConstellItem.Tag], IfThen(ConstellCombo.ItemIndex>0, ConstellCombo.Items[ConstellCombo.ItemIndex]));
    if ConstellCombo.ItemIndex=SelectConstellItem.Tag then SelectConstellItem.Tag:=0;
    sl.Free;
  end;
end;

procedure TMainForm.SelectConstellItemClick(Sender: TObject);
begin
  ConstellCombo.ItemIndex:=SelectConstellItem.Tag;
  ConstellComboChange(nil);
end;

procedure TMainForm.RemoveHighlightItemClick(Sender: TObject);
begin
  HighlightStar:=nil;
end;

procedure TMainForm.ActionImageExecute(Sender: TObject);
var bmp1, bmp2: TBitmap;
    dc: HDC;
    r: Integer;
    p, q: TPoint;
begin
  bmp1:=TBitmap.Create;
  bmp2:=TBitmap.Create;
  dc:=GetDC(0);
  bmp1.LoadFromDevice(dc);
  ReleaseDC(0, dc);
  r:=Round(Zoom*180/pi+10);
  p:=OpenGLBox.ClientToScreen(Point(Max(OpenGLBox.Width div 2 -r, 0), Max(OpenGLBox.Height div 2 -r, 0)));
  q:=Point(Min(2*r, OpenGLBox.Width), Min(2*r, OpenGLBox.Height));
  bmp2.SetSize(q.x, q.y);
  bmp2.Canvas.CopyRect(Rect(0, 0, q.x, q.y), bmp1.Canvas, Bounds(p.x, p.y, q.x, q.y));
  Clipboard.Assign(bmp2);
  bmp1.Free;
  bmp2.Free;
end;

procedure TMainForm.ActionFindExecute(Sender: TObject);
begin
  if FindBox.Left<>-1000 then begin
    FindForm.Left  :=FindBox.Left;
    FindForm.Top   :=FindBox.Top;
    FindForm.Width :=FindBox.Right;
    FindForm.Height:=FindBox.Bottom;
    FindBox.Left:=-1000;
  end;
  FindForm.Visible:=not FindForm.Visible;
end;

procedure TMainForm.ActionConstellsExecute(Sender: TObject);
var i: Integer;
begin
  Application.CreateForm(TConstellForm, ConstellForm);
  ConstellForm.ListBox.Items.Assign(LemConstells);
  ConstellForm.ListBox.ItemIndex:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
  ConstellForm.AddBtn.Enabled:=ConstellForm.ListBox.Items.Count<MaxConstells;
  ConstellForm.UpdateCaption;
  ConstellForm.FindEdit.Text:=ConstellSearch;
  ConstellForm.SearchWhat.ItemIndex:=Ord(ConstellSearchAll);
  ConstellForm.ListBoxClick(nil);
  if (ConstellForm.ShowModal=mrOK) and (Copy(ConstellForm.Caption, 1, 1)='*') then begin
    LemConstells.Assign(ConstellForm.ListBox.Items);
    AssignConstells(ConstellCombo.Items, True);
    ConstellCombo.ItemIndex:=0;
    with ConstellCombo do for i:=0 to Items.Count-1 do if PtrInt(Items.Objects[i])=ConstellForm.ListBox.ItemIndex then ItemIndex:=i;
    ConstellComboChange(nil);
    AssignConstells(InfoForm.ConstellCombo.Items);
    Modified:=Modified or $1;
  end;
  ConstellSearch:=ConstellForm.FindEdit.Text;
  ConstellSearchAll:=ConstellForm.SearchWhat.ItemIndex=1;
  ConstellForm.Free;
end;

procedure TMainForm.ApplyLines;
var i, c: Integer;
begin
  if not LinesForm.ConstellCombo.Enabled then begin
    c:=PtrInt(LinesForm.ConstellCombo.Items.Objects[LinesForm.ConstellCombo.ItemIndex]);
    i:=0;
    while (i<LinesList.Count) and (TLine(LinesList[i]).LemConstell<>c) do Inc(i);
    while (i<LinesList.Count) and (TLine(LinesList[i]).LemConstell in [0, c]) do LinesList.Delete(i);
    with LinesForm.LinesListBox.Items do for i:=0 to Count-1 do LinesList.Add(TLine.CreateFrom(TLine(Objects[i]), IfThen(i=0, c)));
    Modified:=Modified or $2;
    OpenGLBox.Invalidate;
  end;
end;

procedure TMainForm.ActionLinesExecute(Sender: TObject);
var i: Integer;
begin
  Application.CreateForm(TLinesForm, LinesForm);
  LinesForm.OpacityBar.Position:=LinesOpacity;
  if LinesForm.ShowModal=mrOK then ApplyLines;
  for i:=LinesForm.LinesListBox.Items.Count-1 downto 0 do TLine(LinesForm.LinesListBox.Items.Objects[i]).Free;
  LinesOpacity:=LinesForm.OpacityBar.Position;
  LinesForm.Free;
  LinesForm:=nil;
  HighlightStar:=nil;
  OpenGLBox.Invalidate;
end;

procedure TMainForm.ActionHideExecute(Sender: TObject);
  procedure HideStar(s: Integer);
  begin
    Star[s].LemNr:=High(Word);
    Star[s].LemConstell:=99;
    Star[s].AutoNumbered:=False;
  end;
var i, j, n: Integer;
begin
  n:=0;
  if HideTaskDialog.Execute then case HideTaskDialog.ModalResult of
    100: begin
      NotifyLabel.Show;
      for i:=1 to StarCount-1 do begin
        if Star[i].BrightEnough then for j:=i+1 to StarCount-1 do if (Star[j].BrightEnough) and (Angle(Star[i].P, Star[j].P)<=5.11326929295214e-4{1/16 Lem°}) then begin
          if (Star[i].Flamsteed+Star[i].Name='') xor (Star[j].Flamsteed+Star[j].Name='') then HideStar(IfThen(Star[i].Flamsteed+Star[i].Name='', i, j))
            else if Star[i].mag<Star[j].mag then HideStar(j) else HideStar(i);
          Inc(n);
        end;
        if i mod 100=0 then begin
          NotifyLabel.Caption:=IntToStr(i)+' stars checked for distances';
          NotifyLabel.Refresh;
        end;
      end;
      NotifyLabel.Caption:=Plural(n, 'star')+' hidden.';
    end;
    101: begin
      NotifyLabel.Show;
      for i:=1 to StarCount-1 do with Star[i] do if LemConstell=99 then begin
        LemConstell:=0;
        LemNr:=0;
        Inc(n);
      end;
      NotifyLabel.Caption:=Plural(n, 'star')+' un-hidden.';
    end;
  end;
  if n>0 then Modified:=Modified or $4;
  OpenGLBox.Invalidate;
end;

function StarSort(Star1, Star2: Pointer): Integer;
begin
  Result:=Sign(Angle(TStar(Star1).P, GuideStar.P)-Angle(TStar(Star2).P, GuideStar.P));
end;

procedure TMainForm.ActionNumberExecute(Sender: TObject);
var k, l, m: Integer;
    i, j, n, r: LongWord;
    a, b: Extended;
    base, guide, nrs: array of LongWord;
    nextsub: array of Byte;
    mandefined: array[0..15] of Boolean;
    stargroup: TList;
begin
  n:=0;
  if NumberTaskDialog.Execute then case NumberTaskDialog.ModalResult of
    100, 101: begin
      NotifyLabel.Show;
      SetLength(base,    StarCount);
      SetLength(guide,   StarCount);
      SetLength(nrs,     StarCount);
      SetLength(nextsub, StarCount);
      for i:=0 to StarCount-1 do base[i]:=0;
      for i:=0 to StarCount-1 do guide[i]:=0;
      for i:=0 to StarCount-1 do nrs[i]:=0;
      for i:=0 to StarCount-1 do nextsub[i]:=0;
      repeat
        r:=0;
        for i:=1 to StarCount-1 do if nrs[i]=0 then begin
          with Star[i] do if ((LemConstell=0) or (LemNr=0) or AutoNumbered) and BrightEnough then begin
            LemConstell:=0;
            LemNr:=0;
            a:=pi;
            for j:=1 to StarCount-1 do if (i<>j) and (Star[j].LemConstell in [1..98]) and (Star[j].LemNr>0) and
                ((Star[j].LemNr<16) or (Star[j].LemNr mod 16 = 0)) and not Star[j].AutoNumbered then begin
              b:=Angle(P, Star[j].P);
              if (b<a) and (nextsub[j]<=15) then begin
                a:=b;
                guide[i]:=j;
              end;
            end;
            with Star[guide[i]] do if LemNr<16 then base[i]:=LemNr else base[i]:=LemNr div 16;
          end else if (LemConstell in [1..98]) and (LemNr>0) and ((LemNr<16) or (LemNr mod 16 = 0)) and not AutoNumbered then begin
            guide[i]:=i;
            if LemNr<16 then base[i]:=LemNr else base[i]:=LemNr div 16;
          end;
          if i mod 1000=0 then begin
            NotifyLabel.Caption:=IntToStr(i)+' stars assigned to their guide star';
            NotifyLabel.Refresh;
          end;
        end;
        stargroup:=TList.Create;
        for i:=1 to LemConstells.Count-1 do begin
          for j:=1 to 15 do begin
            GuideStar:=nil;
            for k:=1 to StarCount-1 do if (nrs[k]=0) and (Star[guide[k]].LemConstell=i) and (base[k]=j) then begin
              stargroup.Add(Star[k]);
              if (GuideStar=nil) or (Star[guide[k]].LemNr<GuideStar.LemNr) then GuideStar:=Star[guide[k]];
            end;
            for k:=0 to 15 do mandefined[k]:=False;
            for k:=0 to stargroup.Count-1 do with TStar(stargroup[k]) do if (LemConstell in [1..98]) and (LemNr>15) and not AutoNumbered then
              mandefined[TStar(stargroup[k]).LemNr mod 16]:=True;
            stargroup.Sort(@StarSort);
            m:=nextsub[StarList.IndexOf(GuideStar)];
            for k:=0 to stargroup.Count-1 do with TStar(stargroup[k]) do if (LemConstell=0) or (LemNr=0) or AutoNumbered then begin
              l:=StarList.IndexOf(stargroup[k]);
              while mandefined[m] do Inc(m);
              if m<16 then begin
                nrs[l]:=16*base[l]+m;
                Inc(m);
                Inc(r);
              end;
            end;
            nextsub[StarList.IndexOf(GuideStar)]:=m;
            stargroup.Clear;
          end;
          NotifyLabel.Caption:='Stars in '+IntToStr(i)+' constellations numbered';
          NotifyLabel.Refresh;
        end;
        stargroup.Free;
      until (r=0) or (NumberTaskDialog.ModalResult=100);
      for i:=1 to StarCount-1 do with Star[i] do if (LemNr=0) or (LemConstell=0) then begin
        LemNr:=nrs[i];
        LemConstell:=Star[guide[i]].LemConstell;
        AutoNumbered:=True;
        Inc(n);
      end;
      NotifyLabel.Caption:=Plural(n, 'star')+' numbered.';
    end;
    102: begin
      NotifyLabel.Show;
      for i:=1 to StarCount-1 do with Star[i] do if AutoNumbered and BrightEnough and (LemConstell<99) then begin
        LemConstell:=0;
        LemNr:=0;
        Inc(n);
      end;
      NotifyLabel.Caption:=Plural(n, 'star')+' un-numbered.';
    end;
  end;
  if n>0 then Modified:=Modified or $8;
  OpenGLBox.Invalidate;
end;

procedure TMainForm.ActionStatExecute(Sender: TObject);
begin
  Application.CreateForm(TStatForm, StatForm);
  StatForm.PageControl.ActivePage:=StatForm.PageControl.Pages[TAction(Sender).Tag];
  StatForm.HideZeroesBox.Checked:=HideZeroesInStat;
  if StatForm.ShowModal=mrOK then begin
    InfoForm.TheStar:=StatForm.SelStar;
    if InfoForm.StarCombo.Items.Count>0 then InfoForm.ShowModalCenter;
  end;
  HideZeroesInStat:=StatForm.HideZeroesBox.Checked;
  StatForm.Free;
end;

procedure TMainForm.ActionToolsExecute(Sender: TObject);
begin
  if ToolsBox.Left<>-1000 then begin
    ToolsForm.Left  :=ToolsBox.Left;
    ToolsForm.Top   :=ToolsBox.Top;
    ToolsForm.Width :=ToolsBox.Right;
    ToolsForm.Height:=ToolsBox.Bottom;
    ToolsForm.PageControl.ActivePage:=ToolsForm.PageControl.Pages[ToolsBoxPage];
    ToolsForm.LockButton.Down:=ToolsBoxLock;
    ToolsBox.Left:=-1000;
  end;
  ToolsForm.Visible:=not ToolsForm.Visible;
end;

procedure TMainForm.ActionOptionsExecute(Sender: TObject);
begin
  Application.CreateForm(TOptionsForm, OptionsForm);
  OptionsForm.UploadCheckBox.Checked:=UploadBackups;
  OptionsForm.JSCheckBox.Checked:=UploadJS;
  OptionsForm.ShowWinCheckBox.Checked:=ExecProcess.ShowWindow=swoShow;
  OptionsForm.HostEdit.Text:=HostName;
  OptionsForm.UserEdit.Text:=UserName;
  OptionsForm.PasswordEdit.Text:=Password;
  OptionsForm.UploadPathEdit.Text:=UploadPath;
  with OptionsForm do if ShowModal=mrOK then begin
    UploadBackups:=UploadCheckBox.Checked;
    UploadJS:=JSCheckBox.Checked;
    with ExecProcess do if ShowWinCheckBox.Checked then ShowWindow:=swoShow else ShowWindow:=swoHide;
    HostName:=HostEdit.Text;
    UserName:=UserEdit.Text;
    Password:=PasswordEdit.Text;
    UploadPath:=UploadPathEdit.Text;
  end;
  OptionsForm.Free;
end;

procedure TMainForm.ActionBrightnessConvExecute(Sender: TObject);
begin
  Application.CreateForm(TBrightnessConvForm, BrightnessConvForm);
  if Sender is TStar then with TStar(Sender) do BrightnessConvForm.ShowModalStar(mag, ColorIndex)
    else BrightnessConvForm.ShowModalStar(BrightnessConvM, BrightnessConvCI);
  BrightnessConvM:=BrightnessConvForm.MagSpin.Value;
  BrightnessConvCI:=BrightnessConvForm.CISpin.Value;
  BrightnessConvForm.Free;
end;

procedure TMainForm.ActionAboutExecute(Sender: TObject);
begin
  Application.CreateForm(TAboutForm, AboutForm);
  AboutForm.DatabaseMemo.Text:=AboutStrings[1]+LineEnding+AboutStrings[2];
  AboutForm.ShowModal;
  AboutForm.Free;
end;

{----------------------------------------------Utilities------------------------------------------------------------------}

function TMainForm.ConstellName(Nr: Integer): string;
var p: Integer;
begin
  if (Nr>=0) and (Nr<LemConstells.Count) then begin
    p:=Pos('|', LemConstells[Nr]);
    Result:=Copy(LemConstells[Nr], 1, IfThen(p>0, p-1, MaxInt));
  end else Result:='‹hidden›';
end;

procedure TMainForm.Setalpha0(S: Single);
begin
  while S>=2*pi do S-=2*pi;
  while S<0     do S+=2*pi;
  Falpha0:=S;
  OpenGLBox.Invalidate;
  if ViewForm<>nil then ViewForm.FormCreate(nil);
end;

procedure TMainForm.Setdelta0(S: Single);
begin
  Fdelta0:=Min(Max(S, -pi/2), pi/2);
  OpenGLBox.Invalidate;
  if ViewForm<>nil then ViewForm.FormCreate(nil);
end;

procedure TMainForm.SetZoom(S: Single);
begin
  FZoom:=Min(Max(S, 1), 500);
  OpenGLBoxResize(nil);
  OpenGLBox.Invalidate;
  if ViewForm<>nil then ViewForm.FormCreate(nil);
end;

procedure TMainForm.SetModified(B: Byte);
begin
  FModified:=B;
  Caption:=IfThen(B>0, '*')+'Lemizh Stars';
end;

procedure TMainForm.SetHighlightStar(S: TStar);
begin
  FHighlightStar:=S;
  RemoveHighlightItem.Enabled:=S<>nil;
  OpenGLBox.Invalidate;
end;

function TMainForm.GetStar(Nr: Integer): TStar;
begin
  Result:=TStar(StarList[Nr]);
end;

function TMainForm.GetStarCount: Integer;
begin
  Result:=StarList.Count;
end;

function TMainForm.IsActiveLemConstell(Id: Integer): Boolean;
begin
  Result:=(Id=ActiveLemConstell) or (ActiveLemConstell=0);
end;

procedure TMainForm.AssignConstells(Strings: TStrings; NumberConstells: Boolean = False);
var i, p: Integer;
begin
  Strings.Clear;
  for i:=0 to LemConstells.Count-1 do begin
    p:=Pos('|', LemConstells[i]);
    Strings.AddObject(Copy(LemConstells[i], 1, IfThen(p>0, p-1, MaxInt)), TObject(PtrInt(i)));
  end;
end;

procedure TMainForm.ConstellCenter(LemC: Byte; out calpha, cdelta: Single);
var i, n: Integer;
    a: Single;
begin
  n:=0;
  calpha:=0;
  cdelta:=0;
  for i:=0 to StarCount-1 do with Star[i] do if BrightEnough and (LemC=LemConstell) then begin
    Inc(n);
    if alpha-calpha/n>pi then a:=-2*pi else if alpha-calpha/n<-pi then a:=2*pi else a:=0;
    calpha+=alpha+a;
    cdelta+=delta;
  end;
  if n>0 then begin
    calpha:=calpha/n;
    cdelta:=cdelta/n;
  end;
end;

procedure TMainForm.MoveTo(alpha1, delta1: Single);
begin
  Movealpha0:=alpha0;
  Movedelta0:=delta0;
  if alpha1>alpha0+pi then alpha1-=2*pi else if alpha1<alpha0-pi then alpha1+=2*pi;
  if SouthUpItem.Checked then begin
    MovealphaD:=alpha0-2*pi+alpha1;
    MovedeltaD:=delta0+delta1;
  end else begin
    MovealphaD:=alpha0-alpha1;
    MovedeltaD:=delta0-delta1;
  end;
  MoveTimer.Tag:=0;
  MoveTimer.Enabled:=True;
end;

procedure TMainForm.MoveTimerTimer(Sender: TObject);
begin
  with MoveTimer do begin
    Tag:=Tag+1;
    alpha0:=2*MovealphaD*IntPower(Tag/50, 3)-3*MovealphaD*Sqr(Tag/50)+Movealpha0;
    delta0:=2*MovedeltaD*IntPower(Tag/50, 3)-3*MovedeltaD*Sqr(Tag/50)+Movedelta0;
    if Tag=50 then Enabled:=False;
  end;
end;

procedure TMainForm.ZoomTo(Zoom1: Single);
begin
  MoveZoom0:=Zoom;
  MoveZoomD:=Zoom-Zoom1;
  ZoomTimer.Tag:=0;
  ZoomTimer.Enabled:=True;
end;

procedure TMainForm.ZoomTimerTimer(Sender: TObject);
begin
  with ZoomTimer do begin
    Tag:=Tag+1;
    Zoom:=2*MoveZoomD*IntPower(Tag/50, 3)-3*MoveZoomD*Sqr(Tag/50)+MoveZoom0;
    if Tag=50 then Enabled:=False;
  end;
end;

{
POSSIBLY:
* Find box
  + GJ subcodes
  + buggy (can’t distinguish delta/Delphini, tau/Tauri, ...)
* Colour index for blue stars (see MyUtils)
* Show constellation names in main window (English/Lem) (s.a. Menuitem in ViewPopup)
* Folder von Stars.txt, StarsAdd.txt nachträglich ändern; Folder von LemLines, ConstellList etc.
* V 4: Grenzhelligkeit flexibel, schwächere Sterne nummerieren

ARCHIVED:
* Star numbering
  + with aggressive numbering OK: Bull, Centaur, Harpy, Hunter, Ivory Tower, King, Merman, Moth, River, Sparrow, Stag, Wise One
  + manually fixed: Dragon (Hip 76957), Mechanic (Hip 70414 etc.: 17-1A), Scorpion (7), Ship (D Vel, C Vel etc.), Tortoise (Hip 35615), Witch (Hip 67953)
}

end.

