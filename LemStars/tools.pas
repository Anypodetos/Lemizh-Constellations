unit Tools;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Buttons, CheckLst, StdCtrls, StrUtils, Clipbrd, ExtCtrls;

type

  { TToolsForm }

  TToolsForm = class(TForm)
    DupCheckButton: TBitBtn;
    CheckButton: TBitBtn;
    CheckPanel: TPanel;
    CompareGroup: TCheckGroup;
    CopyAllButton: TBitBtn;
    CopyButton: TBitBtn;
    DesignationBox: TComboBox;
    FieldsLabel: TLabel;
    Image1: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NoHDCheckBox: TCheckBox;
    PageControl: TPageControl;
    OKLabel: TLabel;
    OtherCheckBox: TCheckBox;
    NotCheckBox: TCheckBox;
    LockButton: TSpeedButton;
    SeparatorBox: TComboBox;
    FileSheet: TTabSheet;
    OpenDialog: TOpenDialog;
    ListBox: TCheckListBox;
    DuplicatesSheet: TTabSheet;
    UpdateButton: TBitBtn;
    procedure CompareGroupItemClick(Sender: TObject; Index: integer);
    procedure CopyButtonClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure CheckButtonClick(Sender: TObject);
    procedure DesignationBoxChange(Sender: TObject);
    procedure DupCheckButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure ListBoxClick(Sender: TObject);
    procedure ListBoxDblClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure UpdateButtonClick(Sender: TObject);
  private
    DefCaption: string;
  public
  end;

var
  ToolsForm: TToolsForm;

implementation

{$R *.lfm}

uses Main, Info, Stars;

function StripWhitespace(FileName: string): Integer;
var n, s: Integer;
    f: File of Char;
    ch: array[0..1] of Char;
begin
  Result:=0;
  AssignFile(f, FileName);
  try
    Reset(f);
    s:=FileSize(f)-2;
    Seek(f, s);
    BlockRead(f, ch, 2, n);
    if (ch[0]=#13) and (ch[1]=#10) then begin
      Seek(f, s);
      Truncate(f);
      Result:=1;
    end;
  except Result:=-1 end;
  CloseFile(f);
end;

{ TToolsForm }

procedure TToolsForm.FormCreate(Sender: TObject);
begin
  DefCaption:=Caption;
end;

procedure TToolsForm.FormShow(Sender: TObject);
begin
  PageControlChange(nil);
  CompareGroupItemClick(CompareGroup, 0);
end;

procedure TToolsForm.PageControlChange(Sender: TObject);
begin
  CheckButton.Visible:=PageControl.ActivePage=FileSheet;
  DupCheckButton.Visible:=PageControl.ActivePage=DuplicatesSheet;
end;

procedure TToolsForm.CompareGroupItemClick(Sender: TObject; Index: integer);
var st: string;
    i: Integer;
begin
  st:='One entry per line. Required fields:'+LineEnding+'#1: Hip, '+IfThen(not (NoHDCheckBox.Checked and NoHDCheckBox.Enabled), 'HD, ')+'HR, or GJ designation'+LineEnding;
  i:=2;
  if CompareGroup.Checked[0] then begin st+='#2: Proper name'+LineEnding;                                     Inc(i); end;
  if CompareGroup.Checked[1] then begin st+='#'+IntToStr(i)+': Bayer letter (α/alp/alpha, b, C1)'+LineEnding; Inc(i); end;
  if CompareGroup.Checked[2] then begin st+='#'+IntToStr(i)+': Flamsteed number'+LineEnding;                  Inc(i); end;
  if CompareGroup.Checked[1] or CompareGroup.Checked[2] then st+='#'+IntToStr(i)+': Constellation abbreviation (UMa)';
  FieldsLabel.Caption:=st;
  CheckButton.Enabled:=i>2;
end;

procedure TToolsForm.DesignationBoxChange(Sender: TObject);
begin
  NoHDCheckBox.Enabled:=DesignationBox.ItemIndex<>2;
end;

procedure TToolsForm.CheckButtonClick(Sender: TObject);
  function Catalog(C: Char): string;
  begin
    case C of
      'I': Result:='Hip';
      'D': Result:='HD';
      'R': Result:='HR';
      'G': Result:='GJ';
      else Result:='';
    end;
  end;
const defdesigs = 'XIDRG';
      sepchars = ',;|'#9' ';
var i, j, k, q, gli, nother, nnot, nok: Integer;
    c: Char;
    st, both, bothExt: string;
    flam, starflam: array[1..3] of string;
    defdesig, sepchar: Char;
    foundinfile, b: Boolean;
    foundindb: array of Boolean;
    comparechecked: array[0..2] of Boolean;
    sl: TStringList;
begin
  if OpenDialog.Execute then begin
    CheckPanel.Show;
    ListBox.Items.Clear;
    Update;
    ListBox.Items.BeginUpdate;
    sl:=TStringList.Create;
    defdesig:=defdesigs[DesignationBox.ItemIndex+1];
    sepchar :=sepchars [SeparatorBox  .ItemIndex+1];
    try sl.LoadFromFile(OpenDialog.FileName) except MessageDlg('Couldn’t open file “'+OpenDialog.FileName+'”!'+LineEnding
      +'Maybe it is opened in another program.', mtError, [mbOK], 0) end;
    for j:=sl.Count-1 downto 0 do begin
      q:=Pos(sepchar, sl[j]);
      st:=LowerCase(Trim(Copy(sl[j], 1, q-1)));
      if Pos('hip', st)=1 then begin
        sl.Objects[j]:=TObject(PtrInt(StrToIntDef(Trim(Copy(st, 4, MaxInt)), 0)));
        sl[j]:='I'+Trim(Copy(sl[j], q+1, MaxInt));
      end else if (Pos('hd', st)=1) and not (NoHDCheckBox.Checked and NoHDCheckBox.Enabled) then begin
        sl.Objects[j]:=TObject(PtrInt(StrToIntDef(Trim(Copy(st, 3, MaxInt)), 0)));
        sl[j]:='D'+Trim(Copy(sl[j], q+1, MaxInt));
      end else if Pos('hr', st)=1 then begin
        sl.Objects[j]:=TObject(PtrInt(StrToIntDef(Trim(Copy(st, 3, MaxInt)), 0)));
        sl[j]:='R'+Trim(Copy(sl[j], q+1, MaxInt));
      end else if (Pos('gj', st)=1) or (Pos('gl', st)=1) then begin
        sl.Objects[j]:=TObject(PtrInt(StrToIntDef(Trim(Copy(st, 3, MaxInt)), 0)));
        sl[j]:='G'+Trim(Copy(sl[j], q+1, MaxInt));
      end else if (StrToIntDef(st, 0)>0) and (defdesig<>'X') then begin
        sl.Objects[j]:=TObject(PtrInt(StrToInt(Trim(st))));
        sl[j]:=defdesig+Trim(Copy(sl[j], q+1, MaxInt));
      end else begin
        ListBox.Items.AddObject(IfThen(Pos('hd', st)=1, 'Excluded HD entry', 'Couldn’t interpret designation of')
          +' “'+StringReplace(sl[j], sepchar, '  ', [])+'”', nil);
        ListBox.ItemEnabled[ListBox.Items.Count-1]:=False;
        sl.Delete(j);
      end;
    end;
    nother:=0;  nnot:=0;  nok:=0;
    for k:=0 to 2 do comparechecked[k]:=CompareGroup.Checked[k];
    SetLength(foundindb, sl.Count);
    for j:=0 to Length(foundindb)-1 do foundindb[j]:=False;
    if sl.Count>0 then for i:=1 to MainForm.StarList.Count-1 do with TStar(MainForm.StarList[i]) do begin
      foundinfile:=False;
      if Flamsteed<>'' then begin
        q:=Pos('/', Flamsteed);
        if q>0 then begin
          starflam[1]:=Copy(Flamsteed, 1, q-1);
          starflam[2]:=Copy(Flamsteed, q+1, MaxInt);
        end else begin
          q:=Ord(Flamsteed[1] in ['0'..'9']);
          starflam[q+1]:=Flamsteed;
          starflam[2-q]:='';
        end;
        for k:=1 to 2 do if not comparechecked[k] then starflam[k]:='';
        starflam[3]:=Constell;
      end else for k:=1 to 3 do starflam[k]:='';
      gli:=StrToIntDef(Trim(GJ), -1);
      for j:=0 to sl.Count-1 do if (PtrInt(sl.Objects[j])=Hip) and (Hip>0) and (sl[j][1]='I')
                                or (PtrInt(sl.Objects[j])=HD)  and (HD>0)  and (sl[j][1]='D')
                                or (PtrInt(sl.Objects[j])=HR)  and (HR>0)  and (sl[j][1]='R')
                                or (PtrInt(sl.Objects[j])=gli)             and (sl[j][1]='G') then begin
        if comparechecked[0] then begin {proper names}
          q:=Pos(sepchar, sl[j]+sepchar);
          st:=Trim(Copy(sl[j], 2, q-2));
          if st<>'' then
            if st=Name then begin
              ListBox.Items.AddObject(WriteName+': name ✓', TObject(PtrInt(i)));
              ListBox.ItemEnabled[ListBox.Items.Count-1]:=False;
              Inc(nok);
            end else begin
              ListBox.Items.AddObject(WriteName+': called “'+st+'”', TObject(PtrInt(i)));
              ListBox.Checked[ListBox.Items.Count-1]:=True;
              Inc(nother);
            end;
          st:=Copy(sl[j], q+1, MaxInt);
        end else st:=Copy(sl[j], 2, MaxInt);
        if comparechecked[1] or comparechecked[2] then begin {Bayer/Flamsteed}
          for k:=1 to 3 do if (k=3) or comparechecked[k] then begin {1=Bayer, 2=Flamsteed, 3=Constellation}
            q:=Pos(sepchar, st);
            if q=0 then q:=100000;
            flam[k]:=Copy(st, 1, q-1);
            st:=Copy(st, q+1, MaxInt);
          end else flam[k]:='';
          for k:=0 to 47 do flam[1]:=StringReplace(flam[1], GreekTransc[k], GreekAlphabet[k mod 24], [rfReplaceAll, rfIgnoreCase]);
          for c:='0' to '9' do flam[1]:=StringReplace(flam[1], c, SupDigits[c], [rfReplaceAll]);
          for k:=1 to 3 do flam[k]:=StringReplace(flam[k], ' ', '', [rfReplaceAll]);
          b:=True;
          for k:=1 to 3 do if ((k=3) or (flam[k]<>'')) and (flam[k]<>starflam[k]) then b:=False;
          both:=IfThen((flam[1]<>'') and (flam[2]<>''), '/');
          bothExt:=IfThen(flam[1]<>'', 'Bayer')+both+IfThen(flam[2]<>'', 'Flamsteed')+' designation';
          if not b then begin
            ListBox.Items.AddObject(WriteName+': has '+bothExt+' “'+flam[1]+both+flam[2]+' '+flam[3]+'”', TObject(PtrInt(i)));
            ListBox.Checked[ListBox.Items.Count-1]:=True;
            Inc(nother);
          end else if (flam[1]<>'') or (flam[2]<>'') then begin
            ListBox.Items.AddObject(WriteName+': '+bothExt+' ✓', TObject(PtrInt(i)));
            ListBox.ItemEnabled[ListBox.Items.Count-1]:=False;
            Inc(nok);
          end;
        end;
        foundinfile:=True;
        foundindb[j]:=True;
      end;
      if not foundinfile and ((Name<>'') and comparechecked[0] or (starflam[1]<>'') and comparechecked[1] or (starflam[2]<>'') and comparechecked[2]) then begin
        ListBox.Items.AddObject(WriteName+': not in file', TObject(PtrInt(i)));
        ListBox.Checked[ListBox.Items.Count-1]:=False;
        Inc(nnot);
      end;
    end;
    for j:=0 to Length(foundindb)-1 do if not foundindb[j] then begin
      ListBox.Items.AddObject(Catalog(sl[j][1])+' '+IntToStr(PtrInt(sl.Objects[j]))+' ('+Copy(sl[j], 2, MaxInt)+'): not in program’s database', nil);
      ListBox.ItemEnabled[ListBox.Items.Count-1]:=False;
    end;
    ListBox.Items.EndUpdate;
    if sl.Count>0 then begin
      OKLabel      .Caption:=IntToStr(nok)+' '+IfThen(nok=1, 'entry', 'entries')+' okay';
      OtherCheckBox.Caption:=IntToStr(nother)+' d&iffer'+IfThen(nother=1, 's');
      NotCheckBox  .Caption:=IntToStr(nnot)+' &not in file';
      OKLabel      .Show;
      OtherCheckBox.Show;
      NotCheckBox  .Show;
      OtherCheckBox.Checked:=True;
      NotCheckBox  .Checked:=False;
      UpdateButton .Enabled:=True;
      CopyButton   .Enabled:=True;
      CopyAllButton.Enabled:=True;
    end;
    sl.Free;
    CheckPanel.Hide;
    Caption:=IfThen(ListBox.Items.Count=0, DefCaption, OpenDialog.FileName+' - '+DefCaption);
  end;
end;

procedure TToolsForm.UpdateButtonClick(Sender: TObject);
const kindStrings: array[1..4] of string = ('Bayer', 'Flamsteed', 'Bayer/Flamsteed', 'called “'{ProperName});
var i, j, k, n, p, q, r, s, t, u, kind: Integer;
    c: Char;
    change, checkfile: Boolean;
    oldcontent, newcontent, bay: string;
    sl: array[1..2] of TStringList;
begin
  checkfile:=PageControl.ActivePage=FileSheet;
  if MessageDlg('Are you sure you want to '+IfThen(checkfile, 'modify', '𝗱𝗲𝗹𝗲𝘁𝗲 the checked designations in')+
      ' the database files “'+StarFiles[1]+'” and “'+StarFiles[2]+'”?'+LineEnding+LineEnding+
      'You need to restart the program for the modifications to become visible.', mtConfirmation, [mbYes, mbNo], 0)=mrYes then begin
    change:=False;
    for i:=1 to 2 do begin
      sl[i]:=TStringList.Create;
      try sl[i].LoadFromFile(MainForm.StarDir+StarFiles[i]) except MessageDlg('Couldn’t open file “'+MainForm.StarDir+StarFiles[i]+'”!', mtError, [mbOK], 0) end;
    end;
    if (sl[1].Count>0) and (sl[2].Count>0) then for j:=0 to ListBox.Items.Count-1 do if ListBox.Checked[j] then begin
      n:=PtrInt(ListBox.Items.Objects[j])+1;
      i:=Ord(n>sl[1].Count-1)+1;
      if i=2 then n-=sl[1].Count-1;
      kind:=0;
      for k:=1 to 4 do if Pos(kindStrings[k], ListBox.Items[j-Ord(not checkfile and Odd(j))])>0 then kind:=k;
      p:=0;           {start of field to add/modify in StarFiles}
      for k:=1 to 5+2*Ord(kind=4) do p:=PosEx('|', sl[i][n], p+1);
      q:=p;             {end of field to add/modify in StarFiles}
      for k:=1 to 2-Ord(kind=4) do q:=PosEx('|', sl[i][n], q+1);

//      MessageDlg('line '+inttostr(j)+', sl[i][n]="'+sl[i][n]+'", kind='+inttostr(kind), mtinformation, [mbok], 0);

      if (q>0) and (kind>0) then begin
        if checkfile then begin
          r:=Pos('“', ListBox.Items[j]);  {start of designation (Bay/Flam/ProperName) in ListBox}
          if r=0 then newcontent:='' else newcontent:=Copy(ListBox.Items[j], r+3, Pos('”', ListBox.Items[j])-r-3);
          if kind<4 then
            if r=0 then newcontent:='|' else begin
              oldcontent:=Copy(sl[i][n], p+1, q-p-1);
              t:=Pos('/', oldcontent);
              u:=Pos('|', oldcontent)-1;
              newcontent:=StringReplace(newcontent, ' ', '|', []);
              if kind in [1, 3] then begin
                {translate Bayer letters}
                s:=Pos(IfThen(kind=1, '|', '/'), newcontent);
                bay:=Copy(newcontent, 1, s-1);
                for k:=Length(bay) downto 1 do if bay[k] in ['a'..'z', 'A'..'Z'] then begin
                  Insert('!', bay, k+1);
                  Break;
                end;
                bay:=StringReplace(bay, 'θ', 'J', [rfReplaceAll, rfIgnoreCase]);
                for c:='a' to 'z' do bay:=StringReplace(bay, GreekLetters[c], c, [rfReplaceAll, rfIgnoreCase]);
                for c:='0' to '9' do bay:=StringReplace(bay, SupDigits[c], c, [rfReplaceAll]);
                {keep Flam if only Bay in ListBox}
                if kind=1 then
                  if t>0 then bay+=Copy(oldcontent, t, u-t+1) else
                    if (Length(oldcontent)>0) and (oldcontent[1] in ['0'..'9']) then bay+='/'+Copy(oldcontent, 1, u);
                newcontent:=bay+Copy(newcontent, s, MaxInt);
              end;
              {keep Bay if only Flam in ListBox}
              if kind=2 then
                if t>0 then newcontent:=Copy(oldcontent, 1, t)+newcontent else
                  if (Length(oldcontent)>0) and not (oldcontent[1] in ['0'..'9']) then newcontent:=Copy(oldcontent, 1, u)+'/'+newcontent;
            end;
        end else begin {Delete duplicates}
          t:=PosEx('/', sl[i][n], p+1);
          if t>q then t:=0;
          if kind=1 then newcontent:=IfThen(t>0, Copy(sl[i][n], t+1, q-t-1), '|') else begin
            u:=PosEx('|', sl[i][n], p+1);
            newcontent:=IfThen(t>0, Copy(sl[i][n], p+1, t-p-1)+Copy(sl[i][n], u, q-u), '|');
          end;
        end;
        sl[i][n]:=Copy(sl[i][n], 1, p)+newcontent+Copy(sl[i][n], q, MaxInt);
        change:=True;
      end;
    end;
    if change then for i:=1 to 2 do begin
      try
        sl[i].SaveToFile(MainForm.StarDir+StarFiles[i]);
        StripWhitespace (MainForm.StarDir+StarFiles[i]);
      except
        MessageDlg('Couldn’t save file “'+MainForm.StarDir+StarFiles[i]+'”!', mtError, [mbOK], 0);
        change:=False;
      end;
      sl[i].Free;
    end;
    if change then with UpdateButton do begin
      Text:=Text+' ✓';
      Tag:=1;
    end;
  end;
end;

procedure TToolsForm.ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  with UpdateButton do if Tag=1 then begin
    Text:=Copy(Text, 1, LastDelimiter(' ', Text)-1);
    Tag:=0;
  end;
end;

procedure TToolsForm.CopyButtonClick(Sender: TObject);
var i: Integer;
    st: string;
begin
  st:='';
  for i:=0 to ListBox.Items.Count-1 do if ListBox.Checked[i] or (Sender=CopyAllButton) then st+=ListBox.Items[i]+LineEnding;
  if st<>'' then Clipboard.AsText:=st;
end;

procedure TToolsForm.ListBoxClick(Sender: TObject);
begin
  with ListBox do if (ItemIndex>-1) and (Items.Objects[ItemIndex]<>nil) then begin
    MainForm.HighlightStar:=TStar(MainForm.StarList[PtrInt(Items.Objects[ItemIndex])]);
    if LockButton.Down then with MainForm.HighlightStar do MainForm.MoveTo(alpha, delta);
  end else MainForm.HighlightStar:=nil;
end;

procedure TToolsForm.ListBoxDblClick(Sender: TObject);
var i: Integer;
begin
  InfoForm.StarCombo.Items.Clear;
  with ListBox.Items do for i:=0 to Count-1 do if ListBox.ItemEnabled[i] then begin
    InfoForm.StarCombo.Items.AddObject(TStar(MainForm.StarList[PtrInt(Objects[i])]).WriteName, TStar(MainForm.StarList[PtrInt(Objects[i])]));
    if i=ListBox.ItemIndex then InfoForm.StarCombo.ItemIndex:=InfoForm.StarCombo.Items.Count-1;
  end;
  InfoForm.StarComboChange(nil);
  if not LockButton.Down and (MainForm.HighlightStar<>nil) then with MainForm.HighlightStar do MainForm.MoveTo(alpha, delta);
  InfoForm.ShowModalCenter;
end;

procedure TToolsForm.CheckBoxClick(Sender: TObject);
var i: Integer;
begin
  for i:=0 to ListBox.Items.Count-1 do if ListBox.ItemEnabled[i] and ((Pos('“', ListBox.Items[i])=0) = (Sender=NotCheckBox)) then
    ListBox.Checked[i]:=TCheckBox(Sender).Checked;
end;

procedure TToolsForm.DupCheckButtonClick(Sender: TObject);
  procedure GetBayAndFlam(s: TStar; out Bay: string; out Flam: Integer);
  var p: Integer;
  begin
    p:=Pos('/', s.Flamsteed);
    if p>0 then begin
      Bay :=Copy(s.Flamsteed, 1, p-1);
      Flam:=StrToIntDef(Copy(s.Flamsteed, p+1, MaxInt), 0);
    end else begin
      Flam:=StrToIntDef(s.Flamsteed, 0);
      if Flam=0 then Bay:=s.Flamsteed else Bay:='';
    end;
  end;

var i, j, f1, f2: Integer;
    b1, b2: string;
begin
  CheckPanel.Show;
  ListBox.Items.Clear;
  Update;
  ListBox.Items.BeginUpdate;
  with MainForm do for i:=1 to StarList.Count-1 do if TStar(StarList[i]).Constell>'' then begin
    for j:=i+1 to StarList.Count-1 do if TStar(StarList[i]).Constell=TStar(StarList[j]).Constell then begin
      GetBayAndFlam(TStar(StarList[i]), b1, f1);
      GetBayAndFlam(TStar(StarList[j]), b2, f2);
      if (b1>'') and (b1=b2) then begin
        ListBox.Items.AddObject('Bayer designation of '+TStar(StarList[i]).WriteName(True)+' …', TObject(PtrInt(i)));
        ListBox.Items.AddObject('… is used for '+TStar(StarList[j]).WriteName(True), TObject(PtrInt(j)));
      end;
      if (f1>0)  and (f1=f2) then begin
        ListBox.Items.AddObject('Flamsteed designation of '+TStar(StarList[i]).WriteName(True)+' …', TObject(PtrInt(i)));
        ListBox.Items.AddObject('… is used for '+TStar(StarList[j]).WriteName(True), TObject(PtrInt(j)));
      end;
    end;
  end;
  ListBox.CheckAll(cbUnchecked);
  ListBox.Items.EndUpdate;
  OKLabel      .Caption:=IntToStr(ListBox.Items.Count div 2)+' pair'+IfThen(ListBox.Items.Count<>2, 's')+' of duplicates';
  OKLabel      .Show;
  OtherCheckBox.Hide;
  NotCheckBox  .Hide;
  UpdateButton .Enabled:=True;
  CopyButton   .Enabled:=ListBox.Items.Count>0;
  CopyAllButton.Enabled:=CopyButton.Enabled;
  CheckPanel.Hide;
  Caption:=IfThen(ListBox.Items.Count=0, DefCaption, 'Duplicates - '+DefCaption);
end;

end.

