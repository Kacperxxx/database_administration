/*
Utwórz bazę bronx i zmień kontekst połączenia na tę bazę. Następnie utwórz tabelę cars o następujących parametrach (żadna kolumna nie może przyjmować wartości NULL):

atrybuty:
    id - liczba całkowita,
    name - ciąg znaków (max 30),
    prod - data,
    speed - liczba całkowita.

partycjonowanie zakresowe po atrybucie speed:
    p0_slow - wartości mniejsze niż 150,
    p1_medium - wartości mniejsze niż 250,
    p2_fast - wartośći mniejsze niż maksymalna wartość.

Do tabeli wstaw następujące wiersze:

id	name	                    prod	    speed
1	Honda Civic I	            1972-01-01	140
2	Toyota Corolla VIII	        1997-01-01	175
3	Dodge Challenger Hellcat	2015-01-01	320
4	AMC Javelin	                1968-01-01	129
5	Camaro ZL1	                2017-01-01	330
6	Pontiac Firebird	        1982-01-01	160
7	Fiat X1-9	                1972-01-01	170
*/

CREATE DATABASE bronx;

USE bronx;

CREATE TABLE cars 
(
  id INT NOT NULL,
  name VARCHAR(30) NOT NULL,
  prod DATE NOT NULL,
  speed INT NOT NULL
)
PARTITION BY RANGE(speed)
(
    PARTITION p0_slow VALUES LESS THAN (150),
    PARTITION p1_medium VALUES LESS THAN (250),
    PARTITION p2_fast VALUES LESS THAN MAXVALUE
);

INSERT INTO cars VALUES
(1, 'Honda Civic I', '1972-01-01', 140),
(2,'Toyota Corolla VIII','1997-01-01',175),
(3,'Dodge Challenger Hellcat','2015-01-01',320),
(4,'AMC Javelin','1968-01-01',129),
(5,'Camaro ZL1','2017-01-01',330),
(6,'Pontiac Firebird','1982-01-01',160),
(7,'Fiat X1-9','1972-01-01',170);

/*
Przy pomocy polecenia SHOW TABLE STATUS wyświetl status tabel znajdujących się w bazie bronx. Polecenie zakończ \G.

(Po wykonaniu polecenia zwróć uwagę w wyniku na wartość Create_options wskazującą na zastosowanie partycjonowania w tabeli).
*/

SHOW TABLE STATUS IN bronx\G

-- Przy pomocy tabeli INFORMATION_SCHEMA.PARTITIONS wyświetl informacje o partycjach w tabeli cars.

SELECT PARTITION_NAME, PARTITION_METHOD, PARTITION_EXPRESSION, PARTITION_DESCRIPTION, TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME LIKE 'cars';

/*
Przy pomocy polecenia EXPLAIN wyświetl opis zapytania SELECT 
wyświetlającego wszystkie kolumny z tabeli cars i tylko te samochody, 
dla których prędkość jest mniejsza niż 200. Polecenie zakończ \G.

(Po wykonaniu polecenia zwróć uwagę w wyniku na to, 
które partycje zostały wykorzystane do wykonania zapytania SELECT.)
*/

EXPLAIN SELECT *
FROM cars
WHERE speed < (200)\G


/*
Zreorganizuj partycję p2_fast w tabeli cars w taki sposób 
by zachować wszystkie dane oraz by partycjonowanie wyglądało następująco:

    p2_fast - wartości mniejsze niż 325,
    p3_turbo - wartośći mniejsze niż maksymalna wartość.

Partycje p0_slow i p1_medium mają zostać niezmienione.
*/

ALTER TABLE cars
REORGANIZE PARTITION p2_fast INTO 
(
    PARTITION p2_fast VALUES LESS THAN (325),
    PARTITION p3_turbo VALUES LESS THAN MAXVALUE
);

-- Usuń dane znajdujące się w partycji p1_medium (nie usuwaj partycji).

ALTER TABLE cars
TRUNCATE PARTITION p1_medium;

-- Usuń partycję p0_slow.

ALTER TABLE cars
DROP PARTITION p0_slow;

/*
Utwórz tabelę exams o następujących parametrach (żadna kolumna nie może przyjmować wartości NULL):

atrybuty:
    student - liczba całkowita,
    approach - data,
    grade - liczba całkowita.

partycjonowanie zakresowe po atrybucie approach:
    p0 - data wcześniejsza niż 2000-09-01,
    p1 - data wcześniejsza niż 2010-09-01,
    p2 - data wcześniejsza niż maksymalna wartość.

subpartycjonowanie haszowe po liczbie dni między datą approach a rokiem 0
    po 2 subpartycje na partycję.

Do tabeli wstaw następujące wiersze:

INSERT INTO exams VALUES
(83, "1971-02-08", 1), (21, "1970-10-04", 1), (64, "1993-05-16", 5),
(36, "1998-04-06", 2), (35, "1975-02-03", 5), (34, "1985-11-03", 2),
(29, "1979-10-02", 4), (25, "1981-02-12", 2), (53, "1972-03-01", 5),
(64, "1976-08-26", 4), (21, "1982-07-17", 1), (76, "2019-05-26", 1),
(85, "1977-07-05", 5), (54, "1997-06-08", 5), (44, "2006-01-27", 1),
(18, "2003-01-19", 1), (74, "2011-10-04", 1), (19, "1980-04-21", 2),
(20, "1994-07-05", 3), (82, "1989-02-11", 1), (59, "1975-03-21", 4),
(71, "1991-03-15", 2), (13, "2007-08-19", 2), (53, "1973-10-05", 1),
(59, "1975-12-15", 3), (68, "2015-08-11", 2), (79, "1976-02-28", 1),
(72, "1973-09-26", 1), (35, "2013-10-11", 4), (67, "2013-08-29", 5);
*/

CREATE TABLE exams
(
    student INT NOT NULL,
    approach DATE NOT NULL,
    grade INT NOT NULL
)
PARTITION BY RANGE COLUMNS(approach)
SUBPARTITION BY HASH (TO_DAYS(approach))
SUBPARTITIONS 2
(
    PARTITION p0 VALUES LESS THAN ('2000-09-01'),
    PARTITION p1 VALUES LESS THAN ('2010-09-01'),
    PARTITION p2 VALUES LESS THAN MAXVALUE
);

INSERT INTO exams VALUES
(83, "1971-02-08", 1), (21, "1970-10-04", 1), (64, "1993-05-16", 5),
(36, "1998-04-06", 2), (35, "1975-02-03", 5), (34, "1985-11-03", 2),
(29, "1979-10-02", 4), (25, "1981-02-12", 2), (53, "1972-03-01", 5),
(64, "1976-08-26", 4), (21, "1982-07-17", 1), (76, "2019-05-26", 1),
(85, "1977-07-05", 5), (54, "1997-06-08", 5), (44, "2006-01-27", 1),
(18, "2003-01-19", 1), (74, "2011-10-04", 1), (19, "1980-04-21", 2),
(20, "1994-07-05", 3), (82, "1989-02-11", 1), (59, "1975-03-21", 4),
(71, "1991-03-15", 2), (13, "2007-08-19", 2), (53, "1973-10-05", 1),
(59, "1975-12-15", 3), (68, "2015-08-11", 2), (79, "1976-02-28", 1),
(72, "1973-09-26", 1), (35, "2013-10-11", 4), (67, "2013-08-29", 5);


/*
Przy pomocy tabeli INFORMATION_SCHEMA.PARTITIONS wyświetl informacje o 
partycjach i subpartycjach w tabeli exams. Wynik posortuj według kolumny 
SUBPARTITION_NAME
*/

SELECT PARTITION_NAME, SUBPARTITION_NAME, PARTITION_METHOD, PARTITION_EXPRESSION,PARTITION_DESCRIPTION, SUBPARTITION_METHOD, SUBPARTITION_EXPRESSION, TABLE_ROWS    
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME LIKE 'exams'
ORDER BY SUBPARTITION_NAME;

/*
Utwórz tabelę devices o następujących parametrach (żadna kolumna nie może przyjmować wartości NULL):

atrybuty:
    id - liczba całkowita; klucz główny,
    name - ciąg znaków (max 30),
    value - liczba całkowita.

partycjonowanie po kluczu, 3 partycje.

Do tabeli wstaw następujące wiersze:

id	name	        value
1	iPhone 5C	    100
2	iPhone SE	    120
3	Zenfone 2	    200
4	Aquaris U	    180
5	Pixel C 	    390
6	One A9	        575
7	Le Max2	        80
8	Vibe Z2 Pro	    195
9	Moto G 4G	    440
10	Xperia Active	20
*/

CREATE TABLE devices
(
    id INT PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    value INT NOT NULL
)
PARTITION BY KEY()
PARTITIONS 3;

INSERT INTO devices VALUES
(1, 'iPhone 5C', 100),
(2,'iPhone SE', 120),
(3,'Zenfone 2', 200),
(4,'Aquaris U', 180),
(5,'Pixel C', 390),
(6,'One A9', 575),
(7,'Le Max2', 80),
(8,'Vibe Z2 Pro', 195),
(9,'Moto G 4G', 440),
(10,'Xperia Active', 20);

-- Wyświetl wszystkie dane znajdujące się w partycji p2 w tabeli devices.

SELECT *
FROM devices PARTITION (p2);

/*
W tabeli devices dodaj jedną partycję.

Następnie odśwież wartości w kolumnie TABLE_ROWS w 
tabeli INFORMATION_SCHEMA.PARTITIONS dla partycjonowania tabeli devices.
*/

ALTER TABLE devices
ADD PARTITION PARTITIONS 1;

ALTER TABLE devices ANALYZE PARTITION ALL;

/*
Z tabeli devices usuń dwie partycje.

Następnie odśwież wartości w kolumnie TABLE_ROWS w 
tabeli INFORMATION_SCHEMA.PARTITIONS dla partycjonowania tabeli devices.
*/

ALTER TABLE devices
COALESCE PARTITION 2;

ALTER TABLE devices ANALYZE PARTITION ALL;

-- Z tabeli devices usuń partycjonowanie.

ALTER TABLE devices REMOVE PARTITIONING;

-- 

CREATE TABLE employees
(
    emp_no     INT PRIMARY KEY,
    birth_date DATE NOT NULL,
    first_name VARCHAR(14) NOT NULL,
    last_name  VARCHAR(16) NOT NULL,
    gender     ENUM('M', 'F') NOT NULL,
    hire_date  DATE NOT NULL,
    address    VARCHAR(100) DEFAULT NULL
);

/*
W tabeli employees kluczem głównym jest kolumna emp_no. Naszym celem jest utworzenie partycjonowania zakresowego względem roku z kolumny hire_date:

    p1980 - rok wcześniejszy niż 1980,
    p2000 - rok wcześniejszy niż 2000,
    p2020 - rok wcześniejszy niż 2020,
    pmax - rok wcześniejszy niż maksymalna wartość.

Nasz klucz partycjonowania hire_date nie jest częścią klucza podstawowego tabeli (pojedyncza kolumna emp_no). W związku z tym jeśli od razu spróbujemy dodać partycjonowanie, to dostaniemy błąd:

ERROR 1503 (HY000): A PRIMARY KEY must include all columns in the table's partitioning function

Aby rozwiązać tę sytuację poszerzymy klucz główny tabeli.

Najpierw usuń klucz podstawowy tabeli, dodaj na nowo klucz główny składający się z emp_no i hire_date, a następnie dodaj ww. partycjonowanie.
*/

ALTER TABLE employees DROP PRIMARY KEY;

ALTER TABLE employees ADD PRIMARY KEY (emp_no, hire_date);

ALTER TABLE employees
PARTITION BY RANGE(YEAR(hire_date))
(
    PARTITION p1980 VALUES LESS THAN (1980),
    PARTITION p2000 VALUES LESS THAN (2000),
    PARTITION p2020 VALUES LESS THAN (2020),
    PARTITION pmax VALUES LESS THAN MAXVALUE
);

/*
Załóżmy, że w bazie bronx istnieje tabela alonzo, która została podzielona na partycje i subpartycje. 
Napisz polecenie SQL, które przy pomocy tabeli 
INFORMATION_SCHEMA.INNODB_TABLESPACES_BRIEF wyświetli lokalizacje 
wszystkich subpartycji tabeli alonzo.
*/

SELECT NAME, PATH
FROM INFORMATION_SCHEMA.INNODB_TABLESPACES_BRIEF
WHERE NAME LIKE '%/alonzo%'