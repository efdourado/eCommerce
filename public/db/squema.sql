/************************************************************************************************
 * *
 * SCRIPT DE DEFINIÇÃO DE SCHEMA - ECOMMERCE DB                                                 *
 * *
 * Este script cria toda a estrutura do banco de dados, incluindo tabelas, tipos, views e      *
 * a lógica programável (funções, procedures, triggers). Ele é projetado para ser executado    *
 * para criar o banco do zero ou para resetá-lo completamente.                                 *
 * *
 ************************************************************************************************/

\echo '-----> 1. Resetando o ambiente do banco de dados...'
-- Apaga na ordem inversa para evitar erros de dependência
DROP VIEW IF EXISTS vw_detailed_products;
DROP TRIGGER IF EXISTS trg_after_order_product_insert ON order_product;
DROP PROCEDURE IF EXISTS create_new_order(INT, INT, INT, JSON);
DROP FUNCTION IF EXISTS reduce_stock();
DROP FUNCTION IF EXISTS get_supplier_total_sales(INT);
DROP TABLE IF EXISTS "order_product";
DROP TABLE IF EXISTS "order";
DROP TABLE IF EXISTS "product";
DROP TABLE IF EXISTS "user_payment_method";
DROP TABLE IF EXISTS "user_address";
DROP TABLE IF EXISTS "address";
DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS "category";
DROP TABLE IF EXISTS "supplier";
DROP TYPE IF EXISTS "user_role_t";
DROP TYPE IF EXISTS "status_t";

\echo '-----> 2. Criando tipos e tabelas...'

--================== TIPOS (ENUMS) ==================
CREATE TYPE "user_role_t" AS ENUM ('customer', 'admin', 'supplier');
CREATE TYPE "status_t" AS ENUM ('Pending', 'Payment_Confirmed', 'Payment_Failed', 'Shipped', 'Delivered');

--================== TABELAS ==================
CREATE TABLE "supplier" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE "category" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE "user" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL,
  "doc" VARCHAR(255) NOT NULL UNIQUE,
  "email" VARCHAR(255) NOT NULL UNIQUE,
  "password" VARCHAR(255) NOT NULL,
  "phone" VARCHAR(255),
  "role" "user_role_t" NOT NULL DEFAULT 'customer',
  "supplier_id" INT REFERENCES "supplier"("id") ON DELETE SET NULL
);

CREATE TABLE "address" (
  "id" SERIAL PRIMARY KEY,
  "country" VARCHAR(255) NOT NULL,
  "city" VARCHAR(255) NOT NULL,
  "address_line1" VARCHAR(255),
  "postal_code" VARCHAR(255) NOT NULL
);

CREATE TABLE "user_address" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  "address_id" INT NOT NULL REFERENCES "address"("id") ON DELETE CASCADE,
  "is_default" BOOLEAN DEFAULT false
);

CREATE TABLE "user_payment_method" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT NOT NULL REFERENCES "user"("id") ON DELETE CASCADE,
  "acc_number" VARCHAR(255) NOT NULL,
  "provider" VARCHAR(255) NOT NULL,
  "is_default" BOOLEAN DEFAULT false,
  "expiry_date" CHAR(5) NOT NULL
);

CREATE TABLE "product" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL,
  "product_image" VARCHAR(255),
  "price" NUMERIC(10, 2) NOT NULL,
  "supplier_id" INT NOT NULL REFERENCES "supplier"("id") ON DELETE RESTRICT,
  "qty_in_stock" INT NOT NULL DEFAULT 0,
  "category_id" INT NOT NULL REFERENCES "category"("id") ON DELETE RESTRICT
);

CREATE TABLE "order" (
  "id" SERIAL PRIMARY KEY,
  "user_id" INT REFERENCES "user"("id") ON DELETE SET NULL,
  "order_date" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "status" "status_t" NOT NULL,
  "total" NUMERIC(10, 2) NOT NULL,
  "user_payment_method_id" INT NOT NULL REFERENCES "user_payment_method"("id") ON DELETE RESTRICT,
  "shipping_country" VARCHAR(255) NOT NULL,
  "shipping_city" VARCHAR(255) NOT NULL,
  "shipping_address_line1" VARCHAR(255),
  "shipping_postal_code" VARCHAR(255) NOT NULL,
  "shipping_date" DATE
);

CREATE TABLE "order_product" (
  "product_id" INT NOT NULL REFERENCES "product"("id") ON DELETE RESTRICT,
  "order_id" INT NOT NULL REFERENCES "order"("id") ON DELETE CASCADE,
  "qty" INT NOT NULL DEFAULT 1 CHECK (qty > 0),
  "price_at_time" NUMERIC(10, 2) NOT NULL,
  PRIMARY KEY ("product_id", "order_id")
);

\echo '-----> 3. Criando a lógica do Banco de Dados...'

--================== LÓGICA PROGRAMÁVEL ==================

-- VIEW: Simplifica a consulta de produtos com detalhes.
CREATE OR REPLACE VIEW vw_detailed_products AS
SELECT
    p.id AS product_id, p.name AS product_name, p.price, p.qty_in_stock,
    c.name AS category_name, s.name AS supplier_name, p.category_id, p.supplier_id
FROM product p
JOIN category c ON p.category_id = c.id
JOIN supplier s ON p.supplier_id = s.id;

-- FUNCTION: Calcula o total de vendas para um fornecedor.
CREATE OR REPLACE FUNCTION get_supplier_total_sales(p_supplier_id INT)
RETURNS NUMERIC AS $$
DECLARE total_sales NUMERIC;
BEGIN
    SELECT COALESCE(SUM(op.qty * op.price_at_time), 0) INTO total_sales
    FROM order_product op JOIN product p ON op.product_id = p.id
    WHERE p.supplier_id = p_supplier_id;
    RETURN total_sales;
END;
$$ LANGUAGE plpgsql;

-- FUNCTION E TRIGGER: Controlam a baixa de estoque.
CREATE OR REPLACE FUNCTION reduce_stock()
RETURNS TRIGGER AS $$
DECLARE stock_available INT;
BEGIN
    SELECT qty_in_stock INTO stock_available FROM product WHERE id = NEW.product_id FOR UPDATE;
    IF stock_available < NEW.qty THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto ID % (Disponível: %, Pedido: %)', NEW.product_id, stock_available, NEW.qty;
    END IF;
    UPDATE product SET qty_in_stock = qty_in_stock - NEW.qty WHERE id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_order_product_insert AFTER INSERT ON order_product
FOR EACH ROW EXECUTE FUNCTION reduce_stock();

-- PROCEDURE: Orquestra a criação de um novo pedido.
CREATE OR REPLACE PROCEDURE create_new_order(p_user_id INT, p_payment_method_id INT, p_address_id INT, p_products_data JSON)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id INT; v_total_price NUMERIC(10, 2) := 0; v_shipping_address RECORD;
    product_item JSON; v_product_id INT; v_qty INT; v_product_price NUMERIC(10, 2);
BEGIN
    SELECT country, city, address_line1, postal_code INTO v_shipping_address FROM address WHERE id = p_address_id;
    INSERT INTO "order" (user_id, order_date, status, total, user_payment_method_id, shipping_country, shipping_city, shipping_address_line1, shipping_postal_code)
    VALUES (p_user_id, NOW(), 'Pending', 0, p_payment_method_id, v_shipping_address.country::varchar, v_shipping_address.city, v_shipping_address.address_line1, v_shipping_address.postal_code)
    RETURNING id INTO v_order_id;
    FOR product_item IN SELECT * FROM json_array_elements(p_products_data)
    LOOP
        v_product_id := (product_item->>'product_id')::INT; v_qty := (product_item->>'qty')::INT;
        SELECT price INTO v_product_price FROM product WHERE id = v_product_id;
        v_total_price := v_total_price + (v_product_price * v_qty);
        INSERT INTO "order_product" (order_id, product_id, qty, price_at_time) VALUES (v_order_id, v_product_id, v_qty, v_product_price);
    END LOOP;
    UPDATE "order" SET total = v_total_price, status = 'Payment_Confirmed' WHERE id = v_order_id;
END;
$$;

\echo '-----> Definição do Schema concluída com sucesso!'