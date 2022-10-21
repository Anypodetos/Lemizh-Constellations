unit Stars;

interface

uses Vector, Graphics, Classes, Dialogs, SysUtils, Math, Controls, StrUtils, LConvEncoding, MyUtils, Clipbrd;

type
  TStarInfo = (siNone, siFlamBay, siName, siXor, siBoth, siHip, siHD, siHR, siGliese, siAny);
  TConstellInfo = array[0..4] of string;

  { TStar }

  TStar = class(TObject)
    P: TVector;
    mag, magMax, ColorIndex: Single;
    ShamCI: Boolean;
    Hip, HD, HR: Integer;
    Spectrum: string[12];
    GJ, Flamsteed: string[9];
    Constell: string[3];
    Name: string;
    LemConstell: Byte;
    LemNr: Word;  {var c in TStatForm.CalcDoubles relies on LemNr<=$FFFF}
    AutoNumbered: Boolean;
    function Lmag: Single;
    function LmagMax: Single;
    function BrightEnough: Boolean;
    function Temp: Integer;
    function alpha: Single;
    function delta: Single;
    function ColorR: Byte;
    function ColorG: Byte;
    function ColorB: Byte;
    function WriteName(BayAndFlam: Boolean=True; HTML: Boolean=False; GJAlpha: Boolean=True): string;
    function WriteMag(Max: Boolean=False): string;
    function WriteSortStr: string;
    function WriteLemNr: string;
    function WriteLemName: string;
    function WriteLemMag(Both: Boolean; Max: Boolean=False): string;
  end;

  TLine = class(TObject)
    LemConstell: Byte;
    LineTo: Boolean;
    Star: TStar;
    constructor CreateFrom(L: TLine; C: Byte=0);
  end;

const
  StarFiles: array[1..2] of string = ('Stars.txt', 'StarsAdd.txt');
  MaxConstells = 97;
  ListOfConstells = '‹no constellation›';
  GreekLetters: array['a'..'z'] of string = ('α', 'β', 'χ', 'δ', 'ε', 'φ', 'γ', 'η', 'ι', 'φ', 'κ', 'λ', 'μ', 'ν', 'ο', 'π', 'θ', 'ρ', 'σ', 'τ', 'υ', '', 'ω', 'ξ', 'ψ', 'ζ');
  SupDigits: array['0'..'9'] of string = ('⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹');
  GreekAlphabet: array[0..23] of string = ('α', 'β', 'γ', 'δ', 'ε', 'ζ', 'η', 'θ', 'ι', 'κ', 'λ', 'μ', 'ν', 'ξ', 'ο', 'π', 'ρ', 'σ', 'τ', 'υ', 'φ', 'χ', 'ψ', 'ω');
  GreekTransc: array[0..47] of string = (
    'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta', 'Theta', 'Iota', 'Kappa', 'Lambda',
    'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho', 'Sigma', 'Tau', 'Upsilon', 'Phi', 'Chi', 'Psi', 'Omega',
    'Alp', 'Bet', 'Gam', 'Del', 'Eps', 'Zet', 'Eta', 'The', 'Iot', 'Kap', 'Lam',
    'Mu', 'Nu', 'Xi', 'Omi', 'Pi', 'Rho', 'Sig', 'Tau', 'Ups', 'Phi', 'Chi', 'Psi', 'Ome');
  ConstellAbbrs: array[0..87] of string =
    ('And', 'Ant', 'Aps', 'Aql', 'Aqr', 'Ara', 'Ari', 'Aur', 'Boo', 'Cae',
     'Cam', 'Cap', 'Car', 'Cas', 'Cen', 'Cep', 'Cet', 'Cha', 'Cir', 'CMa',
     'CMi', 'Cnc', 'Col', 'Com', 'CrA', 'CrB', 'Crt', 'Cru', 'Crv', 'CVn',
     'Cyg', 'Del', 'Dor', 'Dra', 'Equ', 'Eri', 'For', 'Gem', 'Gru', 'Her',
     'Hor', 'Hya', 'Hyi', 'Ind', 'Lac', 'Leo', 'Lep', 'Lib', 'LMi', 'Lup',
     'Lyn', 'Lyr', 'Men', 'Mic', 'Mon', 'Mus', 'Nor', 'Oct', 'Oph', 'Ori',
     'Pav', 'Peg', 'Per', 'Phe', 'Pic', 'PsA', 'Psc', 'Pup', 'Pyx', 'Ret',
     'Scl', 'Sco', 'Sct', 'Ser', 'Sex', 'Sge', 'Sgr', 'Tau', 'Tel', 'TrA',
     'Tri', 'Tuc', 'UMa', 'UMi', 'Vel', 'Vir', 'Vol', 'Vul');
  ConstellNames: array[0..87] of string =
   ('Andromedae', 'Antliae', 'Apodis', 'Aquilae', 'Aquarii', 'Arae', 'Arietis', 'Aurigae', 'Bootis', 'Caeli',
    'Camelopardalis', 'Capricorni', 'Carinae', 'Cassiopeiae', 'Centauri', 'Cephei', 'Ceti', 'Chamaeleonis', 'Circini', 'Canis Maioris',
    'Canis Minoris', 'Cancri', 'Columbae', 'Comae Berenices', 'Coronae Australis', 'Coronae Borealis', 'Crateris', 'Crucis', 'Corvi', 'Canum Venaticorum',
    'Cygni', 'Delphini', 'Doradus', 'Draconis', 'Equulei', 'Eridani', 'Fornacis', 'Geminorum', 'Gruis', 'Herculis',
    'Horologii', 'Hydrae', 'Hydri', 'Indi', 'Lacertae', 'Leonis', 'Leporis', 'Librae', 'Leo Minoris', 'Lupi',
    'Lyncis', 'Lyrae', 'Mensae', 'Microscopii', 'Monocerotis', 'Muscae', 'Normae', 'Octantis', 'Ophiuchi', 'Orionis',
    'Pavonis', 'Pegasi', 'Persei', 'Phoenicis', 'Pictoris', 'Piscis Austrini', 'Piscium', 'Puppis', 'Pyxis', 'Reticuli',
    'Sculptoris', 'Scorpii', 'Scuti', 'Serpentis', 'Sextantis', 'Sagittae', 'Sagitarii', 'Tauri', 'Telescopii', 'Trianguli Australis',
    'Trianguli', 'Tucanae', 'Ursae Maioris', 'Ursae Minoris', 'Velorum', 'Virginis', 'Volantis', 'Vulpeculae');

function Plural(N: Integer; S: string): string;
function CoordsToStr(alpha, delta: Single): string;
function ZoomToStr(zoom: Single): string;
function ConstellNameToId(S: string): string;
function SplitConstellStr(S: string; LineBreaks: Boolean=True): TConstellInfo;
function ConstellInfo(S: string): string;
function LemTranscr(S: string): string;
function LoadStars(StarList: TList; out AboutString: string; FileName: string): Boolean;

implementation

uses Main;

constructor TLine.CreateFrom(L: TLine; C: Byte = 0);
begin
  inherited Create;
  if C=0 then LemConstell:=L.LemConstell else LemConstell:=C;
  LineTo:=L.LineTo;
  Star:=L.Star;
end;

function Plural(N: Integer; S: string): string;
begin
  Result:=IntToStr(N)+' '+S+IfThen(N<>1, 's');
end;

function CoordsToStr(alpha, delta: Single): string;
begin
  while alpha>=2*pi do alpha-=2*pi;
  while alpha<0     do alpha+=2*pi;
  Result:='α = '+FormatFloat('00', alpha*12/pi)+'ʰ '+FormatFloat('00', 60*Frac(alpha*12/pi+0.0001))+'ᵐ • δ = '
      +StringReplace(FormatFloat('00.0', delta*180/pi), '-', '−', [])+'°';
end;

function ZoomToStr(zoom: Single): string;
begin
  Result:=FloatToStrF(zoom, ffFixed, 0, 1)+' px/° • '+FloatToStrF(60/zoom, ffFixed, 0, 1)+'′/px • r = '+IntToStr(Round(zoom*180/pi))+' px';
end;

function ConstellNameToId(S: string): string;
begin
  Result:=StringReplace(StringReplace(LowerCase(S), ' ', '', [rfReplaceAll]), '-', '', [rfReplaceAll]);
end;

function SplitConstellStr(S: string; LineBreaks: Boolean=True): TConstellInfo;
var p, q, r, t: Integer;
begin
  p:=Pos('|', S);        if p=0 then p:=100000;
  q:=Pos('¤', S);        if q=0 then q:=100000;
  r:=PosEx('¤', S, q+1); if r=0 then r:=100000;
  t:=PosEx('¤', S, r+1); if t=0 then t:=100000;
  Result[0]:=Copy(S, 1, p-1);
  Result[1]:=Copy(S, p+1, q-p-1);
  Result[2]:=Copy(S, q+2, r-q-2);
  Result[3]:=Copy(S, r+2, t-r-2);
  Result[4]:=Copy(S, t+2, MaxInt);
  if LineBreaks then Result[4]:=StringReplace(Result[4], '¶', LineEnding, [rfReplaceAll, rfIgnoreCase]);
end;

function ConstellInfo(S: string): string;
var p, q, r: Integer;
    s2: string;
begin
  if S<>'' then begin
    repeat
      p:=Pos('[[', S);
      q:=Pos(']]', S);
      s2:=Copy(S, p+2, q-p-2);
      if (p>0) and (q>p) then S:=Copy(S, 1, p-1)+'<a href="'+ConstellNameToId(s2)+'.html" title="Constellation '+s2+'">'+s2+'</a>'+Copy(S, q+2, maxInt);
    until (p=0) or (q<=p);
    repeat
      p:=Pos('{{', S);
      q:=Pos('|', S);
      r:=Pos('}}',  S);
      s2:=Copy(S, p+2, q-p-2);
      if Copy(s2, 1, 1)='#' then Delete(s2, 1, 1) else s2:=''''+s2+'''';
      if (p>0) and (q>p) and (r>q) then S:=Copy(S, 1, p-1)+'<span onMouseOver="changeStar('+s2+')" title="Star '+s2+'">'+Copy(S, q+1, r-q-1)+'</span>'+Copy(S, r+2, maxInt);
    until (p=0) or (q<=p) or (r<=q);
    S:=StringReplace(S, LineEnding+LineEnding, LineEnding, [rfReplaceAll]);
    Result:='<p>'+StringReplace(S, LineEnding, '</p>'+LineEnding+'<p>', [rfReplaceAll])+'</p>';
  end else Result:='';
end;

function LemTranscr(S: string): string;
const t: array[#32..#255] of string = (' ', '−', '', 'ʳ', '', '', '', '', '(', ')', '×', '+', ',', '-', '.', '/',
                                       '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', ',(!)', '‘', '', '’', '',
                                       '', 'A', 'B', 'C', 'D', 'E', 'F', '', 'h', '', '', '', 'hl', 'm̌', 'ň', 'ö',
                                       '', '', 'rh', '', '', 'ü', '', '', 'hr', '', 'n', '[', '\', ']', '—', '−',
                                       '`', 'a', 'b', 'zh', 'd', 'e', 'f', 'g', 'sh', 'i', 'gh', 'k', 'l', 'm', 'ng', 'o',
                                       'p', 'th', 'r', 's', 't', 'u', 'dh', 'w', 'x', 'y', 'z', '{', '', '}', '–', '',
                                       '', '', '', '', '', '', '', '', '', '', '', '“', '', '', '', '',
                                       '', '', '', '', '', '', '‥', '…', '', '', '', '”', '', '', '', '',
                                       ' ', '', '', '', '', '', '', '', '', '', '', '“‘', '', '-', '', '',
                                       '', '', '', '', '´', '', '', '', '', '', '', '’”', '', '', '', '',
                                       '☉', '☿', '♀', '♁', '♂', '♃', '♄', '⛢', '♆', '☽', '', '', 'ỳ', '', '', '',
                                       '', '', 'ö̀', 'ö́', '', '', '', '', '', 'ǜ', 'ǘ', '', '', '', '', '',
                                       'à', 'á', '', '', '', '', '', '', 'è', 'é', '', '', 'ì', 'í', '', '',
                                       '', '', 'ò', 'ó', '', '', '', '', '', 'ù', 'ú', '', '', 'ý', '', '');
var i: Integer;
    sr: RawByteString;
begin
  Result:='';
  sr:=UTF8toCP1252(S);
  for i:=1 to Length(sr) do Result+=t[sr[i]];
end;

function LoadStars(StarList: TList; out AboutString: string; FileName: string): Boolean;
  function CalcCI(Spectrum: string): Single;
    function SubClass(Nr: Integer): Integer;
    begin
      try Result:=StrToInt(Spectrum[Nr]) except Result:=5 end;
    end;
  var i: Integer;
  begin
    Result:=0.20;
    for i:=Length(Spectrum) downto 1 do case Spectrum[i] of
      'W': Result:=-0.5;
      'O': Result:=-0.4+SubClass(i+1)*0.02;
      'B': Result:=-0.2+SubClass(i+1)*0.02;
      'A': Result:=0.00+SubClass(i+1)*0.025;
      'F': Result:=0.25+SubClass(i+1)*0.04;
      'G': Result:=0.65+SubClass(i+1)*0.04;
      'K', 'R': Result:=1.05+SubClass(i+1)*0.04;
      'M', 'N', 'C': Result:=1.45+SubClass(i+1)*0.085;
      'S': Result:=2.50;
    end;
  end;
  procedure ReplaceChar(var S: string; N: Integer; SubS: string);
  begin
    S:=Copy(S, 1, N-1)+SubS+Copy(S, N+1, MaxInt);
  end;
var sl: TStringList;
    i, j, p, n: Integer;
    r: Double;
    latin: Boolean;
    st: string;
    sa: array[0..14] of string;
    fs: TFormatSettings;
    S: TStar;
begin
  fs:=DefaultFormatSettings;
  fs.DecimalSeparator:='.';
  sl:=TStringList.Create;
  Result:=True;
  try sl.LoadFromFile(FileName) except Result:=False; end;
  StarList.Capacity:=StarList.Capacity+sl.Count;
  n:=StarList.Count;
  for i:=1 to sl.Count-1 do begin
    {0  1   2  3  4  5        6        7    8 9 10 11 12       13         14     }
    {Id Hip HD HR GJ Bay&Flam Constell Name X Y Z Mag Spectrum ColorIndex ShamCI }
    st:=sl[i];
    for j:=0 to 13 do begin
      p:=Pos('|', st);
      if p=0 then p:=100;
      sa[j]:=Copy(st, 1, p-1);
      st:=Copy(st, p+1, MaxInt)
    end;
    p:=Pos('-', Copy(sa[11], 2, MaxInt))+1;
    if p>1 then begin
      sa[14]:=Copy(sa[11], p, MaxInt);
      sa[11]:=Copy(sa[11], 1, p-1);
    end else sa[14]:='';
    S:=TStar.Create;
    S.Hip:=StrToIntDef(sa[1], 0);
    S.HD:=StrToIntDef(sa[2], 0);
    S.HR:=StrToIntDef(sa[3], 0);
    S.GJ:=Copy(sa[4], 4, MaxInt);
    latin:=False;
    p:=Pos('/', sa[5]);
    if (p=0) and (Length(sa[5])>0) and not (sa[5,1] in ['0'..'9']) then p:=Length(sa[5])+1;
    for j:=p-1 downto 1 do if not latin then case sa[5,j] of
      'a'..'z': ReplaceChar(sa[5], j, GreekLetters[sa[5,j]]);
      'J'     : ReplaceChar(sa[5], j, 'θ');
      '0'..'9': ReplaceChar(sa[5], j, SupDigits[sa[5,j]]);
      '!'     : begin
        ReplaceChar(sa[5], j, '');
        latin:=True;
      end;
      else sa[5,j]:='*';
    end;
    S.Flamsteed:=sa[5];
    S.Constell:=sa[6];
    S.Name:=sa[7];
    for j:=1 to 3 do try S.P[j]:=StrToFloat(sa[j+7], fs) except S.P[j]:=0 end;
    try S.mag:=StrToFloat(sa[11], fs)+5*(Log10(Abs(S.P))-1) except S.mag:=20 end;
    if p>0 then try S.magMax:=S.mag+StrToFloat(sa[14], fs) except S.magMax:=20 end
      else S.magMax:=20;
    r:=Abs(S.P);
    if r>0 then for j:=1 to 3 do S.P[j]:=S.P[j]/r;
    S.Spectrum:=sa[12];
    try
      S.ColorIndex:=StrToFloat(sa[13], fs);
      S.ShamCI:=False;
    except
      S.ColorIndex:=CalcCI(S.Spectrum);
      S.ShamCI:=True;
    end;
    S.ColorIndex:=Min(Max(S.ColorIndex, -0.4), 2.5);
    S.LemConstell:=0;
    S.LemNr:=0;
    StarList.Add(S);
  end;
  if sl.Count>0 then AboutString:='The star database from “'+FileName+'” contains '+FormatFloat(',0', StarList.Count-n)+' stars. '+CP1252toUTF8(sl[0]);
  sl.Free;
end;

function TStar.Lmag: Single;
begin
 Result:=8.33227477-mag*1.32877124;
end;

function TStar.LmagMax: Single;
begin
 Result:=8.33227477-magMax*1.32877124;
end;

function TStar.BrightEnough: Boolean;
begin
  Result:=(Lmag>=0) or (LmagMax>=2);
end;

function TStar.alpha: Single;
begin
  Result:=pi*Ord(P[3]<0)-arctan(P[1]/P[3]);
end;

function TStar.delta: Single;
begin
  Result:=arcsin(P[2]);
end;

function TStar.ColorR: Byte;
begin
  Result:=CItoRed(ColorIndex);
end;

function TStar.ColorG: Byte;
begin
  Result:=CItoGreen(ColorIndex);
end;

function TStar.ColorB: Byte;
begin
  Result:=CItoBlue(ColorIndex);
end;

function TStar.Temp: Integer;
begin
  Result:=CItoTemp(ColorIndex);
end;

function TStar.WriteName(BayAndFlam: Boolean=True; HTML: Boolean=False; GJAlpha: Boolean=True): string;
var f: string;
    q: Integer;
begin
  q:=Pos('/', Flamsteed);
  if BayAndFlam or (q=0) then f:=Flamsteed else f:=Copy(Flamsteed, 1, q-1);
  if f<>'' then Result:=f+' '+Constell else Result:='';
  if Name<>'' then Result+=IfThen(f<>'', ' (')+Name+IfThen(f<>'', ')');
  if Result='' then
    if GJ<>'' then Result:='GJ '+IfThen(not GJAlpha and (GJ[Length(GJ)] in ['A'..'Z']), Trim(Copy(GJ, 1, Length(GJ)-1)), GJ) else
      if Hip>0 then Result:='Hip '+IntToStr(Hip) else Result:='Star';
  if HTML and (Hip>0) then begin
    q:=Pos(' (', Result);
    if q=0 then q:=MaxInt;
    Result:='<a rel="external" href="http:/'+'/simbad.u-strasbg.fr/simbad/sim-basic?Ident=Hip'+IntToStr(Hip)+'">'+Copy(Result, 1, q-1)+'</a>'+Copy(Result, q, MaxInt);
  end;
end;

function TStar.WriteMag(Max: Boolean=False): string;
begin
  Result:=StringReplace(FloatToStrF(IfThen(Max, magMax, mag), ffFixed, 4, 2), '-', '−', []);
end;

function TStar.WriteSortStr: string;
begin
  Result:=MainForm.ConstellName(LemConstell)+' '+IntToHex(LemNr, 8);
end;

function TStar.WriteLemNr: string;
begin
  Result:=IfThen(LemNr>0, IntToHex(LemNr, 0), '?');
end;

function TStar.WriteLemName: string;
begin
  Result:=IfThen(LemConstell<99, WriteLemNr+' ')+MainForm.ConstellName(LemConstell);
end;

function TStar.WriteLemMag(Both: Boolean; Max: Boolean=False): string;
var m: Single;
    st: string;
begin
  if Max then m:=LmagMax else m:=Lmag;
  st:=IfThen(m<0, '−')+IntToHex(Round(System.Abs(256*m)), 3);
  Result:=IfThen(Both, StringReplace(FloatToStrF(m, ffFixed, 4, 2), '-', '−', [])+'ᵈᵉᶜ = ')
    +Copy(st, 1, Length(st)-2)+DefaultFormatSettings.DecimalSeparator+Copy(st, Length(st)-1, 2)+'ʰᵉˣ';
end;

end.
