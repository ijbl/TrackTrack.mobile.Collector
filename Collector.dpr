program Collector;

uses
  System.StartUpCopy,
  FMX.Forms,
  TrackTrack.mobile.Collector.Views.Main in 'Units\Views\TrackTrack.mobile.Collector.Views.Main.pas' {FrmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
