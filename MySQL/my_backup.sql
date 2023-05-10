DROP DATABASE IF EXISTS moto;

CREATE DATABASE moto;

CREATE TABLE moto.cars
(
    year        INT,
    make        VARCHAR(10),
    model       VARCHAR(50),
    description VARCHAR(100),
    price       FLOAT
);

DROP DATABASE IF EXISTS school;

CREATE DATABASE school;

CREATE TABLE school.students
(
    imie  VARCHAR(10),
    opis  VARCHAR(50),
    ocena INT
);

INSERT INTO school.students VALUES
('Karolina', 'fajna', 4),
('Lucjan',   'fajny', 2),
('Maciej',   'wiecznie pyta "która godzina", ale może być', 5);
