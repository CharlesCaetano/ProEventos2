unit uConexao;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - Módulo de Conexão
  Descrição: Gerenciador singleton de conexão com Firebird 5
  Padrão: Singleton + Factory
  ============================================================ }

interface

uses
  Classes, SysUtils, SQLDB, IBConnection;

type
  { TConexao - Singleton de conexão com o banco Firebird }
  TConexao = class
  private
    class var FInstance: TConexao;
    FHost: string;
    FDatabase: string;
    FUser: string;
    FPassword: string;
    FPort: Integer;
    constructor CreatePrivate;
  public
    Connection: TIBConnection;
    Transaction: TSQLTransaction;

    class function GetInstance: TConexao;
    class procedure ReleaseInstance;

    procedure Conectar;
    procedure Desconectar;
    function Conectado: Boolean;

    procedure IniciarTransacao;
    procedure Confirmar;
    procedure Cancelar;
    function EmTransacao: Boolean;

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
  Connection := TIBConnection.Create(nil);
  Transaction := TSQLTransaction.Create(nil);
  Connection.Transaction := Transaction;
  Transaction.DataBase := Connection;

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
  if not Connection.Connected then
  begin
    Connection.HostName := FHost;
    Connection.DatabaseName := FDatabase;
    Connection.UserName := FUser;
    Connection.Password := FPassword;
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
