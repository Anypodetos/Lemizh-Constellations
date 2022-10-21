unit Find;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  LCLType, ExtCtrls, Buttons, LazUTF8, Math, Stars, Info, Types;

type

  { TFindForm }

  TFindForm = class(TForm)
    CenterButton: TSpeedButton;
    DecHexGroup: TRadioGroup;
    Edit: TEdit;
    ListBox: TListBox;
    Panel1: TPanel;
    InfoButton: TSpeedButton;
    MoveButton: TSpeedButton;
    Status: TStaticText;
    procedure EditChange(Sender: TObject);
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure InfoButtonClick(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
  private
  public
  end;

var
  FindForm: TFindForm;

implementation

{$R *.lfm}

uses Main;

{ TFindForm }

procedure TFindForm.EditChange(Sender: TObject);
const cats: array[1..5] of string = ('hip', 'hd', 'hr', 'gj', '#');
var i, n, h, q, cat, lemcnst: Integer;
    c: Char;
    txt, txtC, cnst: string;
begin
  ListBox.Items.Clear;
  ListBox.Items.BeginUpdate;
  txt:=LowerCase(Trim(Edit.Text));
  txtC:=txt;
  cat:=0;
  for i:=1 to Length(cats) do if Pos(cats[i], LowerCase(txtC))=1 then begin
    txtC:=Copy(txtC, Length(cats[i])+1, MaxInt);
    cat:=i;
    Break;
  end;
  lemcnst:=0;
  for i:=1 to MainForm.ConstellCombo.Items.Count-1 do begin
    q:=Pos(LowerCase(MainForm.ConstellCombo.Items[i]), txtC);
    if q>0 then begin
      txtC:=Copy(txtC, 1, q-1)+' '+Copy(txtC, q+Length(MainForm.ConstellCombo.Items[i]), MaxInt);
      lemcnst:=PtrInt(MainForm.ConstellCombo.Items.Objects[i]);
      Break;
    end;
  end;
  cnst:='';
  for i:=0 to Length(ConstellAbbrs)-1 do begin
    q:=Pos(LowerCase(ConstellNames[i]), txtC);
    if q>0 then begin
      txtC:=Copy(txtC, 1, q-1)+' '+Copy(txtC, q+Length(ConstellNames[i]), MaxInt);
      cnst:=ConstellAbbrs[i];
      Break;
    end;
    q:=Pos(LowerCase(ConstellAbbrs[i]), txtC);
    if q>0 then begin
      txtC:=Copy(txtC, 1, q-1)+' '+Copy(txtC, q+Length(ConstellAbbrs[i]), MaxInt);
      cnst:=ConstellAbbrs[i];
      Break;
    end;
  end;
  for i:=0 to 47 do txtC:=StringReplace(txtC, GreekTransc[i], GreekAlphabet[i mod 24], [rfIgnoreCase]);
  txtC:=Trim(txtC);
  if DecHexGroup.ItemIndex in [0, 2] then n:=StrToIntDef(txtC, 0) else n:=0;
  if DecHexGroup.ItemIndex in [1, 2] then h:=StrToIntDef('$'+txtC, 0) else h:=0;
  for c:='0' to '9' do txtC:=StringReplace(txtC, c, SupDigits[c], [rfReplaceAll]);
  for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do begin
    if Pos(txt, LowerCase(Name))>0 then ListBox.Items.AddObject(Name, MainForm.Star[i]);
    q:=Pos('/', Flamsteed);
    if (cat=0) and ((cnst='') or (cnst=Constell)) and (lemcnst=0) then begin
      if Pos(txtC, LowerCase(Flamsteed))=1 then ListBox.Items.AddObject(Copy(Flamsteed, 1, IfThen(q>0, q-1, MaxInt))+' '+Constell, MainForm.Star[i])
        else if StrToIntDef(Copy(Flamsteed, q+1, MaxInt), -1)=n then ListBox.Items.AddObject(IntToStr(n)+' '+Constell, MainForm.Star[i])
          else if (cnst<>'') and (txtC='') and (n=0) then ListBox.Items.AddObject(MainForm.Star[i].WriteName(False), MainForm.Star[i]);
    end;
    if (n>0) and (cnst='') and (lemcnst=0) then begin
      if (Hip=n) and (cat in [0, 1]) then ListBox.Items.AddObject('Hip '+IntToStr(n), MainForm.Star[i]);
      if (HD =n) and (cat in [0, 2]) then ListBox.Items.AddObject('HD ' +IntToStr(n), MainForm.Star[i]);
      if (HR =n) and (cat in [0, 3]) then ListBox.Items.AddObject('HR ' +IntToStr(n), MainForm.Star[i]);
      if (i  =n) and (cat in [0, 5]) then ListBox.Items.AddObject('# '  +IntToStr(n), MainForm.Star[i]);
      if (StrToIntDef(Trim(Copy(GJ, 1, 5)), 0)=n) and (cat in [0, 4]) then ListBox.Items.AddObject('GJ '+GJ, MainForm.Star[i]);
    end;
    if (cnst='') and (cat=0) and ((h>0) and (LemNr=h) and (lemcnst in [0, LemConstell]) or (lemcnst>0) and (lemcnst=LemConstell) and (h=0)) then
      ListBox.Items.AddObject(IntToHex(LemNr, 0)+' '+MainForm.ConstellName(LemConstell), MainForm.Star[i]);
  end;
  ListBox.Items.EndUpdate;
  If ListBox.Items.Count>0 then begin
    ListBox.ItemIndex:=0;
    MainForm.HighlightStar:=TStar(ListBox.Items.Objects[ListBox.ItemIndex]);
  end;
  if txt<>'' then Status.Caption:=' '+Plural(ListBox.Items.Count, 'star')+' found' else Status.Caption:='';
  MoveButton.Enabled:=ListBox.Items.Count>0;
  InfoButton.Enabled:=ListBox.Items.Count>0;
end;

procedure TFindForm.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_Up, VK_Down: if Shift=[] then with ListBox do begin
      ItemIndex:=Min(Max(ItemIndex+2*Ord(Key=VK_Down)-1, 0), Items.Count-1);
      if ItemIndex>-1 then MainForm.HighlightStar:=TStar(Items.Objects[ItemIndex]);
      Key:=0;
    end;
    VK_Return: begin
      if Shift-[ssCtrl]=[] then ListBoxClick(nil);
      if Shift=[ssCtrl] then ListBoxDblClick(nil);
    end;
  end;
end;

procedure TFindForm.ListBoxClick(Sender: TObject);
begin
  with ListBox do if ItemIndex>-1 then begin
    MainForm.HighlightStar:=TStar(Items.Objects[ItemIndex]);
    with MainForm.HighlightStar do MainForm.MoveTo(alpha, delta);
  end else MainForm.HighlightStar:=nil;
end;

procedure TFindForm.ListBoxDblClick(Sender: TObject);
var i: Integer;
begin
  if ListBox.ItemIndex>-1 then begin
    InfoForm.StarCombo.Items.Clear;
    for i:=0 to ListBox.Items.Count-1 do InfoForm.StarCombo.Items.AddObject(TStar(ListBox.Items.Objects[i]).WriteName, TStar(ListBox.Items.Objects[i]));
    InfoForm.StarCombo.ItemIndex:=ListBox.ItemIndex;
    InfoForm.StarComboChange(nil);
    InfoForm.ShowModalCenter;
  end;
end;

procedure TFindForm.InfoButtonClick(Sender: TObject);
begin
  ListBoxClick(nil);
  ListBoxDblClick(nil);
end;

procedure TFindForm.ListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  with ListBox do begin
    Canvas.FillRect(ARect);
    if not TStar(Items.Objects[Index]).BrightEnough then Canvas.Font.Color:=clSilver;
    Canvas.TextOut(ARect.Left, ARect.Top, Items[Index]);
    Canvas.TextOut(ARect.Left+ARect.Width div 2, ARect.Top, TStar(Items.Objects[Index]).WriteName(True));
  end;
end;

end.

