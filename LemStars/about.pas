unit About;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, LclIntf;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    BitBtn1: TBitBtn;
    DatabaseMemo: TMemo;
    LemizhImage: TImage;
    Image2: TImage;
    CompiledLabel: TLabel;
    LabelC: TLabel;
    LabelV: TLabel;
    LicenseImage: TImage;
    HelpMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure LemizhImageClick(Sender: TObject);
    procedure LicenseImageClick(Sender: TObject);
  private
  public
  end;

var
  AboutForm: TAboutForm;

implementation

uses Main {$IFDEF WINDOWS}, Windows{$ENDIF};

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.FormCreate(Sender: TObject);
{$IFDEF WINDOWS}
var Dummy: DWord;
    VerInfo: Pointer;
    VerInfoSize: DWord;
    VerValueSize: DWord;
    VerValue: PVSFixedFileInfo;
    FileName: string;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  Dummy:=0;
  FileName:=ParamStr(0);
  VerInfoSize:=GetFileVersionInfoSize(PChar(FileName), Dummy);
  if VerInfoSize>0 then begin
    GetMem(VerInfo, VerInfoSize);
    GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do LabelV.Caption:='Lemizh Stars  Version '+
      IntToStr(dwFileVersionMS shr 16)+'.'+IntToStr(dwFileVersionMS and $FFFF)+'.'+IntToStr(dwFileVersionLS shr 16);
    FreeMem(VerInfo, VerInfoSize);
  end;
  {$ENDIF}
  LabelC.Caption:='Created 2005–'+Copy(CompileDate, 3, 2)+' by';
  CompiledLabel.Caption:='Written in Free Pascal V '+{$I %FPCVERSION%}+' on Lazarus,'+LineEnding+
    'compiled on '+StringReplace(CompileDate, '/', '-', [rfReplaceAll])+' for '+{$I %FPCTARGETOS%}+'.';
end;

procedure TAboutForm.LemizhImageClick(Sender: TObject);
begin
  OpenURL('https://lemizh.conlang.org/appendix/constell.php');
end;

procedure TAboutForm.LicenseImageClick(Sender: TObject);
begin
  OpenURL('https://www.gnu.org/licenses/gpl-3.0.html');
end;

end.

