/*
Utwórz role o nazwach Adrianna, Joanna, Marianna, Zuzanna, odczyt i zapis. 
Cztery pierwsze role mają mieć możliwość logowania. Dwie ostatnie nie mają mieć tej możliwości.
*/

CREATE ROLE "Adrianna" LOGIN;
CREATE ROLE "Joanna" LOGIN;
CREATE ROLE "Marianna" LOGIN;
CREATE ROLE "Zuzanna" LOGIN;
CREATE ROLE odczyt;
CREATE ROLE zapis;

-- Ustaw możliwość tworzenia baz dla użytkownika Marianna. Wyłącz dziedziczenie uprawnień dla użytkownika Joanna

ALTER ROLE "Marianna" CREATEDB;
ALTER ROLE "Joanna" NOINHERIT;

-- Dodaj rolę Zuzanna do roli odczyt oraz rolę Joanna do roli zapis.

GRANT odczyt TO "Zuzanna";
GRANT zapis TO "Joanna";

-- Wyświetl informacje o rolach zawierające ich nazwę, atrybuty i członkostwo

\du

/*
Ustaw hasła dla ról:

rola	    hasło
Adrianna	atticatand
Joanna	    arenessing
Marianna	denzoareel
Zuzanna	    tieristong
*/

ALTER ROLE "Adrianna" PASSWORD 'atticatand';
ALTER ROLE "Joanna" PASSWORD 'arenessing';
ALTER ROLE "Marianna" PASSWORD 'denzoareel';
ALTER ROLE "Zuzanna" PASSWORD 'tieristong';

/*
(Zadanie wykonujesz po zalogowaniu z użyciem roli Marianna.)

Napisz polecenia PostgreSQL, które utworzą bazę o nazwie secret_data, 
zmienią aktualnie wybraną bazę na secret_data, a następnie umieszczą w niej dwie tabele z danymi, 
tj. movies oraz beers (każda kolumna, poza kluczem głównym tabeli, może przyjmować wartość NULL).

tabela movies:
    id - liczba całkowita, klucz główny,
    title - tekst,
    genre - tekst,
    year - liczba całkowita,
    runtime - liczba całkowita.

tabela beers:
    id - liczba całkowita, klucz główny,
    name - tekst,
    brewery - tekst,
    style - tekst,
    plato - liczba rzeczywista.

Zawartość movies:

id	title	        genre	year	runtime
7	Memento	        Mystery	2000	113
11	Edi	            Drama	2002	97
13	Piętro Wyżej	Comedy	1937	84

Zawartość beers:

id	name	        brewery	    style	            plato
2	Atomowy Morświn	Golem	    Kveik Farmhouse IPA	15.5
4	Furia Ferworu	Harpagan	Baltic Porter	    33
8	Bździągwa	    Szałpiw	    Belgian Ale	        13
*/

SET ROLE "Marianna";

CREATE DATABASE secret_data;
\c secret_data

CREATE TABLE movies
(
    id INT PRIMARY KEY,
    title TEXT,
    genre TEXT,
    "year" INT,
    runtime INT
);

CREATE TABLE beers
(
    id INT PRIMARY KEY,
    "name" TEXT,
    brewery TEXT,
    style TEXT,
    plato FLOAT
);


INSERT INTO movies VALUES 
(7, 'Memento', 'Mystery', 2000, 113),
(11, 'Edi', 'Drama', 2002, 97),
(13, 'Piętro Wyżej', 'Comedy', 1937, 84);

INSERT INTO beers VALUES 
(2, 'Atomowy Morświn', 'Golem', 'Kveik Farmhouse IPA', 15.5),
(4, 'Furia Ferworu', 'Harpagan', 'Baltic Porter', 33),
(8, 'Bździągwa', 'Szałpiw', 'Belgian Ale', 13);


/*
(Zadanie wykonujesz po zalogowaniu z użyciem roli Marianna do bazy secret_data.)

Nadaj rolom odczyt, zapis i Joanna prawo do łączenia się z bazą secret_data.
*/

SET ROLE "Marianna";
\c secret_data

GRANT CONNECT ON DATABASE secret_data TO odczyt;
GRANT CONNECT ON DATABASE secret_data TO zapis;
GRANT CONNECT ON DATABASE secret_data TO "Joanna";

/*
(Zadanie wykonujesz po zalogowaniu z użyciem roli Marianna do bazy secret_data.)

Wyświetl informacje o uprawnieniach do bazy secret_data (i tylko dla niej).
*/

\l secret_data

/*
(Zadanie wykonujesz po zalogowaniu z użyciem roli Marianna z bazą secret_data.)

Nadaj roli odczyt prawo do wykonywania SELECT na obu tabelach w bazie. 
Nadaj roli zapis prawo do wykonywania SELECT, INSERT, UPDATE i DELETE na obu tabelach w bazie.
*/

GRANT SELECT ON movies, beers TO odczyt;

GRANT SELECT, INSERT, UPDATE, DELETE ON movies, beers TO zapis;


/*
(Zadanie wykonujesz po zalogowaniu z użyciem roli Marianna z bazą secret_data.)

Wyświetl uprawnienia wszystkich tabel w bazie.
*/

\dp

-- Zalogowałeś(-aś) się z użyciem roli Zuzanna do bazy secret_data. Wyświetl zawartość tabeli movies.

select * from movies;

/*
Zalogowałeś(-aś) się z użyciem roli Joanna do bazy secret_data. 
Do tabeli movies dodaj nowy wiersz zawierający dane: 17, Loving Vincent, Animation, 2017, 94.
*/

SET ROLE zapis;

INSERT INTO movies VALUES
(17, 'Loving Vincent', 'Animation', 2017, 94);

/*
(Zadanie wykonujesz po zalogowaniu z użyciem roli Marianna z bazą secret_data.)

Zmień domyślne uprawnienia w bazie w taki sposób aby rola odczyt miała prawo do wykonywania SELECT we wszystkich nowych tabelach.
*/

ALTER DEFAULT PRIVILEGES GRANT SELECT ON TABLES TO odczyt;

/*
(To zadanie i wszystkie kolejne wykonywane są jako rola z atrybutem SUPERUSER)

Odbierz roli Joanna prawo do łączenia się z bazą secret_data.
*/

REVOKE CONNECT ON DATABASE secret_data FROM "Joanna";

-- Odbierz roli Joanna członkostwo w roli zapis.

REVOKE zapis FROM "Joanna";

-- Usuń rolę Joanna.

DROP ROLE "Joanna";

