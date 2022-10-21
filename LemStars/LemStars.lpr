program LemStars;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazopenglcontext, Main, About, Constell, Lines, Stat, Info, Find,
  View, Tools, options, MyUtils, brightness;

{$R *.res}

begin
  Application.Title:='Lemizh Stars';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFindForm, FindForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TToolsForm, ToolsForm);
  Application.CreateForm(TViewForm, ViewForm);
  Application.Run;
end.

