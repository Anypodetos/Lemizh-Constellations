unit Options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls;

type

  { TOptionsForm }

  TOptionsForm = class(TForm)
    Bevel: TBevel;
    CancelBtn: TBitBtn;
    JSCheckBox: TCheckBox;
    HostEdit: TEdit;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    OKBtn: TBitBtn;
    PasswordEdit: TEdit;
    ShowWinCheckBox: TCheckBox;
    UploadCheckBox: TCheckBox;
    UploadPathEdit: TEdit;
    UserEdit: TEdit;
  private

  public

  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.lfm}

end.

