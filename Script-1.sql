create schema videoclub;

set schema 'videoclub';

-- Crear la tabla de Socio
create table socio (
    id_socio SMALLSERIAL not NULL,
    nombre VARCHAR(50) not NULL,
    apellido1 VARCHAR(50) not NULL,
    apellido2 VARCHAR (50) not null,
    fecha_nacimiento DATE not NULL,
    telefono VARCHAR(20) not NULL,
    DNI VARCHAR(20) not NULL
);

-- Crear la tabla de Direccion
create table direccion (
    id_direccion SMALLSERIAL not NULL,
    id_socio smallint not NULL,
    codigo_postal VARCHAR(10) not NULL,
    calle VARCHAR(80) not NULL,
    numero VARCHAR(5) not NULL,
    piso VARCHAR(10) not NULL
);


alter table socio add constraint pk_socio primary key (id_socio);


alter table direccion add constraint pk_direccion primary key (id_direccion);


alter table direccion add constraint fk_socio_direccion foreign key (id_socio) references socio(id_socio);

-- Crear la tabla de Pelicula
create table pelicula (
    id_pelicula SMALLSERIAL not NULL,
    titulo VARCHAR(200) not NULL,
    genero VARCHAR(100) not NULL,
    director VARCHAR(100) not NULL,
    sinopsis text not null 
);


alter table pelicula add constraint pk_pelicula primary key (id_pelicula);

-- Crear la tabla de Copia
create table copia(
    id_copia int4 not null,
    id_pelicula smallint NOT NULL
);


alter table copia add constraint pk_copia primary key  (id_copia);


alter table copia add constraint fk_pelicula_copia foreign key (id_pelicula) references pelicula(id_pelicula);

-- Crear la tabla de Prestamo
create table prestamo (
    id_prestamo SMALLSERIAL not NULL,
    id_copia smallint not NULL,
    id_socio smallint not NULL,
    fecha_prestamo TIMESTAMP not NULL,
    fecha_devolucion TIMESTAMP
);


alter table videoclub.prestamo add constraint pk_prestamo primary key (id_prestamo);


alter table videoclub.prestamo add constraint fk_copia_prestamo foreign key (id_copia) references copia(id_copia);


alter table videoclub.prestamo add constraint fk_socio_prestamo foreign key (id_socio) references socio(id_socio);

alter table socio rename column apellido1 to apellido_1;
alter table socio rename column apellido2 to apellido_2;
alter table socio alter column fecha_nacimiento type VARCHAR (50);
alter table	pelicula alter column id_pelicula type INT4;
alter table prestamo alter column id_copia type INT4;
select * from copia c;
select * from socio;
select * from pelicula;
select * from prestamo;





insert into socio(nombre, apellido_1, apellido_2, fecha_nacimiento, telefono, DNI)
select	distinct  nombre, apellido_1, apellido_2, fecha_nacimiento, telefono, DNI
from tmp_videoclub;

insert into direccion (id_socio, codigo_postal, calle, piso, numero)
select s.id_socio, tv.codigo_postal, tv.calle, tv.piso, tv.numero
from tmp_videoclub tv
join socio s on s.id_socio = s.id_socio;

insert into pelicula(titulo,genero,director,sinopsis)
select distinct  titulo,genero ,director ,sinopsis 
from tmp_videoclub;

alter table copia alter column id_copia type INT4;
alter table prestamo alter column fecha_devolucion type DATE;
alter table prestamo alter column fecha_alquiler type DATE;

alter table prestamo rename column fecha_prestamo to fecha_alquiler;
alter sequence prestamo_id_prestamo_seq restart with 100000;

select * from prestamo;

select * from copia;

insert into copia (id_copia, id_pelicula)
select distinct  tv.id_copia, p.id_pelicula
from join pelicula p on tv.titulo = p.titulo
where tv.id_copia is not null;

insert into prestamo (id_copia, id_socio, fecha_alquiler, fecha_devolucion)
select distinct c.id_copia, s.id_socio, tv.fecha_alquiler::date, tv.fecha_devolucion::date
from tmp_videoclub tv
join socio s ON tv.dni = s.dni 
join copia c ON tv.id_copia = c.id_copia 
where tv.fecha_alquiler is not null;

select p.titulo, count(c.id_copia) as copias_disponibles
from pelicula p
left join copia c on p.id_pelicula = c.id_pelicula
left join prestamo pr on c.id_copia = pr.id_copia and pr.fecha_devolucion is null
where pr.id_prestamo is null
group by p.titulo;

