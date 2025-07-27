-- Apaga as tabelas na ordem inversa de criação para evitar erros de dependência
DROP TABLE IF EXISTS "order_product";
DROP TABLE IF EXISTS "order";
DROP TABLE IF EXISTS "product";
DROP TABLE IF EXISTS "user_payment_method";
DROP TABLE IF EXISTS "user_address";
DROP TABLE IF EXISTS "address";
DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS "category";
DROP TABLE IF EXISTS "supplier";

-- Apaga os tipos personalizados
DROP TYPE IF EXISTS "user_role_t";
DROP TYPE IF EXISTS "status_t";

--================== CRIAÇÃO DOS TIPOS (ENUMS) ==================
CREATE TYPE "user_role_t" AS ENUM ('customer', 'admin', 'supplier');
CREATE TYPE "status_t" AS ENUM ('Pending', 'Payment_Confirmed', 'Payment_Failed', 'Shipped', 'Delivered');

--================== CRIAÇÃO DAS TABELAS ==================

CREATE TABLE "supplier" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL
);

CREATE TABLE "category" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL
);

-- Tabela 'user' com a coluna 'role' e 'supplier_id' opcional
CREATE TABLE "user" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL,
  "doc" VARCHAR(255) NOT NULL UNIQUE,
  "email" VARCHAR(255) NOT NULL UNIQUE,
  "password" VARCHAR(255) NOT NULL,
  "phone" VARCHAR(255),
  "role" "user_role_t" NOT NULL DEFAULT 'customer',
  "supplier_id" INT,
  FOREIGN KEY ("supplier_id") REFERENCES "supplier"("id") ON DELETE SET NULL
);

CREATE TABLE "address" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "country" VARCHAR(255) NOT NULL,
  "city" VARCHAR(255) NOT NULL,
  "address_line1" VARCHAR(255),
  "postal_code" VARCHAR(255) NOT NULL
);

CREATE TABLE "user_address" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "address_id" INT NOT NULL,
  "is_default" BOOLEAN DEFAULT false,
  FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE,
  FOREIGN KEY ("address_id") REFERENCES "address"("id") ON DELETE CASCADE
);

CREATE TABLE "user_payment_method" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "acc_number" VARCHAR(255) NOT NULL,
  "provider" VARCHAR(255) NOT NULL,
  "is_default" BOOLEAN DEFAULT false,
  "expiry_date" CHAR(5) NOT NULL,
  FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE
);

CREATE TABLE "product" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "name" VARCHAR(255) NOT NULL,
  "product_image" VARCHAR(255),
  "price" NUMERIC(10, 2) NOT NULL,
  "supplier_id" INT NOT NULL,
  "qty_in_stock" INT NOT NULL DEFAULT 0,
  "category_id" INT NOT NULL,
  -- Usar RESTRICT previne a exclusão acidental de uma categoria/fornecedor com produtos
  FOREIGN KEY ("supplier_id") REFERENCES "supplier"("id") ON DELETE RESTRICT,
  FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE RESTRICT
);

-- Tabela 'order' com o endereço de envio denormalizado para integridade histórica
CREATE TABLE "order" (
  "id" SERIAL NOT NULL PRIMARY KEY,
  "user_id" INT NOT NULL,
  "order_date" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "status" "status_t" NOT NULL,
  "total" NUMERIC(10, 2) NOT NULL,
  "user_payment_method_id" INT NOT NULL,
  "shipping_country" VARCHAR(255) NOT NULL,
  "shipping_city" VARCHAR(255) NOT NULL,
  "shipping_address_line1" VARCHAR(255),
  "shipping_postal_code" VARCHAR(255) NOT NULL,
  "shipping_date" DATE,
  FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE SET NULL,
  FOREIGN KEY ("user_payment_method_id") REFERENCES "user_payment_method"("id") ON DELETE RESTRICT
);

CREATE TABLE "order_product" (
  "product_id" INT NOT NULL,
  "order_id" INT NOT NULL,
  "qty" INT NOT NULL DEFAULT 1,
  "price_at_time" NUMERIC(10, 2) NOT NULL, -- Boa prática: registrar o preço no momento da compra
  PRIMARY KEY ("product_id", "order_id"),
  FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE RESTRICT,
  FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE CASCADE
);