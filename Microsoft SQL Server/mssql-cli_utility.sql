/*
Napisz polecenia Transact-SQL, które utworzą bazę o nazwie important_data, zmienią aktualnie wybraną bazę na important_data, 
a następnie umieszczą w niej dwie tabele z danymi, tj. cars oraz houses.

1. tabela cars:
    - id - liczba całkowita, klucz główny,
    - manufacturer - ciąg znaków (max 50),
    - model - ciąg znaków (max 50),
    - type - ciąg znaków (max 50),
    - horsepower - liczba całkowita.

2. tabela houses:
    - id - liczba całkowita, klucz główny,
    - owner_surname - ciąg znaków (max 50),
    - address - ciąg znaków (max 100),
    - area - liczba rzeczywista,
    - bedrooms - liczba całkowita.

Zawartość cars:

id, manufacturer, model, type, horsepower
3, Acura, ILX, Sedan, 201
7, Fiat, 500X, SUV,	150
8, Lexus, RC, Coupe, 467

Zawartość houses:

id, owner_surname, address, area, bedrooms
2,Markowitz, '293 Davis Place, Toledo, OH',	156.2, 3
3,Earl, '2071 Rockford Mountain Lane, Appleton, WI', 54.5, 1
5,Hampton, '930 Sunny Glen Lane, Cleveland, OH', 111.9,	2
*/

CREATE DATABASE important_data;

USE important_data;

CREATE TABLE cars
(
    id INT PRIMARY KEY,
    manufacturer VARCHAR(50),
    model VARCHAR(50),
    type VARCHAR(50),
    horsepower INT
);

CREATE TABLE houses
(
    id INT PRIMARY KEY,
    owner_surname VARCHAR(50),
    address VARCHAR(100),
    area FLOAT,
    bedrooms INT
);

INSERT INTO cars VALUES
(3, 'Acura', 'ILX', 'Sedan', 201),
(7, 'Fiat', '500X', 'SUV', 150),
(8, 'Lexus', 'RC', 'Coupe', 467);

INSERT INTO houses VALUES
(2,'Markowitz','293  Davis Place, Toledo, OH', 156.2,3),
(3,'Earl','2071  Rockford Mountain Lane, Appleton, WI',54.5,1),
(5,'Hampton','930  Sunny Glen Lane, Cleveland, OH',111.9,2);



/*
Utwórz następujące konta logowania z uwierzytelnianiem SQL Server:

user	password
amara	P@zzw0rd
barry	P@zzw0rd
clark	P@zzw0rd
dante	P@zzw0rd
*/

CREATE LOGIN amara WITH PASSWORD = 'P@zzw0rd';

CREATE LOGIN barry WITH PASSWORD = 'P@zzw0rd';

CREATE LOGIN clark WITH PASSWORD = 'P@zzw0rd';

CREATE LOGIN dante WITH PASSWORD = 'P@zzw0rd';

/*
Dodaj konta logowania do następujących ról na poziomie serwera:

konto	rola
amara	sysadmin
clark	dbcreator
*/

ALTER SERVER ROLE sysadmin ADD MEMBER amara;

ALTER SERVER ROLE dbcreator ADD MEMBER clark;

/*
Napisz wyrażenie Transact-SQL wyświetlające przypisanie ról na poziomie serwera do kont logowania. Skorzystaj z 
widoku systemowego sys.server_role_members połączonego z sys.server_principals. 
Wynik powinien zawierać kolumny MemberName oraz RoleName
*/

SELECT p2.name AS MemberName,
       p1.name AS RoleName
FROM   sys.server_role_members AS srm
       JOIN sys.server_principals AS p1
         ON srm.role_principal_id = p1.principal_id
       JOIN sys.server_principals AS p2
         ON srm.member_principal_id = p2.principal_id;


-- Usuń konto logowania amara z roli na poziomie serwera sysadmin

ALTER SERVER ROLE sysadmin DROP MEMBER amara;

-- Usuń konto logowania dante

DROP LOGIN dante;

/*
Utwórz następujące konta użytkownika w bazie important_data zmapowanych do kont logowania:

amara
barry
clark
*/

CREATE USER amara FOR LOGIN amara;

CREATE USER barry FOR LOGIN barry;

CREATE USER clark FOR LOGIN clark;

/*
Dodaj konta użytkownika w bazie important_data do następujących ról bazy danych:

konto	rola
amara	db_owner
barry	db_owner
clark	db_datareader oraz db_securityadmin
*/

ALTER ROLE db_owner ADD MEMBER amara;

ALTER ROLE db_owner ADD MEMBER barry;

ALTER ROLE db_datareader ADD MEMBER clark;

ALTER ROLE db_securityadmin ADD MEMBER clark;

-- Usuń konto użytkownika barry z roli db_owner na poziomie bazy danych important_data.

ALTER ROLE db_owner DROP MEMBER barry;

-- Napisz zapytanie Transact-SQL wyświetlające uprawnienia użytkownika do tabeli cars w bazie important_data

SELECT * FROM fn_my_permissions('cars', 'object');

-- Nadaj uprawnienia pozwalające na wykonywanie SELECT oraz INSERT dla konta użytkownika barry dla tabeli houses w bazie important_data

GRANT SELECT, INSERT ON OBJECT::houses TO barry;


-- Nadaj uprawnienia zabraniające wykonywania SELECT kolumny address w tabeli houses w bazie important_data dla konta użytkownika barry

DENY SELECT ON OBJECT::houses(address) TO barry;

-- Odbierz uprawnienia SELECT w tabeli houses w bazie important_data dla konta użytkownika barry.

REVOKE SELECT ON OBJECT::houses TO barry;

-- Usuń konto użytkownika amara w bazie important_data

DROP USER amara;

-- Zmień hasło konta logowania clark na NoweP@zzw0rd

ALTER LOGIN clark
WITH PASSWORD = 'NoweP@zzw0rd';

-- Napisz polecenia Transact-SQL, które włączą obsługę zwartych baz danych na serwerze oraz utworzą zwartą bazę o nazwie contained_data

USE master;

sp_configure 'contained database authentication', 1;

RECONFIGURE WITH OVERRIDE;

CREATE DATABASE contained_data CONTAINMENT = PARTIAL;


-- Napisz zapytanie Transact-SQL, które sprawdzi status zwartości bazy danych contained_data

SELECT name,
       containment_desc
FROM sys.databases
WHERE name = 'contained_data';

-- Napisz zapytanie Transact-SQL, które utworzy użytkownika contained_user z hasłem P@zzw0rd w zwartej bazie danych contained_data

CREATE USER contained_user WITH PASSWORD = 'P@zzw0rd';