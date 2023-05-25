CREATE DATABASE aeropuerto2 CHARACTER set utf8mb4;

USE aeropuerto2;

create table aerolinea(
id_aerolinea int not null primary key,
nombre varchar(100) not null
);



create table ruta(
num_vuelo int not null primary key,
id_aerolinea int not null,
origen varchar(100) not null,
destino varchar(100) not null, 
fecha_y_hora datetime not null,
duracion time not null,
foreign key (id_aerolinea) references aerolinea(id_aerolinea) on delete cascade
);

create table vuelo(
num_vuelo int not null,
estado varchar(20)not null,
duracion int not null,
fecha_salida datetime not null,
fecha_llegada datetime not null,
primary key(fecha_salida, num_vuelo),
foreign key (num_vuelo) references ruta(num_vuelo) on delete cascade
);

create table reserva(
id_reserva int not null primary key,
id_cliente int not null,
num_vuelo int not null,
fecha_salida datetime not null,
fecha_reserva datetime not null ,
estado varchar(50) not null,
foreign key (id_cliente) references cliente(id_cliente) on delete cascade,
foreign key (fecha_salida,num_vuelo) references vuelo(fecha_salida, num_vuelo) on delete cascade
);

create table avion(
id_avion int not null primary key,
modelo varchar(100) not null,
capacidad int not null,
num_vuelo int not null,
foreign key (num_vuelo) references ruta(num_vuelo) on delete cascade

);

create table cliente(
id_cliente int not null primary key,
nombre varchar(100) not null,
apellido1 varchar(100) not null,
apellido2 varchar(100) default null,
nacimiento date not null
);
