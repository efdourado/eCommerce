create table "client" (
    "id" serial not null primary key,
    "name" varchar(255) not null,
    "email" varchar(255) not null unique,
    "phone" varchar(255)
);

create table "vehicle" (
    "id" serial not null primary key,
    "license_plate" varchar(255) not null unique,
    "brand" varchar(255),
    "model" varchar(255),
    "year" int,
    "client_id" int,
    foreign key("client_id") references "client"("id")
    on update cascade on delete cascade
);

create table "team" (
    "id" serial not null primary key,
    "name" varchar(255) not null
);

create table "mechanic" (
    "id" serial not null primary key,
    "name" varchar(255) not null,
    "team_id" int,
    foreign key("team_id") references "team"("id")
    on update cascade on delete cascade
);

create table "service" (
    "id" serial not null primary key,
    "name" varchar(255) not null,
    "description" varchar(255)
);

create table "work_order" (
    "id" serial not null primary key,
    "vehicle_id" int,
    "team_id" int,
    "date_of_issue" date not null,
    "date_of_delivery" date not null,
    "total_value" float not null,
    "authorized" boolean not null,
    foreign key("vehicle_id") references "vehicle"("id")
    on update cascade on delete cascade,
    foreign key("team_id") references "team"("id")
    on update cascade on delete cascade
);

create table "work_order_service" (
    "work_order_id" int not null,
    "service_id" int not null,
    primary key("work_order_id", "service_id"),
    foreign key("work_order_id") references "work_order"("id")
    on update cascade on delete cascade,
    foreign key("service_id") references "service"("id")
    on update cascade on delete cascade
);

create table "labor_cost" (
    "id" serial not null primary key,
    "service_id" int,
    "hourly_rate" float not null,
    foreign key("service_id") references "service"("id")
    on update cascade on delete cascade
);

create table "part" (
    "id" serial not null primary key,
    "name" varchar(255) not null,
    "price" float not null
);

create table "work_order_part" (
    "work_order_id" int not null,
    "part_id" int not null,
    "qty" int not null default 1,
    primary key("work_order_id", "part_id"),
    foreign key("work_order_id") references "work_order"("id")
    on update cascade on delete cascade,
    foreign key("part_id") references "part"("id")
    on update cascade on delete cascade
);