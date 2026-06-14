unit uSessao;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - Gerenciador de Sessão
  Descrição: Controle de sessão do usuário logado
  Padrão: Singleton
  ============================================================ }

interface

uses
  Classes, SysUtils;

type
  { TSessao - Dados do usuário logado }
  TSessao = class
  private
    class var FInstance: TSessao;
    FUsuarioId: Int64;
    FEmpresaId: Int64;
    FUsuarioNome: string;
    FUsuarioLogin: string;
    FAdministrador: Boolean;
    FGrupoId: Int64;
    FLogado: Boolean;
    FDataLogin: TDateTime;
    constructor CreatePrivate;
  public
    class function GetInstance: TSessao;
    class procedure ReleaseInstance;

    procedure Logar(AUsuarioId, AEmpresaId, AGrupoId: Int64;
      const ANome, ALogin: string; AAdmin: Boolean);
    procedure Deslogar;

    property UsuarioId: Int64 read FUsuarioId;
    property EmpresaId: Int64 read FEmpresaId;
    property UsuarioNome: string read FUsuarioNome;
    property UsuarioLogin: string read FUsuarioLogin;
    property Administrador: Boolean read FAdministrador;
    property GrupoId: Int64 read FGrupoId;
    property Logado: Boolean read FLogado;
    property DataLogin: TDateTime read FDataLogin;
  end;

implementation

{ TSessao }

constructor TSessao.CreatePrivate;
begin
  inherited Create;
  FLogado := False;
  FUsuarioId := 0;
  FEmpresaId := 0;
  FGrupoId := 0;
end;

class function TSessao.GetInstance: TSessao;
begin
  if FInstance = nil then
    FInstance := TSessao.CreatePrivate;
  Result := FInstance;
end;

class procedure TSessao.ReleaseInstance;
begin
  if FInstance <> nil then
  begin
    FInstance.Free;
    FInstance := nil;
  end;
end;

procedure TSessao.Logar(AUsuarioId, AEmpresaId, AGrupoId: Int64;
  const ANome, ALogin: string; AAdmin: Boolean);
begin
  FUsuarioId := AUsuarioId;
  FEmpresaId := AEmpresaId;
  FGrupoId := AGrupoId;
  FUsuarioNome := ANome;
  FUsuarioLogin := ALogin;
  FAdministrador := AAdmin;
  FLogado := True;
  FDataLogin := Now;
end;

procedure TSessao.Deslogar;
begin
  FLogado := False;
  FUsuarioId := 0;
  FEmpresaId := 0;
  FGrupoId := 0;
  FUsuarioNome := '';
  FUsuarioLogin := '';
  FAdministrador := False;
end;

initialization

finalization
  TSessao.ReleaseInstance;

end.
