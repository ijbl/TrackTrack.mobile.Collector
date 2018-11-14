program Collector;

uses
  System.StartUpCopy,
  FMX.Forms,
  TrackTrack.mobile.Collector.Views.Main in 'Units\Views\TrackTrack.mobile.Collector.Views.Main.pas' {FrmMain},
  TrackTrack.mobile.Collector.Interfaces.TrackTrack in 'Units\Interfaces\TrackTrack.mobile.Collector.Interfaces.TrackTrack.pas',
  TrackTrack.mobile.Collector.Misc.Globals in 'Units\Misc\TrackTrack.mobile.Collector.Misc.Globals.pas',
  TrackTrack.mobile.Collector.Interfaces.Proxy.TrackTrack in 'Units\Interfaces\Proxy\TrackTrack.mobile.Collector.Interfaces.Proxy.TrackTrack.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
