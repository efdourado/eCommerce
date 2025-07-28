/************************************************************************************************
 * *
 * SCRIPT DE DADOS INICIAIS (SEED) - ECOMMERCE DB                                               *
 * *
 * Este script insere os dados iniciais necessários para testar e utilizar a aplicação.        *
 * Ele é projetado para ser executado APÓS o script 'schema.sql' ter sido executado com sucesso.*
 * A cláusula "ON CONFLICT DO NOTHING" torna o script seguro para ser executado várias vezes.   *
 * *
 ************************************************************************************************/

\echo '-----> Inserindo dados iniciais (Seed Data)...'

-- Inserir Fornecedores
INSERT INTO "supplier" (id, name) VALUES (1, 'Fornecedor Musical'), (2, 'Tech Imports')
ON CONFLICT (id) DO NOTHING;

-- Inserir Categorias
INSERT INTO "category" (id, name) VALUES (1, 'Instrumentos de Corda'), (2, 'Periféricos de Áudio')
ON CONFLICT (id) DO NOTHING;

-- Inserir Produtos
INSERT INTO "product" (id, name, price, supplier_id, qty_in_stock, category_id) VALUES
(1, 'Guitarra Elétrica Stratocaster', 3500.00, 1, 15, 1),
(2, 'Microfone Condensador AT2020', 850.00, 2, 30, 2),
(3, 'Baixo Elétrico Jazz Bass', 3200.00, 1, 10, 1)
ON CONFLICT (id) DO NOTHING;

-- Inserir Usuário, Endereço e Método de Pagamento de Teste
INSERT INTO "user" (id, name, doc, email, password, phone, role) VALUES
(1, 'Cliente de Teste', '12345678900', 'cliente@teste.com', 'senha123', '11999999999', 'customer')
ON CONFLICT (id) DO NOTHING;

INSERT INTO "address" (id, country, city, address_line1, postal_code) VALUES
(1, 'Brasil', 'São Paulo', 'Rua dos Testes, 123', '01000-000')
ON CONFLICT (id) DO NOTHING;

INSERT INTO "user_payment_method" (id, user_id, acc_number, provider, is_default, expiry_date) VALUES
(1, 1, '4242...1234', 'Visa', true, '12/29')
ON CONFLICT (id) DO NOTHING;

INSERT INTO "user_address" (id, user_id, address_id, is_default) VALUES
(1, 1, 1, true)
ON CONFLICT (id) DO NOTHING;


\echo '-----> Inserção de dados concluída com sucesso!'