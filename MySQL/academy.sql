DROP DATABASE IF EXISTS academy;
CREATE DATABASE academy;

USE academy;

CREATE TABLE profs (x INT);
CREATE TABLE studs (x INT);
CREATE TABLE ye19 (x INT);
CREATE TABLE ye20 (x INT);
CREATE TABLE ye21 (x INT);
CREATE TABLE ye22 (x INT);

INSERT INTO profs VALUES (1);
INSERT INTO studs VALUES (1);
INSERT INTO ye19 VALUES (1);
INSERT INTO ye20 VALUES (1);
INSERT INTO ye21 VALUES (1);
INSERT INTO ye22 VALUES (1);

DELIMITER //

CREATE PROCEDURE grads()
BEGIN
    SELECT * FROM studs;
END//

DELIMITER ;

DROP USER IF EXISTS 'kyle'@'%';

CREATE USER 'kyle'@'%'
IDENTIFIED WITH auth_socket;

GRANT SELECT, INSERT, UPDATE
   ON academy.*
   TO 'kyle'@'%';
