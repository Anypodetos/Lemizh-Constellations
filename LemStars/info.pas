unit Info;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Stars, Math, StrUtils;

type

  { TInfoForm }

  TInfoForm = class(TForm)
    CenterButton: TSpeedButton;
    LabelId: TLabel;
    LabelCoord: TLabel;
    LabelCI: TLabel;
    OKBtn: TBitBtn;
    BitBtn2: TBitBtn;
    Circle: TShape;
    StarCombo: TComboBox;
    ConstellCombo: TComboBox;
    GroupBox1: TGroupBox;
    HiddenCheckBox: TCheckBox;
    LabelGl: TLabel;
    LabelHD: TLabel;
    LabelHip: TLabel;
    LabelHR: TLabel;
    LabelLmag: TLabel;
    LabelMr: TLabel;
    NrEdit: TEdit;
    snlLabel: TLabel;
    StarPanel: TPanel;
    procedure CenterButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EnableCombo(AEnable: Boolean);
    procedure LabelMrClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HiddenCheckBoxClick(Sender: TObject);
    procedure NrEditChange(Sender: TObject);
    procedure StarComboChange(Sender: TObject);
  private
    procedure UpdatesnlLabel(AAutoNumbered: Boolean);
    function GetTheStar: TStar;
    procedure SetTheStar(AStar: TStar);
  public
    property TheStar: TStar read GetTheStar write SetTheStar;
    function ShowModalPos(P: TPoint): Integer;
    function ShowModalCenter: Integer;
  end;

var
  InfoForm: TInfoForm;

implementation

{$R *.lfm}

uses Main;

{ TInfoForm }

procedure TInfoForm.FormCreate(Sender: TObject);
begin
  MainForm.AssignConstells(ConstellCombo.Items);
end;

function TInfoForm.ShowModalPos(P: TPoint): Integer;
begin
  Left:=P.X+10;
  if Left>Screen.Width-Width then Left:=P.X-Width-15;
  Top:=Max(Min(P.Y-Height div 2, Screen.Height-Height-50), 0);
  Result:=ShowModal;
end;

function TInfoForm.ShowModalCenter: Integer;
begin
  Result:=ShowModalPos(Point(Screen.Width div 2, Screen.Height div 2));
end;

procedure TInfoForm.FormShow(Sender: TObject);
begin
  StarCombo.Hint:=Plural(StarCombo.Items.Count, 'star')+' in list';
  StarCombo.Enabled:=StarCombo.Items.Count>1;
  NrEdit.SelectAll;
end;

procedure TInfoForm.StarComboChange(Sender: TObject);
begin
  with TheStar do begin
    LabelId.Caption:='# '+IntToStr(MainForm.StarList.IndexOf(TheStar));
    if Hip>0 then LabelHip.Caption:='Hip '+IntToStr(Hip) else LabelHip.Caption:='–';
    if HD>0 then LabelHD.Caption:='HD '+IntToStr(HD) else LabelHD.Caption:='–';
    if HR>0 then LabelHR.Caption:='HR '+IntToStr(HR) else LabelHR.Caption:='–';
    if GJ<>'' then LabelGl.Caption:='GJ '+GJ else LabelGl.Caption:='–';
    if magMax=20 then begin
      Circle.Brush.Color:=RGBtoColor(ColorR, ColorG, ColorB);
      Circle.Pen.Color:=clBlack;
      Circle.Height:=Round(9*Lmag)+4;
    end else begin
      Circle.Brush.Color:=clBlack;
      Circle.Pen.Color:=RGBtoColor(ColorR, ColorG, ColorB);
      Circle.Height:=Round(9*LmagMax)+4;
    end;
    Circle.Width:=Circle.Height;
    Circle.Top:=(LabelCI.Top-Circle.Height) div 2;
    Circle.Left:=3*StarPanel.Width div 4-Circle.Width div 2;
    LabelCoord.Caption:=CoordsToStr(alpha, delta);
    LabelMr.Caption:='mᵣ = '+WriteMag+IfThen(magMax<20, ' (max = '+WriteMag(True)+')');
    if magMax=20 then LabelLmag.Caption:='Brightness: '+WriteLemMag(True) else
      LabelLmag.Caption:='Brightn.: '+WriteLemMag(False)+' (max '+WriteLemMag(False, True)+')';
    LabelCI.Caption:='B−V '+IfThen(ShamCI, '≈', '=')+' '+StringReplace(FloatToStrF(ColorIndex, ffFixed, 4, 2), '-', '−', [])+' • T ≈ '+IntToStr(Temp)+' K'+
      IfThen(ColorIndex<0, ' (??)');
    LabelCI.Font.Color:=Circle.Brush.Color or Circle.Pen.Color;
    HiddenCheckBox.Checked:=LemConstell=99;
    if not HiddenCheckBox.Checked then begin
      NrEdit.Text:=WriteLemNr;
      ActiveControl:=NrEdit;
      ConstellCombo.ItemIndex:=ConstellCombo.Items.IndexOf(MainForm.ConstellName(LemConstell));
    end;
    UpdatesnlLabel(AutoNumbered);
    MainForm.HighlightStar:=TheStar;
  end;
  EnableCombo(True);
end;

procedure TInfoForm.LabelMrClick(Sender: TObject);
begin
  MainForm.ActionBrightnessConvExecute(TheStar);
end;

procedure TInfoForm.NrEditChange(Sender: TObject);
begin
  if (Sender=ConstellCombo) and (ConstellCombo.ItemIndex=0) then NrEdit.Text:='?';
  UpdatesnlLabel(False);
  EnableCombo(False);
end;

procedure TInfoForm.HiddenCheckBoxClick(Sender: TObject);
begin
  NrEdit.Visible:=not HiddenCheckBox.Checked;
  ConstellCombo.Visible:=not HiddenCheckBox.Checked;
  snlLabel.Visible:=not HiddenCheckBox.Checked;
  if not HiddenCheckBox.Checked then begin
    NrEdit.Text:='?';
    ConstellCombo.ItemIndex:=0;
  end;
  EnableCombo(False);
end;

procedure TInfoForm.CenterButtonClick(Sender: TObject);
begin
  with TheStar do MainForm.MoveTo(alpha, delta);
end;

procedure TInfoForm.EnableCombo(AEnable: Boolean);
begin
  StarCombo.Enabled:=AEnable;
  OKBtn.Enabled:=not AEnable and ((NrEdit.Text='') or (NrEdit.Text='?') or (StrToIntDef('$'+NrEdit.Text, -1)>-1));
end;

procedure TInfoForm.OKBtnClick(Sender: TObject);
begin
  with TheStar do if HiddenCheckBox.Checked then begin
    LemNr:=High(Word);
    LemConstell:=99;
  end else begin
    LemNr:=StrToIntDef('$'+NrEdit.Text, 0);
    LemConstell:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
  end;
  TheStar.AutoNumbered:=False;
  MainForm.Modified:=MainForm.Modified or $10;
  MainForm.OpenGLBox.Invalidate;
end;

procedure TInfoForm.UpdatesnlLabel(AAutoNumbered: Boolean);
const snlText: array[False..True] of string = ('manually', 'automatically');
      notText: array[False..True] of string = ('too faint to be regularly', 'not');
var numbered: Boolean;
    i, n, n1, nx, c: Integer;
begin
  n:=StrToIntDef('$'+NrEdit.Text, 0);
  n1:=n;
  while n1>=16 do n1:=n1 div 16;
  nx:=0;
  numbered:=TheStar.BrightEnough and ((n1>0) or (ConstellCombo.ItemIndex>0));
  if ConstellCombo.ItemIndex>-1 then begin
    c:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
    if numbered and not AAutoNumbered then for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do
      if (LemConstell=c) and ((LemNr=n1) or (LemNr div 16 = n1)) then nx:=Max(nx, LemNr);
  end;
  snlLabel.Caption:=IfThen(numbered, snlText[AAutoNumbered], notText[TheStar.BrightEnough])+' numbered'
    +IfThen((n>0) and ((n<16) or (n mod 16 = 0)) and (nx>0) and not AAutoNumbered, ', guides up to № '+IntToHex(nx, 0), '');
  snlLabel.Font.Color:=IfThen(numbered, IfThen(AAutoNumbered, clTeal, $ff8080), clRed);
end;

function TInfoForm.GetTheStar: TStar;
begin
  with StarCombo do if ItemIndex>-1 then Result:=TStar(Items.Objects[ItemIndex]) else Result:=nil;
end;

procedure TInfoForm.SetTheStar(AStar: TStar);
begin
  StarCombo.Items.Clear;
  if AStar<>nil then begin
    StarCombo.Items.AddObject(AStar.WriteName, AStar);
    StarCombo.ItemIndex:=0;
    StarComboChange(nil);
  end;
end;

end.

