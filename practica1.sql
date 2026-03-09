-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-03-2026 a las 17:11:38
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `libros`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_genero_libro` (IN `isbn_libro` BIGINT, IN `nuevo_genero` VARCHAR(50))   BEGIN

UPDATE libro
SET lib_genero = nuevo_genero
WHERE lib_isbn = isbn_libro;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_socio` (IN `id_socio` INT, IN `nueva_direccion` VARCHAR(255), IN `nuevo_telefono` VARCHAR(10))   BEGIN

UPDATE socio
SET 
soc_direccion = nueva_direccion,
soc_telefono = nuevo_telefono
WHERE Soc_numero = id_socio;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_libro_nombre` (IN `nombre_libro` VARCHAR(255))   BEGIN

SELECT *
FROM libro
WHERE lib_titulo LIKE CONCAT('%', nombre_libro, '%');

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_libro` (IN `isbn_libro` BIGINT)   BEGIN

IF NOT EXISTS (
SELECT *
FROM prestamo
WHERE lib_copiaisbn = isbn_libro
)
THEN

DELETE FROM libro
WHERE lib_isbn = isbn_libro;

END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `historial_prestamos_socio` (IN `id_socio` INT)   BEGIN

SELECT 
    s.soc_nombre,
    s.soc_apellido,
    l.lib_titulo,
    p.pres_fechaprestamo,
    p.pres_fechadevolucion
FROM prestamo p
INNER JOIN socio s 
ON p.soc_copianumero = s.Soc_numero
INNER JOIN libro l 
ON p.lib_copiaisbn = l.lib_isbn
WHERE s.Soc_numero = id_socio;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_socio` (IN `nombre` VARCHAR(45), IN `apellido` VARCHAR(45), IN `direccion` VARCHAR(255), IN `telefono` VARCHAR(10))   BEGIN

INSERT INTO socio
(soc_nombre, soc_apellido, soc_direccion, soc_telefono)
VALUES
(nombre, apellido, direccion, telefono);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `libros_disponibles` ()   BEGIN

SELECT *
FROM libro
WHERE lib_isbn NOT IN (
    SELECT lib_copiaisbn
    FROM prestamo
);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `libros_en_prestamo` ()   BEGIN
SELECT 
    l.lib_titulo,
    l.lib_isbn,
    s.soc_nombre,
    s.soc_apellido,
    p.pres_fechaprestamo,
    p.pres_fechadevolucion
FROM prestamo p
INNER JOIN socio s 
ON p.soc_copianumero = s.Soc_numero
INNER JOIN libro l 
ON p.lib_copiaisbn = l.lib_isbn;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `socios_con_prestamos` ()   BEGIN
SELECT 
    Soc_numero,
    soc_nombre,
    soc_apellido,
    pres_id,
    pres_fechaprestamo,
    pres_fechadevolucion
FROM socio s
LEFT JOIN prestamo p 
ON Soc_numero = soc_copianumero;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `dias_prestamo` (`idlibro` BIGINT) RETURNS INT(11) DETERMINISTIC BEGIN

DECLARE dias INT;

SELECT DATEDIFF(pres_fechadevolucion, pres_fechaprestamo)
INTO dias
FROM prestamo
WHERE lib_copiaisbn = idlibro
LIMIT 1;

RETURN dias;

END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_socios` () RETURNS INT(11) DETERMINISTIC BEGIN

DECLARE cantidad INT;

SELECT COUNT(*) INTO cantidad
FROM socio;

RETURN cantidad;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_libro`
--

CREATE TABLE `auditoria_libro` (
  `id` int(11) NOT NULL,
  `lib_isbn` bigint(20) DEFAULT NULL,
  `titulo` varchar(100) DEFAULT NULL,
  `genero` varchar(50) DEFAULT NULL,
  `paginas` int(11) DEFAULT NULL,
  `accion` varchar(20) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria_libro`
--

INSERT INTO `auditoria_libro` (`id`, `lib_isbn`, `titulo`, `genero`, `paginas`, `accion`, `fecha`) VALUES
(1, 6666666666, 'La Odisea', 'Épico', 350, 'INSERT', '2026-03-05 10:35:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audi_libro`
--

CREATE TABLE `audi_libro` (
  `id_audi` int(11) NOT NULL,
  `lib_isbn_anterior` bigint(20) DEFAULT NULL,
  `titulo_anterior` varchar(255) DEFAULT NULL,
  `genero_anterior` varchar(50) DEFAULT NULL,
  `paginas_anterior` int(11) DEFAULT NULL,
  `accion` varchar(20) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audi_libro_update`
--

CREATE TABLE `audi_libro_update` (
  `id` int(11) NOT NULL,
  `lib_id` int(11) DEFAULT NULL,
  `titulo_anterior` varchar(100) DEFAULT NULL,
  `titulo_nuevo` varchar(100) DEFAULT NULL,
  `genero_anterior` varchar(50) DEFAULT NULL,
  `genero_nuevo` varchar(50) DEFAULT NULL,
  `paginas_anteriores` int(11) DEFAULT NULL,
  `paginas_nuevas` int(11) DEFAULT NULL,
  `fecha_cambio` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `audi_socio`
--

CREATE TABLE `audi_socio` (
  `id_audi` int(10) NOT NULL,
  `socNumero_audi` int(11) DEFAULT NULL,
  `socNombre_anterior` varchar(45) DEFAULT NULL,
  `socApellido_anterior` varchar(45) DEFAULT NULL,
  `socDireccion_anterior` varchar(255) DEFAULT NULL,
  `socTelefono_anterior` varchar(10) DEFAULT NULL,
  `socNombre_nuevo` varchar(45) DEFAULT NULL,
  `socApellido_nuevo` varchar(45) DEFAULT NULL,
  `socDireccion_nuevo` varchar(255) DEFAULT NULL,
  `socTelefono_nuevo` varchar(10) DEFAULT NULL,
  `audi_fechaModificacion` datetime DEFAULT NULL,
  `audi_usuario` varchar(10) DEFAULT NULL,
  `audi_accion` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `audi_socio`
--

INSERT INTO `audi_socio` (`id_audi`, `socNumero_audi`, `socNombre_anterior`, `socApellido_anterior`, `socDireccion_anterior`, `socTelefono_anterior`, `socNombre_nuevo`, `socApellido_nuevo`, `socDireccion_nuevo`, `socTelefono_nuevo`, `audi_fechaModificacion`, `audi_usuario`, `audi_accion`) VALUES
(1, 1, 'Ana ', 'Ruiz ', 'Calle Primavera 123, Ciudad Jardín, Barcelona ', '9123456780', 'Ana ', 'Ruiz ', 'Calle 50', '3109876543', '2026-03-09 10:16:23', 'root@local', 'Actualización');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autor`
--

CREATE TABLE `autor` (
  `aut_codigo` int(11) NOT NULL,
  `aut_apellido` varchar(45) NOT NULL,
  `aut_nacimiento` date NOT NULL,
  `aut_muerte` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `autor`
--

INSERT INTO `autor` (`aut_codigo`, `aut_apellido`, `aut_nacimiento`, `aut_muerte`) VALUES
(98, 'Smith ', '1974-12-21', '2018-07-21'),
(123, 'Taylor ', '1980-04-15', '0000-00-00'),
(234, 'Medina ', '1977-06-21', '2005-09-12'),
(345, 'Wilson ', '1975-08-29', '0000-00-00'),
(432, 'Miller ', '1981-10-26', '0000-00-00'),
(456, 'García ', '1978-09-27', '2021-12-09'),
(567, 'Davis ', '1983-03-04', '2010-03-28'),
(678, 'Silva ', '1986-02-02', '0000-00-00'),
(765, 'López ', '1976-07-08', '2019-03-18'),
(789, 'Rodríguez ', '1985-12-10', '0000-00-00'),
(890, 'Brown ', '1982-11-17', '0000-00-00'),
(901, 'Soto ', '1979-05-13', '2015-11-05');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libro`
--

CREATE TABLE `libro` (
  `lib_isbn` bigint(20) NOT NULL,
  `lib_titulo` varchar(255) NOT NULL,
  `lib_genero` varchar(20) NOT NULL,
  `lib_numeropaginas` int(11) NOT NULL,
  `lib_diasprestamo` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libro`
--

INSERT INTO `libro` (`lib_isbn`, `lib_titulo`, `lib_genero`, `lib_numeropaginas`, `lib_diasprestamo`) VALUES
(1234567890, 'El Sueño de los Susurros ', 'novela ', 275, 7),
(1357924680, 'El Jardín de las Mariposas Perdidas ', 'novela ', 536, 7),
(2468135790, 'La Melodía de la Oscuridad ', 'romance ', 189, 7),
(2718281828, 'El Bosque de los Suspiros ', 'novela ', 387, 2),
(3141592653, 'El Secreto de las Estrellas Olvidadas ', 'Misterio ', 203, 7),
(5555555555, 'La Última Llave del Destino ', 'cuento ', 503, 7),
(7777777777, 'El Misterio de la Luna Plateada ', 'Misterio ', 422, 7),
(8642097531, 'El Reloj de Arena Infinito ', 'novela ', 321, 7),
(8888888888, 'La Ciudad de los Susurros ', 'Misterio ', 274, 1),
(9517530862, 'Las Crónicas del Eco Silencioso ', 'fantasía ', 448, 7),
(9876543210, 'El Laberinto de los Recuerdos ', 'cuento ', 412, 7),
(9999999999, 'El Enigma de los Espejos Rotos ', 'romance ', 156, 7);

--
-- Disparadores `libro`
--
DELIMITER $$
CREATE TRIGGER `trg_auditoria_insert_libro` AFTER INSERT ON `libro` FOR EACH ROW BEGIN
    INSERT INTO auditoria_libro(
        lib_isbn,
        titulo,
        genero,
        paginas,
        accion,
        fecha
    )
    VALUES(
        NEW.lib_isbn,
        NEW.lib_titulo,
        NEW.lib_genero,
        NEW.lib_numeropaginas,
        'INSERT',
        NOW()
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_auditoria_update_libro` AFTER UPDATE ON `libro` FOR EACH ROW BEGIN
    INSERT INTO auditoria_libro(
        lib_isbn,
        titulo_anterior,
        titulo_nuevo,
        genero_anterior,
        genero_nuevo,
        paginas_anteriores,
        paginas_nuevas,
        fecha_cambio
    )
    VALUES(
        OLD.lib_isbn,
        OLD.lib_titulo,
        NEW.lib_titulo,
        OLD.lib_genero,
        NEW.lib_genero,
        OLD.lib_numeropaginas,
        NEW.lib_numeropaginas,
        NOW()
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamo`
--

CREATE TABLE `prestamo` (
  `pres_id` varchar(20) NOT NULL,
  `pres_fechaprestamo` date NOT NULL,
  `pres_fechadevolucion` date NOT NULL,
  `soc_copianumero` int(11) NOT NULL,
  `lib_copiaisbn` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `prestamo`
--

INSERT INTO `prestamo` (`pres_id`, `pres_fechaprestamo`, `pres_fechadevolucion`, `soc_copianumero`, `lib_copiaisbn`) VALUES
('pres1 ', '2023-01-15', '2023-01-20', 1, 1234567890),
('pres2 ', '2023-02-03', '2023-02-04', 2, 9999999999),
('pres3 ', '2023-04-09', '2023-04-11', 6, 2718281828),
('pres4 ', '2023-06-14', '2023-06-15', 9, 8888888888),
('pres5 ', '2023-07-02', '2023-07-09', 10, 5555555555),
('pres6 ', '2023-08-19', '2023-08-26', 12, 5555555555),
('pres7 ', '2023-10-24', '2023-10-27', 3, 1357924680),
('pres8 ', '2023-11-11', '2023-11-12', 4, 9999999999);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `socio`
--

CREATE TABLE `socio` (
  `Soc_numero` int(11) NOT NULL,
  `soc_nombre` varchar(45) NOT NULL,
  `soc_apellido` varchar(45) NOT NULL,
  `soc_direccion` varchar(255) NOT NULL,
  `soc_telefono` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `socio`
--

INSERT INTO `socio` (`Soc_numero`, `soc_nombre`, `soc_apellido`, `soc_direccion`, `soc_telefono`) VALUES
(0, 'Juan', 'Perez', 'Calle 10', '3001234567'),
(1, 'Ana ', 'Ruiz ', 'Calle 50', '3109876543'),
(2, 'Andrés Felipe ', 'Galindo Luna ', 'Avenida del Sol 456, Pueblo Nuevo, Madrid ', '2123456789'),
(3, 'Juan ', 'González ', 'Calle Principal 789, Villa Flores, Valencia ', '2012345678'),
(4, 'María ', 'Rodríguez ', 'Carrera del Río 321, El Pueblo, Sevilla ', '3012345678'),
(5, 'Pedro ', 'Martínez ', 'Calle del Bosque 654, Los Pinos, Málaga ', '1234567812'),
(6, 'Ana ', 'López ', 'Avenida Central 987, Villa Hermosa, Bilbao ', '6123456781'),
(7, 'Carlos ', 'Sánchez ', 'Calle de la Luna 234, El Prado, Alicante ', '1123456781'),
(8, 'Laura ', 'Ramírez ', 'Carrera del Mar 567, Playa Azul, Palma de Mallorca ', '1312345678'),
(9, 'Luis ', 'Hernández ', 'Avenida de la Montaña 890, Monte Verde, Granada ', '6101234567'),
(10, 'Andrea ', 'García ', 'Calle del Sol 432, La Colina, Zaragoza ', '1112345678'),
(11, 'Alejandro ', 'Torres ', 'Carrera del Oeste 765, Ciudad Nueva, Murcia ', '4951234567'),
(12, 'Sofia ', 'Morales ', 'Avenida del Mar 098, Costa Brava, Gijón ', '5512345678');

--
-- Disparadores `socio`
--
DELIMITER $$
CREATE TRIGGER `socio_after_delete` AFTER DELETE ON `socio` FOR EACH ROW insert into audi_socio(
    socNumero_audi,
    socNombre_anterior,
    socApellido_anterior,
    socDireccion_anterior,
    socTelefono_anterior,
    audi_fechamodificacion,
    audi_usuario,
    audi_accion)
    values(
        old.soc_numero,
        old.soc_nombre,
        old.soc_apellido,
        old.soc_direccion,
        old.soc_telefono,
        Now(),
        current_user(),
        'Registro eliminado')
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `socios_before_update` BEFORE UPDATE ON `socio` FOR EACH ROW INSERT INTO audi_socio(
    socNumero_audi,
    socNombre_anterior,
    socApellido_anterior,
    socDireccion_anterior,
    socTelefono_anterior,
    socNombre_nuevo,
    socApellido_nuevo,
    socDireccion_nuevo,
    socTelefono_nuevo,
    audi_fechaModificacion,
    audi_usuario,
    audi_accion)
VALUES(
    new.soc_numero,
    old.soc_nombre,
    old.soc_apellido,
    old.soc_direccion,
    old.soc_telefono,
    new.soc_nombre,
    new.soc_apellido,
    new.soc_direccion,
    new.soc_telefono,
    NOW(),
    CURRENT_USER(),
    'Actualización')
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipoautores`
--

CREATE TABLE `tipoautores` (
  `tipoautor` varchar(20) NOT NULL,
  `copiaISBN` bigint(20) NOT NULL,
  `copiaAutor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipoautores`
--

INSERT INTO `tipoautores` (`tipoautor`, `copiaISBN`, `copiaAutor`) VALUES
('Traductor', 1357924680, 123),
('Autor', 1234567890, 123),
('Coautor', 1234567890, 456),
('Traductor', 2718281828, 789),
('Autor', 8888888888, 234),
('Autor', 2468135790, 234),
('Autor', 9876543210, 567),
('Autor', 1234567890, 890),
('Autor', 8642097531, 345),
('Coautor', 8888888888, 345),
('Autor', 5555555555, 678),
('Autor', 3141592653, 901),
('Autor', 9517530862, 432),
('Autor', 7777777777, 765),
('Autor', 9999999999, 98);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_libro`
--
ALTER TABLE `auditoria_libro`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `audi_libro`
--
ALTER TABLE `audi_libro`
  ADD PRIMARY KEY (`id_audi`);

--
-- Indices de la tabla `audi_libro_update`
--
ALTER TABLE `audi_libro_update`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `audi_socio`
--
ALTER TABLE `audi_socio`
  ADD PRIMARY KEY (`id_audi`);

--
-- Indices de la tabla `autor`
--
ALTER TABLE `autor`
  ADD PRIMARY KEY (`aut_codigo`);

--
-- Indices de la tabla `libro`
--
ALTER TABLE `libro`
  ADD PRIMARY KEY (`lib_isbn`);

--
-- Indices de la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD PRIMARY KEY (`pres_id`),
  ADD KEY `soc_copianumero` (`soc_copianumero`),
  ADD KEY `lib_copiaisbn` (`lib_copiaisbn`);

--
-- Indices de la tabla `socio`
--
ALTER TABLE `socio`
  ADD PRIMARY KEY (`Soc_numero`);

--
-- Indices de la tabla `tipoautores`
--
ALTER TABLE `tipoautores`
  ADD KEY `copiaISBN` (`copiaISBN`),
  ADD KEY `copiaAutor` (`copiaAutor`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria_libro`
--
ALTER TABLE `auditoria_libro`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `audi_libro`
--
ALTER TABLE `audi_libro`
  MODIFY `id_audi` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `audi_libro_update`
--
ALTER TABLE `audi_libro_update`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `audi_socio`
--
ALTER TABLE `audi_socio`
  MODIFY `id_audi` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `prestamo`
--
ALTER TABLE `prestamo`
  ADD CONSTRAINT `prestamo_ibfk_1` FOREIGN KEY (`soc_copianumero`) REFERENCES `socio` (`Soc_numero`),
  ADD CONSTRAINT `prestamo_ibfk_2` FOREIGN KEY (`lib_copiaisbn`) REFERENCES `libro` (`lib_isbn`);

--
-- Filtros para la tabla `tipoautores`
--
ALTER TABLE `tipoautores`
  ADD CONSTRAINT `tipoautores_ibfk_1` FOREIGN KEY (`copiaISBN`) REFERENCES `libro` (`lib_isbn`),
  ADD CONSTRAINT `tipoautores_ibfk_2` FOREIGN KEY (`copiaAutor`) REFERENCES `autor` (`aut_codigo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
