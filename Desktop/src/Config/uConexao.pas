unit uConexao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, IBConnection;

type
  TConexao = class
  private
    class var FInstance: TConexao;
    constructor CreatePrivate;
  public
    Connection: TIBConnection;
    Transaction: TSQLTransaction;
    Host: string;
    Database: string;
    User: string;
    Password: string;
    Port: Integer;

    class function GetInstance: TConexao;
    class procedure ReleaseInstance;

    procedure Conectar;
    procedure Desconectar;
    function Conectado: Boolean;

    procedure IniciarTransacao;
    procedure Confirmar;
    procedure Cancelar;
    function EmTransacao: Boolean;

    destructor Destroy; override;
  end;

implementation

constructor TConexao.CreatePrivate;
begin
  inherited Create;
  Connection := TIBConnection.Create(nil);
  Transaction := TSQLTransaction.Create(nil);
  Connection.Transaction := Transaction;
  Transaction.DataBase := Connection;
  Host := 'localhost';
  Database := 'C:\Users\Charles\Documents\ProjetoERP\Banco\dados.fdb';
  User := 'SYSDBA';
  Password := 'masterkey';
  Port := 3050;
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
  if not Connection.Connected then
  begin
    Connection.HostName := Host;
    Connection.DatabaseName := Database;
    Connection.UserName := User;
    Connection.Password := Password;
    Connection.CharSet := 'UTF8';
    Connection.Connected := True;
  end;
end;

procedure TConexao.Desconectar;
begin
  if Connection.Connected then
    Connection.Connected := False;
end;

function TConexao.Conectado: Boolean;
begin
  Result := Connection.Connected;
end;

procedure TConexao.IniciarTransacao;
begin
  if not Transaction.Active then
    Transaction.StartTransaction;
end;

procedure TConexao.Confirmar;
begin
  if Transaction.Active then
    Transaction.Commit;
end;

procedure TConexao.Cancelar;
begin
  if Transaction.Active then
    Transaction.Rollback;
end;

function TConexao.EmTransacao: Boolean;
begin
  Result := Transaction.Active;
end;

destructor TConexao.Destroy;
begin
  Desconectar;
  Transaction.Free;
  Connection.Free;
  inherited Destroy;
end;

initialization

finalization
  TConexao.ReleaseInstance;

end.
