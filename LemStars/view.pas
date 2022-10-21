unit View;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  StdCtrls, Buttons, ExtCtrls, Clipbrd, StrUtils;

type

  { TViewForm }

  TViewForm = class(TForm)
    DeltaSpin: TFloatSpinEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    AlphaHSpin: TSpinEdit;
    AlphaMSpin: TSpinEdit;
    Label6: TLabel;
    DefZoomButton: TSpeedButton;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LemdeltaLabel: TLabel;
    LemalphaLabel: TLabel;
    rLabel: TLabel;
    CopyButton: TSpeedButton;
    ZoomSpin: TFloatSpinEdit;
    Label3: TLabel;
    procedure CopyButtonClick(Sender: TObject);
    procedure DefZoomButtonClick(Sender: TObject);
    procedure DeltaSpinChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AlphaSpinChange(Sender: TObject);
    procedure ZoomSpinChange(Sender: TObject);
  private
  public
  end;

var
  ViewForm: TViewForm;

implementation

{$R *.lfm}

uses Main;

{ TViewForm }

procedure TViewForm.FormCreate(Sender: TObject);
begin
  Tag:=1;
  with MainForm do begin
    AlphaHSpin.Value:=Int(alpha0*12/pi);
    AlphaMSpin.Value:=Round(Int(60*Frac(alpha0*12/pi+0.0001)));
    AlphaSpinChange(nil);
    DeltaSpin.Value:=delta0/pi*180;
    DeltaSpinChange(nil);
    ZoomSpin.Value:=Zoom;
    ZoomSpinChange(nil);
  end;
  Tag:=0;
end;

procedure TViewForm.AlphaSpinChange(Sender: TObject);
var a: Integer;
begin
  if Tag=0 then MainForm.alpha0:=AlphaHSpin.Value/12*pi+AlphaMSpin.Value/720*pi+0.0001;
  a:=Round((AlphaHSpin.Value+AlphaMSpin.Value/60)*32);
  LemalphaLabel.Caption:=IntToStr(a)+'ᵈᵉᶜ = '+IntToHex(a, 1)+'ʰᵉˣ';
end;

procedure TViewForm.DeltaSpinChange(Sender: TObject);
var d: Integer;
begin
  if Tag=0 then MainForm.delta0:=DeltaSpin.Value/180*pi;
  d:=Round(DeltaSpin.Value/15*32);
  LemDeltaLabel.Caption:=IfThen(d<0, '−')+IntToStr(Abs(d))+'ᵈᵉᶜ = '+IfThen(d<0, '−')+IntToHex(Abs(d), 1)+'ʰᵉˣ';
end;

procedure TViewForm.CopyButtonClick(Sender: TObject);
begin
  Clipboard.AsText:='<abbr title="right ascension">α</abbr>&nbsp;=&nbsp;'+AlphaHSpin.Text+'ʰ&nbsp;'+AlphaMSpin.Text
    +'ᵐ&nbsp;/ <abbr title="declination">δ</abbr>&nbsp;=&nbsp;'+StringReplace(DeltaSpin.Text, '-', '−', [])+'°';
end;

procedure TViewForm.ZoomSpinChange(Sender: TObject);
begin
  if Tag=0 then MainForm.Zoom:=ZoomSpin.Value;
  rLabel.Caption:='r = '+IntToStr(Round(MainForm.Zoom*180/pi))+' px';
end;

procedure TViewForm.DefZoomButtonClick(Sender: TObject);
begin
  MainForm.ActionZoomExecute(nil);
end;

end.

