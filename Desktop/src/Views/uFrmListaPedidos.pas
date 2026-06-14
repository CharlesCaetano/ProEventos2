unit uFrmListaPedidos;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - FASE 4 - Lista de Pedidos de Venda
  Descrição: Consulta e gerenciamento de pedidos
  ============================================================ }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DBGrids, DB, SQLDB, ComCtrls,
  uConexao, uFrmPedidoVenda;

type
  { TfrmListaPedidos }
  TfrmListaPedidos = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    pnlFiltro: TPanel;
    lblDataInicio: TLabel;
    dtpInicio: TDateTimePicker;
    lblDataFim: TLabel;
    dtpFim: TDateTimePicker;
    lblStatusFiltro: TLabel;
    cmbStatusFiltro: TComboBox;
    btnFiltrar: TBitBtn;
    pnlBotoes: TPanel;
    btnNovoPedido: TBitBtn;
    btnVisualizar: TBitBtn;
    btnFechar: TBitBtn;
    dbGrid: TDBGrid;
    DataSource1: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoPedidoClick(Sender: TObject);
    procedure btnVisualizarClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FConexao: TConexao;
    FQuery: TSQLQuery;
    procedure CarregarPedidos;
  end;

var
  frmListaPedidos: TfrmListaPedidos;

implementation

{$R *.lfm}

procedure TfrmListaPedidos.FormCreate(Sender: TObject);
begin
  FConexao := TConexao.GetInstance;
  FQuery := TSQLQuery.Create(Self);
  FQuery.DataBase := FConexao.Connection;
  FQuery.Transaction := FConexao.Transaction;

  dtpInicio.Date := IncMonth(Now, -1);
  dtpFim.Date := Now;
  cmbStatusFiltro.ItemIndex := 0;
  CarregarPedidos;
end;

procedure TfrmListaPedidos.CarregarPedidos;
var
  LSQL: string;
begin
  LSQL :=
    'SELECT PV.ID, PV.NUMERO, PV.DATA_EMISSAO, C.NOME AS CLIENTE, ' +
    'PV.TOTAL, ' +
    'CASE PV.STATUS WHEN ''P'' THEN ''Pendente'' WHEN ''A'' THEN ''Aprovado'' ' +
    'WHEN ''F'' THEN ''Faturado'' WHEN ''C'' THEN ''Cancelado'' END AS STATUS_DESC ' +
    'FROM PEDIDO_VENDA PV ' +
    'JOIN CLIENTE C ON C.ID = PV.CLIENTE_ID ' +
    'WHERE PV.DATA_EMISSAO BETWEEN :DI AND :DF';

  if cmbStatusFiltro.ItemIndex > 0 then
  begin
    case cmbStatusFiltro.ItemIndex of
      1: LSQL := LSQL + ' AND PV.STATUS = ''P''';
      2: LSQL := LSQL + ' AND PV.STATUS = ''A''';
      3: LSQL := LSQL + ' AND PV.STATUS = ''F''';
      4: LSQL := LSQL + ' AND PV.STATUS = ''C''';
    end;
  end;

  LSQL := LSQL + ' ORDER BY PV.NUMERO DESC';

  FQuery.Close;
  FQuery.SQL.Text := LSQL;
  FQuery.ParamByName('DI').AsDate := dtpInicio.Date;
  FQuery.ParamByName('DF').AsDate := dtpFim.Date + 1;
  FQuery.Open;
  DataSource1.DataSet := FQuery;
end;

procedure TfrmListaPedidos.btnNovoPedidoClick(Sender: TObject);
var
  LForm: TfrmPedidoVenda;
begin
  LForm := TfrmPedidoVenda.Create(Application);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
  CarregarPedidos;
end;

procedure TfrmListaPedidos.btnVisualizarClick(Sender: TObject);
begin
  if FQuery.IsEmpty then Exit;
  // TODO: Abrir pedido para visualização/edição
  MessageDlg('Pedido Nº ' + FQuery.FieldByName('NUMERO').AsString + #13#10 +
    'Cliente: ' + FQuery.FieldByName('CLIENTE').AsString + #13#10 +
    'Total: R$ ' + FormatFloat('#,##0.00', FQuery.FieldByName('TOTAL').AsFloat) + #13#10 +
    'Status: ' + FQuery.FieldByName('STATUS_DESC').AsString,
    mtInformation, [mbOK], 0);
end;

procedure TfrmListaPedidos.btnFiltrarClick(Sender: TObject);
begin
  CarregarPedidos;
end;

procedure TfrmListaPedidos.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
