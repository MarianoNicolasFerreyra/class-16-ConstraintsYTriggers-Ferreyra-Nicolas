USE sakila;

CREATE TABLE `employees` (
  `employeeNumber` int(11) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `extension` varchar(10) NOT NULL,
  `email` varchar(100) NOT NULL,
  `officeCode` varchar(10) NOT NULL,
  `reportsTo` int(11) DEFAULT NULL,
  `jobTitle` varchar(50) NOT NULL,
  PRIMARY KEY (`employeeNumber`)
);

INSERT INTO employees VALUES
(1002, 'Murphy', 'Diane', 'x5800', 'dmurphy@classicmodelcars.com', '1', NULL, 'President');

INSERT INTO employees VALUES
(1056, 'Patterson', 'Mary', 'x4611', 'mpatterso@classicmodelcars.com', '1', 1002, 'VP Sales');

INSERT INTO employees VALUES
(1076, 'Firrelli', 'Jeff', 'x9273', 'jfirrelli@classicmodelcars.com', '1', 1002, 'VP Marketing');

SELECT * FROM employees;

/*
EJERCICIO 1

Consigna:
Insertar un nuevo empleado, pero con un email NULL.
Explicar qué sucede.
*/

INSERT INTO employees (employeeNumber,lastName,firstName,extension,email,officeCode,reportsTo,jobTitle)
VALUES (1100,'Del Gesso Quijote','Pedro','x6767',NULL,'1',1002,'Sales Rep');

/*
El insert es rechazado xq email no puede ser null.
 Por esto, no se puede guardar
un empleado con un email null.
*/


/*
EJERCICIO 2

Consigna:
Ejecutar la primera consulta y explicar qué sucede.
Después, ejecutar la segunda consulta y explicar también ese caso.
*/

UPDATE employees
SET employeeNumber = employeeNumber - 20;

/*
La consulta se ejecuta correctamente y resta 20 al número
de cada empleado:

1002 pasa a 982.
1056 pasa a 1036.
1076 pasa a 1056.
*/

UPDATE employees
SET employeeNumber = employeeNumber + 20;

/*
La segunda consulta tirq un error de clave primaria duplicada.
Cuando intenta cambiar 1036 por 1056, todavía existe
otro empleado con el número 1056. Como employeeNumber es una
pk, no permite valores repetidos.
*/


/*
EJERCICIO 3

Consigna:
Agregar una columna age a la tabla employees, la cual solamente
pueda aceptar edades desde los 16 hasta los 70 años.
*/

ALTER TABLE employees
ADD COLUMN age int NOT NULL DEFAULT 18,
ADD CONSTRAINT chk_employee_age
CHECK (age BETWEEN 16 AND 70);


/*
EJERCICIO 4

Consigna:
Describir la integridad referencial entre las tablas film,
actor y film_actor de la base de datos Sakila.
*/

/*
Las tablas film y actor tienen una relación de muchos a muchos
mediante la tabla film_actor.

actor.actor_id es referenciado por film_actor.actor_id.
film.film_id es referenciado por film_actor.film_id.

La clave primaria de film_actor está formada por actor_id y film_id.
Esto evita repetir la misma relación entre un actor y una película.

Las claves foráneas impiden relacionar actores o películas que no
existan. También utilizan ON DELETE RESTRICT para impedir que se
elimine un actor o una película que tenga relaciones registradas,
y ON UPDATE CASCADE para actualizar automáticamente las referencias
si cambia alguno de sus identificadores.
*/


/*
EJERCICIO 5

Consigna:
Crear una columna llamada lastUpdate en la tabla employees y
utilizar triggers para mantener actualizadas la fecha y la hora
en las operaciones INSERT y UPDATE.

Bonus:
Agregar una columna lastUpdateUser y los triggers correspondientes
para indicar cuál fue el último usuario de MySQL que modificó la fila.
*/

ALTER TABLE employees
ADD COLUMN lastUpdate DATETIME,
ADD COLUMN lastUpdateUser VARCHAR(288);

DELIMITER $$

CREATE TRIGGER before_employees_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
    SET NEW.lastUpdateUser = USER();
END$$

CREATE TRIGGER before_employees_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.lastUpdate = NOW();
    SET NEW.lastUpdateUser = USER();
END$$

DELIMITER ;


/*
EJERCICIO 6

Consigna:
Encontrar todos los triggers de la base de datos Sakila relacionados
con la carga de la tabla film_text. Explicar qué hace cada uno
utilizando su código fuente.
*/

/*
SELECT
    TRIGGER_NAME,
    EVENT_MANIPULATION,
    ACTION_TIMING,
    EVENT_OBJECT_TABLE,
    ACTION_STATEMENT
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'sakila'
  AND ACTION_STATEMENT LIKE '%film_text%';
*/

/*
TRIGGER ins_film

CREATE TRIGGER ins_film
AFTER INSERT ON film
FOR EACH ROW
BEGIN
    INSERT INTO film_text (film_id, title, description)
    VALUES (NEW.film_id, NEW.title, NEW.description);
END;

Se ejecuta después de insertar una película en film.
Copia su identificador, título y descripción en film_text.
*/


/*
TRIGGER upd_film

CREATE TRIGGER upd_film
AFTER UPDATE ON film
FOR EACH ROW
BEGIN
    IF (OLD.title != NEW.title)
       OR (OLD.description != NEW.description)
       OR (OLD.film_id != NEW.film_id)
    THEN
        UPDATE film_text
        SET title = NEW.title,
            description = NEW.description,
            film_id = NEW.film_id
        WHERE film_id = OLD.film_id;
    END IF;
END;

Se ejecuta después de modificar una película. Compara los datos
anteriores con los nuevos. Si cambia el identificador, el título
o la descripción, actualiza el registro correspondiente en film_text.
*/


/*
TRIGGER del_film

CREATE TRIGGER del_film
AFTER DELETE ON film
FOR EACH ROW
BEGIN
    DELETE FROM film_text
    WHERE film_id = OLD.film_id;
END;

Se ejecuta después de eliminar una película de film.
También elimina su registro correspondiente de film_text.
*/