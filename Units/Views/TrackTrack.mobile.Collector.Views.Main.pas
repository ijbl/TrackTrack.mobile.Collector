unit TrackTrack.mobile.Collector.Views.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Controls.Presentation, FMX.Maps, FMX.ExtCtrls, FMX.Edit,
  FMX.ListBox, System.Sensors, System.Sensors.Components, Generics.Collections,
  FMX.TabControl, System.Messaging, FMX.MediaLibrary, FMX.Platform,
  System.Math.Vectors, FMX.Controls3D, System.Actions, FMX.ActnList,
  FMX.StdActns, FMX.MediaLibrary.Actions;

type
  TGPSPoint = class
  private
    FLatitude: Double;
    FLongitude: Double;
    FAltitude: Double;
    FHeading: Double;
  public
    property Latitude: Double read FLatitude write FLatitude;
    property Longitude: Double read FLongitude write FLongitude;
    property Altitude: Double read FAltitude write FAltitude;
    property Heading: Double read FHeading write FHeading;
  end;

  TFrmMain = class(TForm)
    Header: TToolBar;
    HeaderLabel: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    GridPanelLayout2: TGridPanelLayout;
    Label1: TLabel;
    ComboBox1: TComboBox;
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
    procedure FormDestroy(Sender: TObject);
    procedure CleanButtonClick(Sender: TObject);
    procedure LocationSensorLocationChanged(Sender: TObject; const OldLocation,
      NewLocation: TLocationCoord2D);
    procedure InactiveButtonClick(Sender: TObject);
    procedure TakePhotoFromCameraActionDidFinishTaking(Image: TBitmap);
    procedure ImageViewerClick(Sender: TObject);
  private
    FPointList: TList<TGPSPoint>;
    FStopsList: TList<TGPSPoint>;
    FMarkerList: TList<TMapMarker>;

    procedure ActiveCloseDialog(const AResult: TModalResult);
    procedure InactiveCloseDialog(const AResult: TModalResult);
    procedure TerminalCloseDialog(const AResult: TModalResult);
    procedure CleanCloseDialog(const AResult: TModalResult);
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
    Self.FPointList.Clear;
    Self.FStopsList.Clear;
    Self.PointCountLabel.Text := '0 puntos recolectados';

    for I := 0 to Self.FMarkerList.Count - 1 do
      Self.FMarkerList[I].DisposeOf;
    Self.FMarkerList.Clear;
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  Self.FPointList := TList<TGPSPoint>.Create;
  Self.FStopsList := TList<TGPSPoint>.Create;
  Self.FMarkerList := TList<TMapMarker>.Create;
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
  Point: TGPSPoint;
begin
  if AResult = mrYes then
  begin
    Point := TGPSPoint.Create;
    Self.FStopsList.Add(Point);
    with Point do
    begin
      Latitude := Self.LocationSensor.Sensor.Latitude;
      Longitude := Self.LocationSensor.Sensor.Longitude;
      Altitude := Self.LocationSensor.Sensor.Altitude;
      Heading := Self.LocationSensor.Sensor.TrueHeading;
    end;
  end;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  Self.FPointList.Clear;
  Self.FPointList.Free;
  Self.FStopsList.Clear;
  Self.FStopsList.Free;
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

procedure TFrmMain.LocationSensorLocationChanged(Sender: TObject;
  const OldLocation, NewLocation: TLocationCoord2D);
var
  Position: TMapCoordinate;
  MarkerDesc: TMapMarkerDescriptor;
begin
  Self.FPointList.Add(TGPSPoint.Create);
  with Self.FPointList.Last do
  begin
    Latitude := NewLocation.Latitude;
    Longitude := NewLocation.Longitude;
    Altitude := Self.LocationSensor.Sensor.Altitude;
    Heading := Self.LocationSensor.Sensor.TrueHeading;
  end;
  Self.PointCountLabel.Text := Format('%d puntos recolectados', [Self.FPointList.Count]);

  Position := TMapCoordinate.Create(NewLocation.Latitude, NewLocation.Longitude);
  MarkerDesc := TMapMarkerDescriptor.Create(Position);
  MarkerDesc.Draggable := False;
  MarkerDesc.Opacity := 0.8;
  MarkerDesc.Title := 'P' + IntToStr(Self.FPointList.Count);
  MarkerDesc.Snippet := Position.ToString;
  MarkerDesc.Appearance := TMarkerAppearance.Flat;
  MarkerDesc.Visible := True;
  Self.FMarkerList.Add(Self.MapView.AddMarker(MarkerDesc));

  Self.MapView.Location := Position;
  Self.MapView.Zoom := 14;
  Self.MapView.Move;
end;

end.

