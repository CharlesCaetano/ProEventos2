unit uFrmContasReceber;

{$mode objfpc}{$H+}

{ ============================================================
  ERP 2026 - FASE 5 - Contas a Receber
  ============================================================ }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, DBGrids, DB, SQLDB, ComCtrls,
  uConexao, uSessao;

type
  TfrmContasReceber = class(TForm)
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
    btnNovo: TBitBtn;
    btnBaixar: TBitBtn;
    btnFechar: TBitBtn;
    dbGrid: TDBGrid;
    DataSource1: TDataSource;
    pnlResumo: TPanel;
    lblTotalAberto: TLabel;
    lblTotalPago: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnBaixarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FConexao: TConexao;
    FQuery: TSQLQuery;
    procedure CarregarContas;
  end;

var
  frmContasReceber: TfrmContasReceber;

implementation

{$R *.lfm}

procedure TfrmContasReceber.FormCreate(Sender: TObject);
begin
  FConexao := TConexao.GetInstance;
  FQuery := TSQLQuery.Create(Self);
  FQuery.DataBase := FConexao.Connection;
  FQuery.Transaction := FConexao.Transaction;
  dtpInicio.Date := IncMonth(Now, -1);
  dtpFim.Date := IncMonth(Now, 1);
  cmbStatusFiltro.ItemIndex := 0;
  CarregarContas;
end;

procedure TfrmContasReceber.CarregarContas;
var
  LSQL: string;
begin
  LSQL :=
    'SELECT CR.ID, C.NOME AS CLIENTE, CR.DESCRICAO, CR.VALOR, ' +
    'CR.DATA_VENCIMENTO, CR.DATA_PAGAMENTO, CR.VALOR_PAGO, ' +
    'CASE CR.STATUS WHEN ''A'' THEN ''Aberta'' WHEN ''P'' THEN ''Paga'' ' +
    'WHEN ''C'' THEN ''Cancelada'' END AS STATUS_DESC ' +
    'FROM CONTA_RECEBER CR ' +
    'LEFT JOIN CLIENTE C ON C.ID = CR.CLIENTE_ID ' +
    'WHERE CR.DATA_VENCIMENTO BETWEEN :DI AND :DF';

  if cmbStatusFiltro.ItemIndex > 0 then
    case cmbStatusFiltro.ItemIndex of
      1: LSQL := LSQL + ' AND CR.STATUS = ''A''';
      2: LSQL := LSQL + ' AND CR.STATUS = ''P''';
      3: LSQL := LSQL + ' AND CR.STATUS = ''C''';
    end;

  LSQL := LSQL + ' ORDER BY CR.DATA_VENCIMENTO';

  FQuery.Close;
  FQuery.SQL.Text := LSQL;
  FQuery.ParamByName('DI').AsDate := dtpInicio.Date;
  FQuery.ParamByName('DF').AsDate := dtpFim.Date;
  FQuery.Open;
  DataSource1.DataSet := FQuery;

  // Resumo
  var LAberto: Double := 0;
  var LPago: Double := 0;
  FQuery.First;
  while not FQuery.EOF do
  begin
    if FQuery.FieldByName('STATUS_DESC').AsString = 'Aberta' then
      LAberto := LAberto + FQuery.FieldByName('VALOR').AsFloat
    else if FQuery.FieldByName('STATUS_DESC').AsString = 'Paga' then
      LPago := LPago + FQuery.FieldByName('VALOR_PAGO').AsFloat;
    FQuery.Next;
  end;
  FQuery.First;
  lblTotalAberto.Caption := 'Em Aberto: R$ ' + FormatFloat('#,##0.00', LAberto);
  lblTotalPago.Caption := 'Pago: R$ ' + FormatFloat('#,##0.00', LPago);
end;

procedure TfrmContasReceber.btnNovoClick(Sender: TObject);
var
  LCliente, LDesc, LValor, LVenc: string;
  LQuery: TSQLQuery;
begin
  if not InputQuery('Nova Conta a Receber', 'Descrição:', LDesc) then Exit;
  if not InputQuery('Nova Conta a Receber', 'Valor:', LValor) then Exit;
  if not InputQuery('Nova Conta a Receber', 'Vencimento (DD/MM/AAAA):', LVenc) then Exit;

  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text :=
      'INSERT INTO CONTA_RECEBER (EMPRESA_ID, DESCRICAO, VALOR, DATA_VENCIMENTO, STATUS) ' +
      'VALUES (:EMP, :DESC, :VLR, :VENC, ''A'')';
    LQuery.ParamByName('EMP').AsLargeInt := TSessao.GetInstance.EmpresaId;
    LQuery.ParamByName('DESC').AsString := LDesc;
    LQuery.ParamByName('VLR').AsFloat := StrToFloatDef(LValor, 0);
    LQuery.ParamByName('VENC').AsDate := StrToDateDef(LVenc, Now + 30);
    LQuery.ExecSQL;
    FConexao.Confirmar;
    CarregarContas;
  finally
    LQuery.Free;
  end;
end;

procedure TfrmContasReceber.btnBaixarClick(Sender: TObject);
var
  LQuery: TSQLQuery;
begin
  if FQuery.IsEmpty then Exit;
  if FQuery.FieldByName('STATUS_DESC').AsString <> 'Aberta' then
  begin
    MessageDlg('Apenas contas em aberto podem ser baixadas.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg('Confirma baixa desta conta?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

  LQuery := TSQLQuery.Create(nil);
  try
    LQuery.DataBase := FConexao.Connection;
    LQuery.Transaction := FConexao.Transaction;
    LQuery.SQL.Text :=
      'UPDATE CONTA_RECEBER SET STATUS = ''P'', DATA_PAGAMENTO = CURRENT_DATE, ' +
      'VALOR_PAGO = VALOR WHERE ID = :ID';
    LQuery.ParamByName('ID').AsLargeInt := FQuery.FieldByName('ID').AsLargeInt;
    LQuery.ExecSQL;
    FConexao.Confirmar;
    CarregarContas;
  finally
    LQuery.Free;
  end;
end;

procedure TfrmContasReceber.btnFiltrarClick(Sender: TObject);
begin
  CarregarContas;
end;

procedure TfrmContasReceber.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
