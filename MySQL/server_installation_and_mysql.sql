-- Napisz polecenie MySQL, które utworzy bazę o nazwie precious_data

CREATE DATABASE precious_data

-- Napisz polecenie MySQL, które zmieni wybraną bazę na precious_data.

USE precious_data

-- Napisz polecenie MySQL, które wyświetli bazę, na której aktualnie pracujesz

SELECT DATABASE();

/*
Napisz polecenia MySQL, które utworzą dwie tabele:

1. tab1 z dwiema kolumnami:
    x przechowująca liczby całkowite,
    y przechowująca napisy o stałej długości 3 znaków.

2.tab2 z dwiema kolumnami:
    id przechowująca liczby całkowite,
    fin przechowująca datę.
*/

CREATE TABLE tab1
(
    x INT,
    y CHAR(3)
);

CREATE TABLE tab2
(
    id INT,
    fin DATE
);

-- Napisz polecenia MySQL, które wyświetli tabele w aktualnie wybranej bazie.

SHOW TABLES;

-- Napisz polecenia MySQL, które z aktualnej bazy wyświetli nazwy tabel, które w nazwie kończą się cyfrą.

SELECT TABLE_NAME
FROM   INFORMATION_SCHEMA.TABLES
WHERE  REGEXP_LIKE(TABLE_NAME, '^*[1-9]$');

-- Napisz polecenia MySQL, które wyświetli opis tabeli tab1.

DESCRIBE tab1;

/*
Napisz polecenia MySQL, które utworzy poniższą tabelę z silnikiem MyISAM:

tab3 z trzema kolumnami:
    a przechowująca liczby całkowite,
    b przechowująca napisy o stałej długości 5 znaków.
    c przechowująca datę.
*/

CREATE TABLE tab3 
(
    a INT,
    b CHAR(5),
    c DATE
) ENGINE MyISAM;

-- Napisz polecenia MySQL, które wyświetli w aktualnie wybranej bazie nazwy tabel i ich silniki.

SELECT TABLE_NAME,
       ENGINE
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'precious_data';

-- Napisz polecenia MySQL, które wyświetli zestaw znaków i zestawianie danych aktualnie wybranej bazy.

SELECT @@character_set_database,
       @@collation_database;

-- Napisz polecenia MySQL, które wyświetli metodę zestawiania danych w tabeli tab1

SELECT table_name, 
       table_collation
FROM   information_schema.tables
WHERE  table_schema = DATABASE()
       AND table_name = "tab1";

-- Napisz polecenia MySQL, które wyświetli wszystkie informacje o kolumnach tabeli tab1.

SHOW FULL COLUMNS FROM tab1;

-- Napisz polecenie MySQL, które utworzy bazę o nazwie abc o zestawie znaków utf8 i metodzie zestawiania danych utf8_polish_ci.

CREATE DATABASE abc
CHARACTER SET utf8 
COLLATE utf8_polish_ci;

-- Napisz polecenie MySQL, które zmieni w abc zestaw znaków na latin2.

ALTER DATABASE abc 
CHARACTER SET latin2

