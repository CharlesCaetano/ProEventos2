unit uFrmInventario;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - FASE 3 - Inventário de Estoque
  Descrição: Posição atual de estoque de todos os produtos
  ============================================================ }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DBGrids, DB, SQLDB, ComCtrls,
  uConexao;

type
  { TfrmInventario }
  TfrmInventario = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlFiltro: TPanel;
    edtPesquisa: TEdit;
    btnPesquisar: TBitBtn;
    chkApenasComEstoque: TCheckBox;
    chkAbaixoMinimo: TCheckBox;
    btnFechar: TBitBtn;
    dbGrid: TDBGrid;
    DataSource1: TDataSource;
    pnlResumo: TPanel;
    lblTotalItens: TLabel;
    lblValorTotal: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure chkApenasComEstoqueChange(Sender: TObject);
    procedure chkAbaixoMinimoChange(Sender: TObject);
  private
    FConexao: TConexao;
    FQuery: TSQLQuery;
    procedure CarregarInventario;
  end;

var
  frmInventario: TfrmInventario;

implementation

{$R *.lfm}

procedure TfrmInventario.FormCreate(Sender: TObject);
begin
  FConexao := TConexao.GetInstance;
  FQuery := TSQLQuery.Create(Self);
  FQuery.DataBase := FConexao.Connection;
  FQuery.Transaction := FConexao.Transaction;
  CarregarInventario;
end;

procedure TfrmInventario.CarregarInventario;
var
  LSQL, LWhere: string;
begin
  LSQL :=
    'SELECT P.ID, P.CODIGO, P.DESCRICAO, ' +
    'COALESCE(E.QUANTIDADE, 0) AS QTD_ATUAL, ' +
    'P.ESTOQUE_MINIMO, P.ESTOQUE_MAXIMO, ' +
    'P.PRECO_CUSTO, P.PRECO_VENDA, ' +
    '(COALESCE(E.QUANTIDADE, 0) * P.PRECO_CUSTO) AS VALOR_ESTOQUE ' +
    'FROM PRODUTO P ' +
    'LEFT JOIN ESTOQUE E ON E.PRODUTO_ID = P.ID ' +
    'WHERE P.CONTROLA_ESTOQUE = ''S'' AND P.ATIVO = ''A''';

  if Trim(edtPesquisa.Text) <> '' then
    LSQL := LSQL + Format(
      ' AND (UPPER(P.DESCRICAO) CONTAINING UPPER(''%s'') OR P.CODIGO CONTAINING ''%s'')',
      [edtPesquisa.Text, edtPesquisa.Text]);

  if chkApenasComEstoque.Checked then
    LSQL := LSQL + ' AND COALESCE(E.QUANTIDADE, 0) > 0';

  if chkAbaixoMinimo.Checked then
    LSQL := LSQL + ' AND COALESCE(E.QUANTIDADE, 0) < P.ESTOQUE_MINIMO AND P.ESTOQUE_MINIMO > 0';

  LSQL := LSQL + ' ORDER BY P.DESCRICAO';

  FQuery.Close;
  FQuery.SQL.Text := LSQL;
  FQuery.Open;
  DataSource1.DataSet := FQuery;

  // Resumo
  FQuery.Last;
  lblTotalItens.Caption := Format('Total Itens: %d', [FQuery.RecordCount]);
  FQuery.First;

  // Calcular valor total
  var LTotal: Double := 0;
  while not FQuery.EOF do
  begin
    LTotal := LTotal + FQuery.FieldByName('VALOR_ESTOQUE').AsFloat;
    FQuery.Next;
  end;
  FQuery.First;
  lblValorTotal.Caption := Format('Valor Total Estoque: R$ %s', [FormatFloat('#,##0.00', LTotal)]);
end;

procedure TfrmInventario.btnPesquisarClick(Sender: TObject);
begin
  CarregarInventario;
end;

procedure TfrmInventario.chkApenasComEstoqueChange(Sender: TObject);
begin
  CarregarInventario;
end;

procedure TfrmInventario.chkAbaixoMinimoChange(Sender: TObject);
begin
  CarregarInventario;
end;

procedure TfrmInventario.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
