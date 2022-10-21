unit brightness;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  Spin, StdCtrls, ExtCtrls, Math, StrUtils, MyUtils;

type

  { TBrightnessConvForm }

  TBrightnessConvForm = class(TForm)
    CancelBtn: TBitBtn;
    CISpin: TFloatSpinEdit;
    FaintLabel: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    DubiousLabel: TLabel;
    LMagSpin: TFloatSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GomysHexLabel: TLabel;
    LMagHexLabel: TLabel;
    MagSpin: TFloatSpinEdit;
    Label1: TLabel;
    LuxSpin: TSpinEdit;
    GomysSpin: TSpinEdit;
    ColorPanel: TPanel;
    TempSpin: TSpinEdit;
    procedure CISpinChange(Sender: TObject);
    procedure LMagSpinChange(Sender: TObject);
    procedure GomysSpinChange(Sender: TObject);
    procedure LuxSpinChange(Sender: TObject);
    procedure MagSpinChange(Sender: TObject);
    procedure TempSpinChange(Sender: TObject);
  private
    mag, nlx, lmag, gomys_12, ci: Single;
    LastUpdate, LastUpdateC: TDateTime;
    WhichUpdate, WhichUpdateC: TControl;
  public
    procedure ShowModalStar(AMag, ACI: Single);
  end;

var
  BrightnessConvForm: TBrightnessConvForm;

implementation

{$R *.lfm}

{ TBrightnessConvForm }

procedure TBrightnessConvForm.ShowModalStar(AMag, ACI: Single);
begin
  MagSpin.Value:=AMag;
  if AMag>MagSpin.MaxValue then FaintLabel.Caption:='mᵣ = '+FloatToStrF(AMag, ffFixed, 4, 2)+' is too faint for conversion';
  MagSpinChange(nil);
  LuxSpinChange(nil);
  GomysSpinChange(nil);
  LMagSpinChange(nil);
  CISpin.Value:=ACI;
  CISpinChange(nil);
  TempSpinChange(nil);
  ShowModal;
end;

procedure TBrightnessConvForm.MagSpinChange(Sender: TObject);
begin
  if LastUpdate<Now-1/864000 then begin {user input}
    WhichUpdate:=MagSpin;
    mag:=MagSpin.Value;
  end else if WhichUpdate=LuxSpin then Exit; {exit update cycle}
  LastUpdate:=Now;
  nlx:=Power(10, (-14.18-mag)/2.5 +9);
  LuxSpin.Value:=Round(nlx);
end;

procedure TBrightnessConvForm.LuxSpinChange(Sender: TObject);
begin
  if LastUpdate<Now-1/864000 then begin
    WhichUpdate:=LuxSpin;
    nlx:=LuxSpin.Value;
  end else if WhichUpdate=GomysSpin then Exit;
  LastUpdate:=Now;
  gomys_12:=nlx/226.874252e9*IntPower(16, 12);
  GomysSpin.Value:=Round(gomys_12);
end;

procedure TBrightnessConvForm.GomysSpinChange(Sender: TObject);
begin
  GomysHexLabel.Caption:=IntToHex(GomysSpin.Value, 1)+'ʰᵉˣ';
  if LastUpdate<Now-1/864000 then begin
    WhichUpdate:=GomysSpin;
    gomys_12:=GomysSpin.Value;
  end else if WhichUpdate=LMagSpin then Exit;
  LastUpdate:=Now;
  lmag:=Log2(gomys_12)-13; // old: 13.2457056;
  LMagSpin.Value:=lmag;
end;

procedure TBrightnessConvForm.LMagSpinChange(Sender: TObject);
var st: string;
begin
  st:=IfThen(LMagSpin.Value<0, '−')+IntToHex(Round(System.Abs(256*LMagSpin.Value)), 3);
  LMagHexLabel.Caption:=Copy(st, 1, Length(st)-2)+DefaultFormatSettings.DecimalSeparator+Copy(st, Length(st)-1, 2)+'ʰᵉˣ';
  if LastUpdate<Now-1/864000 then begin
    WhichUpdate:=LMagSpin;
    lmag:=LMagSpin.Value;
  end else if WhichUpdate=MagSpin then Exit;
  LastUpdate:=Now;
  mag:=(8.33227477-lmag)/1.32877124;
  MagSpin.Value:=mag;
end;

procedure TBrightnessConvForm.CISpinChange(Sender: TObject);
begin
  ColorPanel.Color:=RGBtoColor(CItoRed(CISpin.Value), CItoGreen(CISpin.Value), CItoBlue(CISpin.Value));
  DubiousLabel.Visible:=CISpin.Value<0;
  if LastUpdateC<Now-1/864000 then begin
    WhichUpdateC:=CISpin;
    ci:=CISpin.Value;
  end else if WhichUpdateC=TempSpin then Exit;
  LastUpdateC:=Now;
  TempSpin.Value:=CItoTemp(ci);
end;

procedure TBrightnessConvForm.TempSpinChange(Sender: TObject);
begin
  if LastUpdateC<Now-1/864000 then begin
    WhichUpdateC:=TempSpin;
  end else if WhichUpdateC=CISpin then Exit;
  LastUpdateC:=Now;
  ci:=TempToCI(TempSpin.Value);
  CISpin.Value:=ci;
end;

end.

