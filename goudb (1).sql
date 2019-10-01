-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3309
-- Tiempo de generación: 01-10-2019 a las 20:38:39
-- Versión del servidor: 10.4.6-MariaDB
-- Versión de PHP: 7.3.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `goudb`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `login_usuario` (`_contrasena` INT, `_correo_elec` VARCHAR(30))  BEGIN
        SELECT 
            `usuarios`.id_usuario, `usuarios`.nombre, `roles`.administrador, `roles`.conductor, `roles`.superusuario, `roles`.usuario  
        FROM
             `usuarios`, `roles` 
        WHERE 
            `usuarios`.id_usuario = `roles`.id_usuario 
        AND
            `usuarios`.correo_elec = _correo_elec AND `usuarios`.contrasena = _contrasena;
            
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `validar_usuario` (`_contrasena` INT, `_correo_elec` VARCHAR(30))  BEGIN
        SELECT 
            `usuarios`.id_usuario, `usuarios`.nombre, `roles`.administrador, `roles`.conductor, `roles`.superusuario, `roles`.usuario  
        FROM
             `usuarios`, `roles` 
        WHERE 
            `usuarios`.id_usuario = `roles`.id_usuario 
        AND
            `usuarios`.correo_elec = _correo_elec AND `usuarios`.contrasena = _contrasena;
            
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `validar_usuario` (`_id_usuario` INT, `_correo_elec` VARCHAR(100)) RETURNS INT(11) BEGIN
    
	IF 
        ((SELECT COUNT(*) FROM `usuarios` WHERE correo_elec = _correo_elec) = 0)
    OR 
        ((SELECT COUNT(*) FROM `usuarios` WHERE id_usuario = _id_usuario) = 0) 
    THEN
		RETURN 2;
    ELSE 
		RETURN -1;
    END IF; 

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_conductores`
--

CREATE TABLE `auditoria_conductores` (
  `id_conductor` int(20) NOT NULL,
  `tipo_sancion` int(11) NOT NULL DEFAULT 0,
  `acumulado` int(11) NOT NULL DEFAULT 0,
  `cantidad_calificaciones` int(11) NOT NULL DEFAULT 0,
  `estado_conductor` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Disparadores `auditoria_conductores`
--
DELIMITER $$
CREATE TRIGGER `auditoria_conductores_AFTER_UPDATE` AFTER UPDATE ON `auditoria_conductores` FOR EACH ROW BEGIN
    INSERT INTO `log_calificaciones` (tipo_registro, fecha, id_usuario, tipo_sancion, acumulado, cantidad_calificaciones, estado_usuario) VALUES ("Modificación", now(), NEW.id_conductor, NEW.tipo_sancion, NEW.acumulado, NEW.cantidad_calificaciones, NEW.estado_conductor);
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `auditoria_conductores_BEFORE_DELETE` BEFORE DELETE ON `auditoria_conductores` FOR EACH ROW BEGIN
    INSERT INTO `log_calificaciones` (tipo_registro, fecha, id_usuario, tipo_sancion, acumulado, cantidad_calificaciones, estado_usuario) VALUES ("Eliminación", now(), OLD.id_conductor, OLD.tipo_sancion, OLD.acumulado, OLD.cantidad_calificaciones, OLD.estado_conductor);
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria_usuarios`
--

CREATE TABLE `auditoria_usuarios` (
  `id_usuario` int(20) NOT NULL,
  `tipo_sancion` int(11) NOT NULL DEFAULT 0,
  `acumulado` int(11) NOT NULL DEFAULT 0,
  `cantidad_calificaciones` int(11) NOT NULL DEFAULT 0,
  `estado_usuario` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `auditoria_usuarios`
--

INSERT INTO `auditoria_usuarios` (`id_usuario`, `tipo_sancion`, `acumulado`, `cantidad_calificaciones`, `estado_usuario`) VALUES
(1070977750, 0, 0, 0, 1);

--
-- Disparadores `auditoria_usuarios`
--
DELIMITER $$
CREATE TRIGGER `auditoria_usuarios_AFTER_UPDATE` AFTER UPDATE ON `auditoria_usuarios` FOR EACH ROW BEGIN
    INSERT INTO `log_calificaciones` (tipo_registro, fecha, id_usuario, tipo_sancion, acumulado, cantidad_calificaciones, estado_usuario) VALUES ("Creación", now(), NEW.id_usuario, NEW.tipo_sancion, NEW.acumulado, NEW.cantidad_calificaciones, NEW.estado_usuario);
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `auditoria_usuarios_BEFORE_DELETE` BEFORE DELETE ON `auditoria_usuarios` FOR EACH ROW BEGIN
    INSERT INTO `log_calificaciones` (tipo_registro, fecha, id_usuario, tipo_sancion, acumulado, cantidad_calificaciones, estado_usuario) VALUES ("Creación", now(), OLD.id_usuario, OLD.tipo_sancion, OLD.acumulado, OLD.cantidad_calificaciones, OLD.estado_usuario);
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `conductores`
--

CREATE TABLE `conductores` (
  `id_conductor` int(20) NOT NULL,
  `tipo_documento` varchar(45) NOT NULL,
  `codigo_asoc` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `celular` varchar(45) NOT NULL,
  `correo_elec` varchar(45) NOT NULL,
  `foto` varchar(150) NOT NULL,
  `fecha_nac` date NOT NULL,
  `contrasena` varchar(25) NOT NULL,
  `fecha_ven_pase` date NOT NULL,
  `foto_pase` varchar(150) NOT NULL,
  `foto_cedula` varchar(150) NOT NULL,
  `cod_referido` varchar(50) NOT NULL,
  `cuenta_activada` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Disparadores `conductores`
--
DELIMITER $$
CREATE TRIGGER `conductores_AFTER_INSERT` AFTER INSERT ON `conductores` FOR EACH ROW BEGIN
	INSERT INTO `roles` (id_usuario, conductor) VALUES (NEW.id_conductor, true) 
    ON DUPLICATE KEY UPDATE `conductor` = '1'; 
	INSERT INTO `auditoria_conductores` (id_conductor) VALUES (NEW.id_conductor) ; 
    
    INSERT INTO `log_conductores` (tipo_registro, fecha, id_conductor, tipo_documento, codigo_asoc, nombre, apellido, celular, correo_elec, foto, fecha_nac, contrasena, fecha_ven_pase, foto_pase, foto_cedula, cod_referido, cuenta_activada) VALUES ("Creación", now(), NEW.id_conductor, NEW.tipo_documento, NEW.codigo_asoc, NEW.nombre, NEW.apellido, NEW.celular, NEW.correo_elec, NEW.foto, NEW.fecha_nac, NEW.contrasena, NEW.fecha_ven_pase, NEW.foto_pase, NEW.foto_cedula, NEW.cod_referido, NEW.cuenta_activada);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `conductores_AFTER_UPDATE` AFTER UPDATE ON `conductores` FOR EACH ROW BEGIN 
    INSERT INTO `log_conductores` (tipo_registro, fecha, id_conductor, tipo_documento, codigo_asoc,nombre, apellido, celular, correo_elec, foto, fecha_nac, contrasena, fecha_ven_pase, foto_pase, foto_cedula, codigo_referido, cuenta_activada) VALUES ("Modificación", now(), NEW.id_conductor, NEW.tipo_documento, NEW.codigo_asoc, NEW.nombre, NEW.apellido, NEW.celular, NEW.correo_elec, NEW.foto, NEW.fecha_nac, NEW.contrasena, NEW.fecha_ven_pase, NEW.foto_pase, NEW.foto_cedula, NEW.cod_referido, NEW.cuenta_activada);
    
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `conductores_BEFORE_DELETE` BEFORE DELETE ON `conductores` FOR EACH ROW BEGIN 
    INSERT INTO `log_conductores` (tipo_registro, fecha, id_conductor, tipo_documento, codigo_asoc, nombre, apellido, celular, correo_elec, foto, fecha_nac, contrasena, fecha_ven_pase, foto_pase, foto_cedula, codigo_referido, cuenta_activada) VALUES ("Eliminación", now(), OLD.id_conductor, OLD.tipo_documento, OLD.codigo_asoc, OLD.nombre, OLD.apellido, OLD.celular, OLD.correo_elec, OLD.foto, OLD.fecha_nac, OLD.contrasena, OLD.fecha_ven_pase, OLD.foto_pase, OLD.foto_cedula, OLD.cod_referido, OLD.cuenta_activada);
    
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_calificaciones`
--

CREATE TABLE `log_calificaciones` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_usuario` int(20) NOT NULL,
  `tipo_sancion` int(11) NOT NULL,
  `acumulado` int(11) NOT NULL DEFAULT 0,
  `cantidad_calificaciones` int(11) NOT NULL DEFAULT 0,
  `estado_usuario` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_conductores`
--

CREATE TABLE `log_conductores` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_conductor` int(20) NOT NULL,
  `tipo_docuento` varchar(45) NOT NULL,
  `codigo_asoc` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `celular` varchar(45) NOT NULL,
  `correo_elec` varchar(45) NOT NULL,
  `foto` varchar(150) NOT NULL,
  `fecha_nac` date NOT NULL,
  `contrasena` varchar(25) NOT NULL,
  `fecha_ven_pase` date NOT NULL,
  `foto_pase` varchar(150) NOT NULL,
  `foto_cedula` varchar(150) NOT NULL,
  `codigo_referido` varchar(50) NOT NULL,
  `cuenta_activada` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_roles`
--

CREATE TABLE `log_roles` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_usuario` int(20) NOT NULL,
  `usuario` varchar(25) NOT NULL,
  `conductor` varchar(25) NOT NULL,
  `administrador` varchar(25) NOT NULL,
  `superusuario` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `log_roles`
--

INSERT INTO `log_roles` (`tipo_registro`, `fecha`, `id_usuario`, `usuario`, `conductor`, `administrador`, `superusuario`) VALUES
('Asignacion de Roles', '2019-09-30 11:28:39', 1070977750, '1', '0', '0', '0');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_rutas`
--

CREATE TABLE `log_rutas` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_ruta` int(11) NOT NULL,
  `conductor` int(20) NOT NULL,
  `origen` varchar(45) NOT NULL,
  `destino` varchar(45) NOT NULL,
  `opcion_parada` tinyint(1) NOT NULL,
  `tarifa_destino` int(11) NOT NULL,
  `hora_sal` datetime NOT NULL,
  `hora_lleg` datetime NOT NULL,
  `cupos` int(11) NOT NULL,
  `historial_viaje` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_servicios`
--

CREATE TABLE `log_servicios` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_servicio` int(11) NOT NULL,
  `id_ruta` int(11) NOT NULL,
  `usuario` int(20) NOT NULL,
  `conductor` int(20) NOT NULL,
  `parada` varchar(45) NOT NULL,
  `tarifa_automatica` int(11) NOT NULL,
  `cancelar_servicio` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_usuarios`
--

CREATE TABLE `log_usuarios` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `id_usuario` int(20) NOT NULL,
  `tipo_documento` varchar(45) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `celular` varchar(25) NOT NULL,
  `correo_elec` varchar(100) NOT NULL,
  `foto` varchar(150) NOT NULL,
  `fecha_nac` date NOT NULL,
  `contrasena` varchar(25) NOT NULL,
  `foto_carnet` varchar(150) NOT NULL,
  `cuenta_activada` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `log_usuarios`
--

INSERT INTO `log_usuarios` (`tipo_registro`, `fecha`, `id_usuario`, `tipo_documento`, `nombre`, `apellido`, `celular`, `correo_elec`, `foto`, `fecha_nac`, `contrasena`, `foto_carnet`, `cuenta_activada`) VALUES
('creación', '2019-09-30 11:28:39', 1070977750, 'Cedula', 'Alexis', 'Gonzalez', '3142876734', 'alexgo.1496@hotmail.com', 'imagen1.jpg', '2015-11-17', '1234', 'imagen2.jpg', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_vehiculos`
--

CREATE TABLE `log_vehiculos` (
  `tipo_registro` varchar(45) NOT NULL,
  `fecha` datetime NOT NULL,
  `placa` varchar(10) NOT NULL,
  `codigo_asoc` int(11) NOT NULL,
  `tipo_vehiculo` varchar(45) NOT NULL,
  `estado_vehiculo` tinyint(1) NOT NULL,
  `modelo` int(5) NOT NULL,
  `marca` varchar(45) NOT NULL,
  `color` varchar(45) NOT NULL,
  `cupos` int(11) NOT NULL,
  `fecha_ven_soat` date NOT NULL,
  `fecha_ven_tecno` date NOT NULL,
  `foto_soat` varchar(150) NOT NULL,
  `foto_tarj_prop` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pasajeros`
--

CREATE TABLE `pasajeros` (
  `idruta` int(11) NOT NULL,
  `usuario` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `referidos`
--

CREATE TABLE `referidos` (
  `id_usuario` int(20) NOT NULL,
  `codigo` varchar(50) NOT NULL,
  `caducidad` datetime NOT NULL,
  `cant_referidos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_usuario` int(20) NOT NULL,
  `usuario` tinyint(1) NOT NULL DEFAULT 0,
  `conductor` tinyint(1) NOT NULL DEFAULT 0,
  `administrador` tinyint(1) NOT NULL DEFAULT 0,
  `superusuario` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_usuario`, `usuario`, `conductor`, `administrador`, `superusuario`) VALUES
(1070977750, 1, 0, 0, 0);

--
-- Disparadores `roles`
--
DELIMITER $$
CREATE TRIGGER `roles_AFTER_INSERT` AFTER INSERT ON `roles` FOR EACH ROW BEGIN
    INSERT INTO `log_roles` (tipo_registro, fecha, id_usuario, usuario, conductor, administrador, superusuario) VALUES ("Asignacion de Roles", now(), NEW.id_usuario, NEW.usuario, NEW.conductor, NEW.administrador, NEW.superusuario);
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `roles_AFTER_UPDATE` AFTER UPDATE ON `roles` FOR EACH ROW BEGIN
    INSERT INTO `log_roles` (tipo_registro, fecha, id_usuario, usuario, conductor, administrador, superusuario) VALUES ("Asignacion de Roles", now(), NEW.id_usuario, NEW.usuario, NEW.conductor, NEW.administrador, NEW.superusuario);
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `roles_BEFORE_DELETE` BEFORE DELETE ON `roles` FOR EACH ROW BEGIN
    INSERT INTO `log_roles` (tipo_registro, fecha, id_usuario, usuario, conductor, administrador, superusuario) VALUES ("Asignacion de Roles", now(), OLD.id_usuario, OLD.usuario, OLD.conductor, OLD.administrador, OLD.superusuario);
    END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rutas`
--

CREATE TABLE `rutas` (
  `id_ruta` int(11) NOT NULL,
  `conductor` int(20) NOT NULL,
  `origen` varchar(45) NOT NULL,
  `destino` varchar(45) NOT NULL,
  `opcion_parada` tinyint(1) NOT NULL,
  `tarifa_destino` int(11) NOT NULL,
  `hora_sal` datetime NOT NULL,
  `hora_lleg` datetime NOT NULL,
  `cupos` int(11) NOT NULL,
  `historial_viaje` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Disparadores `rutas`
--
DELIMITER $$
CREATE TRIGGER `rutas_AFTER_INSERT` AFTER INSERT ON `rutas` FOR EACH ROW BEGIN
		INSERT INTO `log_rutas` (tipo_registro, fecha, id_ruta, conductor, origen, destino, opcion_parada, tarifa_destino, hora_sal, hora_lleg, cupos, historial_viaje) VALUES ("Creación", now(), NEW.id_ruta, NEW.conductor, NEW.origen, NEW.destino, NEW.opcion_parada, NEW.tarifa_destino, NEW.hora_sal, NEW.hora_lleg, NEW.cupos, NEW.historial_viaje);  
        END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rutas_AFTER_UPDATE` AFTER UPDATE ON `rutas` FOR EACH ROW BEGIN
		INSERT INTO `log_rutas` (tipo_registro, fecha, id_ruta, conductor, origen, destino, opcion_parada, tarifa_destino, hora_sal, hora_lleg, cupos, historial_viaje) VALUES ("Modificación", now(), NEW.id_ruta, NEW.conductor, NEW.origen, NEW.destino, NEW.opcion_parada, NEW.tarifa_destino, NEW.hora_sal, NEW.hora_lleg, NEW.cupos, NEW.historial_viaje);  
        END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rutas_BEFORE_DELETE` BEFORE DELETE ON `rutas` FOR EACH ROW BEGIN
		INSERT INTO `log_rutas` (tipo_registro, fecha, id_ruta, conductor, origen, destino, opcion_parada, tarifa_destino, hora_sal, hora_lleg, cupos, historial_viaje) VALUES ("Eliminación", now(), OLD.id_ruta, OLD.conductor, OLD.origen, OLD.destino, OLD.opcion_parada, OLD.tarifa_destino, OLD.hora_sal, OLD.hora_lleg, OLD.cupos, OLD.historial_viaje);  
        END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios`
--

CREATE TABLE `servicios` (
  `id_servicio` int(11) NOT NULL,
  `id_ruta` int(11) NOT NULL,
  `usuario` int(20) NOT NULL,
  `conductor` int(20) NOT NULL,
  `parada` varchar(45) NOT NULL,
  `tarifa_automatica` int(11) NOT NULL,
  `cancelar_servicio` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Disparadores `servicios`
--
DELIMITER $$
CREATE TRIGGER `servicios_AFTER_INSERT` AFTER INSERT ON `servicios` FOR EACH ROW BEGIN
		INSERT INTO `log_servicios` (tipo_registro, fecha, id_servicio, id_ruta, usuario, conductor, parada, tarifa_automatica, cancelar_servicio) VALUES ("Creación", now(), NEW.id_servicio, NEW.id_ruta, NEW.usuario, NEW.conductor, NEW.parada, NEW.tarifa_automatica, NEW.cancelar_servicio);  
        END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `servicios_AFTER_UPDATE` AFTER UPDATE ON `servicios` FOR EACH ROW BEGIN
		INSERT INTO `log_servicios` (tipo_registro, fecha, id_servicio, id_ruta, usuario, conductor, parada, tarifa_automatica, cancelar_servicio) VALUES ("Modificación", now(), NEW.id_servicio, NEW.id_ruta, NEW.usuario, NEW.conductor, NEW.parada, NEW.tarifa_automatica, NEW.cancelar_servicio);  
        END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `servicios_BEFORE_DELETE` BEFORE DELETE ON `servicios` FOR EACH ROW BEGIN
		INSERT INTO `log_servicios` (tipo_registro, fecha, id_servicio, id_ruta, usuario, conductor, parada, tarifa_automatica, cancelar_servicio) VALUES ("Eliminación", now(), OLD.id_servicio, OLD.id_ruta, OLD.usuario, OLD.conductor, OLD.parada, OLD.tarifa_automatica, OLD.cancelar_servicio);  
        END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_sanciones`
--

CREATE TABLE `tipos_sanciones` (
  `id_tipo_sancion` int(11) NOT NULL,
  `descripcion` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens_conductores`
--

CREATE TABLE `tokens_conductores` (
  `id_usuario` int(20) NOT NULL,
  `solicitud_token` tinyint(1) NOT NULL,
  `token` varchar(100) NOT NULL,
  `plazo_token` datetime NOT NULL,
  `ultimo_token` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tokens_usuarios`
--

CREATE TABLE `tokens_usuarios` (
  `id_usuario` int(20) NOT NULL,
  `solicitud_token` tinyint(1) NOT NULL,
  `token` varchar(100) NOT NULL,
  `plazo_token` datetime NOT NULL,
  `ultimo_token` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(20) NOT NULL,
  `tipo_documento` varchar(45) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `celular` varchar(25) NOT NULL,
  `correo_elec` varchar(100) NOT NULL,
  `foto` varchar(150) DEFAULT NULL,
  `fecha_nac` date NOT NULL,
  `contrasena` varchar(25) NOT NULL,
  `foto_carnet` varchar(150) NOT NULL,
  `cuenta_activada` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `tipo_documento`, `nombre`, `apellido`, `celular`, `correo_elec`, `foto`, `fecha_nac`, `contrasena`, `foto_carnet`, `cuenta_activada`) VALUES
(1070977750, 'Cedula', 'Alexis', 'Gonzalez', '3142876734', 'alexgo.1496@hotmail.com', 'imagen1.jpg', '2015-11-17', '1234', 'imagen2.jpg', 1);

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `usuarios_AFTER_INSERT` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
		INSERT INTO `auditoria_usuarios` (id_usuario) VALUES (NEW.id_usuario) ; 
        
        INSERT INTO `log_usuarios` (tipo_registro, fecha, id_usuario, tipo_documento, nombre, apellido, celular, correo_elec, foto, fecha_nac, contrasena, foto_carnet, cuenta_activada) VALUES ("creación", now(), NEW.id_usuario, NEW.tipo_documento, NEW.nombre, NEW.apellido, NEW.celular, NEW.correo_elec, NEW.foto, NEW.fecha_nac, NEW.contrasena, NEW.foto_carnet,  NEW.cuenta_activada);
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `usuarios_AFTER_UPDATE` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO `log_usuarios` (tipo_registro, fecha, id_usuario, tipo_documento, nombre, apellido, celular, correo_elec, foto, fecha_nac, contrasena, foto_carnet) VALUES ("Modificación", now(), NEW.id_usuario, NEW.tipo_documento, NEW.nombre, NEW.apellido, NEW.celular, NEW.correo_elec, NEW.foto, NEW.fecha_nac, NEW.contrasena, NEW.foto_carnet);
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `usuarios_BEFORE_DELETE` BEFORE DELETE ON `usuarios` FOR EACH ROW BEGIN 
    INSERT INTO `log_usuarios` (tipo_registro, fecha, id_usuario, tipo_documento, nombre, apellido, celular, correo_elec, foto, fecha_nac, contrasena, foto_carnet) VALUES ("Eliminación", now(), OLD.id_usuario, OLD.tipo_documento, OLD.nombre, OLD.apellido, OLD.celular, OLD.correo_elec, OLD.foto, OLD.fecha_nac, OLD.contrasena, OLD.foto_carnet);
    DELETE FROM `roles` WHERE id_usuario = OLD.id_usuario;
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `usuarios_BEFORE_INSERT` BEFORE INSERT ON `usuarios` FOR EACH ROW BEGIN 
INSERT INTO `roles` (id_usuario, usuario, conductor, administrador, superusuario) VALUES (NEW.id_usuario , true, false, false, false) ; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `placa` varchar(10) NOT NULL,
  `codigo_asoc` int(11) NOT NULL,
  `tipo_vehiculo` varchar(45) NOT NULL,
  `estado_vehiculo` tinyint(1) NOT NULL,
  `modelo` int(5) NOT NULL,
  `marca` varchar(45) NOT NULL,
  `color` varchar(45) NOT NULL,
  `cupos` int(11) NOT NULL,
  `fecha_ven_soat` date NOT NULL,
  `fecha_ven_tecno` date NOT NULL,
  `foto_soat` varchar(150) NOT NULL,
  `foto_tarj_prop` varchar(150) NOT NULL,
  `foto_tecno` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Disparadores `vehiculos`
--
DELIMITER $$
CREATE TRIGGER `vehiculos_AFTER_INSERT` AFTER INSERT ON `vehiculos` FOR EACH ROW BEGIN
    INSERT INTO `log_vehiculos` (tipo_registro, fecha, placa, codigo_asoc, tipo_vehiculo, estado_vehiculo, modelo, marca, color, cupos, fecha_ven_soat, fecha_ven_tecno, foto_soat, foto_tarj_prop, foto_tecno) VALUES ("Creación", now(), NEW.placa, NEW.codigo_asoc, NEW.tipo_vehiculo, NEW.estado_vehiculo, NEW.modelo, NEW.marca, NEW.color, NEW.cupos, NEW.fecha_ven_soat, NEW.fecha_ven_tecno, NEW.foto_soat, NEW.foto_tarj_prop, NEW.foto_tecno);  
    
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `vehiculos_AFTER_UPDATE` AFTER UPDATE ON `vehiculos` FOR EACH ROW BEGIN
    INSERT INTO `log_vehiculos` (tipo_registro, fecha, placa, codigo_asoc, tipo_vehiculo, estado_vehiculo, modelo, marca, color, cupos, fecha_ven_soat, fecha_ven_tecno, foto_soat, foto_tarj_prop, foto_tecno) VALUES ("Modificación", now(), NEW.placa, NEW.codigo_asoc, NEW.tipo_vehiculo, NEW.estado_vehiculo, NEW.modelo, NEW.marca, NEW.color, NEW.cupos, NEW.fecha_ven_soat, NEW.fecha_ven_tecno, NEW.foto_soat, NEW.foto_tarj_prop, NEW.foto_tecno);  
    
    END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `vehiculos_BEFORE_DELETE` BEFORE DELETE ON `vehiculos` FOR EACH ROW BEGIN
    INSERT INTO `log_vehiculos` (tipo_registro, fecha, placa, codigo_asoc, tipo_vehiculo, estado_vehiculo, modelo, marca, color, cupos, fecha_ven_soat, fecha_ven_tecno, foto_soat, foto_tarj_prop, foto_tecno) VALUES ("Eliminación", now(), OLD.placa, OLD.codigo_asoc,OLD.tipo_vehiculo, OLD.estado_vehiculo, OLD.modelo, OLD.marca, OLD.color, OLD.cupos, OLD.fecha_ven_soat, OLD.fecha_ven_tecno, OLD.foto_soat, OLD.foto_tarj_prop, OLD.foto_tecno);  
    END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria_conductores`
--
ALTER TABLE `auditoria_conductores`
  ADD PRIMARY KEY (`id_conductor`),
  ADD UNIQUE KEY `id_conductor_UNIQUE` (`id_conductor`);

--
-- Indices de la tabla `auditoria_usuarios`
--
ALTER TABLE `auditoria_usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `id_usuario_UNIQUE` (`id_usuario`),
  ADD KEY `FK_id_usuario_idx` (`id_usuario`);

--
-- Indices de la tabla `conductores`
--
ALTER TABLE `conductores`
  ADD PRIMARY KEY (`codigo_asoc`,`id_conductor`),
  ADD UNIQUE KEY `codigo_asoc_UNIQUE` (`codigo_asoc`),
  ADD UNIQUE KEY `id_conductor_UNIQUE` (`id_conductor`),
  ADD KEY `FK_codigo_referido_idx` (`cod_referido`);

--
-- Indices de la tabla `pasajeros`
--
ALTER TABLE `pasajeros`
  ADD KEY `FK_idruta` (`idruta`),
  ADD KEY `FK_pasajero` (`usuario`);

--
-- Indices de la tabla `referidos`
--
ALTER TABLE `referidos`
  ADD PRIMARY KEY (`id_usuario`,`codigo`),
  ADD UNIQUE KEY `codigo_UNIQUE` (`codigo`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `id_usuario_UNIQUE` (`id_usuario`);

--
-- Indices de la tabla `rutas`
--
ALTER TABLE `rutas`
  ADD PRIMARY KEY (`id_ruta`),
  ADD UNIQUE KEY `idruta_UNIQUE` (`id_ruta`),
  ADD KEY `FK_conductor_idx` (`conductor`);

--
-- Indices de la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD PRIMARY KEY (`id_servicio`),
  ADD UNIQUE KEY `idservicios_UNIQUE` (`id_servicio`),
  ADD KEY `FK_idservicio_idx` (`id_ruta`),
  ADD KEY `FK_usuario_idx` (`usuario`),
  ADD KEY `FK_conductor_servicio_idx` (`conductor`);

--
-- Indices de la tabla `tipos_sanciones`
--
ALTER TABLE `tipos_sanciones`
  ADD PRIMARY KEY (`id_tipo_sancion`);

--
-- Indices de la tabla `tokens_conductores`
--
ALTER TABLE `tokens_conductores`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `id_usuario_UNIQUE` (`id_usuario`);

--
-- Indices de la tabla `tokens_usuarios`
--
ALTER TABLE `tokens_usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `id_usuario_UNIQUE` (`id_usuario`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `cedula_UNIQUE` (`id_usuario`);

--
-- Indices de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD PRIMARY KEY (`placa`),
  ADD UNIQUE KEY `placa_UNIQUE` (`placa`),
  ADD KEY `FK_codigo_asoc_vehiculo_idx` (`codigo_asoc`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `conductores`
--
ALTER TABLE `conductores`
  MODIFY `codigo_asoc` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rutas`
--
ALTER TABLE `rutas`
  MODIFY `id_ruta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `servicios`
--
ALTER TABLE `servicios`
  MODIFY `id_servicio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipos_sanciones`
--
ALTER TABLE `tipos_sanciones`
  MODIFY `id_tipo_sancion` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria_conductores`
--
ALTER TABLE `auditoria_conductores`
  ADD CONSTRAINT `FK_id_conductor_auditoria` FOREIGN KEY (`id_conductor`) REFERENCES `conductores` (`id_conductor`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `auditoria_usuarios`
--
ALTER TABLE `auditoria_usuarios`
  ADD CONSTRAINT `FK_id_auditoria_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `conductores`
--
ALTER TABLE `conductores`
  ADD CONSTRAINT `FK_codigo_referido` FOREIGN KEY (`cod_referido`) REFERENCES `referidos` (`codigo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pasajeros`
--
ALTER TABLE `pasajeros`
  ADD CONSTRAINT `FK_idruta` FOREIGN KEY (`idruta`) REFERENCES `rutas` (`id_ruta`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_pasajero` FOREIGN KEY (`usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `referidos`
--
ALTER TABLE `referidos`
  ADD CONSTRAINT `FK_id_usuario_referidos` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `rutas`
--
ALTER TABLE `rutas`
  ADD CONSTRAINT `FK_conductor` FOREIGN KEY (`conductor`) REFERENCES `conductores` (`id_conductor`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD CONSTRAINT `FK_conductor_servicio` FOREIGN KEY (`conductor`) REFERENCES `conductores` (`id_conductor`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `FK_idservicio` FOREIGN KEY (`id_ruta`) REFERENCES `rutas` (`id_ruta`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_usuario` FOREIGN KEY (`usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `tokens_conductores`
--
ALTER TABLE `tokens_conductores`
  ADD CONSTRAINT `FK_idusuario_conductores` FOREIGN KEY (`id_usuario`) REFERENCES `conductores` (`id_conductor`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `tokens_usuarios`
--
ALTER TABLE `tokens_usuarios`
  ADD CONSTRAINT `FK_idusuario_token` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD CONSTRAINT `FK_codigo_asoc_vehiculo` FOREIGN KEY (`codigo_asoc`) REFERENCES `conductores` (`codigo_asoc`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
