-- Inserir Fornecedores
INSERT INTO "supplier" (name) VALUES ('Fornecedor Musical'), ('Tech Imports');

-- Inserir Categorias
INSERT INTO "category" (name) VALUES ('Instrumentos de Corda'), ('Periféricos de Áudio');

-- Inserir Produtos
INSERT INTO "product" (name, price, supplier_id, qty_in_stock, category_id) VALUES
('Guitarra Elétrica Stratocaster', 3500.00, 1, 15, 1),
('Microfone Condensador AT2020', 850.00, 2, 30, 2),
('Baixo Elétrico Jazz Bass', 3200.00, 1, 10, 1);



------------------------------------------------------------------



-- 1. Crie um usuário de teste (lembre-se que já temos o tipo de role 'customer')
INSERT INTO "user" (name, doc, email, password, phone, role) VALUES
('Cliente de Teste', '12345678900', 'cliente@teste.com', 'senha123', '11999999999', 'customer')
RETURNING id;
-- Anote o ID que for retornado. Vamos assumir que foi '1'.

-- 2. Crie um endereço de teste
INSERT INTO "address" (country, city, address_line1, postal_code) VALUES
('Brasil', 'São Paulo', 'Rua dos Testes, 123', '01000-000')
RETURNING id;
-- Anote o ID retornado. Vamos assumir que foi '1'.

-- 3. Crie um método de pagamento de teste para o usuário 1
INSERT INTO "user_payment_method" (user_id, acc_number, provider, is_default, expiry_date) VALUES
(1, '4242...1234', 'Visa', true, '12/29');

-- 4. Associe o endereço ao usuário (opcional para o teste, mas boa prática)
INSERT INTO "user_address" (user_id, address_id, is_default) VALUES
(1, 1, true);



------------------------------------------------------------------



-- TRIGGER FUNCTION para baixar o estoque
CREATE OR REPLACE FUNCTION reduce_stock()
RETURNS TRIGGER AS $$
DECLARE
    stock_available INT;
BEGIN
    -- Bloqueia a linha do produto para evitar condições de concorrência
    SELECT qty_in_stock INTO stock_available FROM product WHERE id = NEW.product_id FOR UPDATE;

    IF stock_available < NEW.qty THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto ID % (Disponível: %, Pedido: %)',
            NEW.product_id, stock_available, NEW.qty;
    END IF;

    UPDATE product
    SET qty_in_stock = qty_in_stock - NEW.qty
    WHERE id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER que chama a função acima
-- DROP TRIGGER IF EXISTS trg_after_order_product_insert ON order_product; -- Use se precisar recriar
CREATE TRIGGER trg_after_order_product_insert
AFTER INSERT ON order_product
FOR EACH ROW
EXECUTE FUNCTION reduce_stock();


-- PROCEDURE para criar o pedido completo
CREATE OR REPLACE PROCEDURE create_new_order(
    p_user_id INT,
    p_payment_method_id INT,
    p_address_id INT,
    p_products_data JSON
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id INT;
    v_total_price NUMERIC(10, 2) := 0;
    v_shipping_address RECORD;
    product_item JSON;
    v_product_id INT;
    v_qty INT;
    v_product_price NUMERIC(10, 2);
BEGIN
    -- 1. Obter e "congelar" o endereço de envio
    SELECT country, city, address_line1, postal_code
    INTO v_shipping_address
    FROM address WHERE id = p_address_id;

    -- 2. Criar o pedido com status 'Pending' e total 0
    INSERT INTO "order" (user_id, order_date, status, total, user_payment_method, shipping_country, shipping_city, shipping_address_line1, shipping_postal_code)
    VALUES (p_user_id, NOW(), 'Pending', 0, p_payment_method_id, v_shipping_address.country::varchar, v_shipping_address.city, v_shipping_address.address_line1, v_shipping_address.postal_code)
    RETURNING id INTO v_order_id;

    -- 3. Iterar sobre os produtos e adicioná-los ao pedido
    FOR product_item IN SELECT * FROM json_array_elements(p_products_data)
    LOOP
        v_product_id := (product_item->>'product_id')::INT;
        v_qty := (product_item->>'qty')::INT;

        SELECT price INTO v_product_price FROM product WHERE id = v_product_id;
        v_total_price := v_total_price + (v_product_price * v_qty);

        -- Inserir em order_product (isso irá disparar o trigger de estoque)
        INSERT INTO "order_product" (order_id, product_id, qty)
        VALUES (v_order_id, v_product_id, v_qty);
    END LOOP;

    -- 4. Atualizar o valor total final e confirmar o pagamento (simulação)
    UPDATE "order" SET total = v_total_price, status = 'Payment_Confirmed' WHERE id = v_order_id;

    -- COMMIT é implícito ao final de uma procedure sem erros
END;
$$;