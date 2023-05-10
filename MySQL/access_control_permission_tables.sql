/*
Napisz polecenia MySQL, które utworzą bazę o nazwie smart_data, zmienią aktualnie wybraną bazę na smart_data, 
a następnie umieszczą w niej dwie tabele z danymi, tj. animals oraz bank (każda kolumna, poza kluczem głównym tabeli, 
może przyjmować wartość NULL).

tabela animals:
    id - liczba całkowita, klucz główny,
    name - ciąg znaków (max 20),
    owner - ciąg znaków (max 20),
    species - ciąg znaków (max 20),
    sex - 1 znak.

tabela bank:
    id - liczba całkowita, klucz główny,
    surname - ciąg znaków (max 20),
    address - ciąg znaków (max 40),
    balance - liczba rzeczywista,
    pin - ciąg znaków o długości 4

Zawartość animals:

id	name	owner	species	sex
4	Fluffy	Harold	cat	f
5	Claws	Gwen	cat	m
9	Buffy	Harold	dog	NULL
Zawartość bank:

id	surname	address	                                balance	pin
5	Smith	4262 Grey Fox Farm Road, Houston, TX	2000.0	1337
7	Rocky	1780 Bartlett Avenue, Troy, MI	9640.5	5428
8	Svenson	759 Stockert Hollow Road, Redmond, WA	827.0	9822
*/

CREATE DATABASE smart_data;

USE smart_data;

CREATE TABLE bank
(
    id INT,
    surname VARCHAR(20) null,
    address VARCHAR(40) null,
    balance FLOAT null,
    pin CHAR(4) null,
    PRIMARY KEY (id)
);

CREATE TABLE animals
(
    id INT,
    name VARCHAR(20) null,
    owner VARCHAR(20) null,
    species VARCHAR(20) null,
    sex CHAR(1) null,
    PRIMARY KEY (id)
);

INSERT INTO animals VALUES
(4, 'Fluffy', 'Harold', 'cat', 'f'),
(5, 'Claws', 'Gwen', 'cat', 'm'),
(9, 'Buffy', 'Harold', 'dog', NULL);

INSERT INTO bank VALUES
(5, 'Smith', '4262 Grey Fox Farm Road, Houston, TX', 2000.0, '1337'),
(7, 'Rocky', '1780 Bartlett Avenue, Troy, MI', 9640.5, '5428'),
(8, 'Svenson', '759 Stockert Hollow Road, Redmond, WA', 827.0, '9822');


/*
Utwórz następujących użytkowników (domyślny tryb uwierzytelniania):

user	host	password
andy	%	pazzw0Rd
ben	    %	pazzw0Rd
collin	%	pazzw0Rd
danny	%	pazzw0Rd
*/

CREATE USER 'andy'@'%'
IDENTIFIED BY 'pazzw0Rd';
CREATE USER 'ben'@'%'
IDENTIFIED BY 'pazzw0Rd';
CREATE USER 'collin'@'%'
IDENTIFIED BY 'pazzw0Rd';
CREATE USER 'danny'@'%'
IDENTIFIED BY 'pazzw0Rd';

-- Nadaj użytkownikowi andy@% uprawnienia do operacji SELECT, DROP i INSERT na tabeli animals w bazie smart_data.

GRANT SELECT, DROP, INSERT ON smart_data.animals TO 'andy'@'%';

-- Wyświetl uprawnienia użytkownika andy@%

SHOW GRANTS FOR 'andy'@'%';

/*
Sprawdź czy użytkownik andy@% ma uprawnienia DROP w tabeli animals w bazie smart_data. 
Jeśli tak, to wyświetl true, a jeśli nie, to wyświetl false.

Weryfikację przeprowadź poprzez sprawdzenie tabeli mysql.tables_priv. 
Być może przyda się informacja o tym jak przetwarzać dane z kolumny o typie SET
*/

SELECT IF((SELECT TRUE 
FROM mysql.tables_priv 
WHERE User='andy' AND Host='%'
AND Table_name='animals' 
AND Db='smart_data' AND Table_priv 
LIKE '%DROP%') LIKE '1', 'true', 'false') AS 'DROP';

-- Napisz polecenie, które wyświetli polecenie tworzące użytkownika andy@%. Polecenie zakończ znacznikiem \G

SHOW CREATE USER 'andy'@'%'\G

-- Odbierz użytkownikowi andy@% uprawnienia do operacji INSERT na tabeli animals w bazie smart_data

REVOKE INSERT
ON smart_data.animals
FROM 'andy'@'%';

-- Usuń użytkownika ben@%.

DROP USER 'ben'@'%'

-- Utwórz widok personal_data wyświetlający z tabeli bank kolumny id, surname i address

CREATE VIEW personal_data AS SELECT id,surname,address FROM bank;

/*
Utwórz następujące role z następującymi uprawnieniami:

nazwa roli	    obiekt	                                    uprawnienia
read_all	    tabela bank, wszystkie kolumny	            wyświetlanie wierszy
write_all	    tabela bank, wszystkie kolumny	            wstawianie, aktualizowanie i usuwanie wierszy
read_rodo	    tabela bank, kolumny id, surname, address	wyświetlanie wierszy
read_view_rodo	widok personal_data, wszystkie kolumny	    wyświetlanie wierszy
*/

CREATE ROLE 'read_all', 'write_all', 'read_rodo', 'read_view_rodo';

GRANT SELECT ON smart_data.bank TO 'read_all';
GRANT INSERT,UPDATE,DELETE ON smart_data.bank TO 'write_all';
GRANT SELECT ON smart_data.personal_data TO 'read_view_rodo';

GRANT 
   SELECT (id, surname, address)
ON bank 
TO 'read_rodo';

-- Wyświetl uprawnienia ról dotyczące tabel i widoków.

SELECT User AS 'Role', Host, Db, Table_name AS 'Table/view', 
IF(Table_priv LIKE '%SELECT%', 'true', 'false') AS 'Select',
IF(Table_priv LIKE '%INSERT%', 'true', 'false') AS 'Insert',
IF(Table_priv LIKE '%UPDATE%', 'true', 'false') AS 'Update',
IF(Table_priv LIKE '%DELETE%', 'true', 'false') AS 'Delete'
FROM mysql.tables_priv
WHERE Db LIKE 'smart_data'
ORDER BY Table_name;


-- Wyświetl uprawnienia ról dotyczące kolumn.

SELECT User AS 'Role', Host,Db, Table_name AS 'Table/view', Column_name,
IF(Column_priv LIKE '%SELECT%', 'true', 'false') AS 'Select',
IF(Column_priv LIKE '%INSERT%', 'true', 'false') AS 'Insert',
IF(Column_priv LIKE '%UPDATE%', 'true', 'false') AS 'Update',
IF(Column_priv LIKE '%DELETE%', 'true', 'false') AS 'Delete'
FROM mysql.columns_priv
WHERE Db LIKE 'smart_data'

/*
Przypisz użytkownikom następujące role:

użytkownik	role
andy@%	    read_rodo
collin@%	read_all, write_all
danny@%	    read_view_rodo
*/

GRANT 'read_rodo' TO 'andy'@'%';
GRANT 'read_all', 'write_all' TO 'collin'@'%';
GRANT 'read_view_rodo' TO 'danny'@'%';


-- Wyświetl role nadane użytkownikom andy@%, collin@% i danny@% w poniższym formacie.

SELECT 
CONCAT(TO_USER,'@',TO_HOST) AS 'User',
CONCAT(FROM_USER,'@',FROM_HOST) AS 'Role'
FROM mysql.role_edges 
ORDER BY CONCAT(TO_USER,'@',TO_HOST)

-- Wyświetl uprawnienia użytkownika collin@% poszerzone o uprawnienia roli write_all

SHOW GRANTS FOR 'collin'@'%' USING 'write_all';


-- (Zadanie wykonujesz jako zalogowany użytkownik andy@%.) Wyświetl aktualną rolę.

SELECT CURRENT_ROLE() AS 'current role';

/*
(Zadanie wykonujesz jako zalogowany użytkownik andy@%.)

Zmień rolę na read_rodo, zmień aktualną bazę na smart_data i wyświetl zawartość 
tabeli bank (w takim zakresie w jakim użytkownik ma dostęp).
*/

SET ROLE 'read_rodo';
USE smart_data;

SELECT id,surname,address FROM bank;

/*
(Zadanie wykonujesz jako zalogowany użytkownik danny@%.)

Zmień rolę na read_view_rodo, zmień aktualną bazę na smart_data 
i wyświetl całą zawartość widoku personal_data (zauważ, że nie ma dostępu do tabeli bank).
*/

SET ROLE 'read_view_rodo';
USE smart_data;
SELECT * FROM personal_data;

/*
(Zadanie wykonujesz jako zalogowany użytkownik collin@%.)

Zmień role na read_all i write_all, zmień aktualną bazę na smart_data, 
zmień w tabeli bank zawartość w wierszu o id = 5 kolumnę surname na Kovalsky, 
dodaj nowy wiersz o wartościach (9, 'Musk', 'Unknown', 9999.0, '5522') i wyświetl całą zawartość tabeli bank.
*/

SET ROLE 'read_all', 'write_all';
USE smart_data;

UPDATE bank
SET surname='Kovalsky'
WHERE id=5;

INSERT INTO bank VALUES (9, 'Musk', 'Unknown', 9999.0, '5522');
SELECT * FROM bank;


-- (Dalsze zadania wykonuj jako root.) Zmień hasło użytkownika andy@% na SARS-Cov-2.

ALTER USER'andy'@'%'
IDENTIFIED BY 'SARS-Cov-2';

-- Odbierz użytkownikowi collin@% rolę read_all i wyświetl aktualnie przypisane mu role

REVOKE 'read_all' FROM 'collin'@'%';

SELECT CONCAT(TO_USER,'@',TO_HOST) AS 'User',
CONCAT(FROM_USER,'@',FROM_HOST) AS 'Role'
FROM mysql.role_edges WHERE CONCAT(TO_USER,'@',TO_HOST) LIKE 'collin@%';

-- Zabierz roli write_all uprawnienie UPDATE na tabeli bank w bazie smart_data

REVOKE UPDATE ON smart_data.bank FROM 'write_all'

-- Usuń rolę read_view_rodo.

DROP ROLE 'read_view_rodo'


