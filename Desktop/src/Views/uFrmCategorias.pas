unit uFrmCategorias;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - FASE 2 - Formulário de Categorias
  Descrição: CRUD de Categorias de Produtos
  ============================================================ }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DBGrids, DB, SQLDB, ComCtrls,
  uFrmCadastroBase, uConexao, uSessao;

type
  { TfrmCategorias }
  TfrmCategorias = class(TfrmCadastroBase)
    lblNome: TLabel;
    edtNome: TEdit;
    lblDescricao: TLabel;
    edtDescricao: TEdit;
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
  end;

var
  frmCategorias: TfrmCategorias;

implementation

{$R *.lfm}

{ TfrmCategorias }

procedure TfrmCategorias.FormCreate(Sender: TObject);
begin
  inherited;
  FQuery := TSQLQuery.Create(Self);
  FQuery.DataBase := FConexao.Connection;
  FQuery.Transaction := FConexao.Transaction;

  lblTitulo.Caption := 'Cadastro de Categorias';
  Caption := 'Categorias';
  CarregarDados;
end;

procedure TfrmCategorias.CarregarDados(const AFiltro: string);
var
  LSQL: string;
begin
  LSQL := 'SELECT ID, NOME, DESCRICAO, STATUS FROM CATEGORIA';
  if AFiltro <> '' then
    LSQL := LSQL + Format(' WHERE UPPER(NOME) CONTAINING UPPER(''%s'')', [AFiltro]);
  LSQL := LSQL + ' ORDER BY NOME';

  FQuery.Close;
  FQuery.SQL.Text := LSQL;
  FQuery.Open;
  DataSource1.DataSet := FQuery;
end;

procedure TfrmCategorias.HabilitarCampos(AHabilitar: Boolean);
begin
  edtNome.Enabled := AHabilitar;
  edtDescricao.Enabled := AHabilitar;
  cmbStatus.Enabled := AHabilitar;
end;

procedure TfrmCategorias.LimparCampos;
begin
  edtNome.Clear;
  edtDescricao.Clear;
  cmbStatus.ItemIndex := 0;
end;

procedure TfrmCategorias.PreencherCampos;
var
  LQuery: TSQLQuery;
begin
  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text := 'SELECT * FROM CATEGORIA WHERE ID = :ID';
    LQuery.ParamByName('ID').AsLargeInt := FIdSelecionado;
    LQuery.Open;
    if not LQuery.IsEmpty then
    begin
      edtNome.Text := LQuery.FieldByName('NOME').AsString;
      edtDescricao.Text := LQuery.FieldByName('DESCRICAO').AsString;
      if LQuery.FieldByName('STATUS').AsString = 'A' then
        cmbStatus.ItemIndex := 0
      else
        cmbStatus.ItemIndex := 1;
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TfrmCategorias.PreencherObjeto;
begin
end;

function TfrmCategorias.Validar: Boolean;
begin
  Result := False;
  if Trim(edtNome.Text) = '' then
  begin
    MessageDlg('O campo Nome é obrigatório.', mtWarning, [mbOK], 0);
    edtNome.SetFocus;
    Exit;
  end;
  Result := True;
end;

function TfrmCategorias.Salvar: Boolean;
var
  LQuery: TSQLQuery;
begin
  Result := False;
  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;

    if FEstado = efInserindo then
    begin
      LQuery.SQL.Text :=
        'INSERT INTO CATEGORIA (EMPRESA_ID, NOME, DESCRICAO, STATUS) ' +
        'VALUES (:EMP, :NOME, :DESC, :STATUS)';
      LQuery.ParamByName('EMP').AsLargeInt := TSessao.GetInstance.EmpresaId;
    end
    else
    begin
      LQuery.SQL.Text :=
        'UPDATE CATEGORIA SET NOME = :NOME, DESCRICAO = :DESC, STATUS = :STATUS WHERE ID = :ID';
      LQuery.ParamByName('ID').AsLargeInt := FIdSelecionado;
    end;

    LQuery.ParamByName('NOME').AsString := edtNome.Text;
    LQuery.ParamByName('DESC').AsString := edtDescricao.Text;
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

function TfrmCategorias.Excluir: Boolean;
var
  LQuery: TSQLQuery;
begin
  Result := False;
  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text := 'DELETE FROM CATEGORIA WHERE ID = :ID';
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
