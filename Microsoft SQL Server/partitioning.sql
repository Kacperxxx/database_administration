/*
Napisz polecenia Transact-SQL, które utworzą bazę danych sklep oraz skonfigurują grupy plików w następujący sposób:

nazwa grupy plików	nazwa pliku w grupie	ścieżka pliku w grupie
FG1	sklep_fg1	/var/opt/mssql/data/sklep_fg1.ndf
FG2	sklep_fg2	/var/opt/mssql/data/sklep_fg2.ndf
FG3	sklep_fg3	/var/opt/mssql/data/sklep_fg3.ndf
FG4	sklep_fg4	/var/opt/mssql/data/sklep_fg4.ndf

Pozostałe parametry grup i plików w grupach powinny pozostać domyślne. Grupa plików PRIMARY nie powinna być modyfikowana.
*/

CREATE DATABASE sklep;

ALTER DATABASE sklep ADD FILEGROUP FG1;

ALTER DATABASE sklep ADD FILEGROUP FG2;

ALTER DATABASE sklep ADD FILEGROUP FG3;

ALTER DATABASE sklep ADD FILEGROUP FG4;

ALTER DATABASE sklep
ADD FILE
(
  NAME = 'sklep_fg1',
  FILENAME = '/var/opt/mssql/data/sklep_fg1.ndf'
)
TO FILEGROUP FG1;

ALTER DATABASE sklep
ADD FILE
(
  NAME = 'sklep_fg2',
  FILENAME = '/var/opt/mssql/data/sklep_fg2.ndf'
)
TO FILEGROUP FG2;

ALTER DATABASE sklep
ADD FILE
(
  NAME = 'sklep_fg3',
  FILENAME = '/var/opt/mssql/data/sklep_fg3.ndf'
)
TO FILEGROUP FG3;

ALTER DATABASE sklep
ADD FILE
(
  NAME = 'sklep_fg4',
  FILENAME = '/var/opt/mssql/data/sklep_fg4.ndf'
)
TO FILEGROUP FG4;

/*
Dodaj w bazie danych sklep funkcję partycjonowania fn_zakresy_punktowe operującą na kolumnie typu INT 
tworzącą 3 partycję według poniższych punktów brzegowych. Wartości brzegowe powinny być przypisane 
do partycji po prawej stronie punktów brzegowych.

    - 100
    - 1000
*/

CREATE PARTITION FUNCTION fn_zakresy_punktowe(INT)
AS RANGE RIGHT
FOR VALUES
(
  100,
  1000
);

/*
Napisz zapytanie Transact-SQL wyświetlające następujące informację o funkcjach partycjonowania zdefiniowanych w bazie danych sklep:

    - nazwa funkcji partycjonowania
    - liczba tworzonych partycji
    - informacja o zachowaniu wartości granicznych
*/

SELECT name, fanout, boundary_value_on_right
FROM sys.partition_functions;

/*
Napisz zapytanie Transact-SQL wyświetlające następujące informację o punktach granicznych w funkcjach partycjonowania zdefiniowanych w bazie sklep:

    - nazwa funkcji partycjonowania
    - wartość punktu granicznego

Uwaga: dokonaj konwersji wynikowej kolumny value z widoku sys.partition_range_values na typ VARCHAR(100)
za pomocą operatora CAST. Pamiętaj o zachowaniu nazwy kolumny value.
*/

SELECT p.name, CAST(r.value AS VARCHAR(100)) AS 'value'
FROM sys.partition_range_values as r
  JOIN sys.partition_functions as p
    ON r.function_id = p.function_id
WHERE
  p.name IN (SELECT name FROM sys.partition_functions);


/*
Dodaj do bazy danych sklep schemat partycjonowania s_zakresy_punktowe używający 
funkcji partycjonowania fn_zakresy_punktowe z rozdziałem partycji do grup plików FG1, FG2 oraz FG3:
*/

CREATE PARTITION SCHEME s_zakresy_punktowe
AS PARTITION fn_zakresy_punktowe
TO (FG1, FG2, FG3);

/*
Napisz zapytanie Transact-SQL wyświetlające następujące informacje o schematach partycjonowania zdefiniowanych w bazie danych sklep:

    - nazwa schematu partycjonowania
    - opis typu obiektu
*/

SELECT name, type_desc
FROM sys.partition_schemes;

/*
Napisz zapytanie Transact-SQL wyświetlające następujące informacje o schematach partycjonowania zdefiniowanych w bazie sklep:

    - nazwa schematu partycjonowania jako NazwaSchematu
    - zmapowane grupy plików jako NazwaGrupy

Wynik powninien zawierać tyle wierszy, ile zmapowano grup plików do każdego schematu partycjonowania.
*/

SELECT
  p.name AS 'NazwaSchematu',
  sp.name as 'NazwaGrupy'
FROM sys.destination_data_spaces as d
  JOIN sys.data_spaces as sp
    ON d.data_space_id = sp.data_space_id
  JOIN sys.partition_schemes as p
    ON p.data_space_id = d.partition_scheme_id

/*
Napisz polecenia Transact-SQL, które utworzą tabelę program_lojalnosciowy w bazie danych sklep używającą 
schematu partycjonowania s_zakresy_punktowe opartego o kolumnę punkty, o następującej strukturze i zawartości:

1. tabela program_lojalnosciowy:
    id - liczba całkowita
    imie - ciąg znaków (max 50),
    nazwisko - ciąg znaków (max 50),
    email - ciąg znaków (max 50)
    punkty - liczba całkowita
*/

USE sklep;

CREATE TABLE program_lojalnosciowy
(
  id              INT,
  imie            VARCHAR(50),
  nazwisko        VARCHAR(50),
  email           VARCHAR(50),
  punkty          INT
)
ON s_zakresy_punktowe(punkty);

INSERT INTO program_lojalnosciowy VALUES
(1, 'Belladonna', 'Sandheaver', 'BelladonnaSandheaver@jourrapide.com', 77),
(2, 'Fredegar', 'Greenhand', 'FredegarGreenhand@teleworm.us', 543),
(3, 'Diamanda', 'Goodchild', 'DiamandaGoodchild@dayrep.com', 1780),
(4, 'Tayla', 'Fairley', 'TaylaFairley@armyspy.com', 157);

/*
Napisz zapytanie Transact-SQL wyświetlające następujące informacje o podziale wierszy na partycje w tabeli program_lojalnosciowy:

    numer partycji jako Partycja
    liczba wierszy w partycji jako Wiersze
*/

SELECT
  COUNT(*) AS 'Wiersze',
  $PARTITION.fn_zakresy_punktowe(punkty) AS 'Partycja'
FROM program_lojalnosciowy
GROUP BY $PARTITION.fn_zakresy_punktowe(punkty);


-- Napisz zapytanie Transact-SQL wyświetlające wszystkie wiersze zawarte w drugiej partycji tabeli program_lojalnosciowy

SELECT *
FROM   program_lojalnosciowy
WHERE  $PARTITION.fn_zakresy_punktowe(punkty) = 2;

/*
Napisz zapytania Transact-SQL, które dodadzą nowy punkt graniczny o wartości 500 do funkcji 
partycjonowania fn_zakresy_punktowe w bazie danych sklep.

Użyj wcześniej utworzonej, ale nieużywanej, grupy plików do rozbudowy schematu partycjonowania.
*/

USE sklep;

ALTER PARTITION SCHEME s_zakresy_punktowe
NEXT USED FG4;

ALTER PARTITION FUNCTION fn_zakresy_punktowe()
SPLIT RANGE (500);

-- Napisz zapytanie Transact-SQL, które usunie punkt graniczny o wartości 1000 z funkcji partycjonowania fn_zakresy_punktowe w bazie danych sklep

ALTER PARTITION FUNCTION fn_zakresy_punktowe()
MERGE RANGE (1000);

/*
Napisz zapytania Transact-SQL, które doprowadzą do usunięcia funkcji partycjonowania fn_zakresy_punktowe w bazie danych sklep.

Pamiętaj o zależnościach między obiektami i odpowiedniej kolejności poleceń!
*/

USE sklep;

drop table program_lojalnosciowy;

DROP PARTITION SCHEME s_zakresy_punktowe;

DROP PARTITION FUNCTION fn_zakresy_punktowe;