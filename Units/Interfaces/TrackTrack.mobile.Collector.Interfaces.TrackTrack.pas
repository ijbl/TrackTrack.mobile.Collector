unit TrackTrack.mobile.Collector.Interfaces.TrackTrack;

interface

uses
  SysUtils,
  SynCrossPlatformJSON,
  SynCrossPlatformSpecific,
  SynCrossPlatformREST,
  TrackTrack.mobile.Collector.Interfaces.Proxy.TrackTrack;

type
  TTrackTrackInterface = class
  private
    FClient: TSQLRestClientHTTP;

    function CreateModel: TSQLModel;
  public
    constructor Create;
    destructor Destroy; override;

    function GetAllRoutes: TRoute;
    function GetZoneById(const ZoneId: TID): TZone;
    function ExistsPointsForRoute(const RouteId: TID): Boolean;
    procedure SaveRoutePoints(const RoutePoints: array of TRoutePoint; const RouteStops: array of TRouteStop);
  end;

implementation

uses
  TrackTrack.mobile.Collector.Misc.Globals;

{ TTrackTrackInterface }

constructor TTrackTrackInterface.Create;
begin
  Self.FClient := TSQLRestClientHTTP.Create(
    TRACKTRACK_IP,
    TRACKTRACK_PORT,
    Self.CreateModel,
    True,
    False
  );
  try
    if (not Self.FClient.Connect) or (Self.FClient.ServerTimeStamp = 0) then
      raise ERestException.CreateFmt('Impossible to connect to %s:%d server', [TRACKTRACK_IP, TRACKTRACK_PORT]);
  except
    Self.FClient.Free;
    raise;
  end;
end;

function TTrackTrackInterface.CreateModel: TSQLModel;
begin
  Result := TSQLModel.Create(
    [
      TCountry,
      TState,
      TCity,
      TZone,
      TRoute,
      TRouteCode,
      TRoutePoint
    ],
    TRACKTRACK_ROOT
  );
end;

destructor TTrackTrackInterface.Destroy;
begin
  Self.FClient.Free;
  inherited;
end;

function TTrackTrackInterface.ExistsPointsForRoute(const RouteId: TID): Boolean;
var
  RoutePoint: TRoutePoint;
begin
  RoutePoint := TRoutePoint.CreateAndFillPrepare(Self.FClient, 'id', 'route=?', [RouteId]);
  try
    Result := RoutePoint.FillOne;
  finally
    RoutePoint.Free;
  end;
end;

function TTrackTrackInterface.GetAllRoutes: TRoute;
begin
  Result := TRoute.CreateAndFillPrepare(Self.FClient, 'name,zone', '', []);
end;

function TTrackTrackInterface.GetZoneById(const ZoneId: TID): TZone;
begin
  Result := TZone.Create(Self.FClient, ZoneId);
end;

procedure TTrackTrackInterface.SaveRoutePoints(
  const RoutePoints: array of TRoutePoint;
  const RouteStops: array of TRouteStop);
var
  I: Integer;
  Rs: TIDDynArray;
begin
  Self.FClient.BatchStart(TRoutePoint);
  try
    for I := 0 to Length(RoutePoints) - 1 do
      Self.FClient.BatchAdd(RoutePoints[I], True);
    if Self.FClient.BatchSend(Rs) <> HTTP_SUCCESS then
      raise Exception.Create('Error al guardar los puntos de la ruta.');
    if Length(Rs) <> Length(RoutePoints) then
      raise Exception.Create('Error: No se guardaron todos los puntos de la ruta');
  except
    Self.FClient.BatchAbort;
    raise;
  end;

  Self.FClient.BatchStart(TRouteStop);
  try
    for I := 0 to Length(RouteStops) - 1 do
      Self.FClient.BatchAdd(RouteStops[I], True);
    if Self.FClient.BatchSend(Rs) <> HTTP_SUCCESS then
      raise Exception.Create('Error al guardar las paradas de la ruta.');
    if Length(Rs) <> Length(RouteStops) then
      raise Exception.Create('Error: No se guardaron todas las paradas de la ruta');
  except
    Self.FClient.BatchAbort;
    raise;
  end;
end;

end.