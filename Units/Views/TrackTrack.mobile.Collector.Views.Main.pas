unit TrackTrack.mobile.Collector.Views.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Maps, FMX.ExtCtrls, FMX.Edit,
  FMX.ListBox, System.Sensors, System.Sensors.Components, Generics.Collections,
  FMX.TabControl, System.Messaging, FMX.MediaLibrary, FMX.Platform,
  System.Math.Vectors, FMX.Controls3D, System.Actions, FMX.ActnList,
  FMX.StdActns, FMX.MediaLibrary.Actions, TrackTrack.mobile.Collector.Interfaces.TrackTrack,
  TrackTrack.mobile.Collector.Interfaces.Proxy.TrackTrack, SynCrossPlatformREST;

type
  TFrmMain = class(TForm)
    Header: TToolBar;
    HeaderLabel: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    GridPanelLayout2: TGridPanelLayout;
    Label1: TLabel;
    comboRoute: TComboBox;
    Label2: TLabel;
    Edit1: TEdit;
    Label3: TLabel;
    ImageViewer: TImageViewer;
    ButtonsLayout: TGridPanelLayout;
    ActiveButton: TButton;
    InactiveButton: TButton;
    StopButton: TButton;
    CleanButton: TButton;
    SaveButton: TButton;
    LocationSensor: TLocationSensor;
    PointCountLabel: TLabel;
    MapView: TMapView;
    Camera1: TCamera;
    ActionList: TActionList;
    TakePhotoFromCameraAction: TTakePhotoFromCameraAction;
    procedure ActiveButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CleanButtonClick(Sender: TObject);
    procedure LocationSensorLocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure InactiveButtonClick(Sender: TObject);
    procedure TakePhotoFromCameraActionDidFinishTaking(Image: TBitmap);
    procedure ImageViewerClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FTrackTrack: TTrackTrackInterface;
    FPointList: array of TRoutePoint;
    FStopsList: array of TRouteStop;
    FMarkerList: array of TMapMarker;

    procedure ActiveCloseDialog(const AResult: TModalResult);
    procedure InactiveCloseDialog(const AResult: TModalResult);
    procedure TerminalCloseDialog(const AResult: TModalResult);
    procedure CleanCloseDialog(const AResult: TModalResult);
    procedure SaveCloseDialog(const AResult: TModalResult);
    procedure SaveConfirmCloseDialog(const AResult: TModalResult);
    procedure LoadRoutes;
    procedure FreePoints;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  FMX.DialogService;

{$R *.fmx}

procedure TFrmMain.ActiveButtonClick(Sender: TObject);
begin
  TDialogService.MessageDialog('¿Activar?', TMsgDlgType.mtInformation, mbYesNo, TMsgDlgBtn.mbYes, 0, Self.ActiveCloseDialog);
end;

procedure TFrmMain.ActiveCloseDialog(const AResult: TModalResult);
begin
  if AResult = mrYes then
  begin
    Self.ActiveButton.Enabled := False;
    Self.InactiveButton.Enabled := True;
    Self.LocationSensor.Active := True;
  end;
end;

procedure TFrmMain.CleanButtonClick(Sender: TObject);
begin
  TDialogService.MessageDialog('¿Limpiar?', TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbYes, 0, Self.CleanCloseDialog);
end;

procedure TFrmMain.CleanCloseDialog(const AResult: TModalResult);
var
  I: Integer;
begin
  if AResult = mrYes then
  begin
    Self.FreePoints;
    Self.FPointList := nil;
    Self.FStopsList := nil;
    Self.FMarkerList := nil;
    Self.PointCountLabel.Text := '0 puntos recolectados';
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Self.FTrackTrack := TTrackTrackInterface.Create;
  Self.LoadRoutes;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  Self.FTrackTrack.Free;
  Self.FreePoints;
  Self.FPointList := nil;
  Self.FStopsList := nil;
  Self.FMarkerList := nil;
end;

procedure TFrmMain.FreePoints;
var
  I: Integer;
begin
  for I := 0 to Length(Self.FPointList) - 1 do
    Self.FPointList[I].Free;
  for I := 0 to Length(Self.FStopsList) - 1 do
    Self.FStopsList[I].Free;
  for I := 0 to Length(Self.FMarkerList) - 1 do
    Self.FMarkerList[I].DisposeOf;
end;

procedure TFrmMain.SaveButtonClick(Sender: TObject);
begin
  TDialogService.MessageDialog('¿Guardar?', TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbYes, 0, Self.SaveCloseDialog);
end;

procedure TFrmMain.SaveCloseDialog(const AResult: TModalResult);
begin
  if Self.FTrackTrack.ExistsPointsForRoute(Self.comboRoute.ItemIndex) then
    TDialogService.MessageDialog('Ya existen puntos para esta ruta.¿Sobrescribir?', TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbYes, 0, Self.SaveConfirmCloseDialog)
  else
    Self.FTrackTrack.SaveRoutePoints(Self.FPointList, Self.FStopsList);
end;

procedure TFrmMain.SaveConfirmCloseDialog(const AResult: TModalResult);
begin
  Self.FTrackTrack.SaveRoutePoints(Self.FPointList, Self.FStopsList);
end;

procedure TFrmMain.StopButtonClick(Sender: TObject);
begin
  TDialogService.MessageDialog('¿Parada?', TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbYes, 0, Self.TerminalCloseDialog);
end;

procedure TFrmMain.TakePhotoFromCameraActionDidFinishTaking(Image: TBitmap);
begin
  Self.ImageViewer.Bitmap.Assign(Image);
  Self.ImageViewer.BestFit;
end;

procedure TFrmMain.TerminalCloseDialog(const AResult: TModalResult);
var
  Point: TRouteStop;
begin
  if AResult = mrYes then
  begin
    Point := TRouteStop.Create;
    try
      with Point do
      begin
        Latitude := Self.LocationSensor.Sensor.Latitude;
        Longitude := Self.LocationSensor.Sensor.Longitude;
        Altitude := Self.LocationSensor.Sensor.Altitude;
        Heading := Self.LocationSensor.Sensor.TrueHeading;
      end;
      SetLength(Self.FStopsList, Length(Self.FStopsList) + 1);
      Self.FStopsList[Length(Self.FStopsList) - 1] := Point;
    except
      Point.Free;
      raise;
    end;
  end;
end;

procedure TFrmMain.ImageViewerClick(Sender: TObject);
begin
  Self.TakePhotoFromCameraAction.Execute;
end;

procedure TFrmMain.InactiveButtonClick(Sender: TObject);
begin
  TDialogService.MessageDialog('¿Desactivar?', TMsgDlgType.mtInformation, mbYesNo, TMsgDlgBtn.mbYes, 0, Self.InactiveCloseDialog);
end;

procedure TFrmMain.InactiveCloseDialog(const AResult: TModalResult);
begin
  if AResult = mrYes then
  begin
    Self.ActiveButton.Enabled := True;
    Self.InactiveButton.Enabled := False;
    Self.LocationSensor.Active := FAlse;
  end;
end;

procedure TFrmMain.LoadRoutes;
var
  Route: TRoute;
  Zone: TZone;
begin
  Route := Self.FTrackTrack.GetAllRoutes;
  try
    Self.comboRoute.Clear;
    while Route.FillOne do
    begin
      Zone := Self.FTrackTrack.GetZoneById(Route.Zone);
      try
        Self.comboRoute.Items.Add(Format('%s (Zona %s)', [Route.Name, Zone.Name]));
      finally
        Zone.Free;
      end;
    end;
  finally
    Route.Free;
  end;
end;

procedure TFrmMain.LocationSensorLocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  Position: TMapCoordinate;
  MarkerDesc: TMapMarkerDescriptor;
  Point: TRoutePoint;
begin
  Point := TRoutePoint.Create;
  try
    with Point do
    begin
      Latitude := NewLocation.Latitude;
      Longitude := NewLocation.Longitude;
      Altitude := Self.LocationSensor.Sensor.Altitude;
      Heading := Self.LocationSensor.Sensor.TrueHeading;
    end;
    Self.PointCountLabel.Text := Format('%d puntos recolectados', [Length(Self.FPointList) + 1]);

    Position := TMapCoordinate.Create(NewLocation.Latitude, NewLocation.Longitude);
    MarkerDesc := TMapMarkerDescriptor.Create(Position);
    MarkerDesc.Draggable := False;
    MarkerDesc.Opacity := 0.8;
    MarkerDesc.Title := 'P' + IntToStr(Length(Self.FPointList) + 1);
    MarkerDesc.Snippet := Position.ToString;
    MarkerDesc.Appearance := TMarkerAppearance.Flat;
    MarkerDesc.Visible := True;
    SetLength(Self.FMarkerList, Length(Self.FMarkerList) + 1);
    Self.FMarkerList[Length(Self.FMarkerList) - 1] := Self.MapView.AddMarker(MarkerDesc);

    Self.MapView.Location := Position;
    Self.MapView.Zoom := 14;
    Self.MapView.Move;

    SetLength(Self.FPointList, Length(Self.FPointList) + 1);
    Self.FPointList[Length(Self.FPointList) - 1] := Point;
  except
    Point.Free;
    raise;
  end;
end;

end.

