program Cavalry;

uses
  Forms,
  UnitJeu in 'UnitJeu.pas',
  UnitHistorique in 'UnitHistorique.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title:='Cavalry';
  Application.CreateForm(TFormJeu, FormJeu);
  Application.Run;
end.

