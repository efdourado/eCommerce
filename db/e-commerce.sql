create table "Supplier" (
	"id" blob,
	"name" varchar(255) not null,
	primary key("id")
);

create table "Category" (
	"id" blob,
	"name" varchar(255) not null,
	primary key("id")
);

create table "Customer" (
	"id" blob,
	"name" varchar(255) not null,
	"customer_type" blob not null,
	"doc" varchar(255) not null unique,
	"email" varchar(255) unique,
	primary key("id")
);

create table "Seller" (
	"id" blob,
	"name" varchar(255) not null,
	"seller_type" blob not null,
	"doc" varchar(255) not null unique,
	"email" varchar(255) unique,
	"phone" varchar(255),
	primary key("id")
);

create table "Product" (
	"id" blob,
	"name" varchar(255) not null,
	"supplier_id" int not null,
	"category_id" int not null,
	"seller_id" int not null,
	primary key("id")
);

create table "Order" (
	"id" blob,
	"customer_id" int not null,
	"order_date" date not null,
	"delivery_date" date,
	"status" blob default Pending,
	"payment_method" blob not null,
	"city" varchar(255) not null,
	"street" varchar(255) not null,
	"CEP" varchar(20) not null,
	primary key("id")
);

create table "OrderProduct" (
	"product_id" int not null,
	"order_id" int not null,
	"quantity" int not null default 1,
	primary key("product_id", "order_id")
);

create table "Stock" (
	"supplier_id" int not null,
	"product_id" int not null,
	primary key("supplier_id", "product_id")
);

alter table "Product"
add foreign key("supplier_id") REFERENCES "Supplier"("id")
on update cascade on delete set null;

alter table "Product"
add foreign key("category_id") REFERENCES "Category"("id")
on update cascade on delete set null;

alter table "Product"
add foreign key("seller_id") REFERENCES "Seller"("id")
on update cascade on delete set null;

alter table "Order"
add foreign key("customer_id") REFERENCES "Customer"("id")
on update cascade on delete cascade;

alter table "OrderProduct"
add foreign key("product_id") REFERENCES "Product"("id")
on update cascade on delete cascade;

alter table "OrderProduct"
add foreign key("order_id") REFERENCES "Order"("id")
on update cascade on delete cascade;

alter table "Stock"
add foreign key("supplier_id") REFERENCES "Supplier"("id")
on update cascade on delete cascade;

alter table "Stock"
add foreign key("product_id") REFERENCES "Product"("id")
on update cascade on delete cascade;