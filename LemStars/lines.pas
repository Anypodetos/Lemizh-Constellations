unit Lines;

interface

uses
  {$IFDEF WINDOWS}Windows, {$ENDIF}Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, LCLType, ExtCtrls, ComCtrls, types, Math;

type

  { TLinesForm }

  TLinesForm = class(TForm)
    ApplyButton: TBitBtn;
    Label1: TLabel;
    LinesLabel: TLabel;
    OKButton: TBitBtn;
    CancelButton: TBitBtn;
    ButtonRemove: TButton;
    ButtonDown: TButton;
    ButtonFrom: TButton;
    ButtonFromTo: TButton;
    ButtonTo: TButton;
    ButtonUp: TButton;
    ConstellCombo: TComboBox;
    ConstellListBox: TListBox;
    LinesListBox: TListBox;
    BtnPanel: TPanel;
    OpacityBar: TTrackBar;
    procedure ApplyButtonClick(Sender: TObject);
    procedure DisableCombo;
    procedure ButtonRemoveClick(Sender: TObject);
    procedure ButtonFromClick(Sender: TObject);
    procedure ButtonFromToClick(Sender: TObject);
    procedure ButtonUpClick(Sender: TObject);
    procedure ConstellComboChange(Sender: TObject);
    procedure ConstellListBoxClick(Sender: TObject);
    procedure ConstellListBoxDblClick(Sender: TObject);
    procedure ConstellListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LinesListBoxClick(Sender: TObject);
    procedure LinesListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure OpacityBarChange(Sender: TObject);
  private
  public
end;

var
  LinesForm: TLinesForm;

implementation

uses Main, Stars;

{$R *.lfm}

{ TLinesForm }

procedure TLinesForm.FormShow(Sender: TObject);
begin
  Left:=10;
  Top:=Screen.Height-Height-80;
  MainForm.AssignConstells(ConstellCombo.Items);
  ConstellCombo.ItemIndex:=MainForm.ConstellCombo.ItemIndex;
  if ConstellCombo.ItemIndex>0 then ConstellComboChange(nil);
end;

procedure TLinesForm.FormResize(Sender: TObject);
begin
  ConstellListBox.Width:=(Width-130) div 2;
  BtnPanel.Left:=ConstellListBox.Left+ConstellListBox.Width+2;
  LinesListBox.Width:=ConstellListBox.Width;
  LinesListBox.Left:=BtnPanel.Left+BtnPanel.Width+2;
  LinesLabel.Left:=LinesListBox.Left;
end;

procedure TLinesForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift=[ssAlt]) and (Key in [VK_M, VK_L, VK_G, VK_S, VK_U, VK_O, VK_D, VK_B]) then MainForm.FormKeyDown(Sender, Key, Shift);
  if (Shift=[ssAlt]) and (Key in [VK_Up, VK_Down]) then
    if Key=VK_Up then ButtonUpClick(ButtonUp) else ButtonUpClick(ButtonDown);
  if (Shift=[]) and (Key=VK_Delete) then ButtonRemoveClick(nil);
end;

procedure TLinesForm.ConstellComboChange(Sender: TObject);
var i, c: Integer;
    L: TLine;
begin
  ConstellListBox.Items.Clear;
  LinesListBox.Items.Clear;
  c:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
  if c>0 then begin
    for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do
      if LemConstell=c then ConstellListBox.Items.AddObject(WriteSortStr, MainForm.Star[i]);
    i:=0;
    while (i<MainForm.LinesList.Count) and (TLine(MainForm.LinesList[i]).LemConstell<>c) do Inc(i);
    while (i<MainForm.LinesList.Count) and (TLine(MainForm.LinesList[i]).LemConstell in [0, c]) do begin
      L:=TLine.Create;
      L.LineTo:=TLine(MainForm.LinesList[i]).LineTo;
      L.Star:=TLine(MainForm.LinesList[i]).Star;
      LinesListBox.Items.AddObject('', L);
      Inc(i);
    end;
  end;
  with ConstellListBox do if Items.Count>0 then begin
    for i:=0 to Items.Count-1 do if TStar(Items.Objects[i]).LemNr>0 then begin
      ItemIndex:=i;
      Break;
    end;
    if ItemIndex=-1 then ItemIndex:=0;
  end;
  ConstellListBoxClick(nil);
  MainForm.ConstellCombo.ItemIndex:=ConstellCombo.ItemIndex;
  MainForm.ConstellComboChange(nil);
  MainForm.ActionCenterExecute(nil);
  MainForm.ZoomTo(CutoffZoom);
  if MainForm.Numbers0.Checked then MainForm.Numbers1.Checked:=True;
  ButtonFrom  .Enabled:=ConstellListBox.ItemIndex>-1;
  ButtonTo    .Enabled:=ConstellListBox.ItemIndex>-1;
  ButtonFromTo.Enabled:=ConstellListBox.ItemIndex>-1;
  ButtonRemove.Enabled:=ConstellListBox.ItemIndex>-1;
  ButtonUp    .Enabled:=ConstellListBox.ItemIndex>-1;
  ButtonDown  .Enabled:=ConstellListBox.ItemIndex>-1;
end;

procedure TLinesForm.DisableCombo;
begin
  ConstellCombo.Enabled:=False;
  OKButton.Enabled:=True;
  ApplyButton.Enabled:=True;
end;

procedure TLinesForm.ConstellListBoxClick(Sender: TObject);
begin
  with ConstellListBox do if ItemIndex>-1 then MainForm.HighlightStar:=TStar(Items.Objects[ItemIndex]) else MainForm.HighlightStar:=nil;
end;

procedure TLinesForm.LinesListBoxClick(Sender: TObject);
begin
  with LinesListBox do if ItemIndex>-1 then MainForm.HighlightStar:=TLine(Items.Objects[ItemIndex]).Star else MainForm.HighlightStar:=nil;
end;

procedure TLinesForm.ConstellListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  ConstellListBox.Canvas.FillRect(ARect);
  with TStar(ConstellListBox.Items.Objects[Index]) do with ConstellListBox.Canvas do begin
    TextOut(ARect.Left+2, ARect.Top, WriteName(False));
    TextOut(3*ARect.Right div 5, ARect.Top, WriteLemName);
  end;
end;

procedure TLinesForm.ConstellListBoxDblClick(Sender: TObject);
begin
  if LinesListBox.Items.Count=0 then ButtonFromClick(ButtonFrom) else ButtonFromClick(ButtonTo);
end;

procedure TLinesForm.LinesListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  LinesListBox.Canvas.FillRect(ARect);
  with LinesListBox.Canvas, TLine(LinesListBox.Items.Objects[Index]) do begin
    if (LineTo and (Index=0)) or (not LineTo and ((Index=LinesListBox.Items.Count-1) or not TLine(LinesListBox.Items.Objects[Index+1]).LineTo))
      then Font.Color:=IfThen(odSelected in State, $c0c0ff, clRed);
    if LineTo then TextOut(ARect.Left+2, ARect.Top, 'to') else TextOut(ARect.Left+2, ARect.Top, 'from');
    TextOut(ARect.Left+6*TextWidth('n'), ARect.Top, Star.WriteName(False));
    TextOut(3*ARect.Right div 5, ARect.Top, Star.WriteLemName);
  end;
end;

procedure TLinesForm.ButtonFromClick(Sender: TObject);
var L: TLine;
begin
  if ConstellListBox.ItemIndex>-1 then begin
    L:=TLine.Create;
    L.LineTo:=Sender=ButtonTo;
    L.Star:=TStar(ConstellListBox.Items.Objects[ConstellListBox.ItemIndex]);
    LinesListBox.Items.AddObject('', L);
    LinesListBox.ItemIndex:=LinesListBox.Items.Count-1;
    DisableCombo;
    MainForm.OpenGLBox.Invalidate;
  end;
end;

procedure TLinesForm.ButtonFromToClick(Sender: TObject);
begin
  if LinesListBox.ItemIndex>-1 then begin
    with TLine(LinesListBox.Items.Objects[LinesListBox.ItemIndex]) do LineTo:=not LineTo;
    LinesListBox.Refresh;
    DisableCombo;
    MainForm.OpenGLBox.Invalidate;
  end;
end;

procedure TLinesForm.ButtonRemoveClick(Sender: TObject);
var i: Integer;
begin
  i:=LinesListBox.ItemIndex;
  if i>-1 then begin
    TLine(LinesListBox.Items.Objects[LinesListBox.ItemIndex]).Free;
    LinesListBox.Items.Delete(LinesListBox.ItemIndex);
    if LinesListBox.Items.Count>0 then LinesListBox.ItemIndex:=Max(i-1, 0);
    DisableCombo;
    MainForm.OpenGLBox.Invalidate;
  end;
end;

procedure TLinesForm.ButtonUpClick(Sender: TObject);
var ni: Integer;
begin
  if LinesListBox.ItemIndex>-1 then begin
    ni:=LinesListBox.ItemIndex-1+2*Ord(Sender=ButtonDown);
    if (ni>-1) and (ni<LinesListBox.Items.Count) then begin
      LinesListBox.Items.Exchange(LinesListBox.ItemIndex, ni);
      LinesListBox.ItemIndex:=ni;
      DisableCombo;
      MainForm.OpenGLBox.Invalidate;
    end;
  end;
end;

procedure TLinesForm.OpacityBarChange(Sender: TObject);
begin
  AlphaBlendValue:=OpacityBar.Position;
end;

procedure TLinesForm.ApplyButtonClick(Sender: TObject);
begin
  MainForm.ApplyLines;
end;

end.

