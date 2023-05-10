/*
Utwórz rolę abd11 z hasłem ttrarchnic oraz rolę limited z hasłem ivingensly. 
Role mają mieć możliwość logowania. 
Utwórz bazę abd11, której właścicielem będzie abd11
*/

CREATE ROLE abd11 LOGIN PASSWORD 'ttrarchnic';
CREATE ROLE limited LOGIN PASSWORD 'ivingensly';

CREATE DATABASE abd11 OWNER abd11;

-- Ustaw ważność hasła roli limited do 2020-07-15 00:00:01

ALTER ROLE limited VALID UNTIL '2020-07-15 00:00:01';

-- Napisz zapytanie SQL zwracające kolumnę o nazwie valid z wartością logiczną, która mówi czy minął termin ważności hasła roli limited

SELECT 
    CASE 
        WHEN valuntil > NOW() THEN 't'
        ELSE 'f'
        END AS valid
    FROM pg_user
    WHERE usename = 'limited';

-- Ustaw limit połączeń dla roli limited na wartość 10.

ALTER ROLE limited  CONNECTION LIMIT 10;

-- Wyświetl limity połączeń ról abd11 i limited.

SELECT rolname, rolconnlimit FROM pg_roles WHERE rolname IN ('abd11', 'limited');

-- Wyświetl nazwy ról połączonych z serwerem oraz liczbę połączeń każdej roli. Wyniki posortuj po usename

SELECT usename, COUNT(*) AS num
FROM pg_stat_activity 
WHERE usename IS NOT NULL
GROUP BY usename;

-- Przełącz się na bazę abd11 i utwórz w niej schematy abd11 i limited, których właścicielem będzie abd11.

\c abd11

CREATE SCHEMA abd11 AUTHORIZATION abd11;
CREATE SCHEMA limited AUTHORIZATION abd11;

-- Zmień właściciela schematu public na abd11.

ALTER SCHEMA public OWNER TO abd11;

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

W schemacie public utwórz tabelę uczestnicy z kolumną email, 
która będzie zawierała tekst.
*/

CREATE TABLE public.uczestnicy
(
    email TEXT
);

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

Wyświetl schematy w bazie.
*/

\dn

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

Wyświetl zmienną przechowującą ustawienia ścieżki przeszukiwania.
*/

SHOW search_path;

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

Zmodyfikuj ścieżkę przeszukiwania tak, aby nowe obiekty były 
tworzone w schemacie public. Schemat odpowiadający 
nazwie roli powinien być przeszukiwany jako następny po public
*/

SET search_path TO public, "$user";

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

Dodaj do wcześniej utworzonej tabeli wiersz osoba@adres.tld
*/

INSERT INTO public.uczestnicy VALUES
('osoba@adres.tld');

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

Zmodyfikuj uprawnienia schematu public w taki sposób, 
aby rola limited nie miała do niego żadnych uprawnień. 
Zmodyfikuj uprawnienia schematu limited nadając roli limited prawo USAGE.
*/

REVOKE ALL PRIVILEGES ON SCHEMA public FROM public;

GRANT USAGE ON SCHEMA limited TO limited;

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

W schemacie limited zdefiniuj funkcję liczba_uczestnikow, 
która umożliwi roli limited odczytanie liczby wierszy 
w tabeli uczestnicy
*/

CREATE FUNCTION limited.liczba_uczestnikow()
returns integer AS
$func$
declare num integer;
BEGIN 
    SELECT count(*) into num from uczestnicy;
    return num;
END;
$func$
language plpgsql
SECURITY DEFINER

/*
(Zadanie wykonujesz po połączeniu z bazą abd11 z użyciem roli abd11.)

Usuń schemat public.
*/

DROP SCHEMA public CASCADE;