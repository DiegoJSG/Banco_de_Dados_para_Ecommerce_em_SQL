-- Criação de banco de dados para cenário de E-commerce
create database ecommerce;

-- Tabela cliente
create table clientes(
		idCliente int auto_increment primary key,
        TipoCliente enum('PJ', 'PF') not null,
        Nome varchar(255) not null,
        CPF_CNPJ char(14) not null,
        Endereco varchar(255),
        constraint unique_cpf_cnpj unique (CPF_CNPJ)
);

-- Tabela pagamento
create table pagamento(
		idPagamento int auto_increment primary key,
        idCliente int,
        Metodo enum('Cartao', 'Boleto', 'Transferencia') not null,
        constraint fk_pagamento_cliente foreign key (idCliente) references clientes(idCliente)
);

-- Tabela entrega
create table entrega(
		idEntrega int auto_increment primary key,
        Status enum('Pendente', 'Em trânsito', 'Entregue') not null,
        CodigoRastreio varchar(20),
        idPedido int,
        constraint fk_entrega_pedido foreign key (idPedido) references pedidos(idPedidos)
);

-- Tabela produto 
create table produto(
		idProduto int auto_increment primary key,
        Pname varchar(255) not null,
        Classificacao_kids bool default false,
        Categoria enum('Eletronico','Vestimenta','Brinquedos','Alimentos','Moveis') not null,
        Avaliacao float default 0,
        Size varchar(10),
        constraint unique_product_name unique (Pname)
);

-- Tabela pedidos 
create table pedidos(
		idPedidos int auto_increment primary key,
        idPedidoCliente int,
        PedidoStatus enum('Cancelado','Confirmado','Em processamento') default 'Processando',
        Pedidodescricao varchar(255),
        EnviarValor float default 10,
        Size varchar(10),
        constraint fk_Pedido_Cliente foreign key (idPedidoCliente) references clientes(idCliente)
);

-- Tabela estoque 
create table estoque(
		idestoque int auto_increment primary key,
        estoqueLocal varchar(255),
        quantidade int default 0
);

-- Tabela fornecedor 
create table fornecedor(
		idfornecedor int auto_increment primary key,
        NomeSocial varchar(255) not null,
        CNPJ char(15) not null,
        Contato char(11) not null,
        constraint unique_fornecedor_cnpj unique (CNPJ)
);

-- Tabela vendedor 
create table vendedor(
		idvendedor int auto_increment primary key,
        NomeSocial varchar(255) not null,
        AbsNome varchar(255),
        CNPJ char(15),
        CPF char(9),
        Endereco varchar(255),
        Contato char(11) not null,
        constraint unique_vendedor_cnpj unique (CNPJ),
        constraint unique_vendedor_cpf unique (CPF)
);

-- Tabela vendedor do produto 
create table vendedorproduto(
		idVproduto int,
        idProduto int,
        prodQuantidade int default 1,
        primary key (idVproduto, idProduto),
        constraint fk_vendedor_produto foreign key (idVproduto) references vendedor(idvendedor),
        constraint fk_produto_produto foreign key (idProduto) references produto(idProduto)
);

-- Tabela produto e pedido 
create table ordemProduto(
		idOProduto int, 
        idOrdemP int,
        prodQuantidade int default 1,
        poStatus enum('Disponivel', 'Sem estoque') default 'Disponivel',
        primary key (idOProduto, idOrdemP),
        constraint fk_vendedor_produto foreign key (idOProduto) references produto(idProduto),
        constraint fk_produto_produto foreign key (idOrdemP) references pedidos(idPedidos)
);

-- Tabela local do produto 
create table localProduto(
		idProduto int, 
        idLocal int,
        local varchar(255) not null,
        primary key (idProduto, idLocal),
        constraint fk_vendedor_produto foreign key (idProduto) references produto(idProduto),
        constraint fk_produto_produto foreign key (idLocal) references pedidos(idPedidos)
);

-- Quantos pedidos foram feitos por cada cliente?
SELECT c.Nome, COUNT(p.idPedidos) as NumeroPedidos
FROM clientes c
LEFT JOIN pedidos p ON c.idCliente = p.idPedidoCliente
GROUP BY c.Nome;

-- Algum vendedor também é fornecedor?
SELECT v.NomeSocial as Vendedor, f.NomeSocial as Fornecedor
FROM vendedor v
INNER JOIN fornecedor f ON v.CNPJ = f.CNPJ;

-- Relação de produtos fornecedores e estoques:
SELECT p.Pname as Produto, f.NomeSocial as Fornecedor, e.estoqueLocal as Estoque, e.quantidade as Quantidade
FROM produto p
INNER JOIN vendedorproduto vp ON p.idProduto = vp.idProduto
INNER JOIN fornecedor f ON vp.idVproduto = f.idfornecedor
INNER JOIN estoque e ON p.idProduto = e.idestoque;

-- Relação de nomes dos fornecedores e nomes dos produtos:
SELECT f.NomeSocial as Fornecedor, p.Pname as Produto
FROM fornecedor f
INNER JOIN vendedorproduto vp ON f.idfornecedor = vp.idVproduto
INNER JOIN produto p ON vp.idProduto = p.idProduto;

