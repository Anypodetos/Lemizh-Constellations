unit Constell;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, StrUtils, types, LCLType, LConvEncoding, Clipbrd, Stars, Math;

type

  { TConstellForm }

  TConstellForm = class(TForm)
    AddBtn: TBitBtn;
    Label7: TLabel;
    LinkEdit: TEdit;
    FindEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    LemEdit: TEdit;
    Label2: TLabel;
    InfoMemo: TMemo;
    CorrEdit: TEdit;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Label1: TLabel;
    ListBox: TListBox;
    NameEdit: TEdit;
    FindButton: TSpeedButton;
    FindClearButton: TSpeedButton;
    CopyButton: TSpeedButton;
    SearchWhat: TRadioGroup;
    CenterButton: TSpeedButton;
    procedure AddBtnClick(Sender: TObject);
    procedure CenterButtonClick(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
    procedure FindClearButtonClick(Sender: TObject);
    procedure FindEditChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure ListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure EditsChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  private
  public
    Modified: Boolean;
    procedure UpdateCaption;
end;

var
  ConstellForm: TConstellForm;

implementation

{$R *.lfm}

{ TConstellForm }

uses Main;

const clInfoMemo: array[False..True] of TColor = (clBtnFace, clDefault);

procedure TConstellForm.FormShow(Sender: TObject);
begin
  Left:=10;
  Top:=Screen.Height-Height-80;
  Modified:=False;
end;

procedure TConstellForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key=VK_F3) and (Shift=[]) then FindEditChange(FindButton);
  if (Key=VK_C)  and (Shift=[ssShift, ssCtrl]) then CopyButtonClick(CopyButton);
  if (Key=VK_X)  and (Shift=[ssShift, ssCtrl]) then CenterButtonClick(CenterButton);
end;

procedure TConstellForm.ListBoxClick(Sender: TObject);
var ci: TConstellInfo;
begin
  if ListBox.ItemIndex<0 then ListBox.ItemIndex:=0;
  ListBox.Tag:=1;
  ci:=SplitConstellStr(ListBox.Items[ListBox.ItemIndex]);
  NameEdit.Text:=ci[0];
  LemEdit .Text:=ci[1];
  LinkEdit.Text:=ci[2];
  CorrEdit.Text:=ci[3];
  InfoMemo.Text:=ci[4];
  ListBox.Tag:=0;
  NameEdit.Enabled:=ListBox.ItemIndex>0;
  LemEdit .Enabled:=ListBox.ItemIndex>0;
  LinkEdit.Enabled:=ListBox.ItemIndex>0;
  CorrEdit.Enabled:=ListBox.ItemIndex>0;
  InfoMemo.Enabled:=ListBox.ItemIndex>0;
  InfoMemo.Color:=clInfoMemo[InfoMemo.Enabled];
  CenterButton.Enabled:=ListBox.ItemIndex>0;
  CopyButton  .Enabled:=InfoMemo.Text<>'';
end;

procedure TConstellForm.ListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var ci: TConstellInfo;
begin
  with ListBox.Canvas do begin
    FillRect(ARect);
    ci:=SplitConstellStr(ListBox.Items[Index]);
    TextOut(ARect.Left+2, ARect.Top+1, IfThen(Index>0, IntToStr(Index)+'. ')+ci[0]);
    Font.Name:=LemEdit.Font.Name;
    Font.Size:=LemEdit.Font.Size;
    TextOut(ARect.Right *3 div 5, ARect.Top, ci[1]);
    Font.Name:=ListBox.Font.Name;
    if ci[4]<>'' then TextOut(ARect.Right-TextWidth('*'), ARect.Top, '*')
  end;
end;

procedure TConstellForm.FindEditChange(Sender: TObject);
const cl: array[False..True] of TColor = ($8080ff, clDefault);
var i, p: Integer;
    st: string;
begin
  if Visible or (ListBox.ItemIndex=0) then begin
    i:=(ListBox.ItemIndex+Ord(Sender=FindButton)) mod ListBox.Items.Count;
    with ListBox do repeat
      if SearchWhat.ItemIndex=1 then st:=LowerCase(Items[i]) else st:=LowerCase(SplitConstellStr(Items[i])[0]);
      p:=Pos(LowerCase(FindEdit.Text), st);
      if p=0 then i:=(i+1) mod Items.Count;
    until (p>0) or (i=ListBox.ItemIndex);
    if p>0 then begin
      ListBox.ItemIndex:=i;
      ListBoxClick(ListBox);
    end;
    FindEdit.Color:=cl[(p>0) or (FindEdit.Text='')];
  end;
end;

procedure TConstellForm.FindClearButtonClick(Sender: TObject);
begin
  FindEdit.Text:='';
end;

procedure TConstellForm.EditsChange(Sender: TObject);
const cases: array[1..8] of string = ('à', 'è', 'Ì', 'ì', 'ò', 'ù', 'Ò', 'Ù');
var i, n: Integer;
    linkhint: string;
begin
  if Sender is TEdit then TEdit(Sender).Text:=StringReplace(StringReplace(TEdit(Sender).Text, '|', '', [rfReplaceAll]), '¤', '', [rfReplaceAll]);
  if Sender=LemEdit then begin
    LemEdit.Hint:=LemTranscr(LemEdit.Text);
    linkhint:=LemEdit.Text;
    n:=Length(linkhint);
    for i:=1 to 8 do linkhint:=StringReplace(linkhint, cases[i], 'a', [rfReplaceAll]);
    LinkEdit.TextHint:=IfThen(n-Length(linkhint)=1, linkhint, '??');
  end;
  if ListBox.Tag=0 then begin
    ListBox.Items[ListBox.ItemIndex]:=IfThen((NameEdit.Text='') or not (NameEdit.Text[1] in ['a'..'z', 'A'..'Z']), 'X')+NameEdit.Text+
      '|'+LemEdit.Text+'¤'+LinkEdit.Text+'¤'+CorrEdit.Text+'¤'+StringReplace(InfoMemo.Text, LineEnding, '¶', [rfReplaceAll]);
    Modified:=True;
  end;
  UpdateCaption;
  CopyButton.Enabled:=InfoMemo.Text<>'';
end;

procedure TConstellForm.AddBtnClick(Sender: TObject);
begin
  ListBox.Items.Add('');
  ListBox.ItemIndex:=ListBox.Items.Count-1;
  NameEdit.Enabled:=True;
  LemEdit .Enabled:=True;
  LinkEdit.Enabled:=True;
  CorrEdit.Enabled:=True;
  InfoMemo.Enabled:=True;
  InfoMemo.Color:=clInfoMemo[InfoMemo.Enabled];
  NameEdit.Text:='';
  LemEdit .Text:='';
  LinkEdit.Text:='';
  CorrEdit.Text:='';
  InfoMemo.Text:='';
  AddBtn.Enabled:=ListBox.Items.Count<MaxConstells;
  UpdateCaption;
  FocusControl(NameEdit);
end;

procedure TConstellForm.CenterButtonClick(Sender: TObject);
var i: Integer;
    calpha, cdelta: Single;
begin
  if ListBox.ItemIndex>0 then with MainForm do begin
    ConstellCenter(ListBox.ItemIndex, calpha, cdelta);
    if (calpha<>0) or (cdelta<>0) then MoveTo(calpha+pi/8, cdelta);
    with ConstellCombo do for i:=0 to Items.Count-1 do if PtrInt(Items.Objects[i])=ConstellForm.ListBox.ItemIndex then ItemIndex:=i;
    ConstellComboChange(nil);
  end;
end;

procedure TConstellForm.CopyButtonClick(Sender: TObject);
begin
  if InfoMemo.Text<>'' then Clipboard.AsText:=ConstellInfo(InfoMemo.Text);
end;

procedure TConstellForm.UpdateCaption;
var i, mlem, minfo: Integer;
    ci: TConstellInfo;
begin
  mlem:=0;  minfo:=0;
  for i:=1 to ListBox.Items.Count-1 do begin
    ci:=SplitConstellStr(ListBox.Items[i]);
    if ci[1]='' then Inc(mlem);
    if ci[4]='' then Inc(minfo);
  end;
  Caption:=IfThen(Modified, '*')+Plural(ListBox.Items.Count-1, 'constellation')+IfThen(mlem+minfo>0, ' ('
    +IfThen(mlem>0, Plural(mlem, 'missing Lemizh name'))+IfThen((mlem>0) and (minfo>0), ' and ')+IfThen(minfo>0, Plural(minfo, 'missing info text'))
    +')');
end;

procedure TConstellForm.OKBtnClick(Sender: TObject);
var i, j, n, p, q, s: Integer;
    id: string;
    ch: Boolean;
begin
  ch:=False;
  for i:=1 to ListBox.Items.Count-1 do begin
    q:=1;
    with ListBox do repeat
      p:=PosEx('{{', Items[i], q);
      if p>0 then begin
        q:=PosEx('|', Items[i], p+2);
        id:=Copy(Items[i], p+2, q-p-2);
      end;
      if (p>0) and (Copy(id, 1, 1)<>'#') then begin
        n:=StrToIntDef('$'+id, -1);
        s:=0;
        for j:=1 to MainForm.StarCount-1 do with MainForm.Star[j] do if (LemConstell=i) and (LemNr=n) then begin
          s:=j;
          Break;
        end;
        if s>0 then begin
          Items[i]:=Copy(Items[i], 1, p+1)+'#'+IntToStr(s)+Copy(Items[i], q, MaxInt);
          ch:=True;
        end;
      end;
    until p=0;
  end;
  if ch then Caption:='*';
end;

end.

