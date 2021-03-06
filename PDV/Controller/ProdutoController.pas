{*******************************************************************************
Title: T2Ti ERP
Description: Classe de controle do produto.

The MIT License

Copyright: Copyright (C) 2010 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

       The author may be contacted at:
           t2ti.com@gmail.com</p>

@author Albert Eije (T2Ti.COM) | Jose Rodrigues de Oliveira Junior
@version 1.0
*******************************************************************************}
unit ProdutoController;

interface

uses
  Classes, SQLdb, SysUtils, ProdutoVO,  fgl;

type
  TProdutoController = class
  protected
  public
    class function Consulta(Codigo: String; Tipo: Integer): TProdutoVO;
    class function ConsultaId(Id: Integer): TProdutoVO;
    class function ConsultaIdProduto(Id: Integer): Boolean;
    class function TabelaProduto:TProdutoListaVO ; overload;
    class function TabelaProduto(CodigoInicio: Integer; CodigoFim: Integer): TProdutoListaVO; overload;
    class function TabelaProduto(NomeInicio: String; NomeFim : String): TProdutoListaVO; overload;
    class function ConsultaProdutoSPED(pDataInicial, pDataFinal: String; pPerfilApresentacao: Integer): TProdutoListaVO;
    class function AtualizaEstoque: Boolean;
    class function GravaCargaProduto(vTupla: String): Boolean;
  end;

implementation

uses Udmprincipal, Biblioteca, UfrmCargaPDV,  ConfiguracaoController;
//UCargaPDV,

var
  ConsultaSQL, ClausulaWhere: String;
  Query: TSQLQuery;

class function TProdutoController.Consulta(Codigo: String; Tipo: Integer): TProdutoVO;
var
  Produto: TProdutoVO;
begin
  case Tipo of
    1:begin      // pesquisa pelo codigo da balanca
      ClausulaWhere := ' where ' +
                      '(P.CODIGO_BALANCA = ' + QuotedStr(Codigo)+')' +
                      ' and (P.ID_UNIDADE_PRODUTO = U.ID)';
    end;
    2:begin     // pesquisa pelo GTIN
       ClausulaWhere := ' where ' +
                       ' (P.GTIN = ' + QuotedStr(Codigo)+ ')' +
                       ' and (P.ID_UNIDADE_PRODUTO = U.ID)';
    end;
    3:begin     // pesquisa pelo CODIGO_INTERNO ou GTIN
       ClausulaWhere := 'where ' +
                       ' ((P.CODIGO_INTERNO = ' + QuotedStr(Codigo)+ ')'+
                       ' or  (P.GTIN = ' + QuotedStr(copy(Codigo,1,14))+  '))' +
                       ' and (P.ID_UNIDADE_PRODUTO = U.ID)';
    end;
    4:begin     // pesquisa pelo Id
       ClausulaWhere := 'where ' +
                       ' (P.ID = ' + QuotedStr(Codigo) + ') '+
                       ' and (P.ID_UNIDADE_PRODUTO = U.ID) ';
    end;
  end;

  ConsultaSQL :=
                  'select ' +
                  ' P.ID, ' +
                  ' P.ID_UNIDADE_PRODUTO, ' +
                  ' P.GTIN, ' +
                  ' P.CODIGO_INTERNO, ' +
                  ' P.NOME AS NOME_PRODUTO, ' +
                  ' P.DESCRICAO, ' +
                  ' P.DESCRICAO_PDV, ' +
                  ' P.VALOR_VENDA, ' +
                  ' P.QTD_ESTOQUE, ' +
                  ' P.QTD_ESTOQUE_ANTERIOR, ' +
                  ' P.ESTOQUE_MIN, ' +
                  ' P.ESTOQUE_MAX, ' +
                  ' P.IAT, ' +
                  ' P.IPPT, ' +
                  ' P.NCM, ' +
                  ' P.TIPO_ITEM_SPED, ' +
                  ' P.DATA_ESTOQUE, ' +
                  ' P.TAXA_IPI, ' +
                  ' P.TAXA_ISSQN, ' +
                  ' P.TAXA_PIS, ' +
                  ' P.TAXA_COFINS, ' +
                  ' P.TAXA_ICMS, ' +
                  ' P.CST, ' +
                  ' P.CSOSN, ' +
                  ' P.TOTALIZADOR_PARCIAL, ' +
                  ' P.ECF_ICMS_ST, ' +
                  ' P.CODIGO_BALANCA, ' +
                  ' P.PAF_P_ST, ' +
                  ' P.HASH_TRIPA, ' +
                  ' P.HASH_INCREMENTO, ' +
                  ' U.NOME AS NOME_UNIDADE, ' +
                  ' U.PODE_FRACIONAR ' +
                  'from ' +
                  ' PRODUTO P, ' +
                  ' UNIDADE_PRODUTO U ' +
                  ClausulaWhere;

  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.Open;

      Produto := TProdutoVO.Create;
      Produto.Id := Query.FieldByName('ID').AsInteger;
      Produto.IdUnidade := Query.FieldByName('ID_UNIDADE_PRODUTO').AsInteger;
      Produto.GTIN := Query.FieldByName('GTIN').AsString;
      Produto.CodigoInterno := Query.FieldByName('CODIGO_INTERNO').AsString;
      Produto.Nome := Query.FieldByName('NOME_PRODUTO').AsString;
      Produto.Descricao := Query.FieldByName('DESCRICAO').AsString;
      Produto.DescricaoPDV := Query.FieldByName('DESCRICAO_PDV').AsString;
      Produto.ValorVenda := Query.FieldByName('VALOR_VENDA').AsFloat;
      Produto.QtdeEstoque := Query.FieldByName('QTD_ESTOQUE').AsFloat;
      Produto.QtdeEstoqueAnterior := Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat;
      Produto.EstoqueMinimo := Query.FieldByName('ESTOQUE_MIN').AsFloat;
      Produto.EstoqueMaximo := Query.FieldByName('ESTOQUE_MAX').AsFloat;
      Produto.IAT := Query.FieldByName('IAT').AsString;
      Produto.IPPT := Query.FieldByName('IPPT').AsString;
      Produto.NCM := Query.FieldByName('NCM').AsString;
      Produto.TipoItemSped := Query.FieldByName('TIPO_ITEM_SPED').AsString;
      Produto.DataEstoque := Query.FieldByName('DATA_ESTOQUE').AsString;
      Produto.AliquotaIpi := Query.FieldByName('TAXA_IPI').AsFloat;
      Produto.AliquotaIssqn := Query.FieldByName('TAXA_ISSQN').AsFloat;
      Produto.AliquotaPis := Query.FieldByName('TAXA_PIS').AsFloat;
      Produto.AliquotaCofins := Query.FieldByName('TAXA_COFINS').AsFloat;
      Produto.AliquotaIcms := Query.FieldByName('TAXA_ICMS').AsFloat;
      Produto.Cst := Query.FieldByName('CST').AsString;
      Produto.Csosn := Query.FieldByName('CSOSN').AsString;
      Produto.TotalizadorParcial := Query.FieldByName('TOTALIZADOR_PARCIAL').AsString;
      Produto.ECFICMS := Query.FieldByName('ECF_ICMS_ST').AsString;
      Produto.CodigoBalanca:= Query.FieldByName('CODIGO_BALANCA').AsInteger;
      Produto.PafProdutoSt := Query.FieldByName('PAF_P_ST').AsString;
      Produto.HashTripa := Query.FieldByName('HASH_TRIPA').AsString;
      Produto.HashIncremento := Query.FieldByName('HASH_INCREMENTO').AsInteger;
      Produto.UnidadeProduto := Query.FieldByName('NOME_UNIDADE').AsString;
      Produto.PodeFracionarUnidade := Query.FieldByName('PODE_FRACIONAR').AsString;
      result := Produto;
    except
      result := nil;
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.ConsultaId(Id: Integer): TProdutoVO;
var
  Produto: TProdutoVO;
begin
  ConsultaSQL :=
                  'select ' +
                  ' P.ID, ' +
                  ' P.ID_UNIDADE_PRODUTO, ' +
                  ' P.GTIN, ' +
                  ' P.CODIGO_INTERNO, ' +
                  ' P.NOME AS NOME_PRODUTO, ' +
                  ' P.DESCRICAO, ' +
                  ' P.DESCRICAO_PDV, ' +
                  ' P.VALOR_VENDA, ' +
                  ' P.QTD_ESTOQUE, ' +
                  ' P.QTD_ESTOQUE_ANTERIOR, ' +
                  ' P.ESTOQUE_MIN, ' +
                  ' P.ESTOQUE_MAX, ' +
                  ' P.IAT, ' +
                  ' P.IPPT, ' +
                  ' P.NCM, ' +
                  ' P.TIPO_ITEM_SPED, ' +
                  ' P.DATA_ESTOQUE, ' +
                  ' P.TAXA_IPI, ' +
                  ' P.TAXA_ISSQN, ' +
                  ' P.TAXA_PIS, ' +
                  ' P.TAXA_COFINS, ' +
                  ' P.TAXA_ICMS, ' +
                  ' P.CST, ' +
                  ' P.CSOSN, ' +
                  ' P.TOTALIZADOR_PARCIAL, ' +
                  ' P.ECF_ICMS_ST, ' +
                  ' P.CODIGO_BALANCA, ' +
                  ' P.PAF_P_ST, ' +
                  ' P.HASH_TRIPA, ' +
                  ' P.HASH_INCREMENTO, ' +
                  ' U.NOME AS NOME_UNIDADE, ' +
                  ' U.PODE_FRACIONAR ' +
                  'from ' +
                  ' PRODUTO P, ' +
                  ' UNIDADE_PRODUTO U ' +
                  'where ' +
                  ' (P.ID = ' + IntToStr(Id) + ') '+
                  ' and (P.ID_UNIDADE_PRODUTO = U.ID) ';
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.Open;

      Produto := TProdutoVO.Create;
      Produto.Id := Query.FieldByName('ID').AsInteger;
      Produto.IdUnidade := Query.FieldByName('ID_UNIDADE_PRODUTO').AsInteger;
      Produto.GTIN := Query.FieldByName('GTIN').AsString;
      Produto.CodigoInterno := Query.FieldByName('CODIGO_INTERNO').AsString;
      Produto.Nome := Query.FieldByName('NOME_PRODUTO').AsString;
      Produto.Descricao := Query.FieldByName('DESCRICAO').AsString;
      Produto.DescricaoPDV := Query.FieldByName('DESCRICAO_PDV').AsString;
      Produto.ValorVenda := Query.FieldByName('VALOR_VENDA').AsFloat;
      Produto.QtdeEstoque := Query.FieldByName('QTD_ESTOQUE').AsFloat;
      Produto.QtdeEstoqueAnterior := Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat;
      Produto.EstoqueMinimo := Query.FieldByName('ESTOQUE_MIN').AsFloat;
      Produto.EstoqueMaximo := Query.FieldByName('ESTOQUE_MAX').AsFloat;
      Produto.IAT := Query.FieldByName('IAT').AsString;
      Produto.IPPT := Query.FieldByName('IPPT').AsString;
      Produto.NCM := Query.FieldByName('NCM').AsString;
      Produto.TipoItemSped := Query.FieldByName('TIPO_ITEM_SPED').AsString;
      Produto.DataEstoque := Query.FieldByName('DATA_ESTOQUE').AsString;
      Produto.AliquotaIpi := Query.FieldByName('TAXA_IPI').AsFloat;
      Produto.AliquotaIssqn := Query.FieldByName('TAXA_ISSQN').AsFloat;
      Produto.AliquotaPis := Query.FieldByName('TAXA_PIS').AsFloat;
      Produto.AliquotaCofins := Query.FieldByName('TAXA_COFINS').AsFloat;
      Produto.AliquotaIcms := Query.FieldByName('TAXA_ICMS').AsFloat;
      Produto.Cst := Query.FieldByName('CST').AsString;
      Produto.Csosn := Query.FieldByName('CSOSN').AsString;
      Produto.TotalizadorParcial := Query.FieldByName('TOTALIZADOR_PARCIAL').AsString;
      Produto.ECFICMS := Query.FieldByName('ECF_ICMS_ST').AsString;
      Produto.CodigoBalanca:= Query.FieldByName('CODIGO_BALANCA').AsInteger;
      Produto.PafProdutoSt := Query.FieldByName('PAF_P_ST').AsString;
      Produto.HashTripa := Query.FieldByName('HASH_TRIPA').AsString;
      Produto.HashIncremento := Query.FieldByName('HASH_INCREMENTO').AsInteger;
      Produto.UnidadeProduto := Query.FieldByName('NOME_UNIDADE').AsString;
      Produto.PodeFracionarUnidade := Query.FieldByName('PODE_FRACIONAR').AsString;
      result := Produto;
    except
      result := nil;
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.ConsultaIdProduto(Id: Integer): Boolean;
begin
  ConsultaSQL := 'select ID from PRODUTO where (ID = :pID) ';
  try
    try
      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.ParamByName('pID').AsInteger:=Id;
      Query.Open;
      if not Query.IsEmpty then
        result := true
      else
        result := false;
    except
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.TabelaProduto: TProdutoListaVO;
var
  ListaProduto: TProdutoListaVO;
  Produto: TProdutoVO;
  TotalRegistros: Integer;
begin
  try
    try
      //verifica se existem produtos
      ConsultaSQL :=
        'select count(*) as TOTAL '+
        'from PRODUTO P, UNIDADE_PRODUTO U '+
        'where (P.ID_UNIDADE_PRODUTO = U.ID)';

      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.Open;
      TotalRegistros := Query.FieldByName('TOTAL').AsInteger;

      if TotalRegistros > 0 then
      begin
        //continua com a execução do procedimento
        ConsultaSQL :=
                      'select ' +
                      ' P.ID, ' +
                      ' P.ID_UNIDADE_PRODUTO, ' +
                      ' P.GTIN, ' +
                      ' P.CODIGO_INTERNO, ' +
                      ' P.NOME AS NOME_PRODUTO, ' +
                      ' P.DESCRICAO, ' +
                      ' P.DESCRICAO_PDV, ' +
                      ' P.VALOR_VENDA, ' +
                      ' P.QTD_ESTOQUE, ' +
                      ' P.QTD_ESTOQUE_ANTERIOR, ' +
                      ' P.ESTOQUE_MIN, ' +
                      ' P.ESTOQUE_MAX, ' +
                      ' P.IAT, ' +
                      ' P.IPPT, ' +
                      ' P.NCM, ' +
                      ' P.TIPO_ITEM_SPED, ' +
                      ' P.DATA_ESTOQUE, ' +
                      ' P.TAXA_IPI, ' +
                      ' P.TAXA_ISSQN, ' +
                      ' P.TAXA_PIS, ' +
                      ' P.TAXA_COFINS, ' +
                      ' P.TAXA_ICMS, ' +
                      ' P.CST, ' +
                      ' P.CSOSN, ' +
                      ' P.TOTALIZADOR_PARCIAL, ' +
                      ' P.ECF_ICMS_ST, ' +
                      ' P.CODIGO_BALANCA, ' +
                      ' P.PAF_P_ST, ' +
                      ' P.HASH_TRIPA, ' +
                      ' P.HASH_INCREMENTO, ' +
                      ' U.NOME AS NOME_UNIDADE, ' +
                      ' U.PODE_FRACIONAR ' +
                      'from ' +
                      ' PRODUTO P, UNIDADE_PRODUTO U '+
                      'where ' +
                      ' (P.ID_UNIDADE_PRODUTO = U.ID)';

        Query.sql.Text := ConsultaSQL;
        Query.Open;

        ListaProduto := TProdutoListaVO.Create(True);

        Query.First;
        while not Query.Eof do
        begin
          Produto := TProdutoVO.Create;
          Produto.Id := Query.FieldByName('ID').AsInteger;
          Produto.IdUnidade := Query.FieldByName('ID_UNIDADE_PRODUTO').AsInteger;
          Produto.GTIN := Query.FieldByName('GTIN').AsString;
          Produto.CodigoInterno := Query.FieldByName('CODIGO_INTERNO').AsString;
          Produto.Nome := Query.FieldByName('NOME_PRODUTO').AsString;
          Produto.Descricao := Query.FieldByName('DESCRICAO').AsString;
          Produto.DescricaoPDV := Query.FieldByName('DESCRICAO_PDV').AsString;
          Produto.ValorVenda := Query.FieldByName('VALOR_VENDA').AsFloat;
          Produto.QtdeEstoque := Query.FieldByName('QTD_ESTOQUE').AsFloat;
          Produto.QtdeEstoqueAnterior := Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat;
          Produto.EstoqueMinimo := Query.FieldByName('ESTOQUE_MIN').AsFloat;
          Produto.EstoqueMaximo := Query.FieldByName('ESTOQUE_MAX').AsFloat;
          Produto.IAT := Query.FieldByName('IAT').AsString;
          Produto.IPPT := Query.FieldByName('IPPT').AsString;
          Produto.NCM := Query.FieldByName('NCM').AsString;
          Produto.TipoItemSped := Query.FieldByName('TIPO_ITEM_SPED').AsString;
          Produto.DataEstoque := Query.FieldByName('DATA_ESTOQUE').AsString;
          Produto.AliquotaIpi := Query.FieldByName('TAXA_IPI').AsFloat;
          Produto.AliquotaIssqn := Query.FieldByName('TAXA_ISSQN').AsFloat;
          Produto.AliquotaPis := Query.FieldByName('TAXA_PIS').AsFloat;
          Produto.AliquotaCofins := Query.FieldByName('TAXA_COFINS').AsFloat;
          Produto.AliquotaIcms := Query.FieldByName('TAXA_ICMS').AsFloat;
          Produto.Cst := Query.FieldByName('CST').AsString;
          Produto.Csosn := Query.FieldByName('CSOSN').AsString;
          Produto.TotalizadorParcial := Query.FieldByName('TOTALIZADOR_PARCIAL').AsString;
          Produto.ECFICMS := Query.FieldByName('ECF_ICMS_ST').AsString;
          Produto.CodigoBalanca:= Query.FieldByName('CODIGO_BALANCA').AsInteger;
          Produto.PafProdutoSt := Query.FieldByName('PAF_P_ST').AsString;
          Produto.HashTripa := Query.FieldByName('HASH_TRIPA').AsString;
          Produto.HashIncremento := Query.FieldByName('HASH_INCREMENTO').AsInteger;
          Produto.UnidadeProduto := Query.FieldByName('NOME_UNIDADE').AsString;
          Produto.PodeFracionarUnidade := Query.FieldByName('PODE_FRACIONAR').AsString;
          ListaProduto.Add(Produto);
          Query.next;
        end;
        result := ListaProduto;
      end
      else
        result := nil;
    except
      result := nil;
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.TabelaProduto(CodigoInicio: Integer; CodigoFim : Integer) : TProdutoListaVO;
var
  ListaProduto: TProdutoListaVO;
  Produto: TProdutoVO;
  TotalRegistros: Integer;
begin
  try
    try
      //verifica se existem produtos
      ConsultaSQL :=
        'select count(*) as TOTAL '+
        'from PRODUTO P, UNIDADE_PRODUTO U '+
        'where (P.ID_UNIDADE_PRODUTO = U.ID) '+
        'and P.ID between '+IntToStr(CodigoInicio)+' and '+IntToStr(CodigoFim);

      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.Open;
      TotalRegistros := Query.FieldByName('TOTAL').AsInteger;

      if TotalRegistros > 0 then
      begin
        //continua com a execução do procedimento
        ConsultaSQL :=
                      'select ' +
                      ' P.ID, ' +
                      ' P.ID_UNIDADE_PRODUTO, ' +
                      ' P.GTIN, ' +
                      ' P.CODIGO_INTERNO, ' +
                      ' P.NOME AS NOME_PRODUTO, ' +
                      ' P.DESCRICAO, ' +
                      ' P.DESCRICAO_PDV, ' +
                      ' P.VALOR_VENDA, ' +
                      ' P.QTD_ESTOQUE, ' +
                      ' P.QTD_ESTOQUE_ANTERIOR, ' +
                      ' P.ESTOQUE_MIN, ' +
                      ' P.ESTOQUE_MAX, ' +
                      ' P.IAT, ' +
                      ' P.IPPT, ' +
                      ' P.NCM, ' +
                      ' P.TIPO_ITEM_SPED, ' +
                      ' P.DATA_ESTOQUE, ' +
                      ' P.TAXA_IPI, ' +
                      ' P.TAXA_ISSQN, ' +
                      ' P.TAXA_PIS, ' +
                      ' P.TAXA_COFINS, ' +
                      ' P.TAXA_ICMS, ' +
                      ' P.CST, ' +
                      ' P.CSOSN, ' +
                      ' P.TOTALIZADOR_PARCIAL, ' +
                      ' P.ECF_ICMS_ST, ' +
                      ' P.CODIGO_BALANCA, ' +
                      ' P.PAF_P_ST, ' +
                      ' P.HASH_TRIPA, ' +
                      ' P.HASH_INCREMENTO, ' +
                      ' U.NOME AS NOME_UNIDADE, ' +
                      ' U.PODE_FRACIONAR ' +
                      'from ' +
                      ' PRODUTO P, UNIDADE_PRODUTO U '+
                      'where ' +
                      ' (P.ID_UNIDADE_PRODUTO = U.ID) '+
                      'and P.ID between '+IntToStr(CodigoInicio)+' and '+IntToStr(CodigoFim);

        Query.sql.Text := ConsultaSQL;
        Query.Open;

        ListaProduto := TProdutoListaVO.Create(True);

        Query.First;
        while not Query.Eof do
        begin
          Produto := TProdutoVO.Create;
          Produto.Id := Query.FieldByName('ID').AsInteger;
          Produto.IdUnidade := Query.FieldByName('ID_UNIDADE_PRODUTO').AsInteger;
          Produto.GTIN := Query.FieldByName('GTIN').AsString;
          Produto.CodigoInterno := Query.FieldByName('CODIGO_INTERNO').AsString;
          Produto.Nome := Query.FieldByName('NOME_PRODUTO').AsString;
          Produto.Descricao := Query.FieldByName('DESCRICAO').AsString;
          Produto.DescricaoPDV := Query.FieldByName('DESCRICAO_PDV').AsString;
          Produto.ValorVenda := Query.FieldByName('VALOR_VENDA').AsFloat;
          Produto.QtdeEstoque := Query.FieldByName('QTD_ESTOQUE').AsFloat;
          Produto.QtdeEstoqueAnterior := Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat;
          Produto.EstoqueMinimo := Query.FieldByName('ESTOQUE_MIN').AsFloat;
          Produto.EstoqueMaximo := Query.FieldByName('ESTOQUE_MAX').AsFloat;
          Produto.IAT := Query.FieldByName('IAT').AsString;
          Produto.IPPT := Query.FieldByName('IPPT').AsString;
          Produto.NCM := Query.FieldByName('NCM').AsString;
          Produto.TipoItemSped := Query.FieldByName('TIPO_ITEM_SPED').AsString;
          Produto.DataEstoque := Query.FieldByName('DATA_ESTOQUE').AsString;
          Produto.AliquotaIpi := Query.FieldByName('TAXA_IPI').AsFloat;
          Produto.AliquotaIssqn := Query.FieldByName('TAXA_ISSQN').AsFloat;
          Produto.AliquotaPis := Query.FieldByName('TAXA_PIS').AsFloat;
          Produto.AliquotaCofins := Query.FieldByName('TAXA_COFINS').AsFloat;
          Produto.AliquotaIcms := Query.FieldByName('TAXA_ICMS').AsFloat;
          Produto.Cst := Query.FieldByName('CST').AsString;
          Produto.Csosn := Query.FieldByName('CSOSN').AsString;
          Produto.TotalizadorParcial := Query.FieldByName('TOTALIZADOR_PARCIAL').AsString;
          Produto.ECFICMS := Query.FieldByName('ECF_ICMS_ST').AsString;
          Produto.CodigoBalanca:= Query.FieldByName('CODIGO_BALANCA').AsInteger;
          Produto.PafProdutoSt := Query.FieldByName('PAF_P_ST').AsString;
          Produto.HashTripa := Query.FieldByName('HASH_TRIPA').AsString;
          Produto.HashIncremento := Query.FieldByName('HASH_INCREMENTO').AsInteger;
          Produto.UnidadeProduto := Query.FieldByName('NOME_UNIDADE').AsString;
          Produto.PodeFracionarUnidade := Query.FieldByName('PODE_FRACIONAR').AsString;
          ListaProduto.Add(Produto);
          Query.next;
        end;
        result := ListaProduto;
      end
      else
        result := nil;
    except
      result := nil;
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.TabelaProduto(NomeInicio: String ; NomeFim: String): TProdutoListaVO;
var
  ListaProduto: TProdutoListaVO;
  Produto: TProdutoVO;
  TotalRegistros: Integer;
begin
  try
    try
      //verifica se existem produtos
      ConsultaSQL :=
        'select count(*) as TOTAL '+
        'from PRODUTO P, UNIDADE_PRODUTO U '+
        'where (P.ID_UNIDADE_PRODUTO = U.ID) '+
        'and (P.NOME like "%'+Trim(NomeInicio)+'%" or P.NOME like "%'+Trim(NomeFim) + '%")';


      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.Open;
      TotalRegistros := Query.FieldByName('TOTAL').AsInteger;

      if TotalRegistros > 0 then
      begin
        //continua com a execução do procedimento
        ConsultaSQL :=
                      'select ' +
                      ' P.ID, ' +
                      ' P.ID_UNIDADE_PRODUTO, ' +
                      ' P.GTIN, ' +
                      ' P.CODIGO_INTERNO, ' +
                      ' P.NOME AS NOME_PRODUTO, ' +
                      ' P.DESCRICAO, ' +
                      ' P.DESCRICAO_PDV, ' +
                      ' P.VALOR_VENDA, ' +
                      ' P.QTD_ESTOQUE, ' +
                      ' P.QTD_ESTOQUE_ANTERIOR, ' +
                      ' P.ESTOQUE_MIN, ' +
                      ' P.ESTOQUE_MAX, ' +
                      ' P.IAT, ' +
                      ' P.IPPT, ' +
                      ' P.NCM, ' +
                      ' P.TIPO_ITEM_SPED, ' +
                      ' P.DATA_ESTOQUE, ' +
                      ' P.TAXA_IPI, ' +
                      ' P.TAXA_ISSQN, ' +
                      ' P.TAXA_PIS, ' +
                      ' P.TAXA_COFINS, ' +
                      ' P.TAXA_ICMS, ' +
                      ' P.CST, ' +
                      ' P.CSOSN, ' +
                      ' P.TOTALIZADOR_PARCIAL, ' +
                      ' P.ECF_ICMS_ST, ' +
                      ' P.CODIGO_BALANCA, ' +
                      ' P.PAF_P_ST, ' +
                      ' P.HASH_TRIPA, ' +
                      ' P.HASH_INCREMENTO, ' +
                      ' U.NOME AS NOME_UNIDADE, ' +
                      ' U.PODE_FRACIONAR ' +
                      'from ' +
                      ' PRODUTO P, UNIDADE_PRODUTO U '+
                      ' where (P.ID_UNIDADE_PRODUTO = U.ID) '+
                      ' and (P.NOME like "%'+Trim(NomeInicio)+'%" or P.NOME like "%'+Trim(NomeFim) + '%")';

        Query.sql.Text := ConsultaSQL;
        Query.Open;

        ListaProduto := TProdutoListaVO.Create(True);

        Query.First;
        while not Query.Eof do
        begin
          Produto := TProdutoVO.Create;
          Produto.Id := Query.FieldByName('ID').AsInteger;
          Produto.IdUnidade := Query.FieldByName('ID_UNIDADE_PRODUTO').AsInteger;
          Produto.GTIN := Query.FieldByName('GTIN').AsString;
          Produto.CodigoInterno := Query.FieldByName('CODIGO_INTERNO').AsString;
          Produto.Nome := Query.FieldByName('NOME_PRODUTO').AsString;
          Produto.Descricao := Query.FieldByName('DESCRICAO').AsString;
          Produto.DescricaoPDV := Query.FieldByName('DESCRICAO_PDV').AsString;
          Produto.ValorVenda := Query.FieldByName('VALOR_VENDA').AsFloat;
          Produto.QtdeEstoque := Query.FieldByName('QTD_ESTOQUE').AsFloat;
          Produto.QtdeEstoqueAnterior := Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat;
          Produto.EstoqueMinimo := Query.FieldByName('ESTOQUE_MIN').AsFloat;
          Produto.EstoqueMaximo := Query.FieldByName('ESTOQUE_MAX').AsFloat;
          Produto.IAT := Query.FieldByName('IAT').AsString;
          Produto.IPPT := Query.FieldByName('IPPT').AsString;
          Produto.NCM := Query.FieldByName('NCM').AsString;
          Produto.TipoItemSped := Query.FieldByName('TIPO_ITEM_SPED').AsString;
          Produto.DataEstoque := Query.FieldByName('DATA_ESTOQUE').AsString;
          Produto.AliquotaIpi := Query.FieldByName('TAXA_IPI').AsFloat;
          Produto.AliquotaIssqn := Query.FieldByName('TAXA_ISSQN').AsFloat;
          Produto.AliquotaPis := Query.FieldByName('TAXA_PIS').AsFloat;
          Produto.AliquotaCofins := Query.FieldByName('TAXA_COFINS').AsFloat;
          Produto.AliquotaIcms := Query.FieldByName('TAXA_ICMS').AsFloat;
          Produto.Cst := Query.FieldByName('CST').AsString;
          Produto.Csosn := Query.FieldByName('CSOSN').AsString;
          Produto.TotalizadorParcial := Query.FieldByName('TOTALIZADOR_PARCIAL').AsString;
          Produto.ECFICMS := Query.FieldByName('ECF_ICMS_ST').AsString;
          Produto.CodigoBalanca:= Query.FieldByName('CODIGO_BALANCA').AsInteger;
          Produto.PafProdutoSt := Query.FieldByName('PAF_P_ST').AsString;
          Produto.HashTripa := Query.FieldByName('HASH_TRIPA').AsString;
          Produto.HashIncremento := Query.FieldByName('HASH_INCREMENTO').AsInteger;
          Produto.UnidadeProduto := Query.FieldByName('NOME_UNIDADE').AsString;
          Produto.PodeFracionarUnidade := Query.FieldByName('PODE_FRACIONAR').AsString;
          ListaProduto.Add(Produto);
          Query.next;
        end;
        result := ListaProduto;
      end
      else
        result := nil;
    except
      result := nil;
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.ConsultaProdutoSPED(pDataInicial, pDataFinal: String; pPerfilApresentacao : Integer): TProdutoListaVO;
var
  ListaProduto: TProdutoListaVO;
  Produto: TProdutoVO;
  TotalRegistros, Perfil: Integer;
  DataInicio, DataFim : String ;
begin
  try
    try

     DataInicio := QuotedStr(FormatDateTime('yyyy-mm-dd', StrToDate(pDataInicial)));
     DataFim := QuotedStr(FormatDateTime('yyyy-mm-dd', StrToDate(pDataFinal)));
     Perfil := pPerfilApresentacao;

        ConsultaSQL :=
            ' select count(*) as total '+
            ' from  PRODUTO P, UNIDADE_PRODUTO U, ECF_VENDA_CABECALHO V, ECF_VENDA_DETALHE D'+
            ' where V.DATA_VENDA between '+DataInicio+' and '+DataFim+
            ' and (P.ID_UNIDADE_PRODUTO = U.ID)'+
            ' and (V.ID=D.ID_ECF_VENDA_CABECALHO)'+
            ' and (D.ID_ECF_PRODUTO=P.ID) group by D.ID_ECF_PRODUTO';

        Query := TSQLQuery.Create(nil);
        Query.DataBase := dmPrincipal.IBCon;
        Query.sql.Text := ConsultaSQL;
        Query.Open;
        TotalRegistros := Query.FieldByName('TOTAL').AsInteger;

    if TotalRegistros > 0 then
    begin
      ListaProduto := TProdutoListaVO.Create(true);
      case Perfil of
       0 : begin
       // Perfil A
        ClausulaWhere :=
                      ' where v.DATA_VENDA between '+DataInicio+' and '+DataFim+
                      ' and D.CANCELADO <> ' + QuotedStr('S') +
                      ' and (P.ID_UNIDADE_PRODUTO = U.ID)'+
                      ' and (v.id=d.id_ecf_venda_cabecalho)'+
                      ' and (d.id_ecf_produto=p.id)';
       end;
       1 : begin
       // Perfil B
        ClausulaWhere :=
                      ' where v.DATA_VENDA between '+DataInicio+' and '+DataFim+
                      ' and (P.ID_UNIDADE_PRODUTO = U.ID)'+
                      ' and (v.id=d.id_ecf_venda_cabecalho)'+
                      ' and (d.id_ecf_produto=p.id)';
       end;
       2 : begin
       // Perfil C
        ClausulaWhere :=
                      ' where v.DATA_VENDA between '+DataInicio+' and '+DataFim+
                      ' and (P.ID_UNIDADE_PRODUTO = U.ID)'+
                      ' and (v.id=d.id_ecf_venda_cabecalho)'+
                      ' and (d.id_ecf_produto=p.id)';
       end;
      end;

        ConsultaSQL :=
                      'select distinct ' +
                      ' P.ID, ' +
                      ' P.ID_UNIDADE_PRODUTO, ' +
                      ' P.GTIN, ' +
                      ' P.CODIGO_INTERNO, ' +
                      ' P.NOME AS NOME_PRODUTO, ' +
                      ' P.DESCRICAO, ' +
                      ' P.DESCRICAO_PDV, ' +
                      ' P.VALOR_VENDA, ' +
                      ' P.QTD_ESTOQUE, ' +
                      ' P.QTD_ESTOQUE_ANTERIOR, ' +
                      ' P.ESTOQUE_MIN, ' +
                      ' P.ESTOQUE_MAX, ' +
                      ' P.IAT, ' +
                      ' P.IPPT, ' +
                      ' P.NCM, ' +
                      ' P.TIPO_ITEM_SPED, ' +
                      ' P.DATA_ESTOQUE, ' +
                      ' P.TAXA_IPI, ' +
                      ' P.TAXA_ISSQN, ' +
                      ' P.TAXA_PIS, ' +
                      ' P.TAXA_COFINS, ' +
                      ' P.TAXA_ICMS, ' +
                      ' P.CST, ' +
                      ' P.CSOSN, ' +
                      ' P.TOTALIZADOR_PARCIAL, ' +
                      ' P.ECF_ICMS_ST, ' +
                      ' P.CODIGO_BALANCA, ' +
                      ' P.PAF_P_ST, ' +
                      ' P.HASH_TRIPA, ' +
                      ' U.NOME AS NOME_UNIDADE, ' +
                      ' U.PODE_FRACIONAR ' +
                      'from ' +
                      ' PRODUTO P, UNIDADE_PRODUTO U, ECF_VENDA_CABECALHO V, ECF_VENDA_DETALHE D'+
                      ClausulaWhere;

      Query.sql.Text := ConsultaSQL;
      Query.Open;
      Query.First;

      while not Query.Eof do
      begin
        Produto := TProdutoVO.Create;
        Produto.Id := Query.FieldByName('ID').AsInteger;
        Produto.IdUnidade := Query.FieldByName('ID_UNIDADE_PRODUTO').AsInteger;
        Produto.GTIN := Query.FieldByName('GTIN').AsString;
        Produto.CodigoInterno := Query.FieldByName('CODIGO_INTERNO').AsString;
        Produto.Nome := Query.FieldByName('NOME_PRODUTO').AsString;
        Produto.Descricao := Query.FieldByName('DESCRICAO').AsString;
        Produto.DescricaoPDV := Query.FieldByName('DESCRICAO_PDV').AsString;
        Produto.ValorVenda := Query.FieldByName('VALOR_VENDA').AsFloat;
        Produto.QtdeEstoque := Query.FieldByName('QTD_ESTOQUE').AsFloat;
        Produto.QtdeEstoqueAnterior := Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat;
        Produto.EstoqueMinimo := Query.FieldByName('ESTOQUE_MIN').AsFloat;
        Produto.EstoqueMaximo := Query.FieldByName('ESTOQUE_MAX').AsFloat;
        Produto.IAT := Query.FieldByName('IAT').AsString;
        Produto.IPPT := Query.FieldByName('IPPT').AsString;
        Produto.NCM := Query.FieldByName('NCM').AsString;
        Produto.TipoItemSped := Query.FieldByName('TIPO_ITEM_SPED').AsString;
        Produto.DataEstoque := Query.FieldByName('DATA_ESTOQUE').AsString;
        Produto.AliquotaIpi := Query.FieldByName('TAXA_IPI').AsFloat;
        Produto.AliquotaIssqn := Query.FieldByName('TAXA_ISSQN').AsFloat;
        Produto.AliquotaPis := Query.FieldByName('TAXA_PIS').AsFloat;
        Produto.AliquotaCofins := Query.FieldByName('TAXA_COFINS').AsFloat;
        Produto.AliquotaIcms := Query.FieldByName('TAXA_ICMS').AsFloat;
        Produto.Cst := Query.FieldByName('CST').AsString;
        Produto.Csosn := Query.FieldByName('CSOSN').AsString;
        Produto.TotalizadorParcial := Query.FieldByName('TOTALIZADOR_PARCIAL').AsString;
        Produto.ECFICMS := Query.FieldByName('ECF_ICMS_ST').AsString;
        Produto.CodigoBalanca:= Query.FieldByName('CODIGO_BALANCA').AsInteger;
        Produto.PafProdutoSt := Query.FieldByName('PAF_P_ST').AsString;
        Produto.HashTripa := Query.FieldByName('HASH_TRIPA').AsString;
        Produto.UnidadeProduto := Query.FieldByName('NOME_UNIDADE').AsString;
        Produto.PodeFracionarUnidade := Query.FieldByName('PODE_FRACIONAR').AsString;
        ListaProduto.Add(Produto);
        Query.next;
      end;
      result := ListaProduto;
     end
     else
       result := nil;
    except
      result := nil;
    end;
  finally
    Query.Free;
  end;
end;

class function TProdutoController.AtualizaEstoque: Boolean;
var
  ConsultaSQL, Tupla, Tripa: String;
  Data : TDateTime;
  Query: TSQLQuery;
  i: Integer;
begin
  Data := TextoParaData(TConfiguracaoController.ConsultaDataAtualizacaoEstoque);
  DecimalSeparator := '.';
  try
    try
      try
        ConsultaSQL := 'Select Count(*) as TOTAL from PRODUTO WHERE DATA_ESTOQUE >= :pData';
        Query := TSQLQuery.Create(nil);
        Query.DataBase := dmPrincipal.IBBalcao;
        Query.sql.Text := ConsultaSQL;
        Query.ParamByName('pData').AsDateTime := Data;
        Query.Open;

        i := Query.FieldByName('TOTAL').AsInteger;
      finally
        Query.free;
      end;

      if i > 0  then
      begin
        FrmCargaPDV.ProgressBar.Max:= i;

        ConsultaSQL := 'select * from PRODUTO where (DATA_ESTOQUE >= :pData)';
        try
          Query := TSQLQuery.Create(nil);
          Query.DataBase := dmPrincipal.IBBalcao;
          Query.sql.Text := ConsultaSQL;
          Query.ParamByName('pData').AsDateTime := Data;
          Query.Open;

          i := 0;
          if not Query.IsEmpty then
          begin
            while not Query.Eof do
            begin
              inc(i);

              Tripa :=
                trim(Query.FieldByName('GTIN').AsString)+                          //   TProdutoVO(ListaProduto.Items[i]).GTIN +
                trim(Query.FieldByName('DESCRICAO').AsString)+                   //   TProdutoVO(ListaProduto.Items[i]).Descricao +
                trim(Query.FieldByName('DESCRICAO_PDV').AsString)+               //   TProdutoVO(ListaProduto.Items[i]).DescricaoPDV +
                FormataFloat('Q',Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsFloat)+      //   FormataFloat('Q',TProdutoVO(ListaProduto.Items[i]).QtdeEstoque) +
                Query.FieldByName('DATA_ESTOQUE').AsString+     //   TProdutoVO(ListaProduto.Items[i]).DataEstoque +
                trim(Query.FieldByName('CST').AsString)+                         //   TProdutoVO(ListaProduto.Items[i]).Cst +
                FormataFloat('V',Query.FieldByName('TAXA_ICMS').AsFloat)+        //   FormataFloat('V',TProdutoVO(ListaProduto.Items[i]).AliquotaICMS) +
                FormataFloat('V',Query.FieldByName('VALOR_VENDA').AsFloat)+ '0'; //   FormataFloat('V',TProdutoVO(ListaProduto.Items[i]).ValorVenda) + '0';

              Tupla := VerificaNULL(Query.FieldByName('ID').AsString,0) + '|'+                // ID                    INTEGER NOT NULL,
              VerificaNULL(Query.FieldByName('ID_UNIDADE_PRODUTO').AsString,0) + '|' +        // ID_UNIDADE_PRODUTO    INTEGER NOT NULL,
              VerificaNULL(Query.FieldByName('GTIN').AsString,1) + '|' +                      // GTIN                  VARCHAR(14),
              VerificaNULL(Query.FieldByName('CODIGO_INTERNO').AsString,1) + '|' +            // CODIGO_INTERNO        VARCHAR(20),
              VerificaNULL(Query.FieldByName('NOME').AsString,1) + '|' +                      // NOME                  VARCHAR(100),
              VerificaNULL(Query.FieldByName('DESCRICAO').AsString,1) + '|' +                 // DESCRICAO             VARCHAR(250),
              VerificaNULL(Query.FieldByName('DESCRICAO_PDV').AsString,1) + '|' +             // DESCRICAO_PDV         VARCHAR(30),
              VerificaNULL(Query.FieldByName('VALOR_VENDA').AsString,0) + '|' +               // VALOR_VENDA           DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('QTD_ESTOQUE').AsString,0) + '|' +               // QTD_ESTOQUE           DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('QTD_ESTOQUE_ANTERIOR').AsString,0) + '|' +      // QTD_ESTOQUE_ANTERIOR  DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('ESTOQUE_MIN').AsString,0) + '|' +               // ESTOQUE_MIN           DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('ESTOQUE_MAX').AsString,0) + '|' +               // ESTOQUE_MAX           DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('IAT').AsString,1) + '|' +                       // IAT                   CHAR(1),
              VerificaNULL(Query.FieldByName('IPPT').AsString,1) + '|' +                      // IPPT                  CHAR(1),
              VerificaNULL(Query.FieldByName('NCM').AsString,1) + '|' +                       // NCM                   VARCHAR(8),
              VerificaNULL(Query.FieldByName('TIPO_ITEM_SPED').AsString,1) + '|' +            // TIPO_ITEM_SPED        CHAR(2),
              QuotedStr(DataParaTexto(Query.FieldByName('DATA_ESTOQUE').AsDateTime)) + '|' +  // DATA_ESTOQUE          DATE,
              VerificaNULL(Query.FieldByName('TAXA_IPI').AsString,0) + '|' +                  // TAXA_IPI              DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('TAXA_ISSQN').AsString,0) + '|' +                // TAXA_ISSQN            DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('TAXA_PIS').AsString,0) + '|' +                  // TAXA_PIS              DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('TAXA_COFINS').AsString,0) + '|' +               // TAXA_COFINS           DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('TAXA_ICMS').AsString,0) + '|' +                 // TAXA_ICMS             DECIMAL(18,6),
              VerificaNULL(Query.FieldByName('CST').AsString,1) + '|' +                       // CST                   CHAR(3),
              VerificaNULL(Query.FieldByName('CSOSN').AsString,1) + '|' +                     // CSOSN                 CHAR(4),
              VerificaNULL(Query.FieldByName('TOTALIZADOR_PARCIAL').AsString,1) + '|' +       // TOTALIZADOR_PARCIAL   VARCHAR(10),
              VerificaNULL(Query.FieldByName('ECF_ICMS_ST').AsString,1) + '|' +               // ECF_ICMS_ST           VARCHAR(4),
              VerificaNULL(Query.FieldByName('CODIGO_BALANCA').AsString,0) + '|' +            // CODIGO_BALANCA        INTEGER,
              VerificaNULL(Query.FieldByName('PAF_P_ST').AsString,1) + '|' +                  // PAF_P_ST              CHAR(1)
             // VerificaNULL((MD5String(Tripa)),1)+'|'+                              // ok
              '-1|';                                                                // ok

              TProdutoController.GravaCargaProduto(Tupla);

              frmCargaPDV.ProgressBar.Position:= i;
              Query.Next;
            end;

          end;
           Result := True;

           TConfiguracaoController.GravaDataAtulaizacaoEstoque(DataParaTexto(dmprincipal.ACBrECF.DataHora));
        finally
          Query.Free;
        end;
      end;
    except
      Result := False;
    end;
  finally
    DecimalSeparator := ',';
  end;

end;

class function TProdutoController.GravaCargaProduto(vTupla: String): Boolean;
var
  ID: Integer;
begin
  try
    try
      if dmprincipal.BancoPAF = 'FIREBIRD' then
      begin
        ConsultaSQL :=
        'UPDATE OR INSERT INTO PRODUTO ('+
        'ID, '+
        'ID_UNIDADE_PRODUTO, '+
        'GTIN, '+
        'CODIGO_INTERNO, '+
        'NOME, '+
        'DESCRICAO, '+
        'DESCRICAO_PDV, '+
        'VALOR_VENDA, '+
        'QTD_ESTOQUE, '+
        'QTD_ESTOQUE_ANTERIOR, '+
        'ESTOQUE_MIN, '+
        'ESTOQUE_MAX, '+
        'IAT, '+
        'IPPT, '+
        'NCM, '+
        'TIPO_ITEM_SPED, '+
        'DATA_ESTOQUE, '+
        'TAXA_IPI, '+
        'TAXA_ISSQN, '+
        'TAXA_PIS, '+
        'TAXA_COFINS, '+
        'TAXA_ICMS, '+
        'CST, '+
        'CSOSN, '+
        'TOTALIZADOR_PARCIAL, '+
        'ECF_ICMS_ST, '+
        'CODIGO_BALANCA, '+
        'PAF_P_ST, '+
        'HASH_TRIPA, '+
        'HASH_INCREMENTO)'+

        ' values ('+

        DevolveConteudoDelimitado('|',vTupla)+', '+   //    ID                    INTEGER NOT NULL,
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    ID_UNIDADE_PRODUTO    INTEGER NOT NULL,
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    GTIN                  VARCHAR(14),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    CODIGO_INTERNO        VARCHAR(20),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    NOME                  VARCHAR(100),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    DESCRICAO             VARCHAR(250),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    DESCRICAO_PDV         VARCHAR(30),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    VALOR_VENDA           DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    QTD_ESTOQUE           DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    QTD_ESTOQUE_ANTERIOR  DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    ESTOQUE_MIN           DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    ESTOQUE_MAX           DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    IAT                   CHAR(1),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    IPPT                  CHAR(1),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    NCM                   VARCHAR(8),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TIPO_ITEM_SPED        CHAR(2),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    DATA_ESTOQUE          DATE,
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_IPI              DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_ISSQN            DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_PIS              DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_COFINS           DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_ICMS             DECIMAL(18,6),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    CST                   CHAR(3),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    CSOSN                 CHAR(4),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    TOTALIZADOR_PARCIAL   VARCHAR(10),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    ECF_ICMS_ST           VARCHAR(4),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    CODIGO_BALANCA        INTEGER,
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    PAF_P_ST              CHAR(1),
        DevolveConteudoDelimitado('|',vTupla)+', '+   //    HASH_TRIPA            VARCHAR(32),
        DevolveConteudoDelimitado('|',vTupla)+')';    //    HASH_INCREMENTO       INTEGER
      end
      else if dmprincipal.BancoPAF = 'MYSQL' then
      begin
        ID := StrToInt(DevolveConteudoDelimitado('|',vTupla));  //    ID              INTEGER NOT NULL,

        if not ConsultaIdProduto(ID) then
          ConsultaSQL :=
          'INSERT INTO PRODUTO ('+
          'ID, '+
          'ID_UNIDADE_PRODUTO, '+
          'GTIN, '+
          'CODIGO_INTERNO, '+
          'NOME, '+
          'DESCRICAO, '+
          'DESCRICAO_PDV, '+
          'VALOR_VENDA, '+
          'QTD_ESTOQUE, '+
          'QTD_ESTOQUE_ANTERIOR, '+
          'ESTOQUE_MIN, '+
          'ESTOQUE_MAX, '+
          'IAT, '+
          'IPPT, '+
          'NCM, '+
          'TIPO_ITEM_SPED, '+
          'DATA_ESTOQUE, '+
          'TAXA_IPI, '+
          'TAXA_ISSQN, '+
          'TAXA_PIS, '+
          'TAXA_COFINS, '+
          'TAXA_ICMS, '+
          'CST, '+
          'CSOSN, '+
          'TOTALIZADOR_PARCIAL, '+
          'ECF_ICMS_ST, '+
          'CODIGO_BALANCA, '+
          'PAF_P_ST, '+
          'HASH_TRIPA, '+
          'HASH_INCREMENTO)'+

          ' values ('+

          IntToStr(ID)+', '+                            //    ID                    INTEGER NOT NULL,
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    ID_UNIDADE_PRODUTO    INTEGER NOT NULL,
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    GTIN                  VARCHAR(14),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    CODIGO_INTERNO        VARCHAR(20),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    NOME                  VARCHAR(100),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    DESCRICAO             VARCHAR(250),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    DESCRICAO_PDV         VARCHAR(30),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    VALOR_VENDA           DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    QTD_ESTOQUE           DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    QTD_ESTOQUE_ANTERIOR  DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    ESTOQUE_MIN           DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    ESTOQUE_MAX           DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    IAT                   CHAR(1),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    IPPT                  CHAR(1),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    NCM                   VARCHAR(8),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TIPO_ITEM_SPED        CHAR(2),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    DATA_ESTOQUE          DATE,
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_IPI              DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_ISSQN            DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_PIS              DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_COFINS           DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_ICMS             DECIMAL(18,6),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    CST                   CHAR(3),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    CSOSN                 CHAR(4),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TOTALIZADOR_PARCIAL   VARCHAR(10),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    ECF_ICMS_ST           VARCHAR(4),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    CODIGO_BALANCA        INTEGER,
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    PAF_P_ST              CHAR(1),
          DevolveConteudoDelimitado('|',vTupla)+', '+   //    HASH_TRIPA            VARCHAR(32),
          '0)'                                          //    HASH_INCREMENTO       INTEGER
        else
          ConsultaSQL :=
          ' update  PRODUTO set '+

          'ID_UNIDADE_PRODUTO ='+  DevolveConteudoDelimitado('|',vTupla)+', '+   //    ID_UNIDADE_PRODUTO
          'GTIN ='+                DevolveConteudoDelimitado('|',vTupla)+', '+   //    GTIN
          'CODIGO_INTERNO ='+      DevolveConteudoDelimitado('|',vTupla)+', '+   //    CODIGO_INTERNO
          'NOME ='+                DevolveConteudoDelimitado('|',vTupla)+', '+   //    NOME
          'DESCRICAO ='+           DevolveConteudoDelimitado('|',vTupla)+', '+   //    DESCRICAO
          'DESCRICAO_PDV ='+       DevolveConteudoDelimitado('|',vTupla)+', '+   //    DESCRICAO_PDV
          'VALOR_VENDA ='+         DevolveConteudoDelimitado('|',vTupla)+', '+   //    VALOR_VENDA
          'QTD_ESTOQUE ='+         DevolveConteudoDelimitado('|',vTupla)+', '+   //    QTD_ESTOQUE
          'QTD_ESTOQUE_ANTERIOR ='+DevolveConteudoDelimitado('|',vTupla)+', '+   //    QTD_ESTOQUE_ANTERIOR
          'ESTOQUE_MIN ='+         DevolveConteudoDelimitado('|',vTupla)+', '+   //    ESTOQUE_MIN
          'ESTOQUE_MAX ='+         DevolveConteudoDelimitado('|',vTupla)+', '+   //    ESTOQUE_MAX
          'IAT ='+                 DevolveConteudoDelimitado('|',vTupla)+', '+   //    IAT
          'IPPT ='+                DevolveConteudoDelimitado('|',vTupla)+', '+   //    IPPT
          'NCM ='+                 DevolveConteudoDelimitado('|',vTupla)+', '+   //    NCM
          'TIPO_ITEM_SPED ='+      DevolveConteudoDelimitado('|',vTupla)+', '+   //    TIPO_ITEM_SPED
          'DATA_ESTOQUE ='+        DevolveConteudoDelimitado('|',vTupla)+', '+   //    DATA_ESTOQUE
          'TAXA_IPI ='+            DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_IPI
          'TAXA_ISSQN ='+          DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_ISSQN
          'TAXA_PIS ='+            DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_PIS
          'TAXA_COFINS ='+         DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_COFINS
          'TAXA_ICMS ='+           DevolveConteudoDelimitado('|',vTupla)+', '+   //    TAXA_ICMS
          'CST ='+                 DevolveConteudoDelimitado('|',vTupla)+', '+   //    CST
          'CSOSN ='+               DevolveConteudoDelimitado('|',vTupla)+', '+   //    CSOSN
          'TOTALIZADOR_PARCIAL ='+ DevolveConteudoDelimitado('|',vTupla)+', '+   //    TOTALIZADOR_PARCIAL
          'ECF_ICMS_ST ='+         DevolveConteudoDelimitado('|',vTupla)+', '+   //    ECF_ICMS_ST
          'CODIGO_BALANCA ='+      DevolveConteudoDelimitado('|',vTupla)+', '+   //    CODIGO_BALANCA
          'PAF_P_ST ='+            DevolveConteudoDelimitado('|',vTupla)+', '+   //    PAF_P_ST
          'HASH_TRIPA ='+          DevolveConteudoDelimitado('|',vTupla)+', '+   //    HASH_TRIPA
          'HASH_INCREMENTO =-1'+                                                //    HASH_INCREMENTO
          ' where ID ='+IntToStr(ID);
      end;

      Query := TSQLQuery.Create(nil);
      Query.DataBase := dmPrincipal.IBCon;
      Query.sql.Text := ConsultaSQL;
      Query.ExecSQL();

      Result:= true;
    except
       Result:= false;
    end;
  finally
    Query.Free;
  end;
end;

end.
