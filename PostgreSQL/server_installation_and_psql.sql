-- Napisz polecenie PostgreSQL, które wyświetli wszystkie bazy na serwerze.

\l

-- Napisz polecenie PostgreSQL, które utworzy bazę szkola.

create database szkola;

-- Napisz polecenie PostgreSQL, które zmieni aktualną bazę na szkola.

\c szkola;

-- Napisz polecenie PostgreSQL, które wyświetli aktualną bazę.

select current_database();

/*
Napisz polecenie PostgreSQL, które utworzy tabele:

przedmioty z kolumnami:
    id przechowująca liczby całkowite,
    nazwa przechowująca tekst dowolnej długości
    symbol przechowująca tekst dowolnej długości,

zajecia z kolumnami:
    przedmiotId przechowująca liczby całkowite,
    startDate przechowująca datę,
    endDate przechowująca datę.
*/

create table przedmioty
(
    id INT,
    nazwa TEXT,
    symbol TEXT
);

create table zajecia
(
    "przedmiotId" INT,
    "startDate" DATE,
    "endDate" DATE
);

-- Napisz polecenie PostgreSQL, które wyświetli listę tabel w aktualnie wybranej bazie

\dt

-- Napisz polecenie PostgreSQL, które wyświetli właściwości kolumn tabeli przedmioty

\d przedmioty;

/*
Napisz polecenie PostgreSQL, które doda do tabel następujące dane:

tabela przedmioty:
    1, 'Administrowanie bazami danych', 'ABD'
    2, 'Analiza Matematyczna', 'ANA'
    3, 'Algorytmy grafowe', 'AGR'

tabela zajecia:
    2, '2019-10-01', '2020-02-03'
    1, '2020-02-22', '2020-06-24'
    3, '2020-10-01', '2021-02-03'
*/

insert into przedmioty values
(1, 'Administrowanie bazami danych', 'ABD'),
(2, 'Analiza Matematyczna', 'ANA'),
(3, 'Algorytmy grafowe', 'AGR');

insert into zajecia values
(2, '2019-10-01', '2020-02-03'),
(1, '2020-02-22', '2020-06-24'),
(3, '2020-10-01', '2021-02-03');

-- Napisz polecenie PostgreSQL wyświetlające symbole przedmiotów, które w nazwach przedmiotów jako przedostatnią literę mają n lub w.

SELECT symbol FROM przedmioty
WHERE nazwa ~ '^.*(w|n).$';

-- Napisz polecenie PostgreSQL, które usunie tylko tabelę zajecia.

DROP TABLE zajecia;

-- Napisz polecenie PostgreSQL, które usunie tylko bazę szkola.

\c postgres;

drop database "szkola";

/*
Napisz dwa polecenia PostgreSQL, z których pierwsze utworzy tabelę imiona z kolumną imie przechowującą tekst z collation C.
Drugie polecenie powinno dodać wartości 'Mieczysława', 'Łucja' i 'Ludmiła' do kolumny imie.
*/

create table imiona
(
    imie TEXT COLLATE "C"
);

INSERT INTO imiona VALUES
('Mieczysława'),
('Łucja'),
('Ludmiła');

-- Napisz polecenie PostgreSQL, które wyświetli dane z kolumny imie posortowane przy użyciu collation pl-PL-x-icu

SELECT imie
FROM imiona
ORDER by imie
COLLATE "pl-PL-x-icu";

-- Napisz polecenie PostgreSQL, które zmieni collation na pl-PL-x-icu dla kolumny imie

ALTER TABLE imiona
ALTER COLUMN imie
SET DATA TYPE text 
COLLATE "pl-PL-x-icu";