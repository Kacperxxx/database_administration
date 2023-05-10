-- Przywróć dane z pliku my_backup.sql.

SOURCE my_backup.sql

-- Włącz zmienną systemową local_infile

SET GLOBAL local_infile = 1;

-- Przy pomocy polecenia LOAD DATA przywróć dane z pliku cars.csv do tabeli moto.cars

USE moto;


LOAD DATA LOCAL INFILE 'cars.csv'
INTO TABLE moto.cars
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

/*
Następujące zadanie wykonaj przy pomocy programu mysqlimport; do domyślnych parametrów dopisz niezbędne opcje w miejscu ....

Przywróć dane z pliku students.csv do tabeli school.students.
*/

mysqlimport --ignore-lines=1 --fields-terminated-by=, --local school students.csv

/*
Następujące zadania wykonaj przy pomocy programu mysqldump; do domyślnych parametrów dopisz niezbędne opcje w miejscu .... Wynik ma być zapisywany na standardowe wyjście.

Wykonaj kopię zapasową bazy school.
*/

mysqldump --compact --skip-comments --skip-opt --databases school

-- Wykonaj kopię zapasową tabeli students znajdującej się w bazie school.

mysqldump --compact --skip-comments --skip-opt school students

-- Wykonaj kopię zapasową tabeli students znajdującej się w bazie school, ale bez danych

mysqldump --compact --skip-comments --skip-opt --no-data school students

-- Wykonaj kopię zapasową tabeli students znajdującej się w bazie school, ale bez stuktury tabeli (tylko dane)

mysqldump --compact --skip-comments --skip-opt --no-create-info school students

/*
Przy pomocy mysqlpump stwórz kopię danych przechowywanych w tabelach bazy academy,
których nazwy zaczynają się na ye (użyj symboli wieloznacznych).
*/

mysqlpump --no-create-db --no-create-info --exclude-routines=grads --default-parallelism=1 --skip-tz-utc --skip-set-charset --skip-watch-progress --include-tables=ye% --include-databases=academy

-- Przy pomocy mysqlpump stwórz kopię poleceń CREATE USER i GRANT dotyczących użytkownika kyle

mysqlpump --default-parallelism=1 --skip-tz-utc --skip-set-charset --skip-watch-progress --exclude-databases=% --users --include-users=kyle

-- Przy pomocy mysqlpump stwórz kopię polecenia tworzącego procedurę grads() z bazy academy (pomiń element DEFINER).

mysqlpump --no-create-db --no-create-info --extended-insert=0 --default-parallelism=1 --skip-tz-utc --skip-set-charset --skip-watch-progress --skip-definer --include-routines=grads --exclude-tables=% --include-databases=academy

/*
Podobnie jak w poprzednim zadaniu, przy pomocy mysqlpump stwórz kopię polecenia tworzącego procedurę grads() z 
bazy academy (pomiń element DEFINER), ale tym razem zapisz wynik w 
pliku procdump.zlib kompresując go algorytmem zlib. 
Nie używaj przekierowania wyjścia > (użyj odpowiedniej opcji mysqlpump 
zapisującej wyjście do pliku).
*/

mysqlpump --no-create-db --no-create-info --extended-insert=0 --default-parallelism=1 --skip-tz-utc --skip-set-charset --skip-watch-progress --skip-definer --include-routines=grads --compress-output=ZLIB --exclude-tables=% --include-databases=academy --result-file=procdump.zlib