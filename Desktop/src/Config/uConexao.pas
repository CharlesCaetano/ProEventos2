unit uConexao;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - Módulo de Conexão
  Descrição: Gerenciador singleton de conexão com Firebird 5
  Padrão: Singleton + Factory
  ============================================================ }

interface

uses
  Classes, SysUtils, IBConnection, SQLDB;

type
  { TConexao - Singleton de conexão com o banco Firebird }
  TConexao = class
  private
    class var FInstance: TConexao;
    FConnection: TIBConnection;
    FTransaction: TSQLTransaction;
    FHost: string;
    FDatabase: string;
    FUser: string;
    FPassword: string;
    FPort: Integer;
    constructor CreatePrivate;
  public
    class function GetInstance: TConexao;
    class procedure ReleaseInstance;

    procedure Conectar;
    procedure Desconectar;
    function Conectado: Boolean;

    procedure IniciarTransacao;
    procedure Confirmar;
    procedure Cancelar;
    function EmTransacao: Boolean;

    property Connection: TIBConnection read FConnection;
    property Transaction: TSQLTransaction read FTransaction;
    property Host: string read FHost write FHost;
    property Database: string read FDatabase write FDatabase;
    property User: string read FUser write FUser;
    property Password: string read FPassword write FPassword;
    property Port: Integer read FPort write FPort;

    destructor Destroy; override;
  end;

implementation

{ TConexao }

constructor TConexao.CreatePrivate;
begin
  inherited Create;
  FConnection := TIBConnection.Create(nil);
  FTransaction := TSQLTransaction.Create(nil);
  FConnection.Transaction := FTransaction;
  FTransaction.DataBase := FConnection;

  // Valores padrão
  FHost := 'localhost';
  FDatabase := 'C:\Users\Charles\Documents\ProjetoERP\Banco\dados.fdb';
  FUser := 'SYSDBA';
  FPassword := 'masterkey';
  FPort := 3050;
end;

class function TConexao.GetInstance: TConexao;
begin
  if FInstance = nil then
    FInstance := TConexao.CreatePrivate;
  Result := FInstance;
end;

class procedure TConexao.ReleaseInstance;
begin
  if FInstance <> nil then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

procedure TConexao.Conectar;
begin
  if not FConnection.Connected then
  begin
    FConnection.HostName := FHost;
    FConnection.DatabaseName := FDatabase;
    FConnection.UserName := FUser;
    FConnection.Password := FPassword;
    FConnection.Port := FPort;
    FConnection.CharSet := 'UTF8';
    FConnection.Connected := True;
  end;
end;

procedure TConexao.Desconectar;
begin
  if FConnection.Connected then
    FConnection.Connected := False;
end;

function TConexao.Conectado: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TConexao.IniciarTransacao;
begin
  if not FTransaction.Active then
    FTransaction.StartTransaction;
end;

procedure TConexao.Confirmar;
begin
  if FTransaction.Active then
    FTransaction.Commit;
end;

procedure TConexao.Cancelar;
begin
  if FTransaction.Active then
    FTransaction.Rollback;
end;

function TConexao.EmTransacao: Boolean;
begin
  Result := FTransaction.Active;
end;

destructor TConexao.Destroy;
begin
  Desconectar;
  FTransaction.Free;
  FConnection.Free;
  inherited Destroy;
end;

initialization

finalization
  TConexao.ReleaseInstance;

end.
