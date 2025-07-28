# Backend do Projeto de E-commerce - Banco de Dados 2

Este repositório contém o código-fonte do back-end para um sistema de e-commerce, desenvolvido como parte do projeto da disciplina de Banco de Dados 2.

## 1\. Visão Geral do Projeto

O objetivo deste projeto é implementar a lógica de um sistema de e-commerce, com foco especial na utilização de recursos avançados de um SGBD (Sistema de Gerenciamento de Banco de Dados) para garantir a integridade, automação e eficiência das operações.

A aplicação permite visualizar produtos, criar pedidos e realizar cálculos de negócio, utilizando uma arquitetura de API REST que se comunica com um banco de dados PostgreSQL.

## 2\. Tecnologias Utilizadas

  * **Linguagem:** TypeScript
  * **Ambiente de Execução:** Node.js
  * **Framework API:** Express.js
  * **Banco de Dados:** PostgreSQL
  * **Hospedagem do Banco:** Neon (Serverless Postgres)

## 3\. Requisitos de Banco de Dados Implementados

O projeto atende a todos os requisitos de lógica de banco de dados solicitados, demonstrando o uso prático de cada recurso:

  * **`[✓]` Procedure (`create_new_order`)**: Uma procedure foi criada para encapsular toda a lógica de negócio da criação de um pedido. Isso garante que a operação seja transacional e atômica: ou o pedido é criado com sucesso e todas as tabelas são atualizadas, ou nada é alterado em caso de erro.

  * **`[✓]` Trigger (`trg_after_order_product_insert`)**: Um trigger é disparado automaticamente após a inserção de um item em um pedido. Ele invoca a função `reduce_stock` para decrementar a quantidade do produto em estoque, garantindo a consistência dos dados de forma automática e segura, sem a necessidade de intervenção da API.

  * **`[✓]` View (`vw_detailed_products`)**: Para simplificar as consultas de listagem de produtos, foi criada uma view que une as tabelas `product`, `category` e `supplier`. Isso permite que a API faça uma consulta simples (`SELECT * FROM vw_detailed_products`) em vez de um `JOIN` complexo a cada requisição.

  * **`[✓]` Function (`get_supplier_total_sales`)**: Uma função que aceita o ID de um fornecedor e retorna o valor total de suas vendas foi implementada. Isso demonstra como cálculos específicos e reutilizáveis podem ser encapsulados diretamente no banco de dados para serem consumidos pela aplicação.

  * **`[✓]` Padrão DAO (Data Access Object)**: A arquitetura do back-end segue os princípios do padrão DAO. A pasta `services` atua como a camada de acesso a dados, sendo a única responsável por se comunicar com o banco. Os `controllers` operam com os dados e chamam os serviços, mas não têm conhecimento da lógica SQL, promovendo a separação de responsabilidades.

## 4\. Diagrama Entidade-Relacionamento

O diagrama ER que guia a estrutura do banco de dados pode ser encontrado em `public/docs/der.png`.

## 5\. Como Configurar e Executar o Projeto

Siga os passos abaixo para executar a aplicação localmente.

### Pré-requisitos

  * Node.js (versão 16 ou superior)
  * NPM ou Yarn
  * Uma conta na plataforma [Neon](https://neon.tech/) para o banco de dados PostgreSQL.

### Passos de Instalação

1.  **Clone o repositório** (ou baixe os arquivos):

    ```bash
    git clone https://caminho/para/seu/repositorio.git
    cd backend
    ```

2.  **Instale as dependências** do projeto:

    ```bash
    npm install
    ```

3.  **Configure as Variáveis de Ambiente**:

      * Renomeie o arquivo `.env.example` para `.env`.
      * Faça login no Neon, crie um projeto e copie a URL de conexão.
      * Preencha as variáveis no arquivo `.env` com suas credenciais do Neon.

4.  **Configure o Banco de Dados**:

      * Acesse o **SQL Editor** no seu projeto do Neon.
      * Copie e cole o conteúdo completo do arquivo `public/db/schema.sql` e execute-o. Isso criará toda a estrutura do banco.
      * Em seguida, copie e cole o conteúdo completo do arquivo `public/db/seed.sql` e execute-o para popular o banco com dados iniciais.

5.  **Inicie o Servidor**:

    ```bash
    npm run dev
    ```

    O servidor estará rodando em `http://localhost:3333`.

## 6\. Documentação da API

### Listar todos os produtos

  * **Endpoint:** `GET /api/products`
  * **Descrição:** Retorna uma lista de todos os produtos disponíveis, utilizando a `vw_detailed_products`.
  * **Resposta de Sucesso (200 OK):**
    ```json
    [
      {
        "product_id": 1,
        "product_name": "Guitarra Elétrica Stratocaster",
        "price": "3500.00",
        "qty_in_stock": 15,
        "category_name": "Instrumentos de Corda",
        "supplier_name": "Fornecedor Musical"
      }
    ]
    ```

### Criar um novo pedido

  * **Endpoint:** `POST /api/orders`
  * **Descrição:** Cria um novo pedido no sistema. Esta rota invoca a procedure `create_new_order`.
  * **Corpo da Requisição (Body):**
    ```json
    {
      "userId": 1,
      "addressId": 1,
      "paymentMethodId": 1,
      "products": [
        { "product_id": 1, "qty": 1 },
        { "product_id": 3, "qty": 1 }
      ]
    }
    ```
  * **Resposta de Sucesso (201 Created):**
    ```json
    {
        "message": "Order created successfully!"
    }
    ```

### Obter o total de vendas de um fornecedor

  * **Endpoint:** `GET /api/suppliers/:id/sales`
  * **Descrição:** Retorna o valor total das vendas para um fornecedor específico, utilizando a função `get_supplier_total_sales`.
  * **Exemplo de URL:** `/api/suppliers/1/sales`
  * **Resposta de Sucesso (200 OK):**
    ```json
    {
      "total_sales": "6700.00"
    }
    ```