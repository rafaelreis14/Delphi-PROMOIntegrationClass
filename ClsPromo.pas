unit ClsPromo;

interface

uses Generics.Collections, System.SysUtils, Classes, IdHTTP, Xml.XMLIntf, XMLDoc, Math;

type
    TStatusEnvio = (NaoEnviado, Enviado);

    TStatusRetono = (ComErro, Correto, AguadandoOpcaoUsuario);

    TTipoBeneficio = (FixedDiscount, PercentageDiscount, NewPrice, PaymentPlanBenefit, CouponBenefit, GiftBenefit);

    TTipoEnvio = (sale, loyaltyValidation, finish, commit, rollback);

    TGenerico = 0 .. 255;

    TConverteEnum<T: record > = class
    private
    public
        class function ToEnum(const AStr: string): T;
        class function ToString(const eEnum: T): string;
    end;

    IApresentavel = interface
        ['{B97E420C-ED06-4D99-BA48-23CB5178A4EF}']
        function GetExibida: boolean;
        procedure SetExibida(const Value: boolean);
        procedure SetSequencia(const Value: string);
        procedure SetDescricao(const Value: string);
        procedure SetSequenciaExibida(const Value: string);
        function GetSequencia: string;
        function GetDescricao: string;
        function GetSequenciaExibida: string;
        property Exibida: boolean read GetExibida write SetExibida;
        property Sequencia: string read GetSequencia write SetSequencia;
        property Descricao: string read GetDescricao write SetDescricao;
        property SequenciaExibida: string read GetSequenciaExibida write SetSequenciaExibida;
    end;

    TBeneficio = class abstract(TInterfacedObject)
    private
        FDescricao: string;
        FIDPromo: string;
        FNumeroPromo: string;
        FSequencia: string;
        FTipoBeneficio: TTipoBeneficio;
        procedure SetDescricao(const Value: string);
        procedure SetIDPromo(const Value: string);
        procedure SetNumeroPromo(const Value: string);
        procedure SetSequencia(const Value: string);
        procedure SetTipoBeneficio(const Value: TTipoBeneficio);
        function GetSequencia: string;
        function GetDescricao: string;
    public
        property IDPromo: string read FIDPromo write SetIDPromo;
        property NumeroPromo: string read FNumeroPromo write SetNumeroPromo;
        property Descricao: string read GetDescricao write SetDescricao;
        property Sequencia: string read GetSequencia write SetSequencia;
        property TipoBeneficio: TTipoBeneficio read FTipoBeneficio write SetTipoBeneficio;
    end;

    TBeneficioApresentavel = class(TBeneficio, IApresentavel)
    private
        FExibida: boolean;
        FSequenciaExibida: string;
        function GetExibida: boolean;
        function GetSequenciaExibida: string;
        procedure SetExibida(const Value: boolean);
        procedure SetSequenciaExibida(const Value: string);
    public
        property Exibida: boolean read GetExibida write SetExibida;
        property SequenciaExibida: string read GetSequenciaExibida write SetSequenciaExibida;
    end;

    TBeneficioMonetario = class(TBeneficioApresentavel)
    private
        FUnidadeMedida: string;
        FValorTotal: double;
        FMetodoRateio: string;
        FDesconto: double;
        FValor: double;
        procedure SetMetodoRateio(const Value: string);
        procedure SetUnidadeMedida(const Value: string);
        procedure SetValorTotal(const Value: double);
        function GetValorComDesconto: double;
        procedure SetDesconto(const Value: double);
        procedure SetValor(const Value: double);

    public
        property UnidadeMedida: string read FUnidadeMedida write SetUnidadeMedida;
        property ValorTotal: double read FValorTotal write SetValorTotal;
        property MetodoRateio: string read FMetodoRateio write SetMetodoRateio;
        property Valor: double read FValor write SetValor;
        property Desconto: double read FDesconto write SetDesconto;
        property ValorComDesconto: double read GetValorComDesconto;
    end;

    TBeneficioPagamento = class(TBeneficioApresentavel)
    private
        FBanco: string;
        FPercentualDesconto: double;
        FFormaPagamento: string;
        FTipoPlano: string;
        FLimite: double;
        FTipoPercentual: string;
        FIDPlano: string;
        FTotalPagamento: double;
        FParcelas: integer;
        procedure SetBanco(const Value: string);
        procedure SetFormaPagamento(const Value: string);
        procedure SetIDPlano(const Value: string);
        procedure SetLimite(const Value: double);
        procedure SetPercentualDesconto(const Value: double);
        procedure SetTipoPercentual(const Value: string);
        procedure SetTipoPlano(const Value: string);
        procedure SetTotalPagamento(const Value: double);
        procedure SetParcelas(const Value: integer);
    public
        property FormaPagamento: string read FFormaPagamento write SetFormaPagamento;
        property Limite: double read FLimite write SetLimite;
        property IDPlano: string read FIDPlano write SetIDPlano;
        property TipoPlano: string read FTipoPlano write SetTipoPlano;
        property Banco: string read FBanco write SetBanco;
        property PercentualDesconto: double read FPercentualDesconto write SetPercentualDesconto;
        property TipoPercentual: string read FTipoPercentual write SetTipoPercentual;
        property TotalPagamento: double read FTotalPagamento write SetTotalPagamento;
        property Parcelas: integer read FParcelas write SetParcelas;
    end;

    TBeneficioVoucher = class(TBeneficioApresentavel)
    private
        FQuantidade: integer;
        FIDVoucher: string;
        procedure SetIDVoucher(const Value: string);
        procedure SetQuantidade(const Value: integer);
    public
        property IDVoucher: string read FIDVoucher write SetIDVoucher;
        property Quantidade: integer read FQuantidade write SetQuantidade;
    end;

    TBeneficioBrinde = class(TBeneficioApresentavel)
    private
        FIDBrinde: string;
        FQuantidade: integer;
        FTipoBrinde: string;
        procedure SetIDBrinde(const Value: string);
        procedure SetQuantidade(const Value: integer);
        procedure SetTipoBrinde(const Value: string);
    public
        property IDBrinde: string read FIDBrinde write SetIDBrinde;
        property Quantidade: integer read FQuantidade write SetQuantidade;
        property TipoBrinde: string read FTipoBrinde write SetTipoBrinde;
    end;

    TBasePromo = class abstract(TInterfacedObject)
    private
        FSequencia: string;
        FTagEnvio: string;
        FStatusEnvio: TStatusEnvio;
        FDeletado: boolean;
        procedure SetSequencia(const Value: string);
        procedure SetTagEnvio(const Value: string);
        procedure SetDeletado(const Value: boolean);
        procedure SetStatusEnvio(const Value: TStatusEnvio);
        function GetSequencia: string;
    public
        property TagEnvio: string read FTagEnvio write SetTagEnvio;
        property Sequencia: string read GetSequencia write SetSequencia;
        property StatusEnvio: TStatusEnvio read FStatusEnvio write SetStatusEnvio;
        property Deletado: boolean read FDeletado write SetDeletado;
        constructor Create;
        destructor Destroy; override;
    end;

    TVoucherPromo = class(TBasePromo)
    private
        FValorVoucher: double;
        FTipo: string;
        FQuantidade: integer;
        FIDVoucher: string;
    FValidado: boolean;
        procedure SetIDVoucher(const Value: string);
        procedure SetQuantidade(const Value: integer);
        procedure SetTipo(const Value: string);
        procedure SetValorVoucher(const Value: double);
        procedure SetValidado(const Value: boolean);
    public
        property ValorVoucher: double read FValorVoucher write SetValorVoucher;
        property Tipo: string read FTipo write SetTipo;
        property Quantidade: integer read FQuantidade write SetQuantidade;
        property IDVoucher: string read FIDVoucher write SetIDVoucher;
        property Validado: boolean read FValidado write SetValidado;
    end;

    TClientePromo = class(TBasePromo)
    private
        FTipoCliente: string;
        FSaldo: double;
        FPontos: integer;
        FIDCliente: string;
        procedure SetIDCliente(const Value: string);
        procedure SetPontos(const Value: integer);
        procedure SetSaldo(const Value: double);
        procedure SetTipoCliente(const Value: string);
    public
        property TipoCliente: string read FTipoCliente write SetTipoCliente;
        property IDCliente: string read FIDCliente write SetIDCliente;
        property Saldo: double read FSaldo write SetSaldo;
        property Pontos: integer read FPontos write SetPontos;
    end;

    TPagamentoPromo = class(TBasePromo)
    private
        FBanco: string;
        FIDPagamento: string;
        FValor: double;
        FTipoPagamento: string;
        FPlano: string;
        FParcelas: integer;
        procedure SetBanco(const Value: string);
        procedure SetIDPagamento(const Value: string);
        procedure SetPlano(const Value: string);
        procedure SetTipoPagamento(const Value: string);
        procedure SetValor(const Value: double);
        procedure SetParcelas(const Value: integer);
    public
        property TipoPagamento: string read FTipoPagamento write SetTipoPagamento;
        property IDPagamento: string read FIDPagamento write SetIDPagamento;
        property Plano: string read FPlano write SetPlano;
        property Valor: double read FValor write SetValor;
        property Banco: string read FBanco write SetBanco;
        property Parcelas: integer read FParcelas write SetParcelas;
    end;

    TSugestao = class(TBasePromo, IApresentavel)
    private
        FDescricao: string;
        FIDPromo: string;
        FExibida: boolean;
        FSequenciaExibida: string;
        procedure SetDescricao(const Value: string);
        procedure SetIDPromo(const Value: string);
        procedure SetSequencia(const Value: string);
        procedure SetExibida(const Value: boolean);
        function GetExibida: boolean;
        function GetDescricao: string;
        function GetSequenciaExibida: string;
        procedure SetSequenciaExibida(const Value: string);
    public
        property IDPromo: string read FIDPromo write SetIDPromo;
        property Descricao: string read GetDescricao write SetDescricao;
        property Exibida: boolean read GetExibida write SetExibida;
        property SequenciaExibida: string read GetSequenciaExibida write SetSequenciaExibida;
    end;

    TItemPromo = class(TBasePromo)
    private
        FCodigo: string;
        FQuantidade: double;
        FValor: double;
        FFamilia: string;
        FFabricante: string;
        FSubGrupo: string;
        FTipologia: string;
        FGrupo: string;
        FBeneficiosPagamentos: TObjectList<TBeneficioPagamento>;
        FBeneficiosBrindes: TObjectList<TBeneficioBrinde>;
        FBeneficiosMonetarios: TObjectList<TBeneficioMonetario>;
        FBeneficiosVouchers: TObjectList<TBeneficioVoucher>;
        FFornecedor: string;
        FDescricao: string;
        TotalDescontoAnterior: double;
        TotalBrindesAnterior: integer;
        TotalPagamentosAnterior: integer;
        TotalVoucherAnterior: integer;
        procedure SetCodigo(const Value: string);
        procedure SetQuantidade(const Value: double);
        procedure SetValor(const Value: double);
        function GetTotal: double;
        procedure SetFabricante(const Value: string);
        procedure SetFamilia(const Value: string);
        procedure SetGrupo(const Value: string);
        procedure SetSubGrupo(const Value: string);
        procedure SetTipologia(const Value: string);
        procedure SetBeneficiosBrindes(const Value: TObjectList<TBeneficioBrinde>);
        procedure SetBeneficiosMonetarios(const Value: TObjectList<TBeneficioMonetario>);
        procedure SetBeneficiosPagamentos(const Value: TObjectList<TBeneficioPagamento>);
        procedure SetBeneficiosVouchers(const Value: TObjectList<TBeneficioVoucher>);
        function GetTotalDesconto: double;
        procedure SetFornecedor(const Value: string);
        function GetGrupo: string;
        function GetSubGrupo: string;
        function GetTipologia: string;
        procedure SetDescricao(const Value: string);
        function GetExibida: boolean;
    public
        property Codigo: string read FCodigo write SetCodigo;
        property Descricao: string read FDescricao write SetDescricao;
        property Quantidade: double read FQuantidade write SetQuantidade;
        property Valor: double read FValor write SetValor;
        property Total: double read GetTotal;
        property Familia: string read FFamilia write SetFamilia;
        property Grupo: string read GetGrupo write SetGrupo;
        property SubGrupo: string read GetSubGrupo write SetSubGrupo;
        property Tipologia: string read GetTipologia write SetTipologia;
        property Fabricante: string read FFabricante write SetFabricante;
        property Fornecedor: string read FFornecedor write SetFornecedor;
        property TotalDesconto: double read GetTotalDesconto;
        function Exibida<T: TBeneficioApresentavel>: boolean;

        property BeneficiosMonetarios: TObjectList<TBeneficioMonetario> read FBeneficiosMonetarios write SetBeneficiosMonetarios;
        property BeneficiosPagamentos: TObjectList<TBeneficioPagamento> read FBeneficiosPagamentos write SetBeneficiosPagamentos;
        property BeneficiosBrindes: TObjectList<TBeneficioBrinde> read FBeneficiosBrindes write SetBeneficiosBrindes;
        property BeneficiosVouchers: TObjectList<TBeneficioVoucher> read FBeneficiosVouchers write SetBeneficiosVouchers;

        procedure AdicionarBeneficio(beneficio: TBeneficio);

        function ItemTemBeneficio: boolean;

        constructor Create;
        destructor Destroy; override;
    end;

    TPromo = class
    private
        FFilial: string;
        FIdentificador: string;
        FItensPromo: TObjectList<TItemPromo>;
        FSugestoes: TObjectList<TSugestao>;
        FUrl: string;
        FMessagemID: integer;
        FClientes: TObjectList<TClientePromo>;
        FVouchers: TObjectList<TVoucherPromo>;
        FPagamentos: TObjectList<TPagamentoPromo>;
        FSalvarXml: boolean;
        SequenciaItem, SequenciaCliente, SequenciaPagamento, SequenciaVoucher: string;
        FStatusRetorno: TStatusRetono;
        FNumeroEnvios: integer;
        FNEnvios: integer;
        FItensPromoComBeneficio: TList<TItemPromo>;
        FMapa: string;
        FValidarClientePROMO: boolean;
        procedure SetValidarClientePROMO(const Value: boolean);


        const
            LimiteMaximoEnvioItens: integer = 15;



        procedure SetFilial(const Value: string);
        procedure SetIdentificador(const Value: string);
        procedure SetItensPromo(const Value: TObjectList<TItemPromo>);
        procedure SetSugestoes(const Value: TObjectList<TSugestao>);
        procedure SetUrl(const Value: string);
        procedure SetMessagemID(const Value: integer);
        function ConverterNumeroTexto(numero: double): string;
        function ConverterTextoNumero(numero: string): double;
        procedure SetClientes(const Value: TObjectList<TClientePromo>);
        procedure SetPagamentos(const Value: TObjectList<TPagamentoPromo>);
        procedure SetVouchers(const Value: TObjectList<TVoucherPromo>);
        procedure SetSalvarXml(const Value: boolean);
        procedure SetStatusRetorno(const Value: TStatusRetono);
        procedure SetItensPromoComBeneficio(const Value: TList<TItemPromo>);


        function ObterListaDados<T: TBasePromo>: TObjectList<T>;
        procedure TratarRetornoSale(noMessage: IXMLNode);
        procedure TratarRetornoLoyaltyValidation(noMessage: IXMLNode);
        procedure ValidarErroLoyaltyFinish(noMessage: IXMLNode);

        procedure ValidarErro(noMessage: IXMLNode);
        function ObterNumeroDeOpcoes(noMessage: IXMLNode): integer;
        procedure LimpaBeneficios;
        function ConverterRequisicao(requisicao: string): string;
        procedure AtualizarDados;
        function VerificarSugestao(IDPromo, Sequencia: string): boolean; deprecated;

        procedure ObterNoItem(noMessage: IXMLNode);
        procedure ObterNoVoucher(noMessage: IXMLNode);
        procedure ObterNoCliente(noMessage: IXMLNode);
        procedure ObterNoPagamento(noMessage: IXMLNode);
        function ObterUltimaSequencia<T: TBasePromo>: string;
        procedure SalvarArquivoXml(Xml: TXMLDocument; nomeArquivo: string);
        function IfTernario(condicao: boolean; verdadeiro, falso: variant): variant;
        procedure ObterDadosBeneficio(Sequencia, IDPromo, NumeroPromo, Descricao: string; Valor, Desconto: double; TipoBeneficio: TTipoBeneficio; atributosBeneficio: IXMLNodeList);
        procedure VerificarMensagens<T: IApresentavel>(lista: TList<IApresentavel>; sequencias: TStringList; var result: TStringList);
        procedure RetornarMensagens<T: IApresentavel>(apresentavel: IApresentavel; validaExibida: boolean; var result: TStringList);
        procedure AdicionarSugestao(IDPromo: string; Sequencia: string; Descricao: string);
        function VeririficarExibicaoSugestao(sugestao: TSugestao): boolean;

        function ObterVoucherPorCodigoBarra(codigoBarra: string): TVoucherPromo;
        function ObterTotalVoucherNaoValidado: integer;
    public
        property Filial: string read FFilial write SetFilial;
        property Identificador: string read FIdentificador write SetIdentificador;
        property MessagemID: integer read FMessagemID write SetMessagemID;
        property ItensPromo: TObjectList<TItemPromo> read FItensPromo write SetItensPromo;
        property ItensPromoComBeneficio: TList<TItemPromo> read FItensPromoComBeneficio write SetItensPromoComBeneficio;
        property Sugestoes: TObjectList<TSugestao> read FSugestoes write SetSugestoes;
        property Vouchers: TObjectList<TVoucherPromo> read FVouchers write SetVouchers;
        property Clientes: TObjectList<TClientePromo> read FClientes write SetClientes;
        property Pagamentos: TObjectList<TPagamentoPromo> read FPagamentos write SetPagamentos;
        property Url: string read FUrl write SetUrl;
        property SalvarXml: boolean read FSalvarXml write SetSalvarXml;
        property StatusRetorno: TStatusRetono read FStatusRetorno write SetStatusRetorno;
        property NumeroEnvios: integer read FNEnvios;
        property Mapa: string read FMapa;
        property ValidarClientePROMO: boolean read FValidarClientePROMO write SetValidarClientePROMO;

        procedure ObterItensPromoComBeneficio;
        function ObterTodasSugestoesFormatadas: TStringList;

        function ObterItensNaoEnviados(out itens: string): integer; overload;
        function ObterItensNaoEnviados: integer; overload;

        function AdicionarItemPromo(Codigo, Descricao: string; Quantidade, Valor: double; Familia, Grupo, SubGrupo, Tipologia, Fabricante: string;
          Fornecedor: string; Sequencia: string): string; overload;
        function AdicionarItemPromo(Codigo, Descricao: string; Quantidade, Valor: double; Familia, Grupo, SubGrupo, Tipologia, Fabricante: string;
          Fornecedor: string): string; overload;
        function AdicionarItemPromo(Codigo: string; Quantidade, Valor: double): string; overload;
        procedure AlterarItemPromo(Sequencia: string; Quantidade: double; Valor: double);

        function AdicionarVoucher(ValorVoucher: double; Tipo: string; Quantidade: integer; IDVoucher: string): string; overload;
        function AdicionarVoucher(IDVoucher: string): string; overload;

        function AdicionarCliente(TipoCliente: string; IDCliente: string; Saldo: double; Pontos: integer): string; overload;
        function AdicionarCliente(Codigo: string; atividade: string; TipoCliente: string): string; overload;

        function AdicionarPagamento(TipoPagamento: string; IDPagamento: string; Plano: string; Valor: double; Banco: string; Parcelas: integer): string; overload;
        function AdicionarPagamento(FormaPagamento: string; administradora: string; Parcelas: integer; Valor: double): string; overload;

        procedure EnviarDados(data, hora: string; tipoEnvio: TTipoEnvio = sale); overload;
        procedure EnviarDados; overload;
        procedure EnviarDados(tipoEnvio: TTipoEnvio); overload;
        procedure ReenviarDados;
        procedure ValidarFidelidade;
        procedure Finalizar;
        procedure Comitar;
        procedure Reverter;

        procedure RemoverDados<T: TBasePromo>(Sequencia: string); overload;
        procedure RemoverDados<T: TBasePromo>; overload;
        function ObterDados<T: TBasePromo>(Sequencia: string): T;

        function ApresentarMensagens<T: IApresentavel>(sequencias: TStringList): TStringList; overload;
        function ApresentarMensagens<T: IApresentavel>(Sequencia: string): TStringList; overload;
        function ApresentarMensagens<T: IApresentavel>: TStringList; overload;

        procedure TratarRetorno(retorno: widestring; tipo:TTipoEnvio);

        procedure NovaSessao;

        constructor Create(Filial: string; Identificador: string; Url: string; SalvarXml: boolean; mapa: string = ''); overload;
        constructor Create(Filial: string; Identificador: string; Url: string); overload;
        destructor Destroy; override;
    end;

implementation

uses Vcl.Forms, Vcl.Dialogs, System.TypInfo, IdURI;

{ TPromo }

function TPromo.AdicionarItemPromo(Codigo, Descricao: string; Quantidade, Valor: double; Familia, Grupo, SubGrupo, Tipologia, Fabricante: string;
  Fornecedor: string; Sequencia: string): string;
var
    itemPromo: TItemPromo;
begin
    itemPromo := TItemPromo.Create;
    itemPromo.Sequencia := Sequencia;
    Self.SequenciaItem := Sequencia;
    itemPromo.Codigo := trim(Codigo);
    itemPromo.Quantidade := Quantidade;
    itemPromo.Valor := Valor;
    itemPromo.Familia := trim(Familia);
    itemPromo.Grupo := trim(Grupo);
    itemPromo.SubGrupo := trim(SubGrupo);
    itemPromo.Tipologia := trim(Tipologia);
    itemPromo.Fabricante := trim(Fabricante);
    itemPromo.Fornecedor := trim(Fornecedor);
    itemPromo.Descricao := trim(Descricao);
    Self.ItensPromo.Add(itemPromo);
    result := Sequencia;
end;

constructor TPromo.Create(Filial: string; Identificador: string; Url: string);
begin
    Self.Create(Filial, Identificador, Url, false);
end;

destructor TPromo.Destroy;
begin
    FreeAndNil(FItensPromo);

    if FSugestoes <> nil then
        FreeAndNil(FSugestoes);

    FreeAndNil(FClientes);
    FreeAndNil(FVouchers);
    FreeAndNil(FPagamentos);
    FreeAndNil(FItensPromoComBeneficio);
    inherited;
end;

procedure TPromo.EnviarDados(tipoEnvio: TTipoEnvio);
begin
   EnviarDados('', '', tipoenvio);
end;

procedure TPromo.Finalizar;
begin
    Self.EnviarDados(finish);
end;

procedure TPromo.EnviarDados;
begin
    EnviarDados('', '');
end;

procedure TPromo.ObterItensPromoComBeneficio;
var
    item: TItemPromo;
    beneficio: TBeneficio;
begin
    if FItensPromoComBeneficio <> nil then
        FreeAndNil(FItensPromoComBeneficio);

    FItensPromoComBeneficio := TList<TItemPromo>.Create;

    for item in Self.ItensPromo do
    begin
        if item.ItemTemBeneficio then
            FItensPromoComBeneficio.Add(item)
    end;
end;

procedure TPromo.ObterNoPagamento(noMessage: IXMLNode);
var
    pagto: TPagamentoPromo;
    noItem: IXMLNode;
begin
    for pagto in Self.Pagamentos do
    begin
        if pagto.StatusEnvio = NaoEnviado then
        begin
            if pagto.Deletado = false then
            begin
                noItem := noMessage.AddChild('payment-add');
                noItem.Attributes['seq'] := pagto.Sequencia;
                noItem.Attributes['type'] := pagto.TipoPagamento;
                noItem.Attributes['id'] := pagto.IDPagamento;
                noItem.Attributes['plan'] := pagto.Plano;
                noItem.Attributes['amount'] := Self.ConverterNumeroTexto(pagto.Valor);
                noItem.Attributes['bank'] := pagto.Banco;
                noItem.Attributes['installments'] := pagto.Parcelas;
            end
            else
            begin
                noItem := noMessage.AddChild('payment-void');
                noItem.Attributes['seq'] := pagto.Sequencia;
            end;
        end;
    end;
end;

procedure TPromo.ObterNoCliente(noMessage: IXMLNode);
var
    cliente: TClientePromo;
    noItem: IXMLNode;
begin
    for cliente in Self.Clientes do
    begin
        if cliente.StatusEnvio = NaoEnviado then
        begin
            if cliente.Deletado = false then
            begin
                noItem := noMessage.AddChild('customer-add');
                noItem.Attributes['seq'] := cliente.Sequencia;
                noItem.Attributes['type'] := cliente.TipoCliente;
                noItem.Attributes['remainingamount'] := Self.ConverterNumeroTexto(cliente.Saldo);
                noItem.Attributes['id'] := cliente.IDCliente;
            end
            else
            begin
                noItem := noMessage.AddChild('customer-void');
                noItem.Attributes['seq'] := cliente.Sequencia;
            end;
        end;
    end;
end;

procedure TPromo.ObterNoItem(noMessage: IXMLNode);
var
    item: TItemPromo;
    noItem: IXMLNode;
    count: integer;
begin
    count := 0;
    for item in Self.ItensPromo do
    begin
        if item.StatusEnvio = NaoEnviado then
        begin
            if item.Deletado = false then
            begin
                noItem := noMessage.AddChild('item-add');
                noItem.Attributes['seq'] := item.Sequencia;
                noItem.Attributes['code'] := item.Codigo;

                // varifica se tem casas decimais
                if (item.Quantidade - trunc(item.Quantidade) = 0) then
                begin
                    noItem.Attributes['qty'] := ConverterNumeroTexto(item.Quantidade);
                    noItem.Attributes['magnitude'] := ConverterNumeroTexto(item.Quantidade);
                end
                else
                begin
                    noItem.Attributes['qty'] := '1';
                    noItem.Attributes['magnitude'] := ConverterNumeroTexto(item.Quantidade);
                end;

                noItem.Attributes['unitprice'] := ConverterNumeroTexto(item.Valor);
                noItem.Attributes['xprice'] := ConverterNumeroTexto(item.Total);
                noItem.Attributes['level1'] := item.Tipologia;
                noItem.Attributes['level2'] := item.Familia;
                noItem.Attributes['level3'] := item.Grupo;
                noItem.Attributes['level4'] := item.SubGrupo;
                noItem.Attributes['supplier'] := item.Fornecedor;
                noItem.Attributes['brand'] := item.Fabricante;
                noItem.Attributes['discountable'] := 'true';
                inc(count);
            end
            else
            begin
                noItem := noMessage.AddChild('item-void');
                noItem.Attributes['seq'] := item.Sequencia;
                inc(count);
            end;
        end;

        if count = Self.LimiteMaximoEnvioItens then
            break;
    end;
end;

procedure TPromo.ObterNoVoucher(noMessage: IXMLNode);
var
    voucher: TVoucherPromo;
    noItem: IXMLNode;
begin
    for voucher in Self.Vouchers do
    begin
        if voucher.StatusEnvio = NaoEnviado then
        begin
            if voucher.Deletado = false then
            begin
                noItem := noMessage.AddChild('coupon-add');
                noItem.Attributes['seq'] := voucher.Sequencia;
                noItem.Attributes['amount'] := Self.ConverterNumeroTexto(voucher.ValorVoucher);
                noItem.Attributes['type'] := voucher.Tipo;
                noItem.Attributes['qty'] := voucher.Quantidade;
                noItem.Attributes['id'] := voucher.IDVoucher;
            end
            else
            begin
                noItem := noMessage.AddChild('coupon-void');
                noItem.Attributes['seq'] := voucher.Sequencia;
            end;
        end;
    end;
end;

function TPromo.ObterNumeroDeOpcoes(noMessage: IXMLNode): integer;
var
    atributos: IXMLNodeList;
    i: integer;
begin
    result := 0;
    for i := 0 to noMessage.ChildNodes.count - 1 do
        if noMessage.ChildNodes[i].NodeName = 'optional' then
            inc(result);

end;

function TPromo.ObterTodasSugestoesFormatadas: TStringList;
var
    sug: TSugestao;
    mensagem: string;
begin
    result := nil;

    if Sugestoes.count > 0 then
    begin
        result := TStringList.Create;
        for sug in Sugestoes do
        begin
            mensagem := 'SUGESTAO [Item(ns): ' + sug.Sequencia + ']' + #13#10 + sug.Descricao + #13#10;
            result.Add(mensagem);
        end;
    end;
end;

function TPromo.ObterTotalVoucherNaoValidado: integer;
var
    voucher: TVoucherPromo;
begin
    result := 0;
    for voucher in Self.Vouchers do
    begin
        if not voucher.Validado then
            inc(result)
    end;
end;

function TPromo.ObterUltimaSequencia<T>: string;
var
    seq: integer;
begin
    result := '1';
    if (TypeInfo(T) = System.TypeInfo(TItemPromo)) then
    begin
        seq := strtoint(Self.SequenciaItem);
        inc(seq);
        Self.SequenciaItem := IntToStr(seq);
        result := Self.SequenciaItem;
    end
    else if (TypeInfo(T) = System.TypeInfo(TVoucherPromo)) then
    begin
        seq := strtoint(Self.SequenciaVoucher);
        inc(seq);
        Self.SequenciaVoucher := IntToStr(seq);
        result := Self.SequenciaVoucher;
    end
    else if (TypeInfo(T) = System.TypeInfo(TClientePromo)) then
    begin
        seq := strtoint(Self.SequenciaCliente);
        inc(seq);
        Self.SequenciaCliente := IntToStr(seq);
        result := Self.SequenciaCliente;
    end
    else if (TypeInfo(T) = System.TypeInfo(TPagamentoPromo)) then
    begin
        seq := strtoint(Self.SequenciaPagamento);
        inc(seq);
        Self.SequenciaPagamento := IntToStr(seq);
        result := Self.SequenciaPagamento;
    end;
end;

function TPromo.ObterVoucherPorCodigoBarra(codigoBarra: string): TVoucherPromo;
var
    voucher: TVoucherPromo;
begin
    result := nil;
    for voucher in Self.Vouchers do
    begin
        if voucher.IDVoucher = codigoBarra then
        begin
            result := voucher;
            break
        end;
    end;

end;

procedure TPromo.AtualizarDados;
    procedure Atualizar(lista: TObjectList<TBasePromo>);
    var
        i: integer;
        item: TBasePromo;
        count: integer;
    begin
        for i := lista.count - 1 downto 0 do
        begin
            item := lista[i];

            if item.Deletado then
            begin
                lista.Remove(item);
                continue;
            end;
        end;

        for i := 0 to lista.count - 1 do
        begin
            item := lista[i];

            if item.StatusEnvio = NaoEnviado then
            begin
                item.StatusEnvio := Enviado;
                inc(count);

                if count = Self.LimiteMaximoEnvioItens then
                    break;
            end;

        end;
    end;

begin
    Atualizar(TObjectList<TBasePromo>(Self.ItensPromo));
    Atualizar(TObjectList<TBasePromo>(Self.Pagamentos));
    Atualizar(TObjectList<TBasePromo>(Self.Clientes));
    Atualizar(TObjectList<TBasePromo>(Self.Vouchers));
end;

function TPromo.AdicionarPagamento(TipoPagamento, IDPagamento, Plano: string; Valor: double; Banco: string; Parcelas: integer): string;
var
    pagto: TPagamentoPromo;
begin
    pagto := TPagamentoPromo.Create;
    pagto.Sequencia := Self.ObterUltimaSequencia<TPagamentoPromo>;
    pagto.TipoPagamento := trim(TipoPagamento);
    pagto.IDPagamento := trim(IDPagamento);
    pagto.Plano := Plano;
    pagto.Valor := Valor;
    pagto.Banco := Banco;
    pagto.Parcelas := Parcelas;
    Self.Pagamentos.Add(pagto);
    result := pagto.Sequencia;
end;

procedure TPromo.ObterDadosBeneficio(Sequencia, IDPromo, NumeroPromo, Descricao: string; Valor, Desconto: double; TipoBeneficio: TTipoBeneficio;
  atributosBeneficio: IXMLNodeList);
var
    beneficioMonetario: TBeneficioMonetario;
    beneficioPagamento: TBeneficioPagamento;
    beneficioVoucher: TBeneficioVoucher;
    beneficioBrinde: TBeneficioBrinde;
    beneficio: TBeneficio;
    campoValorMonetario: string;
    item: TItemPromo;
begin
    if TipoBeneficio in [TTipoBeneficio.FixedDiscount, TTipoBeneficio.PercentageDiscount, TTipoBeneficio.NewPrice] then
    begin
        beneficioMonetario := TBeneficioMonetario.Create;

        if TipoBeneficio = FixedDiscount then
            campoValorMonetario := 'discountAmount'
        else if TipoBeneficio = PercentageDiscount then
            campoValorMonetario := 'discountPercentage'
        else if TipoBeneficio = NewPrice then
            campoValorMonetario := 'newPrice';

        beneficioMonetario.Valor := Valor;
        beneficioMonetario.Desconto := Desconto;
        beneficioMonetario.UnidadeMedida := atributosBeneficio.FindNode('unit').Text;
        beneficioMonetario.ValorTotal := ConverterTextoNumero(atributosBeneficio.FindNode(campoValorMonetario).Text);
        beneficioMonetario.MetodoRateio := atributosBeneficio.FindNode('prorationMethod').Text;
        beneficio := beneficioMonetario;
    end
    else if TipoBeneficio in [TTipoBeneficio.PaymentPlanBenefit] then
    begin
        beneficioPagamento := TBeneficioPagamento.Create;
        beneficioPagamento.FormaPagamento := atributosBeneficio.FindNode('tender').Text;
        // beneficioPagamento.Limite := ConverterTextoNumero(atributosBeneficio.FindNode('limitAmount').Text);
        beneficioPagamento.IDPlano := atributosBeneficio.FindNode('planId').Text;
        beneficioPagamento.TipoPlano := atributosBeneficio.FindNode('type').Text;
        // beneficioPagamento.Banco := atributosBeneficio.FindNode('bank').Text;
        // beneficioPagamento.PercentualDesconto := ConverterTextoNumero(atributosBeneficio.FindNode('percent').Text);
        // beneficioPagamento.TipoPercentual := atributosBeneficio.FindNode('percenttype').Text;
        beneficioPagamento.TotalPagamento := ConverterTextoNumero(atributosBeneficio.FindNode('paymentAmount').Text);
        beneficioPagamento.Parcelas := strtoint(atributosBeneficio.FindNode('installments').Text);
        beneficio := beneficioPagamento;
    end
    else if TipoBeneficio in [TTipoBeneficio.CouponBenefit] then
    begin
        beneficioVoucher := TBeneficioVoucher.Create;
        beneficioVoucher.IDVoucher := atributosBeneficio.FindNode('couponId').Text;
        beneficioVoucher.Quantidade := StrToIntDef(atributosBeneficio.FindNode('qty').Text, 0);
        beneficio := beneficioVoucher;
    end
    else if TipoBeneficio in [TTipoBeneficio.GiftBenefit] then
    begin
        beneficioBrinde := TBeneficioBrinde.Create;
        beneficioBrinde.IDBrinde := atributosBeneficio.FindNode('giftId').Text;
        beneficioBrinde.TipoBrinde := atributosBeneficio.FindNode('giftType').Text;
        beneficioBrinde.Quantidade := StrToIntDef(atributosBeneficio.FindNode('qty').Text, 0);
        beneficio := beneficioBrinde;
    end;

    beneficio.Sequencia := Sequencia;
    beneficio.IDPromo := IDPromo;
    beneficio.NumeroPromo := NumeroPromo;
    beneficio.Descricao := Descricao;
    beneficio.TipoBeneficio := TipoBeneficio;

    item := Self.ObterDados<TItemPromo>(Sequencia);
    if item <> nil then
        item.AdicionarBeneficio(beneficio);
end;

function TPromo.ObterItensNaoEnviados: integer;
var
    itens: string;
begin
    result := ObterItensNaoEnviados(itens);
end;

function TPromo.ObterItensNaoEnviados(out itens: string): integer;
var
    item: TItemPromo;
begin
    itens := EmptyStr;
    result := 0;
    for item in Self.ItensPromo do
    begin
        if (item.StatusEnvio = NaoEnviado) and (item.Deletado = false) then
        begin
            inc(result);
            itens := itens + item.Sequencia + ',';
        end;
    end;
end;

function TPromo.AdicionarCliente(TipoCliente, IDCliente: string; Saldo: double; Pontos: integer): string;
var
    cliente: TClientePromo;
begin
    if Self.Clientes.count > 0 then
    begin
        FreeAndNil(Self.FClientes);
        Self.FClientes := TObjectList<TClientePromo>.Create;
    end;

    cliente := TClientePromo.Create;
    cliente.Sequencia := '1'; // Self.ObterUltimaSequencia<TClientePromo>;
    cliente.TipoCliente := TipoCliente;
    cliente.IDCliente := trim(IDCliente);
    cliente.Saldo := Saldo;
    cliente.Pontos := Pontos;
    Self.Clientes.Add(cliente);
    result := cliente.Sequencia;
end;

function TPromo.AdicionarItemPromo(Codigo, Descricao: string; Quantidade, Valor: double; Familia, Grupo, SubGrupo, Tipologia, Fabricante: string;
  Fornecedor: string): string;
begin
    result := Self.AdicionarItemPromo(Codigo, Descricao, Quantidade, Valor, Familia, Grupo, SubGrupo, Tipologia, Fabricante, Fornecedor,
      Self.ObterUltimaSequencia<TItemPromo>);
end;

function TPromo.AdicionarPagamento(FormaPagamento, administradora: string; Parcelas: integer; Valor: double): string;
begin
    result := Self.AdicionarPagamento(FormaPagamento, '', FormaPagamento, Valor, administradora, Parcelas);
end;

function TPromo.AdicionarCliente(Codigo, atividade, TipoCliente: string): string;
begin
    result := Self.AdicionarCliente(atividade, Codigo, 0, IfTernario(TipoCliente = 'J', 0, 1));
end;

function TPromo.AdicionarItemPromo(Codigo: string; Quantidade, Valor: double): string;
begin
    result := Self.AdicionarItemPromo(Codigo, '', Quantidade, Valor, '', '', '', '', '', '');
end;

procedure TPromo.AdicionarSugestao(IDPromo, Sequencia, Descricao: string);
var
    sug: TSugestao;
begin
    if FSugestoes = nil then
        FSugestoes := TObjectList<TSugestao>.Create;

    sug := TSugestao.Create;
    sug.IDPromo := IDPromo;
    sug.Sequencia := Sequencia;
    sug.Descricao := Descricao;
    Self.Sugestoes.Add(sug);
end;

function TPromo.AdicionarVoucher(IDVoucher: string): string;
begin
    result := Self.AdicionarVoucher(0, '', 0, IDVoucher);
end;

function TPromo.AdicionarVoucher(ValorVoucher: double; Tipo: string; Quantidade: integer; IDVoucher: string): string;
var
    voucher: TVoucherPromo;
begin
    voucher := TVoucherPromo.Create;
    voucher.Sequencia := Self.ObterUltimaSequencia<TVoucherPromo>;
    voucher.ValorVoucher := ValorVoucher;
    voucher.Tipo := Tipo;
    voucher.Quantidade := Quantidade;
    voucher.IDVoucher := trim(IDVoucher);
    Self.Vouchers.Add(voucher);
    result := voucher.Sequencia;
end;

procedure TPromo.AlterarItemPromo(Sequencia: string; Quantidade: double; Valor: double);
var
    item: TItemPromo;
begin
    item := Self.ObterDados<TItemPromo>(Sequencia);
    if item <> nil then
    begin
        item.StatusEnvio := NaoEnviado;
        item.Quantidade := Quantidade;
        item.Valor := Valor;
    end;
end;

procedure TPromo.Comitar;
begin
    Self.EnviarDados(commit);
end;

function TPromo.ConverterNumeroTexto(numero: double): string;
var
    texto: string;
begin
    texto := FloatToStr(numero);
    texto := StringReplace(texto, '.', '', [rfReplaceAll, rfIgnoreCase]);
    texto := StringReplace(texto, ',', '.', [rfReplaceAll, rfIgnoreCase]);
    result := texto;
end;

function TPromo.ConverterTextoNumero(numero: string): double;
var
    texto: string;
begin
    texto := numero;
    texto := StringReplace(texto, '.', ',', [rfReplaceAll, rfIgnoreCase]);
    result := StrToFloat(texto);
end;

constructor TPromo.Create(Filial, Identificador: string; Url: string; SalvarXml: boolean; mapa: string);
begin
    Self.Filial := Filial;
    Self.Identificador := Identificador;
    Self.MessagemID := 1;
    Self.FItensPromo := TObjectList<TItemPromo>.Create;
    Self.FSugestoes := nil;
    Self.FClientes := TObjectList<TClientePromo>.Create;
    Self.FVouchers := TObjectList<TVoucherPromo>.Create;
    Self.FPagamentos := TObjectList<TPagamentoPromo>.Create;
    Self.FSalvarXml := SalvarXml;
    Self.SequenciaItem := '0';
    Self.SequenciaCliente := '0';
    Self.SequenciaPagamento := '0';
    Self.SequenciaVoucher := '0';
    Self.FNumeroEnvios := 0;
    Self.FUrl := Url;
    Self.FMapa := mapa;
    Self.FValidarClientePROMO := false;
end;

function TPromo.ConverterRequisicao(requisicao: string): string;
begin
    result := StringReplace(requisicao, '<', '%3C', [rfReplaceAll]);
    result := StringReplace(result, '>', '%3E', [rfReplaceAll]);
    result := StringReplace(result, ' ', '%20', [rfReplaceAll]);
    result := StringReplace(result, '"', '%22', [rfReplaceAll]);
    result := StringReplace(result, '#', '%23', [rfReplaceAll]);
    result := StringReplace(result, ''#$D#$A'', '', [rfReplaceAll]);
end;

procedure TPromo.LimpaBeneficios;
var
    item: TItemPromo;
begin
    for item in Self.ItensPromo do
    begin
        FreeAndNil(item.FBeneficiosPagamentos);
        item.FBeneficiosPagamentos := TObjectList<TBeneficioPagamento>.Create;

        FreeAndNil(item.FBeneficiosBrindes);
        item.FBeneficiosBrindes := TObjectList<TBeneficioBrinde>.Create;

        FreeAndNil(item.FBeneficiosMonetarios);
        item.FBeneficiosMonetarios := TObjectList<TBeneficioMonetario>.Create;

        FreeAndNil(item.FBeneficiosVouchers);
        item.FBeneficiosVouchers := TObjectList<TBeneficioVoucher>.Create;
    end;
end;

function TPromo.ApresentarMensagens<T>(Sequencia: string): TStringList;
var
    seq: TStringList;
begin
    try
        seq := TStringList.Create;
        seq.Add(Sequencia);
        result := Self.ApresentarMensagens<T>(seq);
    finally
        if seq <> nil then
            FreeAndNil(seq);
    end;
end;

function TPromo.ApresentarMensagens<T>: TStringList;
begin
    result := Self.ApresentarMensagens<T>(nil);
end;

procedure TPromo.RetornarMensagens<T>(apresentavel: IApresentavel; validaExibida: boolean; var result: TStringList);
var
    mensagem: string;
begin
    if (TypeInfo(T) = System.TypeInfo(TBeneficioMonetario)) then
        mensagem := 'BENEFICIO: '
    else if (TypeInfo(T) = System.TypeInfo(TSugestao)) then
        mensagem := 'SUGESTAO: '
    else if (TypeInfo(T) = System.TypeInfo(TBeneficioVoucher)) then
        mensagem := 'VOUCHER: '
    else if (TypeInfo(T) = System.TypeInfo(TBeneficioBrinde)) then
        mensagem := 'BRINDE: '
    else if (TypeInfo(T) = System.TypeInfo(TBeneficioBrinde)) then
        mensagem := 'PAGAMENTO: ';

    if ((not apresentavel.Exibida) and (validaExibida)) or (not validaExibida) then
    begin
        mensagem := '[' + mensagem + ' Item(ns): ' + apresentavel.Sequencia + ']' + #13#10 + apresentavel.Descricao;
        result.Add(mensagem);
    end;
end;

procedure TPromo.Reverter;
begin
    Self.EnviarDados(rollback);
end;

procedure TPromo.VerificarMensagens<T>(lista: TList<IApresentavel>; sequencias: TStringList; var result: TStringList);
var
    seq: TStringList;
    apresentavel: IApresentavel;
    r, i, j: integer;

begin
    try
        seq := TStringList.Create;
        if lista <> nil then
        begin
            for apresentavel in lista do
            begin
                if sequencias <> nil then
                begin
                    for i := 0 to sequencias.count - 1 do
                    begin
                        seq.CommaText := apresentavel.Sequencia;

                        for j := 0 to seq.count - 1 do
                        begin // todas a mensagens de aviso terao que ser apresentadas
                            if (sequencias[i] = seq[j]) or (apresentavel.Sequencia = '0') then
                            begin
                                RetornarMensagens<T>(apresentavel, true, result);
                            end;
                        end;
                    end;
                end
                else
                begin
                    RetornarMensagens<T>(apresentavel, false, result);
                end;
            end;
        end;
    finally
        if seq <> nil then
            FreeAndNil(seq);
    end;
end;

function TPromo.VeririficarExibicaoSugestao(sugestao: TSugestao): boolean;
begin

end;

function TPromo.ApresentarMensagens<T>(sequencias: TStringList): TStringList;
var
    lista: TList<IApresentavel>;
    obj: T;
    mensagem: string;
    item: TItemPromo;
    apre: IApresentavel;
    sug: TSugestao;
    vou: TBeneficioVoucher;
    bri: TBeneficioBrinde;
    mon: TBeneficioMonetario;
    pag: TBeneficioPagamento;

begin
    result := TStringList.Create;
    lista := nil;

    if (TypeInfo(T) = System.TypeInfo(TSugestao)) then
    begin
        if Self.Sugestoes <> nil then
        begin
            lista := TList<IApresentavel>.Create;

            for sug in Self.Sugestoes do
            begin
                if not sug.Exibida then
                begin
                    sug.Exibida := true;
                    apre := TSugestao.Create;
                    apre.Sequencia := sug.Sequencia;
                    apre.Descricao := sug.Descricao;
                    lista.Add(IApresentavel(apre));
                end;
            end;

            VerificarMensagens<T>(lista, sequencias, result);
            FreeAndNil(lista);
        end;
    end
    else
    begin
        for item in Self.ItensPromo do
        begin
            if (TypeInfo(T) = System.TypeInfo(TBeneficioVoucher)) then
            begin
                if not item.Exibida<TBeneficioVoucher> then
                begin
                    lista := TList<IApresentavel>.Create;
                    for vou in item.BeneficiosVouchers do
                    begin
                        apre := TBeneficioVoucher.Create;
                        apre.Sequencia := vou.Sequencia;
                        apre.Descricao := vou.Descricao;
                        lista.Add(IApresentavel(apre));
                    end;
                end;
            end
            else if (TypeInfo(T) = System.TypeInfo(TBeneficioBrinde)) then
            begin
                if not item.Exibida<TBeneficioBrinde> then
                begin
                    lista := TList<IApresentavel>.Create;
                    for bri in item.BeneficiosBrindes do
                    begin
                        apre := TBeneficioVoucher.Create;
                        apre.Sequencia := bri.Sequencia;
                        apre.Descricao := bri.Descricao;
                        lista.Add(IApresentavel(apre));
                    end;
                end;
            end
            else if (TypeInfo(T) = System.TypeInfo(TBeneficioMonetario)) then
            begin
                if not item.Exibida<TBeneficioMonetario> then
                begin
                    lista := TList<IApresentavel>.Create;
                    for mon in item.BeneficiosMonetarios do
                    begin
                        apre := TBeneficioMonetario.Create;
                        apre.Sequencia := mon.Sequencia;
                        apre.Descricao := mon.Descricao;
                        lista.Add(apre);
                    end;
                end;
            end
            else if (TypeInfo(T) = System.TypeInfo(TBeneficioPagamento)) then
            begin
                if not item.Exibida<TBeneficioPagamento> then
                begin
                    lista := TList<IApresentavel>.Create;
                    for pag in item.BeneficiosPagamentos do
                    begin
                        apre := TBeneficioMonetario.Create;
                        apre.Sequencia := pag.Sequencia;
                        apre.Descricao := pag.Descricao;
                        lista.Add(apre);
                    end;
                end;
            end;

            if lista <> nil then
            begin
                VerificarMensagens<T>(lista, sequencias, result);
                FreeAndNil(lista);
            end;
        end;
    end;
end;

procedure TPromo.NovaSessao;
var
    fil, term: string;
    sal: boolean;
    Url: string;
begin
    fil := Self.Filial;
    term := Self.Identificador;
    sal := Self.SalvarXml;
    Url := Self.Url;
    FreeAndNil(Self);

    Self := TPromo.Create(fil, term, Url, sal);

end;

procedure TPromo.EnviarDados(data, hora: string; tipoEnvio: TTipoEnvio);
var
    ws: TIdHTTP;
    requisicao: string;
    retorno: widestring;
    noMessage: IXMLNode;
    Xml: TXMLDocument;
    init_tck: string;
    dataHora: string;
begin
    try
        try
            if (tipoEnvio = sale) or ((tipoEnvio <> sale) and (FNumeroEnvios = 0)) then
                inc(FNumeroEnvios);

            Xml := TXMLDocument.Create(Application);
            Xml.Active := true;
            Xml.Encoding := 'ISO-8859-1';
            Xml.Version := '1.0';
            Xml.StandAlone := 'yes';
            noMessage := Xml.Node.AddChild('message');

            noMessage.Attributes['substore'] := 'sales';

            noMessage.Attributes['store'] := Self.Filial;
            noMessage.Attributes['terminal'] := Self.Identificador;

            if (data = EmptyStr) then
                dataHora := FormatDateTime('yyyy-MM-dd hh:mm', Now)
            else
                dataHora := FormatDateTime('yyyy-MM-dd hh:mm', StrToDateTime(data + ' ' + hora));

            noMessage.Attributes['date-time'] := dataHora;

            noMessage.Attributes['messageId'] := IntToStr(Self.MessagemID);
            noMessage.Attributes['void-trx'] := 'false';
            noMessage.Attributes['suggest'] := 'true';
            noMessage.Attributes['response'] := 'true';

            if MessagemID = 1 then
            begin
                init_tck := 'true';
                if Self.Mapa <> emptyStr then
                    NoMessage.Attributes['map-version'] := Self.Mapa;
            end
            else
                init_tck := 'false';

            noMessage.Attributes['init-tck'] := init_tck;
            noMessage.Attributes['evaluate'] := 'true';
            noMessage.Attributes['msg-version'] := '2.4';
            noMessage.Attributes['status'] := TConverteEnum<TTipoEnvio>.ToString(tipoEnvio);


            if tipoEnvio = sale then
            begin
                ObterNoItem(noMessage);

                ObterNoVoucher(noMessage);

                ObterNoCliente(noMessage);

                ObterNoPagamento(noMessage);
            end;

            if Self.SalvarXml then
                Self.SalvarArquivoXml(Xml, 'requisicao' + TConverteEnum<TTipoEnvio>.ToString(tipoEnvio) + IntToStr(Self.FNumeroEnvios));

            ws := TIdHTTP.Create(Application);

            requisicao := Self.Url + '/engine/evaluate?request=' + Xml.Xml.Text;

            requisicao := Self.ConverterRequisicao(requisicao);

            retorno := ws.Get(requisicao);

            TratarRetorno(retorno, tipoEnvio);

            Self.MessagemID := Self.MessagemID + 1;

            AtualizarDados;

            if ObterItensNaoEnviados() > 0 then
                Self.EnviarDados(data, hora)
            else
            begin
                // caso não tenha mais nada pra enviar verifico se tem voucher e valido os vouchers.
                if tipoEnvio <> loyaltyValidation then
                    if Self.ObterTotalVoucherNaoValidado > 0 then
                        Self.ValidarFidelidade;
            end;

            if FNumeroEnvios > 0 then
                FNEnvios := FNumeroEnvios;

            FNumeroEnvios := 0;

        finally
            if Xml <> nil then
                FreeAndNil(Xml);

            if ws <> nil then
                FreeAndNil(ws);
        end;
    except
        on e: exception do
        begin
            FNumeroEnvios := 0;
            raise exception.Create('Erro ao  enviar dados.' + #13#10 + e.Message);

        end;
    end;
end;

procedure TPromo.ValidarErro(noMessage: IXMLNode);
var
    result: string;
    atributos: IXMLNodeList;
    erro: string;
begin
    result := EmptyStr;
    atributos := noMessage.AttributeNodes;
    erro := atributos.FindNode('ack').Text;

    Self.StatusRetorno := Correto;
    if erro <> '0' then
    begin
        if erro = '1' then
            result := 'Erro 1' + #13#10 + 'Falta de comunicação ou mensagem é ilegível.'
        else if erro = '2' then
            result := 'Erro 2' + #13#10 + 'A sessão não foi inicializada ou não existe tal sessão'
        else if erro = '3' then
            result := 'Erro 3' + #13#10 + 'Erro de validação da mensagem.'
        else if erro = '2001' then
            result := 'Erro 2001' + #13#10 + 'Erro de validação.'
        else if erro = '2002' then
            //result := 'Erro 2002' + #13#10 + 'Não existe uma mapa válido para cálculo da mensagem recebida'
        else if erro = '2003' then
            result := 'Erro 2003' + #13#10 + 'A sessão esta em uso'
        else if erro = '2004' then
            result := 'Erro 2004' + #13#10 + 'Erro geral de instanciação da sessão'
        else if erro = '2005' then
            result := 'Erro 2005' + #13#10 + 'Time out da sessão'
        else if erro = '4001' then
            result := 'Erro 4001' + #13#10 + 'Erro da avaliação da sugestão'
        else if erro = '8297' then
            result := 'Erro 8297' + #13#10 + 'Indica que o corpo da mensagem está vazio.'
        else if erro = '8298' then
            result := 'Erro 8298' + #13#10 + 'Solicitou a recuperação da transação original, mas não enviou qual é.'
        else if erro = '8299' then
            result := 'Erro 8299' + #13#10 + 'Erro genérico no envio do PROMO Central'
        else if erro = '9000' then
            result := 'Erro 9000' + #13#10 + 'A mensagem não tem um ticket associado'
        else if erro = '9001' then
            result := 'Erro 9001' + #13#10 + 'Há uma transação pendente. Ele recebeu uma nova transação a ser processada, mas não é isso que está pendente.'
        else if erro = '9002' then
            result := 'Erro 9002' + #13#10 + 'Não há nenhuma transação pendente. Ele recebeu uma mensagem com status = commit ou rollback, mas não houve transação pendente antes. Verificar'
        else if erro = '9003' then
            result := 'Erro 9003' + #13#10 + 'Solicitou informações a partir de uma transação anterior, mas não foi informado sobre o mesmo identificador'
        else if erro = '9004' then
            result := 'Erro 9004' + #13#10 + 'Solicitou informações a partir de uma transação anterior, mas a transação não existe.'
        else if erro = '9005' then
            result := 'Erro 9005' + #13#10 + 'Indica que o console está no modo offline.'
        else if erro = '9005' then
            result := 'Erro 9005' + #13#10 + 'Job de finalização de transações.'
        else if erro = '9101' then
            result := 'Erro 9101' + #13#10 + 'Voucher não encontrado.'
        else if erro = '9102' then
            result := 'Erro 9102' + #13#10 + 'Voucher já consumido.'
        else if erro = '9103' then
            result := 'Erro 9103' + #13#10 + 'Voucher inativo.'
        else if erro = '9104' then
            result := 'Erro 9104' + #13#10 + 'Tipo do Voucher não encontrado.'
        else if erro = '9105' then
            result := 'Erro 9105' + #13#10 + 'Voucher já expirado.'
        else if erro = '9106' then
            result := 'Erro 9106' + #13#10 + 'Já alcançou o número máximo de uso.'
        else if erro = '9107' then
            result := 'Erro 9107' + #13#10 + 'O Voucher é nomeado e não informou um cliente.'
        else if erro = '9108' then
            result := 'Erro 9108' + #13#10 + 'O tipo do voucher não está ativo.'
        else if erro = '9109' then
            result := 'Erro 9109' + #13#10 + 'O montante enviado não corresponde à quantidade de quota.'
        else if erro = '9110' then
            result := 'Erro 9110' + #13#10 + 'Voucher não usado.'
        else if erro = '9210' then
            result := 'Erro 9210' + #13#10 + 'Não encontrou o cabeçalho da transação.'
        else if erro = '9500' then
            result := 'Erro 9500' + #13#10 + 'Não encontrou o cartão fidelidade.'
        else if erro = '9501' then
            result := 'Erro 9501' + #13#10 + 'Cartão fidelidade inabilitado.'
        else if erro = '9502' then
            result := 'Erro 9502' + #13#10 + 'Cartão fidelidade cancelado.'
        else if erro = '9503' then
            result := 'Erro 9503' + #13#10 + 'Não encontrou o tipo do Cartão fidelidade.'
        else if erro = '9504' then
            result := 'Erro 9504' + #13#10 + 'O tipo do Cartão fidelidade não está ativo.'
        else if erro = '9505' then
            result := 'Erro 9505' + #13#10 + 'O tipo do Cartão fidelidade não recarregável.'
        else if erro = '9506' then
            result := 'Erro 9506' + #13#10 + 'O Cartão fidelidade já tem um cliente assiciado.'
        else if erro = '9507' then
            result := 'Erro 9507' + #13#10 + 'Não existe o status enviado do Cartão fidelidade.'
        else if erro = '9508' then
            result := 'Erro 9508' + #13#10 + 'O cartão não se aplica a um benefício.'
        else if erro = '9509' then
            result := 'Erro 9509' + #13#10 + 'O cartão requer um cliente.'
        else if erro = '9510' then
            result := 'Erro 9510' + #13#10 + 'Cartão não autorizado.'
        else if erro = '9511' then
            result := 'Erro 9511' + #13#10 + 'Amount inválido.'
        else if erro = '9512' then
            result := 'Erro 9512' + #13#10 + 'Requer ao menos dois cartões.'
        else if erro = '9513' then
            result := 'Erro 9513' + #13#10 + 'O cartão não adimite transferência.'
        else if erro = '9514' then
            result := 'Erro 9514' + #13#10 + 'o cartão destino está ativo.'
        else if erro = '9515' then
            result := 'Erro 9515' + #13#10 + 'Os cartões não são iguais.'
        else if erro = '9516' then
            result := 'Erro 9516' + #13#10 + 'o saldo informado é maior que o saldo total.'
        else if erro = '9603' then
            if ValidarClientePROMO then result := 'Erro 9603' + #13#10 + 'Cliente inexistente.'
        else if erro = '9610' then
            if ValidarClientePROMO then result := 'Erro 9610' + #13#10 + 'Identificador do cliente vazio.'
        else if erro = '9611' then
            if ValidarClientePROMO then result := 'Erro 9611' + #13#10 + 'Nome do cliente vazio.'
        else if erro = '9612' then
            if ValidarClientePROMO then result := 'Erro 9612' + #13#10 + 'Apelido do cliente vazio.'
        else if erro = '9613' then
            if ValidarClientePROMO then result := 'Erro 9613' + #13#10 + 'ID do cliente vazio.'
        else if erro = '9614' then
            if ValidarClientePROMO then result := 'Erro 9614' + #13#10 + 'Não recebeu parâmetro do cliente.'
        else if erro = '9620' then
            if ValidarClientePROMO then result := 'Erro 9620' + #13#10 + 'Cliente já existente.'
        else if erro = '9629' then
            if ValidarClientePROMO then result := 'Erro 9629' + #13#10 + 'Cliente inativo.'
        else if erro = '9901' then
            result := 'Erro 9901' + #13#10 + 'Erro de voucher inesperado.'
        else if erro = '9999' then
            result := 'Erro 9999' + #13#10 + 'Erro inesperado.'
        else
            result := 'Erro não catalogado.'
    end;

    if result <> EmptyStr then
        StatusRetorno := ComErro;

    // if  ObterNumeroDeOpcoes(noMessage) > 1 then
    // result := 'Erro 7347'+ #13#10 +'Erro na criação da promoção. Foi criada alguma promoção utilizando o Método "Opções" e precisa ser ajustado no departamento responsável.';

    if result <> EmptyStr then
        raise exception.Create(result);
end;

procedure TPromo.ValidarFidelidade;
begin
    Self.EnviarDados(loyaltyvalidation);
end;



function TPromo.ObterListaDados<T>: TObjectList<T>;
begin
    result := nil;
    if (TypeInfo(T) = System.TypeInfo(TItemPromo)) then
        result := TObjectList<T>(Self.ItensPromo)
    else if (TypeInfo(T) = System.TypeInfo(TVoucherPromo)) then
        result := TObjectList<T>(Self.Vouchers)
    else if (TypeInfo(T) = System.TypeInfo(TClientePromo)) then
        result := TObjectList<T>(Self.Clientes)
    else if (TypeInfo(T) = System.TypeInfo(TPagamentoPromo)) then
        result := TObjectList<T>(Self.Pagamentos);
end;


function TPromo.ObterDados<T>(Sequencia: string): T;
var
    lista: TObjectList<T>;
    item: TBasePromo;
    i: integer;
begin
    result := nil;

    lista := Self.ObterListaDados<T>;

    for i := 0 to lista.count - 1 do
    begin
        item := TBasePromo(lista[i]);
        if item.Sequencia = Sequencia then
        begin
            result := T(item);
            break;
        end;
    end;
end;

procedure TPromo.RemoverDados<T>(Sequencia: string);
var
    base: TBasePromo;
    lista: TObjectList<T>;
begin

    base := Self.ObterDados<T>(Sequencia);
    if (base <> nil) then
    begin
        if (base.StatusEnvio = NaoEnviado) then
        begin
            lista := Self.ObterListaDados<T>;
            lista.Remove(base);
        end
        else
        begin
            base.Deletado := true;
            base.StatusEnvio := NaoEnviado;
        end;

    end
    else
        raise exception.Create('Erro ao remover o item' + #13#10 + 'Item não encontrado');
end;

procedure TPromo.ReenviarDados;
var
    basePromo: TBasePromo;
begin
    Self.MessagemID := 1;

    Self.LimpaBeneficios;

    for basepromo in Self.ItensPromo do
        basePromo.StatusEnvio := NaoEnviado;

    for basepromo in Self.Clientes do
        basePromo.StatusEnvio := NaoEnviado;

    for basepromo in Self.Vouchers do
        basePromo.StatusEnvio := NaoEnviado;

    for basepromo in Self.Pagamentos do
        basePromo.StatusEnvio := NaoEnviado;

    Self.EnviarDados;
end;

procedure TPromo.RemoverDados<T>;
var
    lista: TObjectList<T>;
    item: TBasePromo;
    i: integer;
begin
    lista := nil;

    lista := Self.ObterListaDados<T>;

    for item in lista do
        Self.RemoverDados<T>(item.Sequencia);

end;

procedure TPromo.SalvarArquivoXml(Xml: TXMLDocument; nomeArquivo: string);
begin
    Xml.SaveToFile(ExtractFilePath(Application.ExeName) + '\' + nomeArquivo + '.xml');
end;

procedure TPromo.SetClientes(const Value: TObjectList<TClientePromo>);
begin
    FClientes := Value;
end;

procedure TPromo.SetFilial(const Value: string);
begin
    FFilial := Value;
end;

procedure TPromo.SetItensPromo(const Value: TObjectList<TItemPromo>);
begin
    FItensPromo := Value;
end;

procedure TPromo.SetItensPromoComBeneficio(const Value: TList<TItemPromo>);
begin
    FItensPromoComBeneficio := Value;
end;


procedure TPromo.SetMessagemID(const Value: integer);
begin
    FMessagemID := Value;
end;

procedure TPromo.SetPagamentos(const Value: TObjectList<TPagamentoPromo>);
begin
    FPagamentos := Value;
end;

procedure TPromo.SetSalvarXml(const Value: boolean);
begin
    FSalvarXml := Value;
end;

procedure TPromo.SetStatusRetorno(const Value: TStatusRetono);
begin
    FStatusRetorno := Value;
end;

procedure TPromo.SetSugestoes(const Value: TObjectList<TSugestao>);
begin
    FSugestoes := Value;
end;

procedure TPromo.SetIdentificador(const Value: string);
begin
    FIdentificador := Value;
end;

procedure TPromo.SetUrl(const Value: string);
begin
    FUrl := Value;
end;

procedure TPromo.SetValidarClientePROMO(const Value: boolean);
begin
  FValidarClientePROMO := Value;
end;

procedure TPromo.SetVouchers(const Value: TObjectList<TVoucherPromo>);
begin
    FVouchers := Value;
end;

function TPromo.VerificarSugestao(IDPromo: string; Sequencia: string): boolean;
var
    sug: TSugestao;
begin
    result := true;
    for sug in Self.Sugestoes do
    begin

        if (sug.IDPromo = IDPromo) and (sug.Sequencia = Sequencia) then
            result := false;
    end;
end;

procedure TPromo.TratarRetorno(retorno: widestring; tipo:TTipoEnvio);
var
    noMessage: IXMLNode;
    Xml: TXMLDocument;
begin
    try
        Xml := TXMLDocument.Create(Application);
        Xml.LoadFromXML(retorno);

        if Self.SalvarXml then
            Self.SalvarArquivoXml(Xml, 'retorno' + TConverteEnum<TTipoEnvio>.ToString(tipo) + IntToStr(Self.FNumeroEnvios));

        noMessage := Xml.DocumentElement;

        if tipo = sale then
            Self.TratarRetornoSale(noMessage)
        else
        if tipo = loyaltyValidation then
            Self.TratarRetornoLoyaltyValidation(noMessage)
        else
        if tipo = finish then
            Self.ValidarErroLoyaltyFinish(noMessage)
        else
            ValidarErro(noMessage);
    except
        on e: exception do
        begin
            raise exception.Create('Erro ao tratar o retorno do PROMO' + #13#10 + e.Message);

        end;
    end;
end;


procedure TPromo.TratarRetornoSale(noMessage: IXMLNode);
var
    Sequencia: string;
    NoAck, NoOptional, NoPromo, NoBenefit, NoApply, noItem, NoSuggestion, NoAux: IXMLNode;
    atributos, atributosBeneficio: IXMLNodeList;
    i, j, r, g: integer;
    IDPromo, NumeroPromo, Valor, Desconto, Descricao: string;
    sug1, sug2: TSugestao;
    TipoBeneficio: TTipoBeneficio;
    listaSugestaoPromo: TObjectList<TSugestao>;
    achou: boolean;
begin
    listaSugestaoPromo := nil;
    try
        try
            ValidarErro(noMessage);

            LimpaBeneficios;

            atributos := noMessage.AttributeNodes;
            Self.FMapa := atributos.FindNode('mapversion').Text;


            NoOptional := noMessage.ChildNodes.FindNode('optional');
            if NoOptional <> nil then
            begin
                for i := 0 to NoOptional.ChildNodes.count - 1 do
                begin
                    NoPromo := NoOptional.ChildNodes[i];
                    for j := 0 to NoPromo.ChildNodes.count - 1 do
                    begin
                        if NoPromo.ChildNodes[j].NodeName = 'benefit' then
                        begin
                            NoBenefit := NoPromo.ChildNodes[j];
                            atributos := NoPromo.AttributeNodes;
                            IDPromo := atributos.FindNode('id').Text;
                            NumeroPromo := atributos.FindNode('nro').Text;

                            for r := 0 to NoBenefit.ChildNodes.count - 1 do
                            begin

                                NoApply := NoBenefit.ChildNodes.FindNode('apply');

                                atributosBeneficio := NoBenefit.AttributeNodes;
                                Descricao := atributosBeneficio.FindNode('displayMessage').Text;
                                TipoBeneficio := TConverteEnum<TTipoBeneficio>.ToEnum(atributosBeneficio.FindNode('benefitType').Text);

                                for g := 0 to NoApply.ChildNodes.count - 1 do
                                begin
                                    noItem := NoApply.ChildNodes[g];
                                    atributos := noItem.AttributeNodes;
                                    Sequencia := atributos.FindNode('seq').Text;
                                    Valor := atributos.FindNode('xprice').Text;
                                    Desconto := atributos.FindNode('value').Text;
                                    Self.ObterDadosBeneficio(Sequencia, IDPromo, NumeroPromo, Descricao, ConverterTextoNumero(Valor),
                                      ConverterTextoNumero(Desconto), TipoBeneficio, atributosBeneficio);
                                end;
                            end;
                        end;
                    end;
                end;
            end;

            NoSuggestion := noMessage.ChildNodes.FindNode('suggestions');

            if ObterNumeroDeOpcoes(noMessage) > 1 then
                Self.AdicionarSugestao('0', '0',
                  'AVISO IMPORTANTE: EXISTE ALGUMA PROMOÇÃO QUE ESTA CADASTRADA ERRADA COM A FUNCÇÃO DE CONVIVÊNCIA "OPÇÃO". FAVOR COMUNICAR DEPARTAMENTO DE TI');

            if NoSuggestion <> nil then
            begin
                listaSugestaoPromo := TObjectList<TSugestao>.Create;

                for i := 0 to NoSuggestion.ChildNodes.count - 1 do
                begin
                    NoPromo := NoSuggestion.ChildNodes[i];
                    atributos := NoPromo.AttributeNodes;
                    IDPromo := atributos.FindNode('id').Text;

                    NoAux := atributos.FindNode('item-seq');
                    if NoAux <> nil then
                        Sequencia := NoAux.Text;

                    Descricao := IfTernario(atributos.FindNode('descriptor') <> nil, atributos.FindNode('descriptor').Text, '');

                    sug2 := TSugestao.Create;
                    sug2.IDPromo := IDPromo;
                    sug2.Sequencia := Sequencia;
                    sug2.Descricao := Descricao;
                    listaSugestaoPromo.Add(sug2);
                end;
            end;
            if listaSugestaoPromo <> nil then
            begin
                if listaSugestaoPromo.count > 0 then
                begin
                    if Sugestoes <> nil then
                    begin
                        for sug1 in Sugestoes do
                        begin
                            achou := false;
                            for sug2 in listaSugestaoPromo do
                            begin
                                if (sug1.Descricao = sug2.Descricao) and (sug1.Sequencia = sug2.Sequencia) and (sug1.Deletado = false) then
                                begin
                                    achou := true;
                                    break;
                                end;
                            end;
                            if not achou then
                                sug1.Deletado := true;
                        end;
                    end;
                    for sug2 in listaSugestaoPromo do
                    begin
                        achou := false;
                        if Sugestoes <> nil then
                        begin
                            for sug1 in Sugestoes do
                            begin
                                if (sug2.Descricao = sug1.Descricao) and (sug2.Sequencia = sug1.Sequencia) and (sug1.Deletado = false) then
                                begin
                                    sug2.Exibida := true;
                                    achou := true;
                                    break;
                                end;
                            end;
                        end;
                        if not achou then
                            Self.AdicionarSugestao(sug2.IDPromo, sug2.Sequencia, sug2.Descricao);
                    end;
                end;
            end;
        finally
            if listaSugestaoPromo <> nil then
                FreeAndNil(listaSugestaoPromo);
        end;
    except
        on e: exception do
        begin
            raise exception.Create('Erro retorno Sale' + #13#10 + e.Message);

        end;
    end;
end;

procedure TPromo.ValidarErroLoyaltyFinish(noMessage: IXMLNode);
var
     NoLoyalty, NoErros, NoErro : IXMLNode;
     atributos: IXMLNodeList;
     i: integer;
     sequencia, tipoErro, codigoBarra: string;
begin
    try
        try
            ValidarErro(noMessage);

            NoLoyalty := noMessage.ChildNodes.FindNode('loyalty');
            if NoLoyalty <> nil then
            begin
                NoErros := NoLoyalty.ChildNodes.FindNode('errors');
                if NoErros <> nil then
                begin
                   for i := 0 to NoErros.ChildNodes.Count-1 do
                   begin
                       NoErro := NoErros.ChildNodes[i];
                       ValidarErro(NoErro);

                       atributos := NoErro.AttributeNodes;
                       codigoBarra := atributos.FindNode('info').Text;
                       sequencia := atributos.FindNode('seq').Text;
                       tipoErro := atributos.FindNode('type').Text;
                       if tipoErro = 'coupon-redeem' then
                       begin
                            //caso aconteça algum erro eu limpo os vouchers.
                            if Self.FVouchers <> nil then
                               FreeAndNil(Self.FVouchers);

                            Self.FVouchers := TObjectList<TVoucherPromo>.Create;
                        end;
                   end;
               end;
           end;
        except
        on e: exception do
        begin
            raise exception.Create('Erro ao validar erro Loyalt ou Finish' + #13#10 + e.Message);
        end;
    end;
    finally
//       if NoLoyalty <> nil then
//           FreeAndNil(NoLoyalty);
//       if NoErros <> nil then
//           FreeAndNil(NoErros);
//       if NoErro <> nil then
//           FreeAndNil(NoErro);
    end;
end;


procedure TPromo.TratarRetornoLoyaltyValidation(noMessage: IXMLNode);
var
    NoLoyalty, NoCoupon, NoCoupons: IXMLNode;
    atributos: IXMLNodeList;
    i: integer;
    tipoVoucher,codigoBarra: string;
    sequencia, tipoErro: string;
    voucher: TVoucherPromo;
begin
    try
        try
           ValidarErroLoyaltyFinish(noMessage);

           NoLoyalty := noMessage.ChildNodes.FindNode('loyalty');
           if NoLoyalty <> nil then
           begin

               NoCoupons := NoLoyalty.ChildNodes.FindNode('coupons');
               if NoCoupons <> nil then
               begin
                  for i := 0 to NoCoupons.ChildNodes.Count-1 do
                  begin
                        NoCoupon := NoCoupons.ChildNodes[i];
                        ValidarErro(NoCoupon);
                        atributos := NoCoupon.AttributeNodes;
                        codigoBarra := atributos.FindNode('barcode').Text;
                        tipoVoucher := atributos.FindNode('couponId').Text;
                        sequencia := atributos.FindNode('seq').Text;

                        //voucher := Self.ObterVoucherPorCodigoBarra(codigoBarra);
                        voucher := Self.ObterDados<TVoucherPromo>(sequencia);
                        if voucher <> nil then
                        begin
                            voucher.StatusEnvio :=  NaoEnviado;
                            voucher.Tipo := tipoVoucher;
                            voucher.Validado := true;
                        end;
                  end;
                  Self.EnviarDados;
               end;
           end;

        except
            on e: exception do
            begin
                raise exception.Create('Erro retorno Loyalt Validation' + #13#10 + e.Message);

            end;
        end;
    finally
//        if NoLoyalty <> nil then
//            FreeAndNil(NoLoyalty);
//        if NoCoupon <> nil then
//            FreeAndNil(NoCoupon);
//        if NoCoupons <> nil then
//            FreeAndNil(NoCoupons);
    end;
end;


function TPromo.IfTernario(condicao: boolean; verdadeiro, falso: variant): variant;
begin
    if condicao then
        result := verdadeiro
    else
        result := falso;
end;

{ TItemPromo }

procedure TItemPromo.AdicionarBeneficio(beneficio: TBeneficio);
var
    lista: TObjectList<TBeneficio>;
begin
    if beneficio.TipoBeneficio in [TTipoBeneficio.FixedDiscount, TTipoBeneficio.PercentageDiscount, TTipoBeneficio.NewPrice] then
        lista := TObjectList<TBeneficio>(Self.BeneficiosMonetarios)
    else if beneficio.TipoBeneficio in [TTipoBeneficio.PaymentPlanBenefit] then
        lista := TObjectList<TBeneficio>(Self.BeneficiosPagamentos)
    else if beneficio.TipoBeneficio in [TTipoBeneficio.CouponBenefit] then
        lista := TObjectList<TBeneficio>(Self.BeneficiosVouchers)
    else if beneficio.TipoBeneficio in [TTipoBeneficio.GiftBenefit] then
        lista := TObjectList<TBeneficio>(Self.BeneficiosBrindes);

    lista.Add(beneficio);
end;

constructor TItemPromo.Create;
begin
    FBeneficiosPagamentos := TObjectList<TBeneficioPagamento>.Create;
    FBeneficiosBrindes := TObjectList<TBeneficioBrinde>.Create;
    FBeneficiosMonetarios := TObjectList<TBeneficioMonetario>.Create;
    FBeneficiosVouchers := TObjectList<TBeneficioVoucher>.Create;
end;

destructor TItemPromo.Destroy;
begin
    FreeAndNil(FBeneficiosPagamentos);
    FreeAndNil(FBeneficiosBrindes);
    FreeAndNil(FBeneficiosMonetarios);
    FreeAndNil(FBeneficiosVouchers);
    inherited;
end;

function TItemPromo.Exibida<T>: boolean;
var
    val: double;
begin
    result := true;
    if (TypeInfo(T) = System.TypeInfo(TBeneficioVoucher)) then
    begin
        result := (BeneficiosVouchers.count = TotalVoucherAnterior);
        TotalVoucherAnterior := BeneficiosVouchers.count;
    end
    else if (TypeInfo(T) = System.TypeInfo(TBeneficioBrinde)) then
    begin
        result := (BeneficiosBrindes.count = TotalBrindesAnterior);
        TotalBrindesAnterior := BeneficiosBrindes.count;
    end
    else if (TypeInfo(T) = System.TypeInfo(TBeneficioMonetario)) then
    begin
        val := Self.TotalDesconto;
        result := val = TotalDescontoAnterior;
        TotalDescontoAnterior := val;
    end
    else if (TypeInfo(T) = System.TypeInfo(TBeneficioPagamento)) then
    begin
        result := (BeneficiosPagamentos.count = TotalPagamentosAnterior);
        TotalPagamentosAnterior := BeneficiosPagamentos.count;
    end;
end;

function TItemPromo.GetExibida: boolean;
begin
end;

function TItemPromo.GetGrupo: string;
begin
    if (Self.FFamilia <> '') and (FGrupo <> '') then
        result := Self.FFamilia + '-' + Self.FGrupo
    else
        result := '';
end;

function TItemPromo.GetSubGrupo: string;
begin
    if (Self.FFamilia <> '') and (Self.FGrupo <> '') and (Self.FSubGrupo <> '') then
        result := Self.FFamilia + '-' + Self.FGrupo + '-' + Self.FSubGrupo
    else
        result := '';
end;

function TItemPromo.GetTipologia: string;
begin
    // if (Self.FFamilia <> '') and (Self.FGrupo <> '') and (Self.FSubGrupo <> '') and (Self.FTipologia <> '')then
    // result := Self.FFamilia+'.'+Self.FGrupo+'.'+Self.FSubGrupo+'.'+Self.FTipologia
    // else
    // result := '';
    result := FTipologia;
end;

function TItemPromo.GetTotal: double;
begin
    result := Self.Quantidade * Self.Valor;
end;

function TItemPromo.GetTotalDesconto: double;
var
    benf: TBeneficioMonetario;
begin
    result := 0;
    for benf in Self.BeneficiosMonetarios do
        result := result + benf.Desconto;

    // garante que o valor de desconto não será maior que o total do item.
    if result >= Self.Total then
        result := Self.Total - 0.01;
end;

function TItemPromo.ItemTemBeneficio: boolean;
begin
    result := false;
    if Self.BeneficiosMonetarios.Count > 0 then result := true;
    if Self.BeneficiosPagamentos.Count > 0 then result := true;
    if Self.BeneficiosBrindes.Count > 0 then result := true;
    if Self.BeneficiosVouchers.Count > 0 then result := true;
end;

procedure TItemPromo.SetBeneficiosBrindes(const Value: TObjectList<TBeneficioBrinde>);
begin
    FBeneficiosBrindes := Value;
end;

procedure TItemPromo.SetBeneficiosMonetarios(const Value: TObjectList<TBeneficioMonetario>);
begin
    FBeneficiosMonetarios := Value;
end;

procedure TItemPromo.SetBeneficiosPagamentos(const Value: TObjectList<TBeneficioPagamento>);
begin
    FBeneficiosPagamentos := Value;
end;

procedure TItemPromo.SetBeneficiosVouchers(const Value: TObjectList<TBeneficioVoucher>);
begin
    FBeneficiosVouchers := Value;
end;

procedure TItemPromo.SetCodigo(const Value: string);
begin
    FCodigo := Value;
end;

procedure TItemPromo.SetDescricao(const Value: string);
begin
    FDescricao := Value;
end;

procedure TItemPromo.SetFabricante(const Value: string);
begin
    FFabricante := Value;
end;

procedure TItemPromo.SetFamilia(const Value: string);
begin
    FFamilia := Value;
end;

procedure TItemPromo.SetFornecedor(const Value: string);
begin
    FFornecedor := Value;
end;

procedure TItemPromo.SetGrupo(const Value: string);
begin
    FGrupo := Value;
end;

procedure TItemPromo.SetQuantidade(const Value: double);
begin
    FQuantidade := Value;
end;

procedure TItemPromo.SetSubGrupo(const Value: string);
begin
    FSubGrupo := Value;
end;

procedure TItemPromo.SetTipologia(const Value: string);
begin
    FTipologia := Value;
end;

procedure TItemPromo.SetValor(const Value: double);
begin
    FValor := Value;
end;

{ TSugestao }

function TSugestao.GetDescricao: string;
begin
    result := FDescricao;
end;

function TSugestao.GetExibida: boolean;
begin
    result := FExibida;
end;

function TSugestao.GetSequenciaExibida: string;
begin
    result := FSequenciaExibida;
end;

procedure TSugestao.SetDescricao(const Value: string);
begin
    FDescricao := Value;
end;

procedure TSugestao.SetExibida(const Value: boolean);
begin
    FExibida := Value;
end;

procedure TSugestao.SetIDPromo(const Value: string);
begin
    FIDPromo := Value;
end;

procedure TSugestao.SetSequencia(const Value: string);
begin
    FSequencia := Value;
end;

procedure TSugestao.SetSequenciaExibida(const Value: string);
begin
    FSequenciaExibida := Value;
end;

{ TBeneficio }

function TBeneficio.GetDescricao: string;
begin
    result := FDescricao;
end;

function TBeneficio.GetSequencia: string;
begin
    result := FSequencia;
end;

procedure TBeneficio.SetDescricao(const Value: string);
begin
    FDescricao := Value;
end;

procedure TBeneficio.SetIDPromo(const Value: string);
begin
    FIDPromo := Value;
end;

procedure TBeneficio.SetNumeroPromo(const Value: string);
begin
    FNumeroPromo := Value;
end;

procedure TBeneficio.SetSequencia(const Value: string);
begin
    FSequencia := Value;
end;

procedure TBeneficio.SetTipoBeneficio(const Value: TTipoBeneficio);
begin
    FTipoBeneficio := Value;
end;

{ TVoucherPromo }

procedure TVoucherPromo.SetIDVoucher(const Value: string);
begin
    FIDVoucher := Value;
end;

procedure TVoucherPromo.SetQuantidade(const Value: integer);
begin
    FQuantidade := Value;
end;

procedure TVoucherPromo.SetTipo(const Value: string);
begin
    FTipo := Value;
end;

procedure TVoucherPromo.SetValidado(const Value: boolean);
begin
  FValidado := Value;
end;

procedure TVoucherPromo.SetValorVoucher(const Value: double);
begin
    FValorVoucher := Value;
end;

{ tClientePromo }

procedure TClientePromo.SetIDCliente(const Value: string);
begin
    FIDCliente := Value;
end;

procedure TClientePromo.SetPontos(const Value: integer);
begin
    FPontos := Value;
end;

procedure TClientePromo.SetSaldo(const Value: double);
begin
    FSaldo := Value;
end;

procedure TClientePromo.SetTipoCliente(const Value: string);
begin
    FTipoCliente := Value;
end;

{ TPagamentoPromo }

procedure TPagamentoPromo.SetBanco(const Value: string);
begin
    FBanco := Value;
end;

procedure TPagamentoPromo.SetIDPagamento(const Value: string);
begin
    FIDPagamento := Value;
end;

procedure TPagamentoPromo.SetParcelas(const Value: integer);
begin
    FParcelas := Value;
end;

procedure TPagamentoPromo.SetPlano(const Value: string);
begin
    FPlano := Value;
end;

procedure TPagamentoPromo.SetTipoPagamento(const Value: string);
begin
    FTipoPagamento := Value;
end;

procedure TPagamentoPromo.SetValor(const Value: double);
begin
    FValor := Value;
end;

{ TBasePromo }

constructor TBasePromo.Create;
begin
end;

destructor TBasePromo.Destroy;
begin
    inherited;
end;

function TBasePromo.GetSequencia: string;
begin
    result := FSequencia;
end;

procedure TBasePromo.SetDeletado(const Value: boolean);
begin
    FDeletado := Value;
end;

procedure TBasePromo.SetSequencia(const Value: string);
begin
    FSequencia := Value;
end;

procedure TBasePromo.SetStatusEnvio(const Value: TStatusEnvio);
begin
    FStatusEnvio := Value;
end;

procedure TBasePromo.SetTagEnvio(const Value: string);
begin
    FTagEnvio := Value;
end;

{ TConverteEnum<T> }

class function TConverteEnum<T>.ToEnum(const AStr: string): T;
var
    P: ^T;
    num: integer;
begin
    try
        num := GetEnumValue(TypeInfo(T), AStr);
        if num = -1 then
            abort;
        P := @num;
        result := P^;
    except
        raise EConvertError.Create('O Parâmetro "' + AStr + '" passado não ' + sLineBreak + ' corresponde a um Tipo Enumerado');
    end;
end;

class function TConverteEnum<T>.ToString(const eEnum: T): string;
var
    P: PInteger;
    num: integer;
begin
    try
        P := @eEnum;
        num := integer(TGenerico((P^)));
        result := GetEnumName(TypeInfo(T), num);
    except
        raise EConvertError.Create('O Parâmetro passado não corresponde a ' + sLineBreak + 'Ou a um Tipo Enumerado');
    end;
end;

{ TBeneficioPagamento }

procedure TBeneficioPagamento.SetBanco(const Value: string);
begin
    FBanco := Value;
end;

procedure TBeneficioPagamento.SetFormaPagamento(const Value: string);
begin
    FFormaPagamento := Value;
end;

procedure TBeneficioPagamento.SetIDPlano(const Value: string);
begin
    FIDPlano := Value;
end;

procedure TBeneficioPagamento.SetLimite(const Value: double);
begin
    FLimite := Value;
end;

procedure TBeneficioPagamento.SetParcelas(const Value: integer);
begin
    FParcelas := Value;
end;

procedure TBeneficioPagamento.SetPercentualDesconto(const Value: double);
begin
    FPercentualDesconto := Value;
end;

procedure TBeneficioPagamento.SetTipoPercentual(const Value: string);
begin
    FTipoPercentual := Value;
end;

procedure TBeneficioPagamento.SetTipoPlano(const Value: string);
begin
    FTipoPlano := Value;
end;

procedure TBeneficioPagamento.SetTotalPagamento(const Value: double);
begin
    FTotalPagamento := Value;
end;

{ TBeneficioMonetario }

function TBeneficioMonetario.GetValorComDesconto: double;
begin
    if Self.Valor - Self.Desconto = 0 then
        result := 0.01
    else
        result := Self.Valor - Self.Desconto;
end;

procedure TBeneficioMonetario.SetDesconto(const Value: double);
begin
    FDesconto := Value;
end;

procedure TBeneficioMonetario.SetMetodoRateio(const Value: string);
begin
    FMetodoRateio := Value;
end;

procedure TBeneficioMonetario.SetUnidadeMedida(const Value: string);
begin
    FUnidadeMedida := Value;
end;

procedure TBeneficioMonetario.SetValor(const Value: double);
begin
    FValor := Value;
end;

procedure TBeneficioMonetario.SetValorTotal(const Value: double);
begin
    FValorTotal := Value;
end;

{ TBeneficioVoucher }

procedure TBeneficioVoucher.SetIDVoucher(const Value: string);
begin
    FIDVoucher := Value;
end;

procedure TBeneficioVoucher.SetQuantidade(const Value: integer);
begin
    FQuantidade := Value;
end;

{ TBeficioBrinde }

procedure TBeneficioBrinde.SetIDBrinde(const Value: string);
begin
    FIDBrinde := Value;
end;

procedure TBeneficioBrinde.SetQuantidade(const Value: integer);
begin
    FQuantidade := Value;
end;

procedure TBeneficioBrinde.SetTipoBrinde(const Value: string);
begin
    FTipoBrinde := Value;
end;

{ TBeneficioApresentavel }

function TBeneficioApresentavel.GetExibida: boolean;
begin
    result := FExibida;
end;

function TBeneficioApresentavel.GetSequenciaExibida: string;
begin
    result := FSequenciaExibida;
end;

procedure TBeneficioApresentavel.SetExibida(const Value: boolean);
begin
    Exibida := Value;
end;

procedure TBeneficioApresentavel.SetSequenciaExibida(const Value: string);
begin
    FSequenciaExibida := Value;

end;

end.
