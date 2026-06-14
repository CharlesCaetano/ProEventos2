unit uFrmKardex;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - FASE 3 - Kardex do Produto
  Descrição: Histórico de movimentações de um produto
  ============================================================ }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DBGrids, DB, SQLDB, ComCtrls,
  uConexao;

type
  { TfrmKardex }
  TfrmKardex = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlFiltro: TPanel;
    lblProduto: TLabel;
    edtProduto: TEdit;
    btnBuscar: TBitBtn;
    lblProdutoNome: TLabel;
    lblEstoqueAtual: TLabel;
    lblDataInicio: TLabel;
    dtpInicio: TDateTimePicker;
    lblDataFim: TLabel;
    dtpFim: TDateTimePicker;
    btnFiltrar: TBitBtn;
    btnFechar: TBitBtn;
    dbGrid: TDBGrid;
    DataSource1: TDataSource;
    pnlResumo: TPanel;
    lblTotalEntradas: TLabel;
    lblTotalSaidas: TLabel;
    lblSaldoFinal: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FConexao: TConexao;
    FQuery: TSQLQuery;
    FProdutoId: Int64;
    procedure CarregarKardex;
    procedure CarregarResumo;
  end;

var
  frmKardex: TfrmKardex;

implementation

{$R *.lfm}

procedure TfrmKardex.FormCreate(Sender: TObject);
begin
  FConexao := TConexao.GetInstance;
  FQuery := TSQLQuery.Create(Self);
  FQuery.DataBase := FConexao.Connection;
  FQuery.Transaction := FConexao.Transaction;
  FProdutoId := 0;
  dtpInicio.Date := IncMonth(Now, -3);
  dtpFim.Date := Now;
end;

procedure TfrmKardex.btnBuscarClick(Sender: TObject);
var
  LQuery: TSQLQuery;
begin
  if Trim(edtProduto.Text) = '' then Exit;

  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text :=
      'SELECT P.ID, P.DESCRICAO, COALESCE(E.QUANTIDADE, 0) AS ESTOQUE_ATUAL ' +
      'FROM PRODUTO P LEFT JOIN ESTOQUE E ON E.PRODUTO_ID = P.ID ' +
      'WHERE P.CODIGO = :COD OR P.CODIGO_BARRAS = :COD OR CAST(P.ID AS VARCHAR(20)) = :COD';
    LQuery.ParamByName('COD').AsString := Trim(edtProduto.Text);
    LQuery.Open;

    if not LQuery.IsEmpty then
    begin
      FProdutoId := LQuery.FieldByName('ID').AsLargeInt;
      lblProdutoNome.Caption := LQuery.FieldByName('DESCRICAO').AsString;
      lblEstoqueAtual.Caption := 'Estoque Atual: ' +
        FormatFloat('#,##0.0000', LQuery.FieldByName('ESTOQUE_ATUAL').AsFloat);
      CarregarKardex;
      CarregarResumo;
    end
    else
    begin
      MessageDlg('Produto não encontrado.', mtWarning, [mbOK], 0);
      FProdutoId := 0;
      lblProdutoNome.Caption := '';
      lblEstoqueAtual.Caption := '';
    end;
  finally
    LQuery.Free;
  end;
end;

procedure TfrmKardex.CarregarKardex;
begin
  if FProdutoId <= 0 then Exit;

  FQuery.Close;
  FQuery.SQL.Text :=
    'SELECT ME.DATA_MOVIMENTO, ' +
    'CASE ME.TIPO WHEN ''E'' THEN ''Entrada'' WHEN ''S'' THEN ''Saída'' ' +
    'WHEN ''A'' THEN ''Ajuste'' WHEN ''I'' THEN ''Inventário'' END AS TIPO, ' +
    'ME.QUANTIDADE, ME.CUSTO_UNITARIO, ' +
    '(ME.QUANTIDADE * ME.CUSTO_UNITARIO) AS VALOR_TOTAL, ' +
    'ME.DOCUMENTO, ME.OBSERVACAO ' +
    'FROM MOVIMENTO_ESTOQUE ME ' +
    'WHERE ME.PRODUTO_ID = :PROD ' +
    'AND ME.DATA_MOVIMENTO BETWEEN :DI AND :DF ' +
    'ORDER BY ME.DATA_MOVIMENTO';
  FQuery.ParamByName('PROD').AsLargeInt := FProdutoId;
  FQuery.ParamByName('DI').AsDate := dtpInicio.Date;
  FQuery.ParamByName('DF').AsDate := dtpFim.Date + 1;
  FQuery.Open;
  DataSource1.DataSet := FQuery;
end;

procedure TfrmKardex.CarregarResumo;
var
  LQuery: TSQLQuery;
begin
  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text :=
      'SELECT ' +
      'COALESCE(SUM(CASE WHEN TIPO IN (''E'',''A'') THEN QUANTIDADE ELSE 0 END), 0) AS ENTRADAS, ' +
      'COALESCE(SUM(CASE WHEN TIPO = ''S'' THEN QUANTIDADE ELSE 0 END), 0) AS SAIDAS ' +
      'FROM MOVIMENTO_ESTOQUE ' +
      'WHERE PRODUTO_ID = :PROD AND DATA_MOVIMENTO BETWEEN :DI AND :DF';
    LQuery.ParamByName('PROD').AsLargeInt := FProdutoId;
    LQuery.ParamByName('DI').AsDate := dtpInicio.Date;
    LQuery.ParamByName('DF').AsDate := dtpFim.Date + 1;
    LQuery.Open;

    lblTotalEntradas.Caption := 'Entradas: ' + FormatFloat('#,##0.0000', LQuery.FieldByName('ENTRADAS').AsFloat);
    lblTotalSaidas.Caption := 'Saídas: ' + FormatFloat('#,##0.0000', LQuery.FieldByName('SAIDAS').AsFloat);
    lblSaldoFinal.Caption := 'Saldo: ' + FormatFloat('#,##0.0000',
      LQuery.FieldByName('ENTRADAS').AsFloat - LQuery.FieldByName('SAIDAS').AsFloat);
  finally
    LQuery.Free;
  end;
end;

procedure TfrmKardex.btnFiltrarClick(Sender: TObject);
begin
  CarregarKardex;
  CarregarResumo;
end;

procedure TfrmKardex.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
