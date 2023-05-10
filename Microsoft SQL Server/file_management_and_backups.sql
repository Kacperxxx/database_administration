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


/*
Dodaj 2 pliki danych do głównej grupy plików bazy university o następujących parametrach:

nazwa, ścieżka, rozmiar, rozrost
university_2, /var/opt/mssql/data/university_2.ndf,	1MB, 8MB
university_3, /var/opt/mssql/data/university_3.ndf,	1MB, 8MB
*/

ALTER DATABASE university
ADD FILE
(
  NAME = 'university_2',
  SIZE = 1MB,
  FILEGROWTH = 8MB,
  FILENAME = '/var/opt/mssql/data/university_2.ndf'
)
TO FILEGROUP [PRIMARY];

ALTER DATABASE university
ADD FILE
(
  NAME = 'university_3',
  SIZE = 1MB,
  FILEGROWTH = 8MB,
  FILENAME = '/var/opt/mssql/data/university_3.ndf'
)
TO FILEGROUP [PRIMARY];


-- Zmień maksymalny rozmiar pliku danych university_2 na 3GB

ALTER DATABASE university
MODIFY FILE
(
  NAME = 'university_2',
  MAXSIZE = 3GB
);

/*
Napisz zapytanie Transact-SQL wyświetlające stan plików danych zawierający następujące informacje:

    - identyfikator grupy plików danych
    - maksymalny rozmiar
    - nazwę pliku danych
    - ścieżkę pliku danych
    - rozmiar
*/

USE university;
SELECT data_space_id, size, max_size, name, physical_name
FROM sys.database_files
WHERE data_space_id = 1;

/*
Dodaj grupę plików danych o nazwie gpd1 do bazy university zawierającą następujące pliki danych:

nazwa, ścieżka, rozmiar, rozrost
university_gpd1_1, /var/opt/mssql/data/university_gpd1_1.ndf, 8MB, 16MB
university_gpd1_2, /var/opt/mssql/data/university_gpd1_2.ndf, 8MB, 16MB
*/

ALTER DATABASE university
ADD FILEGROUP gpd1;

ALTER DATABASE university
ADD FILE
(
  NAME = 'university_gpd1_1',
  SIZE = 8MB,
  FILEGROWTH = 16MB,
  FILENAME = '/var/opt/mssql/data/university_gpd1_1.ndf'
)
TO FILEGROUP gpd1;

ALTER DATABASE university
ADD FILE
(
  NAME = 'university_gpd1_2',
  SIZE = 8MB,
  FILEGROWTH = 16MB,
  FILENAME = '/var/opt/mssql/data/university_gpd1_2.ndf'
)
TO FILEGROUP gpd1;

/*
Utwórz tabelę o następującej specyfikacji i przypisz ją do grupy plików danych gpd1 w bazie university:

tabela courses:
    - id - liczba całkowita, klucz główny,
    - name - ciąg znaków (max 50),
*/

USE university;
CREATE TABLE courses
(
    id INT PRIMARY KEY,
    name VARCHAR(50)
)
ON gpd1;

/*
Dodaj 2 pliki logów do bazy university o następujących parametrach:

nazwa, ścieżka, rozmiar, maksymalny, rozmiar, rozrost
university_log_2, /var/opt/mssql/data/university_log_2.ldf, 1MB, 2GB, 16MB
university_log_3, /var/opt/mssql/data/university_log_3.ldf, 1MB, 2GB, 16MB
*/


ALTER DATABASE university
ADD LOG FILE
(
  NAME = 'university_log_2',
  SIZE = 1MB,
  MAXSIZE = 2GB,
  FILEGROWTH = 16MB,
  FILENAME = '/var/opt/mssql/data/university_log_2.ldf'
);


ALTER DATABASE university
ADD LOG FILE
(
  NAME = 'university_log_3',
  SIZE = 1MB,
  MAXSIZE = 2GB,
  FILEGROWTH = 16MB,
  FILENAME = '/var/opt/mssql/data/university_log_3.ldf'
);


-- Usuń plik logu university_log_3 z bazy university.

ALTER DATABASE university
REMOVE FILE university_log_3;


/*
Napisz zapytanie Transact-SQL wyświetlające stan plików logów zawierający następujące informacje:

    - maksymalny rozmiar
    - nazwę pliku danych
    - ścieżkę pliku danych
    - rozmiar
*/

USE university;
SELECT size, max_size, name, physical_name
FROM sys.database_files
WHERE type_desc = 'LOG';

/*
Utwórz pełną kopię zapasową bazy university o nazwie university Full 
do zestawu nośników składającego się z jednego urządzenia będącego plikiem 
na dysku o ścieżce /var/opt/mssql/data/university.bak
*/

BACKUP DATABASE university
    TO DISK = '/var/opt/mssql/data/university.bak'
    WITH
        NOFORMAT,
        NAME = 'university Full';

/*
Dodaj do tabeli courses w bazie university wiersz:

id	name
2	Administracja Bazami Danych 2

A następnie utwórz kopię zapasową logu bazy university o nazwie university Log do zestawu nośników użytego w poprzednich zadaniach.
*/

USE university;

INSERT INTO courses VALUES
(2, 'Administracja Bazami Danych 2');

BACKUP LOG university
    TO DISK = '/var/opt/mssql/data/university.bak'
    WITH
        NOFORMAT,
        NAME = 'university Log';

/*
Przywróć tylko pełną kopię zapasową bazy university 
znajdującą się w zestawie nośników użytym w poprzednim zadaniu o ścieżce /var/opt/mssql/data/university.bak.
*/

RESTORE DATABASE university
    FROM DISK = '/var/opt/mssql/data/university.bak'
    WITH
        FILE = 1,
        REPLACE;


-- Zmień model odzyskiwania bazy university na SIMPLE

ALTER DATABASE university
SET RECOVERY SIMPLE;

-- Napisz zapytanie Transact-SQL wyświetlające aktualny model odzyskiwania dla bazy university.

SELECT name, recovery_model_desc  
FROM sys.databases
WHERE name = 'university';