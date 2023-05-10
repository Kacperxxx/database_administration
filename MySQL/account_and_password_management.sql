CREATE USER   'root'@'%'
IDENTIFIED BY 'Pa$sw0rd';

GRANT ALL
   ON *.*
   TO 'root'@'%'
 WITH GRANT OPTION;

GRANT PROXY
   ON ''@''
   TO 'root'@'%' 
 WITH GRANT OPTION;


 /*
Zainstaluj na serwerze wtyczkę uwierzytelniającą mysql_no_login. 
(Uwaga: możliwe, że na Twojej maszynie jest ona już zainstalowana i włączona.)
 */

 INSTALL PLUGIN mysql_no_login SONAME 'mysql_no_login.so';

--  Sprawdź czy wtyczka mysql_no_login jest zainstalowana i aktywna.

SELECT PLUGIN_NAME, PLUGIN_STATUS
FROM   INFORMATION_SCHEMA.PLUGINS
WHERE  PLUGIN_NAME LIKE 'mysql_no_login';

-- Włącz zmienne systemowe check_proxy_users i mysql_native_password_proxy_users.

SET PERSIST check_proxy_users = ON;
SET PERSIST mysql_native_password_proxy_users = ON;

-- Sprawdź wartość zmiennych systemowych check_proxy_users i mysql_native_password_proxy_users.

SHOW VARIABLES
WHERE Variable_name LIKE "check_proxy_users" OR Variable_name LIKE 'mysql_native_password_proxy_users';

/*
Utwórz bazę o nazwie factory, zmień kontekst sesji na tę bazę, 
utwórz tabelę secrets o jednej kolumnie control_pin zawierającej 
liczby całkowite; do tabeli wstaw jeden wiersz o wartości 1337.

Następnie utwórz użytkowników 'worker_a'@'%', 'worker_b'@'%' 
i 'worker_c'@'%', którzy uwierzytelniają się przy pomocy hasła 
p@s$w0rd i wtyczki mysql_native_password. Następnie utwórz 
użytkownika 'super_worker'@'%', który uwierzytelnia się przy 
pomocy wtyczki mysql_no_login
*/

CREATE DATABASE factory;

USE factory;

CREATE TABLE secrets
(
    control_pin INT
);

INSERT INTO secrets VALUES (1337);

CREATE USER 'worker_a'@'%'
IDENTIFIED WITH mysql_native_password BY 'p@s$w0rd';

CREATE USER 'worker_b'@'%'
IDENTIFIED WITH mysql_native_password BY 'p@s$w0rd';
            
CREATE USER 'worker_c'@'%'
IDENTIFIED WITH mysql_native_password BY 'p@s$w0rd';
            
CREATE USER 'super_worker'@'%'
IDENTIFIED WITH mysql_no_login;

-- Nadaj użytkownikowi 'super_worker'@'%' uprawnienia SELECT i EXECUTE w bazie factory.

GRANT SELECT, EXECUTE
ON factory.*
TO 'super_worker'@'%';

-- Sprawdź czy użytkownik 'super_worker'@'%' ma nadane uprawnienia SELECT i EXECUTE w bazie factory

SELECT User, Host, Db, Select_priv, Execute_priv
FROM mysql.db
WHERE Db LIKE 'factory' AND User LIKE 'super_worker'

SELECT User, Host, Db, Select_priv, Execute_priv
FROM mysql.db
WHERE Db LIKE 'factory' AND User LIKE 'super_worker'

-- Nadaj uprawnienie PROXY użytkownikowi 'worker_c'@'%' względem 'super_worker'@'%'

GRANT PROXY
   ON 'super_worker'@'%'
   TO 'worker_c'@'%';

-- Wyświetl jakie uprawnienia PROXY ma przyznane użytkownik 'worker_c'@'%'

SELECT User, Host, Proxied_user, Proxied_host, With_grant
FROM mysql.proxies_priv
WHERE User LIKE 'worker_c';

/*
Utwórz procedurę show_workers(), 
która wyświetla nazwy użytkowników zaczynające sie od worker; 
jako DEFINER ustaw 'root'@'%', a jako SQL SECURITY ustaw DEFINER.

Swoją odpowiedź wstaw w miejscu ..., a polecenie definujące procedurę 
zakończ END// zamiast END; (ustawienia delimiter są spowodowane tym w 
jaki sposób klient mysql parsuje polecenia tworzące procedury);
*/

delimiter //

CREATE DEFINER = 'root'@'%'
PROCEDURE show_workers()
SQL SECURITY DEFINER
BEGIN
    SELECT User FROM mysql.user WHERE User LIKE "worker%";
END//

delimiter ;

/*
Wyświetl metadane procedury show_workers() dotyczące DEFINER i SQL SECURITY. 
Użyj informacji zawartych w tabeli INFORMATION_SCHEMA.ROUTINES
*/

SELECT SPECIFIC_NAME, DEFINER, SECURITY_TYPE
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE SPECIFIC_NAME LIKE 'show_workers';

/*
Utwórz procedurę show_vault_pin(), która wyświetla zawartość 
tabeli secrets; jako DEFINER ustaw 'super_worker'@'%', 
a jako SQL SECURITY ustaw INVOKER.

Swoją odpowiedź wstaw w miejscu ..., a polecenie definujące 
procedurę zakończ END// zamiast END; (ustawienia delimiter są 
spowodowane tym w jaki sposób klient mysql parsuje polecenia 
tworzące procedury);
*/

delimiter //

CREATE DEFINER = 'super_worker'@'%'
PROCEDURE show_vault_pin()
SQL SECURITY INVOKER
BEGIN
    SELECT * FROM secrets;
END//

delimiter ;

/*
Wyświetl metadane procedury show_vault_pin() dotyczące DEFINER i SQL SECURITY. 
Użyj informacji zawartych w tabeli INFORMATION_SCHEMA.ROUTINES.
*/

SELECT SPECIFIC_NAME, DEFINER, SECURITY_TYPE
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE SPECIFIC_NAME LIKE 'show_vault_pin';

-- Wygaś hasło użytkownikowi 'worker_a'@'%'.

ALTER USER 'worker_a'@'%'
PASSWORD EXPIRE;

-- Wyświetl użytkowników z wygaszonym hasłem.

SELECT User, Host, password_expired
FROM mysql.user
WHERE password_expired LIKE 'Y';

-- Zablokuj konto 'worker_a'@'%'

ALTER USER 'worker_a'@'%'
ACCOUNT LOCK;

-- Wyświetl zablokowane konta (tylko host %).

SELECT User, Host, account_locked
FROM mysql.user
WHERE account_locked LIKE 'Y' AND Host LIKE '\%';

/*
Zmień użytkownikowi 'worker_b'@'%' maksymalną liczbę poleceń UPDATE na godzinę na 10, 
historię haseł na 5, liczbę nieudanych logowań na 3 oraz blokadę konta na 3 dni w 
przypadku nieudanych logowań.
*/

ALTER USER   'worker_b'@'%'
        WITH MAX_UPDATES_PER_HOUR 10
            PASSWORD HISTORY 5
            FAILED_LOGIN_ATTEMPTS 3
            PASSWORD_LOCK_TIME 3;

/*
Dla konta 'worker_b'@'%' wyświetl maksymalną liczbę poleceń UPDATE na godzinę, historię haseł, 
maksymalną liczbę nieudanych logowań oraz liczbę dni gdy konto zostanie 
zablokowane w przypadku nieudanych logowań. Użyj wierszy przechowywanych 
w tabeli mysql.user (zauważ, że będzie trzeba dostać się do wartości 
przechowywanych jako JSON; może przydać się operator ->>). 
Swoje polecenie SELECT zakończ \G
*/

SELECT User, 
    Host,
    Password_reuse_history,
    Password_reuse_time,
    Password_require_current,
    User_attributes->>'$.Password_locking.failed_login_attempts' AS failed_login_attempts,
    User_attributes->>'$.Password_locking.password_lock_time_days' AS password_lock_time_days,
    max_questions,
    max_updates, 
    max_connections,  
    max_user_connections
FROM mysql.user
WHERE User LIKE 'worker_b'\G

/*
(Zadanie wykonaj jako zalogowany użytkownik 'worker_c'@'%'.)

    1. Wyświetl wartość funkcji CURRENT_USER() i zawartość zmiennej @@proxy_user.
    2. Zmień bazę na factory.
    3. Następnie wywołaj funkcję show_workers().
    4. Ostatecznie wywołaj funkcję show_vault_pin()
*/

SELECT CURRENT_USER(), @@proxy_user;

USE factory;

CALL show_workers();
CALL show_vault_pin();

