-- CONSULTAS MULTITABLA	

-- Obtener el número de vuelos por mes y año
SELECT MONTH(v.fecha_salida) AS mes, YEAR(v.fecha_salida) AS año, COUNT(*) AS total_vuelos
FROM vuelo v
GROUP BY MONTH(v.fecha_salida), YEAR(v.fecha_salida) order by year(v.fecha_salida );

-- Obtener el promedio de duración de los vuelos por aerolínea
SELECT a.nombre AS aerolinea, AVG(r.duracion) AS duracion_promedio
FROM aerolinea a
JOIN ruta r ON a.id_aerolinea = r.id_aerolinea
JOIN vuelo v ON r.num_vuelo = v.num_vuelo
GROUP BY a.nombre;

-- Obtener el nombre del cliente y la fecha de reserva de todas las 
-- reservas realizadas en vuelos con origen en Argentina y destino en China
SELECT c.nombre, re.fecha_reserva
FROM reserva re
JOIN cliente c ON re.id_cliente = c.id_cliente
JOIN vuelo v ON re.num_vuelo = v.num_vuelo
JOIN ruta r ON v.num_vuelo = r.num_vuelo
WHERE r.origen = 'Argentina' AND r.destino = 'China';

-- Obtener el nombre de la aerolínea, el origen y el destino de 
-- todas las reservas realizadas por un cliente específico
SELECT a.nombre, r.origen, r.destino
FROM reserva re
JOIN vuelo v ON re.num_vuelo = v.num_vuelo
JOIN ruta r ON v.num_vuelo = r.num_vuelo
JOIN aerolinea a ON r.id_aerolinea = a.id_aerolinea
WHERE re.id_cliente = 255;

-- Obtener las reservas realizadas en vuelos que duran más de cierto tiempo
SELECT *
FROM reserva
WHERE num_vuelo IN (SELECT num_vuelo FROM ruta WHERE duracion > 15);

-- ------------------------------------------
-- PROCEDIMIENTOS Y FUNCIONES	

-- Función: Obtener la capacidad de un avion en especifico
delimiter &&
 CREATE FUNCTION obtener_capacidad_avion (num_avion INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE cap INT;
    SELECT capacidad INTO cap
    FROM avion
    WHERE id_avion = num_avion
   	limit 1;
    RETURN cap;
end&& 
delimiter ;

select obtener_cAapacidad_avion(4);

DELIMITER //


-- Funcion: Obtener la duracion de un vuelo 
CREATE FUNCTION ObtenerDuracionVuelo(num_vuelo_param INT) 
RETURNS int
deterministic
BEGIN
    DECLARE duracion_vuelo int;

    SELECT duracion INTO duracion_vuelo
    FROM ruta
    WHERE num_vuelo = num_vuelo_param;

    RETURN duracion_vuelo;
END //

DELIMITER ;

select ObtenerDuracionVuelo(4);

-- Procedimiento: Realiza una Reserva

DELIMITER //

CREATE PROCEDURE RealizarReserva(
    IN id_reserva_param INT,
    IN id_cliente_param INT,
    IN num_vuelo_param INT,
    IN fecha_salida_param DATETIME,
    IN fecha_reserva_param DATETIME,
    IN estado_param VARCHAR(50)
)

BEGIN
    INSERT INTO reserva (id_reserva, id_cliente, num_vuelo, fecha_salida, fecha_reserva, estado)
    VALUES (id_reserva_param, id_cliente_param, num_vuelo_param, fecha_salida_param, fecha_reserva_param, estado_param);
    SELECT *
    FROM reserva r
    where id_reserva = id_reserva_param;
END //

DELIMITER ;

CALL RealizarReserva(1003, 100, 2, '2023-05-21 10:00:00', '2023-05-20 15:00:00', 'pagado');


-- Procedimiento: llamar a otra función llamada obtener_capacidad_avion para obtener 
-- la capacidad del avión con el número especificado. Luego, muestra un mensaje 
-- que indica la capacidad del avión. (usando una funcion anterior)

DELIMITER $$
CREATE PROCEDURE mostrar_capacidad_avion(num_avion INT)
BEGIN
    DECLARE capacidad INT;
    
    set capacidad = obtener_capacidad_avion(num_avion);
    
    SELECT CONCAT('La capacidad del avión ', num_avion, ' es: ', capacidad) AS 'Mensaje';
END $$
DELIMITER ;

call mostrar_capacidad_avion(4);

-- *****

-- Procedimiento: Mostrar el nombre de los clientes. Uso del cursor

DELIMITER &&

CREATE PROCEDURE MostrarNombresClientes()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cliente_nombre VARCHAR(100);

    -- Cursor para recorrer los nombres de los clientes
    DECLARE cursor_clientes CURSOR FOR SELECT nombre FROM cliente;

    -- Manejador para cuando no se encuentren más filas
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cursor_clientes;

    read_loop: LOOP
        FETCH cursor_clientes INTO cliente_nombre;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Mostrar el nombre del cliente
        SELECT cliente_nombre;

    END LOOP;

    CLOSE cursor_clientes;
END &&

DELIMITER ;

CALL MostrarNombresClientes();


-- -----------------
-- TRIGGERS	

-- Trigger en la tabla Vuelo que actualiza la 
-- fecha de llegada automáticamente al insertar una 
-- fecha de salida:


DELIMITER //

CREATE TRIGGER actualizar_fecha_llegada
BEFORE INSERT ON vuelo
FOR EACH ROW
BEGIN
    SET NEW.fecha_llegada = ADDTIME(NEW.fecha_salida, NEW.duracion);
END //

DELIMITER ;

INSERT INTO vuelo (num_vuelo, estado, duracion, fecha_salida, fecha_llegada)
VALUES (1, 'En proceso', 3, '2023-05-21 10:00:00', '2023-05-21 10:00:00');

SELECT fecha_llegada
FROM vuelo
WHERE num_vuelo = 1;

-- Si el trigger "actualizar_fecha_llegada" está funcionando correctamente, 
-- el resultado de la consulta debería mostrar la fecha de llegada actualizada 
-- de acuerdo a la fecha de salida y duración proporcionadas en la inserción.


-- *******************

-- Trigger que actualiza la capacidad máxima del 
-- avión automáticamente
delimiter $$
create trigger actualiza_capacidad_avion
before update on avion
for each row
begin
    if new.modelo = 'Leone' then
        set new.capacidad = 500;
    elseif new.modelo = 'Malibu' then
        set new.capacidad = 150;
    elseif new.modelo = 'Eclipse' then
        set new.capacidad = 330;
    else
        set new.capacidad = 200;
    end if;
end $$
delimiter ;

update avion
set modelo = 'Leone'
where id_avion = 2;

select  capacidad
from avion
where id_avion = 4;
