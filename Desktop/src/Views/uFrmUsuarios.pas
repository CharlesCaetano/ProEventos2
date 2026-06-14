unit uFrmUsuarios;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - FASE 2 - Formulário de Usuários
  Descrição: CRUD de Usuários do sistema
  ============================================================ }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DBGrids, DB, SQLDB, ComCtrls,
  uFrmCadastroBase, uConexao, uSessao;

type
  { TfrmUsuarios }
  TfrmUsuarios = class(TfrmCadastroBase)
    lblNome: TLabel;
    edtNome: TEdit;
    lblLogin: TLabel;
    edtLogin: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    lblConfirmarSenha: TLabel;
    edtConfirmarSenha: TEdit;
    lblEmail: TLabel;
    edtEmail: TEdit;
    lblTelefone: TLabel;
    edtTelefone: TEdit;
    lblGrupo: TLabel;
    cmbGrupo: TComboBox;
    chkAdministrador: TCheckBox;
    lblStatus: TLabel;
    cmbStatus: TComboBox;
    procedure FormCreate(Sender: TObject);
  protected
    procedure HabilitarCampos(AHabilitar: Boolean); override;
    procedure LimparCampos; override;
    procedure PreencherCampos; override;
    procedure PreencherObjeto; override;
    function Validar: Boolean; override;
    procedure CarregarDados(const AFiltro: string = ''); override;
    function Salvar: Boolean; override;
    function Excluir: Boolean; override;
  private
    FQuery: TSQLQuery;
    procedure CarregarGrupos;
  end;

var
  frmUsuarios: TfrmUsuarios;

implementation

{$R *.lfm}

{ TfrmUsuarios }

procedure TfrmUsuarios.FormCreate(Sender: TObject);
begin
  inherited;
  FQuery := TSQLQuery.Create(Self);
  FQuery.DataBase := FConexao.Connection;
  FQuery.Transaction := FConexao.Transaction;

  lblTitulo.Caption := 'Cadastro de Usuários';
  Caption := 'Usuários';
  CarregarGrupos;
  CarregarDados;
end;

procedure TfrmUsuarios.CarregarGrupos;
var
  LQuery: TSQLQuery;
begin
  cmbGrupo.Items.Clear;
  cmbGrupo.Items.Add('');
  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text := 'SELECT ID, NOME FROM GRUPO WHERE STATUS = ''A'' ORDER BY NOME';
    LQuery.Open;
    while not LQuery.EOF do
    begin
      cmbGrupo.Items.AddObject(LQuery.FieldByName('NOME').AsString,
        TObject(PtrInt(LQuery.FieldByName('ID').AsLargeInt)));
      LQuery.Next;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TfrmUsuarios.CarregarDados(const AFiltro: string);
var
  LSQL: string;
begin
  LSQL := 'SELECT ID, NOME, LOGIN, EMAIL, ADMINISTRADOR, STATUS FROM USUARIO';
  if AFiltro <> '' then
    LSQL := LSQL + Format(' WHERE UPPER(NOME) CONTAINING UPPER(''%s'') OR UPPER(LOGIN) CONTAINING UPPER(''%s'')',
      [AFiltro, AFiltro]);
  LSQL := LSQL + ' ORDER BY NOME';

  FQuery.Close;
  FQuery.SQL.Text := LSQL;
  FQuery.Open;
  DataSource1.DataSet := FQuery;
end;

procedure TfrmUsuarios.HabilitarCampos(AHabilitar: Boolean);
begin
  edtNome.Enabled := AHabilitar;
  edtLogin.Enabled := AHabilitar;
  edtSenha.Enabled := AHabilitar;
  edtConfirmarSenha.Enabled := AHabilitar;
  edtEmail.Enabled := AHabilitar;
  edtTelefone.Enabled := AHabilitar;
  cmbGrupo.Enabled := AHabilitar;
  chkAdministrador.Enabled := AHabilitar;
  cmbStatus.Enabled := AHabilitar;
end;

procedure TfrmUsuarios.LimparCampos;
begin
  edtNome.Clear;
  edtLogin.Clear;
  edtSenha.Clear;
  edtConfirmarSenha.Clear;
  edtEmail.Clear;
  edtTelefone.Clear;
  cmbGrupo.ItemIndex := 0;
  chkAdministrador.Checked := False;
  cmbStatus.ItemIndex := 0;
end;

procedure TfrmUsuarios.PreencherCampos;
var
  LQuery: TSQLQuery;
begin
  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text := 'SELECT * FROM USUARIO WHERE ID = :ID';
    LQuery.ParamByName('ID').AsLargeInt := FIdSelecionado;
    LQuery.Open;
    if not LQuery.IsEmpty then
    begin
      edtNome.Text := LQuery.FieldByName('NOME').AsString;
      edtLogin.Text := LQuery.FieldByName('LOGIN').AsString;
      edtSenha.Text := '';
      edtConfirmarSenha.Text := '';
      edtEmail.Text := LQuery.FieldByName('EMAIL').AsString;
      edtTelefone.Text := LQuery.FieldByName('TELEFONE').AsString;
      chkAdministrador.Checked := LQuery.FieldByName('ADMINISTRADOR').AsString = 'S';

      if LQuery.FieldByName('STATUS').AsString = 'A' then
        cmbStatus.ItemIndex := 0
      else
        cmbStatus.ItemIndex := 1;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TfrmUsuarios.PreencherObjeto;
begin
end;

function TfrmUsuarios.Validar: Boolean;
begin
  Result := False;

  if Trim(edtNome.Text) = '' then
  begin
    MessageDlg('O campo Nome é obrigatório.', mtWarning, [mbOK], 0);
    edtNome.SetFocus;
    Exit;
  end;

  if Trim(edtLogin.Text) = '' then
  begin
    MessageDlg('O campo Login é obrigatório.', mtWarning, [mbOK], 0);
    edtLogin.SetFocus;
    Exit;
  end;

  // Senha obrigatória apenas para novos usuários
  if (FEstado = efInserindo) and (Trim(edtSenha.Text) = '') then
  begin
    MessageDlg('O campo Senha é obrigatório para novos usuários.', mtWarning, [mbOK], 0);
    edtSenha.SetFocus;
    Exit;
  end;

  if (edtSenha.Text <> '') and (edtSenha.Text <> edtConfirmarSenha.Text) then
  begin
    MessageDlg('As senhas não conferem.', mtWarning, [mbOK], 0);
    edtConfirmarSenha.SetFocus;
    Exit;
  end;

  if (edtSenha.Text <> '') and (Length(edtSenha.Text) < 6) then
  begin
    MessageDlg('A senha deve ter pelo menos 6 caracteres.', mtWarning, [mbOK], 0);
    edtSenha.SetFocus;
    Exit;
  end;

  Result := True;
end;

function TfrmUsuarios.Salvar: Boolean;
var
  LQuery: TSQLQuery;
  LAdmin: string;
begin
  Result := False;
  if chkAdministrador.Checked then LAdmin := 'S' else LAdmin := 'N';

  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;

    if FEstado = efInserindo then
    begin
      LQuery.SQL.Text :=
        'INSERT INTO USUARIO (EMPRESA_ID, NOME, LOGIN, SENHA, EMAIL, TELEFONE, ' +
        'ADMINISTRADOR, STATUS) VALUES (:EMP, :NOME, :LOGIN, :SENHA, :EMAIL, ' +
        ':TEL, :ADMIN, :STATUS)';
      LQuery.ParamByName('EMP').AsLargeInt := TSessao.GetInstance.EmpresaId;
      LQuery.ParamByName('SENHA').AsString := edtSenha.Text;
    end
    else
    begin
      if edtSenha.Text <> '' then
      begin
        LQuery.SQL.Text :=
          'UPDATE USUARIO SET NOME = :NOME, LOGIN = :LOGIN, SENHA = :SENHA, ' +
          'EMAIL = :EMAIL, TELEFONE = :TEL, ADMINISTRADOR = :ADMIN, STATUS = :STATUS ' +
          'WHERE ID = :ID';
        LQuery.ParamByName('SENHA').AsString := edtSenha.Text;
      end
      else
      begin
        LQuery.SQL.Text :=
          'UPDATE USUARIO SET NOME = :NOME, LOGIN = :LOGIN, EMAIL = :EMAIL, ' +
          'TELEFONE = :TEL, ADMINISTRADOR = :ADMIN, STATUS = :STATUS WHERE ID = :ID';
      end;
      LQuery.ParamByName('ID').AsLargeInt := FIdSelecionado;
    end;

    LQuery.ParamByName('NOME').AsString := edtNome.Text;
    LQuery.ParamByName('LOGIN').AsString := edtLogin.Text;
    LQuery.ParamByName('EMAIL').AsString := edtEmail.Text;
    LQuery.ParamByName('TEL').AsString := edtTelefone.Text;
    LQuery.ParamByName('ADMIN').AsString := LAdmin;

    if cmbStatus.ItemIndex = 0 then
      LQuery.ParamByName('STATUS').AsString := 'A'
    else
      LQuery.ParamByName('STATUS').AsString := 'I';

    LQuery.ExecSQL;
    FConexao.Confirmar;
    Result := True;
  except
    on E: Exception do
    begin
      FConexao.Cancelar;
      MessageDlg('Erro ao salvar: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
  LQuery.Free;
end;

function TfrmUsuarios.Excluir: Boolean;
var
  LQuery: TSQLQuery;
begin
  Result := False;

  if FIdSelecionado = TSessao.GetInstance.UsuarioId then
  begin
    MessageDlg('Não é possível excluir o próprio usuário logado.', mtError, [mbOK], 0);
    Exit;
  end;

  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text := 'DELETE FROM USUARIO WHERE ID = :ID';
    LQuery.ParamByName('ID').AsLargeInt := FIdSelecionado;
    LQuery.ExecSQL;
    FConexao.Confirmar;
    Result := True;
  except
    on E: Exception do
    begin
      FConexao.Cancelar;
      MessageDlg('Erro ao excluir: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
  LQuery.Free;
end;

end.
