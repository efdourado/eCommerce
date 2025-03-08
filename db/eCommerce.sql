create table "supplier" (
	"id" serial not null primary key,
	"name" varchar(255) not null
);

create table "category" (
	"id" serial not null primary key,
	"name" varchar(255) not null
);

create table "user" (
	"id" serial not null primary key,
	"name" varchar(255) not null,
	"doc" varchar(255) not null unique,
	"email" varchar(255) not null unique,
	"password" varchar(255) not null,
	"phone" varchar(255)
);

create type "country_t" as enum ('Brasil', 'USA');

create table "address" (
	"id" serial not null primary key,
	"country" country_t not null,
	"city" varchar(255) not null,
	"address_line1" varchar(255),
	"postal_code" varchar(255) not null
);

create table "user_address" (
	"id" serial not null primary key,
	"user_id" int,
	"address_id" int,
	"is_default" boolean,
	foreign key("user_id") references "user"("id")
		on update no action on delete cascade,
	foreign key("address_id") references "address"("id")
		on update no action on delete cascade
);

create table "user_payment_method" (
	"id" serial not null primary key,
	"user_id" int,
	"acc_number" varchar(255),
	"provider" varchar(255),
	"is_default" boolean,
	"expiry_date" char(5),
	foreign key("user_id") references "user"("id")
		on update no action on delete cascade
);

create table "product" (
	"id" serial not null primary key,
	"name" varchar(255) not null,
	"product_image" varchar(255),
	"price" numeric(10, 2) not null,
	"supplier_id" int not null,
	"qty_in_stock" int,
	"category_id" int not null,
	foreign key("supplier_id") references "supplier"("id")
		on update cascade on delete cascade,
	foreign key("category_id") references "category"("id")
		on update cascade on delete cascade
);

create type "status_t" as enum ('Payment_Confirmed', 'Payment_Failed', 'Pending');

create table "order" (
	"id" serial not null primary key,
	"user_id" int not null,
	"order_date" date not null,
	"status" status_t not null,
	"total" numeric(10, 2) not null,
	"user_payment_method" int not null,
	"shipping_address" int not null,
	"shipping_date" date,
	foreign key("user_id") references "user"("id")
		on update cascade on delete cascade,
	foreign key("user_payment_method") references "user_payment_method"("id")
		on update no action on delete no action,
	foreign key("shipping_address") references "address"("id")
		on update no action on delete no action
);

create table "order_product" (
	"product_id" int not null,
	"order_id" int not null,
	"qty" int not null default 1,
	primary key("product_id", "order_id"),
	foreign key("product_id") references "product"("id")
		on update cascade on delete cascade,
	foreign key("order_id") references "order"("id")
		on update cascade on delete cascade
);