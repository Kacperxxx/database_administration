/*
Napisz polecenia Transact-SQL, które:

- utworzą bazę danych o nazwie university,
- zmienią aktualnie wybraną bazę danych na university,
- umieszczą w niej dwie tabele z danymi, tj. student oraz faculty,
- utworzą konto użytkownika mapowane na konto logowania bob,
- dodadzą konto użytkownika bob do ról db_datareader oraz db_datawriter.

1. tabela student:
    - id - liczba całkowita, klucz główny,
    - name - ciąg znaków (max 50),
    - surname - ciąg znaków (max 50),
    - birthday - data,
    - personal_id - ciąg znaków (max 50),
    - address - ciąg znaków (max 100),
    - zip_code - ciąg znaków (max 10),
    - email - ciąg znaków (max 50)
    - tuition - wartość pieniężna

2. tabela faculty:
    - id - liczba całkowita, klucz główny,
    - name - ciąg znaków (max 50),
    - surname - ciąg znaków (max 50),
    - birthday - data,
    - personal_id - ciąg znaków (max 50),
    - address - ciąg znaków (max 100),
    - zip_code - ciąg znaków (max 10),
    - email - ciąg znaków (max 50)
    - salary - wartość pieniężna
*/

USE master;

DROP DATABASE IF EXISTS university;

CREATE DATABASE university; 

USE university;

CREATE TABLE student
(
    id          INT PRIMARY KEY,
    name        VARCHAR(50),
    surname     VARCHAR(50),
    birthday    DATE,
    personal_id VARCHAR(50),
    address     VARCHAR(100),
    zip_code    VARCHAR(10),
    email       VARCHAR(50),
    tuition     MONEY
);

INSERT INTO student VALUES 
( 2, 'Belladonna' , 'Sandheaver',  '1947-02-23', '47022329148', '3219 Poplar Lane Miami, FL', '33-176', 'BelladonnaSandheaver@jourrapide.com', 2025),
( 7, 'Fredegar', 'Greenhand', '1985-07-06', '85070644484', '3311 Laurel Lee Saint Paul, MN', '55-106', 'FredegarGreenhand@teleworm.us', 1024),
( 9, 'Diamanda', 'Goodchild', '1994-09-14', '94091438255', '1647 Rhode Island Avenue Washington, DC', '20-007', 'DiamandaGoodchild@dayrep.com', 0);

CREATE TABLE faculty
(
    id          INT PRIMARY KEY,
    name        VARCHAR(50),
    surname     VARCHAR(50),
    birthday    DATE,
    personal_id VARCHAR(50),
    address     VARCHAR(100),
    zip_code    VARCHAR(10),
    email       VARCHAR(50),
    salary      MONEY
);

INSERT INTO faculty VALUES 
( 3, 'Tayla', 'Fairley', '1973-03-26', '73032676844', '1737 Central Avenue Ramsey, NJ 07446', '07-446', 'TaylaFairley@armyspy.com', 4057),
( 6, 'Evie', 'Cox', '1952-02-26', '52022678499', '3888 Kenwood Place Fort Lauderdale, FL', '33-301', 'EvieCox@dayrep.com',  11754),
( 12, 'James', 'Buchanan', '1950-05-21', '50052165886', '1176 Cook Hill Road Stamford, CT', '06-902', 'JamesBuchanan@rhyta.com', 7780);

CREATE USER bob FOR LOGIN bob;

ALTER ROLE db_datareader ADD MEMBER bob;

ALTER ROLE db_datawriter ADD MEMBER bob;

/*
Utwórz następujące schematy:

    - HumanResources
    - StudentOffice
*/

CREATE SCHEMA HumanResources;
CREATE SCHEMA StudentOffice;

-- Ustaw właściciela schematu HumanResources na konto użytkownika bob

ALTER AUTHORIZATION ON schema::HumanResources TO bob;

-- Ustaw domyślny schemat konta użytkownika bob na HumanResources

ALTER USER bob WITH DEFAULT_SCHEMA = HumanResources;

-- Przenieś tabelę faculty do schematu HumanResources

ALTER SCHEMA HumanResources TRANSFER dbo.faculty;

/*
Napisz zapytanie Transact-SQL wyświetlające 
przypisanie do schematów wszystkich tabel w bazie university za pomocą widoku systemowego INFORMATION_SCHEMA.TABLES
*/

SELECT * 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_CATALOG = 'university';

-- Usuń schemat StudentOffice

DROP SCHEMA StudentOffice;

/*
Jako użytkownik bob wykonaj zapytanie Transact-SQL:

SELECT * FROM student;
*/

EXECUTE AS USER = 'bob';
SELECT * FROM student;
REVERT;

-- W tabeli student dodaj domyślne maskowanie tekstowe dla kolumny address

ALTER TABLE student  
  ALTER COLUMN address VARCHAR(100) MASKED WITH (FUNCTION = 'default()');

-- W tabeli student dodaj domyślne maskowanie daty dla kolumny birthday

ALTER TABLE student  
  ALTER COLUMN birthday DATE MASKED WITH (FUNCTION = 'default()');

-- W tabeli student dodaj maskowanie e-mail dla kolumny email

ALTER TABLE student  
ALTER COLUMN email VARCHAR(50) MASKED WITH (FUNCTION = 'email()');

/*
W tabeli student dodaj maskowanie własne dla kolumny zip_code, tak aby zakryte były trzy ostatnie znaki:

33-XXX
55-XXX
20-XXX
*/

ALTER TABLE student  
ALTER COLUMN zip_code VARCHAR(10) MASKED WITH (FUNCTION = 'partial(3,"XXX",0)');


-- W tabeli student dodaj losowe maskowanie liczbowe z zakresu od 1000 do 15000 dla kolumny tuition

ALTER TABLE student
ALTER COLUMN tuition MONEY MASKED WITH (FUNCTION = 'random(1000, 15000)');

-- W tabeli student usuń maskowanie dla kolumn birthday oraz tuition

ALTER TABLE student
  ALTER COLUMN birthday DROP MASKED;

ALTER TABLE student
  ALTER COLUMN tuition DROP MASKED;