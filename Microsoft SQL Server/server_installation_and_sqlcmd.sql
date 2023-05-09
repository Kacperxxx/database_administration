-- Zad 1. Napisz polecenie Transact-SQL, które wyświetli nazwy wszystkich baz na serwerze.

SELECT name FROM sys.databases;

-- Zad 2. Napisz polecenie Transact-SQL, które utworzy bazę o nazwie quarantine.

CREATE DATABASE quarantine;

-- Zad 3. Napisz polecenie Transact-SQL, które zmieni wybraną bazę na quarantine

USE quarantine;

-- Zad 4. Napisz polecenie Transact-SQL, które wyświetli aktualną bazę, na której pracujesz.

SELECT DB_NAME();

/* Zad 5. 
Napisz polecenia Transact-SQL, które utworzą dwie tabele:

1. 'people' z trzema kolumnami:
    i.   id: przechowująca liczby całkowite,
    ii.  name: przechowująca napisy Unicode o zmiennej długości do 200 znaków.,
    iii. surname: przechowująca napisy Unicode o zmiennej długości do 200 znaków.

2. 'self_isolations' z trzema kolumnami:
    i.   personId: przechowująca liczby całkowite,
    ii.  startDate: przechowująca datę,
    iii. endDate: przechowująca datę.
    */

CREATE TABLE people
(
    id INT,
    name NVARCHAR(200),
    surname NVARCHAR(200)
);

CREATE TABLE self_isolations
(
    personId INT,
    startDate DATE,
    endDate DATE
);

-- Zad 6. Napisz polecenie Transact-SQL, które wyświetli nazwy tabel w aktualnie wybranej bazie.

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES

-- Zad 7. Napisz polecenie Transact-SQL, które wyświetli nazwy tabel w aktualnie wybranej bazie kończące się na isolations.

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%isolations';

/* Zad 8.
Napisz polecenie Transact-SQL, które wyświetli następujące informacje o kolumnach tabeli people:

- nazwa
- typ wartości danych
- maksymalna długość danych
*/

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'people';

/* Zad 9.
Napisz polecenie Transact-SQL, które usunie tabelę self_isolations z bazy danych quarantine. 
Pozostałe tabele w bazie muszą pozostać nienaruszone.
*/

DROP TABLE self_isolations;

/* Zad 10.
Napisz polecenie Transact-SQL, które usunie bazę danych quarantine. 
Pozostałe bazy na serwerze muszą pozostać nienaruszone
*/

DROP DATABASE quarantine;

-- Zad 11. Napisz polecenie Transact-SQL, które wyświetli aktualnie skonfigurowane collation na poziomie serwera.

SELECT SERVERPROPERTY('Collation');

-- Zad 12. Napisz polecenie Transact-SQL, które utworzy bazę lokalne_produkty z collation Polish_100_CS_AS

CREATE DATABASE lokalne_produkty COLLATE Polish_100_CS_AS;

-- Zad 13. Napisz polecenie Transact-SQL, które wyświetli aktualnie skonfigurowane collation na poziomie bazy lokalne_produkty

SELECT DATABASEPROPERTYEX('lokalne_produkty','collation');

/* Zad 14.

Napisz polecenie Transact-SQL, które utworzy tabelę 'producenci' o następującej strukturze:

    - id: przechowująca liczby całkowite,
    - nazwa: przechowująca napisy o zmiennej długości do 200 znaków z collation Latin1_General_100_CS_AS_SC
    - adres: przechowująca napisy o zmiennej długości do 1000 znaków z collation Latin1_General_100_CS_AS_SC
*/

CREATE TABLE producenci
(
    id INT,
    nazwa VARCHAR(200) COLLATE Latin1_General_100_CS_AS_SC,
    adres VARCHAR(1000) COLLATE Latin1_General_100_CS_AS_SC
);

-- Zad 15. Napisz polecenie Transact-SQL, które wyświetli nazwę kolumny oraz aktualnie skonfigurowane collation dla tabeli producenci w bazie lokalne_produkty

SELECT COLUMN_NAME, COLLATION_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_CATALOG = 'lokalne_produkty' AND TABLE_NAME = 'producenci';

-- Zad 16. Napisz polecenia Transact-SQL, które zmienią collation kolumn nazwa typu VARCHAR(200) oraz adres typu VARCHAR(1000) na Polish_100_CS_AS w tabeli producenci

ALTER TABLE producenci
ALTER COLUMN nazwa VARCHAR(1000) COLLATE Polish_100_CS_AS;
ALTER TABLE producenci
ALTER COLUMN adres VARCHAR(1000) COLLATE Polish_100_CS_AS;