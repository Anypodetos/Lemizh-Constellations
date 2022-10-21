unit Stat;

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Grids, StdCtrls, Buttons, Stars, Math, StrUtils, Clipbrd, types;

type

  { TStatForm }

  TStatForm = class(TForm)
    CloseButton: TBitBtn;
    AboutButton: TBitBtn;
    CopyButton: TBitBtn;
    HideZeroesBox: TCheckBox;
    CopyHTMLButton: TBitBtn;
    ConstellCombo: TComboBox;
    ConstellListBox: TListBox;
    Constells: TTabSheet;
    DoubleListBox: TListBox;
    DoubleNames: TTabSheet;
    StarsLabel: TLabel;
    NrsStars: TTabSheet;
    PageControl: TPageControl;
    StarListBox: TListBox;
    StringGrid: TStringGrid;
    procedure ConstellComboChange(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
    procedure CopyHTMLButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure StarListBoxDblClick(Sender: TObject);
    procedure StarListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure StringGridSelection(Sender: TObject; aCol, aRow: Integer);
  private
    procedure FillNrsBox;
    procedure CalcNumbers;
    procedure CalcConstells;
    procedure CalcDoubles;
  public
    function SelStar: TStar;
  end;

var
  StatForm: TStatForm;

implementation

{$R *.lfm}

uses Main;

{ TStatForm }

procedure TStatForm.FormShow(Sender: TObject);
begin
  MainForm.AssignConstells(ConstellCombo.Items);
  StringGrid.Col:=1;
  ConstellCombo.ItemIndex:=MainForm.ConstellCombo.ItemIndex;
  ConstellComboChange(nil);
  PageControlChange(nil);
end;

procedure TStatForm.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage=NrsStars then CalcNumbers else if PageControl.ActivePage=Constells then CalcConstells else CalcDoubles;
  CopyButton.Enabled:=SelStar<>nil;
  AboutButton.Enabled:=SelStar<>nil;
end;

const MaxDigits = 3;  BrightCount = 2;

procedure TStatForm.StringGridSelection(Sender: TObject; aCol, aRow: Integer);
begin
  FillNrsBox;
end;

procedure TStatForm.FillNrsBox;
var i, m, r: Integer;
begin
  StarListBox.Items.BeginUpdate;
  StarListBox.Items.Clear;
  for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do begin
    if magMax=20 then m:=Floor(Lmag) else m:=Floor(LmagMax)-2;
    case m of
      3..11: r:=1;
      0..2:  r:=2;
      else r:=0;
    end;
    if (r>0) and (StringGrid.Row in [r, BrightCount+1]) and
            (((LemNr<=0) or (LemConstell=0)) and (StringGrid.Col=1)
          or ((LemNr>0) and (LemConstell in [1..98])) and (StringGrid.Col=Floor(LogN(16, LemNr))+2)
          or ((LemConstell=99) and (StringGrid.Col=MaxDigits+2))
          or (StringGrid.Col=MaxDigits+3))
      then StarListBox.Items.AddObject(WriteSortStr, MainForm.Star[i]);
  end;
  StarListBox.Items.EndUpdate;
  StarListBox.Sorted:=True;
  if StarListBox.Items.Count>0 then StarListBox.ItemIndex:=0;
  CopyButton.Enabled:=SelStar<>nil;
  AboutButton.Enabled:=SelStar<>nil;
end;

procedure TStatForm.StarListBoxDblClick(Sender: TObject);
begin
  if AboutButton.Enabled then ModalResult:=mrOK;
end;

procedure TStatForm.StarListBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var l: Integer;
begin
  TListBox(Control).Canvas.FillRect(ARect);
  with TListBox(Control).Canvas do if Control=DoubleListBox then begin
    l:=ARect.Left+9*TextWidth('n');
    if Odd(Index) then TextOut(ARect.Left+2, ARect.Top, 'used for') else TextOut(ARect.Left+2, ARect.Top, 'Name of');
  end else l:=ARect.Left;
  with TStar(TListBox(Control).Items.Objects[Index]) do begin
    TListBox(Control).Canvas.TextOut(l+2, ARect.Top, WriteName(False));
    TListBox(Control).Canvas.TextOut(ARect.Right div 2, ARect.Top, WriteLemName);
    TListBox(Control).Canvas.TextOut(4*ARect.Right div 5, ARect.Top, WriteLemMag(False));
  end;
end;

procedure TStatForm.ConstellComboChange(Sender: TObject);
var i, c: Integer;
begin
  if ConstellCombo.ItemIndex>-1 then begin
    ConstellListBox.Clear;
    ConstellListBox.Items.BeginUpdate;
    c:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
    if c>0 then for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do
      if (LemConstell=c) and (not HideZeroesBox.Checked or (LemNr>0)) then ConstellListBox.Items.AddObject(WriteSortStr, MainForm.Star[i]);
    ConstellListBox.Items.EndUpdate;
    StarsLabel.Caption:='with '+IntToStr(ConstellListBox.Items.Count)+' stars';
    StarsLabel.Visible:=c>0;
  end;
  if ConstellListBox.Items.Count>0 then ConstellListBox.ItemIndex:=0;
  CopyButton.Enabled:=SelStar<>nil;
  AboutButton.Enabled:=SelStar<>nil;
end;

procedure TStatForm.CalcNumbers;
var i, j, m, r: Integer;
    g: array[0..MaxDigits+2, 1..BrightCount+1] of Integer;
begin
  StringGrid.Cells[0, 0]:='Lem. brightness';
  for i:=1 to MaxDigits do StringGrid.Columns[i].Title.Caption:=Plural(i, 'digit');
  StringGrid.Columns[MaxDigits+1].Title.Caption:='hidden';
  StringGrid.Columns[MaxDigits+2].Title.Caption:='Σ';
  StringGrid.Cells[0, 1]:='A…3 (vars: A…5)';
  StringGrid.Cells[0, 2]:='3…0 (vars: 5…2)';
  StringGrid.Cells[0, BrightCount+1]:='Σ';
  for i:=0 to MaxDigits+2 do for j:=1 to BrightCount+1 do g[i, j]:=0;
  for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do begin
    if magMax=20 then m:=Floor(Lmag) else m:=Floor(LmagMax)-2;
    case m of
      3..11: r:=1;
      0..2:  r:=2;
      else r:=0;
    end;
    if r>0 then
      if (LemConstell=99) then Inc(g[MaxDigits+1, r]) else
        if (LemNr<=0) or (LemConstell=0) then Inc(g[0, r]) else Inc(g[Floor(LogN(16, LemNr))+1, r]);
  end;
  for i:=0 to MaxDigits+2 do begin
    for j:=1 to BrightCount+1 do begin
      StringGrid.Cells[i+1, j]:=IntToStr(g[i, j]);
      Inc(g[i, BrightCount+1], g[i, j]);
      Inc(g[MaxDigits+2, j], g[i, j]);
    end;
  end;
  StringGrid.Cells[MaxDigits+3, BrightCount+1]:=IntToStr(g[MaxDigits+2, BrightCount+1] div 12);
  FillNrsBox;
end;

procedure TStatForm.CalcConstells;
begin
  ConstellComboChange(nil);
  Constells.Caption:=Plural(MainForm.LemConstells.Count-1, 'constellation');
  ConstellListBox.Sorted:=True;
end;

procedure TStatForm.CalcDoubles;
var i, j: Integer;
    c: array[1..$FFFF] of Integer;
begin
  DoubleListBox.Clear;
  DoubleListBox.Items.BeginUpdate;
  for j:=1 to MainForm.LemConstells.Count-1 do begin
    for i:=1 to 65535 do c[i]:=-1;
    for i:=1 to MainForm.StarCount-1 do with MainForm.Star[i] do if (LemConstell=j) and (LemNr>0) then begin
      if c[LemNr]>-1 then begin
        DoubleListBox.Items.AddObject(WriteSortStr+' '+IntToStr(i), MainForm.Star[i]);
        DoubleListBox.Items.AddObject(WriteSortStr+' '+IntToStr(i)+'A', MainForm.Star[c[LemNr]]);
      end else c[LemNr]:=i;
    end;
  end;
  DoubleListBox.Items.EndUpdate;
  DoubleNames.Caption:=Plural(DoubleListBox.Items.Count div 2, 'double designation');
  DoubleListBox.Sorted:=True;
  if DoubleListBox.Items.Count>0 then DoubleListBox.ItemIndex:=0;
end;

function TStatForm.SelStar: TStar;
begin
  if PageControl.ActivePage=NrsStars then begin
    if StarListBox.ItemIndex>-1 then Result:=TStar(StarListBox.Items.Objects[StarListBox.ItemIndex]) else Result:=nil;
  end else if PageControl.ActivePage=Constells then begin
    if ConstellListBox.ItemIndex>-1 then Result:=TStar(ConstellListBox.Items.Objects[ConstellListBox.ItemIndex]) else Result:=nil;
  end else begin
    if DoubleListBox.ItemIndex>-1 then Result:=TStar(DoubleListBox.Items.Objects[DoubleListBox.ItemIndex]) else Result:=nil;
  end;
end;

procedure TStatForm.CopyButtonClick(Sender: TObject);
var lb: TListBox;
    sl: TStringList;
    i: Integer;
begin
  sl:=TStringList.Create;
  case PageControl.ActivePageIndex of
      0: lb:=StarListBox;
      1: lb:=ConstellListBox;
    else lb:=DoubleListBox;
  end;
  for i:=0 to lb.Items.Count-1 do with TStar(lb.Items.Objects[i]) do sl.Add(WriteName(False)+#9+WriteLemName+#9+WriteLemMag(False));
  Clipboard.AsText:=sl.Text;
  sl.Free;
end;

procedure TStatForm.CopyHTMLButtonClick(Sender: TObject);
const abbrs: array[0..1] of string = ('Hip', 'GJ');
      titles: array[0..1] of string = ('Hipparcos', 'Gliese-Jahreiss');
var sl: TStringList;
    lb: TListBox;
    i, c: Integer;
    img: string;
    ci: TConstellInfo;
begin
  sl:=TStringList.Create;
  case PageControl.ActivePageIndex of
    0: begin
      with StringGrid do sl.Add('<h2>'+IfThen(Col>MaxDigits+1, IfThen(Col=MaxDigits+2, 'Hidden stars', 'Stars'), 'Stars with '+Columns[Col-1].Title.Caption)+
        IfThen(Row<=BrightCount, ' '+IfThen(Col>MaxDigits+1, 'with', 'and')+' Lemizh brightness '+Cells[0, Row])+'</h2>');
      lb:=StarListBox;
    end;
    1: begin
      if ConstellCombo.Text<>ListOfConstells then begin
        c:=PtrInt(ConstellCombo.Items.Objects[ConstellCombo.ItemIndex]);
        ci:=SplitConstellStr(MainForm.LemConstells[c]);
        sl.Add('<h2>Constellation '+ConstellCombo.Text+IfThen(ci[1]<>'', ' (<span lang="x-lm" title="'+LemTranscr(ci[1])+'">'+ci[1]+'</span>)')+'</h2>');
        sl.Add('<div class="float imgbox">');
        img:='<img class="filled" src="images/'+ConstellNameToId(ConstellCombo.Text);
        sl.Add(img+'_o.png" alt="Location of the constellation '+ConstellCombo.Text+' in the sky" style="border-radius: 50%"><br>');
        sl.Add(img+'.png" alt="Map of the constellation '+ConstellCombo.Text+'">');
        sl.Add('</div>');
        if ci[4]<>'' then sl.Add(ConstellInfo(ci[4]));
      end;
      lb:=ConstellListBox;
    end;
    {2} else begin
      sl.Add('<h2>Double designations</h2>');
      lb:=DoubleListBox;
    end;
  end;
  sl.Add('<p>In the ‘Corresponds to’ column, letters (sometimes with superscript numbers) in front of constellation symbols refer to Bayer’s Catalogue, and numbers to Flamsteed’s. Row colours roughly approximate the stars’ colours.</p>');
  sl.Add('<table>');
  sl.Add('<tr><th colspan="2">Designation (<abbr title="hexadecimal">hex</abbr>)</th><th>Corresponds to</th><th><abbr title="apparent magnitude"><i>m</i></abbr></th></tr>');
  for i:=0 to lb.Items.Count-1 do with TStar(lb.Items.Objects[i]) do
    sl.Add('<tr style="background-color: #'+LowerCase(IntToHex((ColorR+256) div 2, 2)+IntToHex((ColorG+256) div 2, 2)+IntToHex((ColorB+256) div 2, 2))+
      '"><td lang="x-lm" title="'+WriteLemNr+'">'+WriteLemNr+'</td><td>'+WriteLemNr+'</td><td>'+WriteName(False, True)+'</td><td>'+WriteMag+'</td></tr>');
  sl.Add('</table>');
  sl.Add('<p><strong>Sum:</strong> '+IntToStr(lb.Items.Count)+' stars</p>');
  for i:=0 to High(abbrs) do sl.Text:=StringReplace(sl.Text, '>'+abbrs[i]+' ', '><abbr title="'+titles[i]+' Catalogue">'+abbrs[i]+'</abbr> ', [rfReplaceAll]);
  for i:=0 to High(ConstellAbbrs) do
    sl.Text:=StringReplace(sl.Text, ' '+ConstellAbbrs[i]+'<', ' <abbr title="'+ConstellNames[i]+'">'+ConstellAbbrs[i]+'</abbr><', [rfReplaceAll]);
  Clipboard.AsText:=sl.Text;
  sl.Free;
end;

end.

