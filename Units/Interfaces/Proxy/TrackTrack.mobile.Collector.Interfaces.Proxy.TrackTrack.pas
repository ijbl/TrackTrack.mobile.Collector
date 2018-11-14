/// remote access to a mORMot server using SynCrossPlatform* units
// - retrieved from http://192.168.1.6:888/tracktrack/wrapper/CrossPlatform/mORMotClient.pas
// at 2018-11-12 20:05:11 using "CrossPlatform.pas.mustache" template
unit TrackTrack.mobile.Collector.Interfaces.Proxy.TrackTrack;

{
  WARNING:
    This unit has been generated by a mORMot 1.18.4864 server.
    Any manual modification of this file may be lost after regeneration.

  Synopse mORMot framework. Copyright (C) 2018 Arnaud Bouchez
    Synopse Informatique - http://synopse.info

  This unit is released under a MPL/GPL/LGPL tri-license,
  and therefore may be freely included in any application.

  This unit would work on Delphi 6 and later, under all supported platforms
  (including MacOSX, and NextGen iPhone/iPad), and the Free Pascal Compiler.
}

interface

uses
  SynCrossPlatformJSON,
  SynCrossPlatformSpecific,
  SynCrossPlatformREST;



type
  /// map "Country" table
  TCountry = class(TSQLRecord)
  protected
    fName: String;
    fIsoCode: String;
  published
    property Name: String index 100 read fName write fName;
    property IsoCode: String index 3 read fIsoCode write fIsoCode;
  end;

  /// map "State" table
  TState = class(TSQLRecord)
  protected
    fName: String;
    fIsoCode: String;
    fCountry: TID;
  published
    property Name: String index 100 read fName write fName;
    property IsoCode: String read fIsoCode write fIsoCode;
    // defined as Country: TCountry on the server
    property Country: TID read fCountry write fCountry;
  end;

  /// map "City" table
  TCity = class(TSQLRecord)
  protected
    fName: String;
    fIATA: String;
    fState: TID;
  published
    property Name: String index 50 read fName write fName;
    property IATA: String index 3 read fIATA write fIATA;
    // defined as State: TState on the server
    property State: TID read fState write fState;
  end;

  /// map "Zone" table
  TZone = class(TSQLRecord)
  protected
    fName: String;
    fCity: TID;
  published
    property Name: String index 50 read fName write fName;
    // defined as City: TCity on the server
    property City: TID read fCity write fCity;
  end;

  /// map "Route" table
  TRoute = class(TSQLRecord)
  protected
    fName: String;
    fZone: TID;
  published
    property Name: String index 200 read fName write fName;
    // defined as Zone: TZone on the server
    property Zone: TID read fZone write fZone;
  end;

  /// map "RouteCode" table
  TRouteCode = class(TSQLRecord)
  protected
    fRoute: TID;
    fName: String;
  published
    // defined as Route: TRoute on the server
    property Route: TID read fRoute write fRoute;
    property Name: String index 50 read fName write fName;
  end;

  /// map "RoutePoint" table
  TRoutePoint = class(TSQLRecord)
  protected
    fRoute: TID;
    fLatitude: Double;
    fLongitude: Double;
    fAltitude: Double;
    fHeading: Double;
  published
    // defined as Route: TRoute on the server
    property Route: TID read fRoute write fRoute;
    property Latitude: Double read fLatitude write fLatitude;
    property Longitude: Double read fLongitude write fLongitude;
    property Altitude: Double read fAltitude write fAltitude;
    property Heading: Double read fHeading write fHeading;
  end;

  /// map "RouteStop" table
  TRouteStop = class(TSQLRecord)
  protected
    fRoute: TID;
    fLatitude: Double;
    fLongitude: Double;
    fAltitude: Double;
    fHeading: Double;
  published
    // defined as Route: TRoute on the server
    property Route: TID read fRoute write fRoute;
    property Latitude: Double read fLatitude write fLatitude;
    property Longitude: Double read fLongitude write fLongitude;
    property Altitude: Double read fAltitude write fAltitude;
    property Heading: Double read fHeading write fHeading;
  end;

const
  /// the server port, corresponding to http://192.168.1.6:888
  SERVER_PORT = 888;
  /// the server model root name, corresponding to http://192.168.1.6:888
  SERVER_ROOT = 'tracktrack';


/// return the database Model corresponding to this server
function GetModel(const aRoot: string=SERVER_ROOT): TSQLModel;

/// create a TSQLRestClientHTTP instance and connect to the server
// - it will use by default port 888 over root 'tracktrack', corresponding
// to http://192.168.1.6:888/tracktrack
function GetClient(const aServerAddress: string;
  aServerPort: integer=SERVER_PORT; const aServerRoot: string=SERVER_ROOT;
  aHttps: boolean=false): TSQLRestClientHTTP;


implementation

{$HINTS OFF} // for H2164 hints of unused variables


{$HINTS ON} // for H2164 hints of unused variables

function GetModel(const aRoot: string): TSQLModel;
begin
  result := TSQLModel.Create([TCountry,TState,TCity,TZone,TRoute,TRouteCode,TRoutePoint,TRouteStop],aRoot);
end;

function GetClient(const aServerAddress: string;
  aServerPort: integer; const aServerRoot: string; aHttps: boolean): TSQLRestClientHTTP;
begin
  result := TSQLRestClientHTTP.Create(aServerAddress,aServerPort,
    GetModel(aServerRoot),true,aHttps); // aOwnModel=true
  try
    if (not result.Connect) or (result.ServerTimeStamp=0) then
      raise ERestException.CreateFmt('Impossible to connect to %s:%d server',
        [aServerAddress,aServerPort]);
  except
    result.Free;
    raise;
  end;
end;


end.
