create table "supplier" (
	"id" int primary key,
	"name" varchar(255) not null
);

create table "category" (
	"id" int primary key,
	"name" varchar(255) not null
);

create table "user" (
	"id" int primary key,
	"name" varchar(255) not null,
	"doc" varchar(255) not null unique,
	"email" varchar(255) not null unique,
	"password" varchar(255) not null,
	"phone" varchar(255)
);

create table "product" (
	"id" int primary key,
	"name" varchar(255) not null,
	"supplier_id" int not null,
	"category_id" int not null,
	"price" float,
	foreign key("supplier_id") references "supplier"("id") on update cascade on delete set null,
	foreign key("category_id") references "category"("id") on update cascade on delete set null
);

create type "status_t" as enum ('delivered', 'canceled', 'payment_confirmed', 'payment_failed', 'pending');

create table "order" (
	"id" int primary key,
	"user_id" int not null,
	"order_date" date not null,
	"status" status_t not null default 'pending',
	"total" float not null,
	foreign key("user_id") references "user"("id") on update cascade on delete cascade
);

create table "order_product" (
	"product_id" int not null,
	"order_id" int not null,
	"quantity" int not null default 1,
	primary key("product_id", "order_id"),
	foreign key("product_id") references "product"("id") on update cascade on delete cascade,
	foreign key("order_id") references "order"("id") on update cascade on delete cascade
);

create table "stock" (
	"supplier_id" int not null,
	"product_id" int not null,
	primary key("supplier_id", "product_id"),
	foreign key("supplier_id") references "supplier"("id") on update cascade on delete cascade,
	foreign key("product_id") references "product"("id") on update cascade on delete cascade
);

create table "address" (
	"id" serial not null unique,
	"country" varchar(255) not null,
	"city" varchar(255) not null,
	"adress_line1" varchar(255),
	"postal_code" varchar(255) not null,
	primary key("id")
);

create table "user_address" (
	"id" serial not null unique,
	"user_id" int,
	"address_id" int,
	primary key("id"),
	foreign key("user_id") references "user"("id"),
	foreign key("address_id") references "address"("id")
);

create table "user_payment_method" (
	"id" serial not null unique,
	"user_id" int,
	primary key("id"),
	foreign key("user_id") references "user"("id")
);