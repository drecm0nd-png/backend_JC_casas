-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema borrador_bd
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema borrador_bd
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `borrador_bd` DEFAULT CHARACTER SET utf8mb3 ;
USE `borrador_bd` ;

-- -----------------------------------------------------
-- Table `borrador_bd`.`almuerzo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`almuerzo` (
  `id_almuerzo` BIGINT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  `activo` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_almuerzo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`categoria_ingrediente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`categoria_ingrediente` (
  `id_categoria` BIGINT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`ingrediente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`ingrediente` (
  `id_ingrediente` BIGINT NOT NULL AUTO_INCREMENT,
  `id_categoria` BIGINT NOT NULL,
  `nombre` VARCHAR(80) NOT NULL,
  `descripcion` VARCHAR(255) NULL DEFAULT NULL,
  `unidad_medida` VARCHAR(30) NOT NULL,
  `cantidad_disponible` DECIMAL(12,3) NOT NULL DEFAULT '0.000',
  `activo` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_ingrediente`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE,
  INDEX `fk_ingrediente_categoria` (`id_categoria` ASC) VISIBLE,
  CONSTRAINT `fk_ingrediente_categoria`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `borrador_bd`.`categoria_ingrediente` (`id_categoria`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`almuerzo_componente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`almuerzo_componente` (
  `id_almuerzo` BIGINT NOT NULL,
  `id_ingrediente` BIGINT NOT NULL,
  `cantidad_requerida` DECIMAL(12,3) NOT NULL,
  PRIMARY KEY (`id_almuerzo`, `id_ingrediente`),
  INDEX `fk_almuerzo_componente_ingrediente` (`id_ingrediente` ASC) VISIBLE,
  CONSTRAINT `fk_almuerzo_componente_almuerzo`
    FOREIGN KEY (`id_almuerzo`)
    REFERENCES `borrador_bd`.`almuerzo` (`id_almuerzo`),
  CONSTRAINT `fk_almuerzo_componente_ingrediente`
    FOREIGN KEY (`id_ingrediente`)
    REFERENCES `borrador_bd`.`ingrediente` (`id_ingrediente`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`usuario` (
  `id_usuario` BIGINT NOT NULL AUTO_INCREMENT,
  `correo` VARCHAR(254) NOT NULL,
  `nombre` VARCHAR(80) NOT NULL,
  `apellido` VARCHAR(80) NULL DEFAULT NULL,
  `telefono` VARCHAR(20) NULL DEFAULT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `activo` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `correo` (`correo` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`cliente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`cliente` (
  `id_cliente` BIGINT NOT NULL AUTO_INCREMENT,
  `id_usuario` BIGINT NOT NULL,
  `direccion_predeterminada` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE INDEX `id_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_cliente_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `borrador_bd`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`estado_pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`estado_pedido` (
  `id_estado_pedido` SMALLINT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_estado_pedido`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`pedido` (
  `id_pedido` BIGINT NOT NULL AUTO_INCREMENT,
  `id_cliente` BIGINT NOT NULL,
  `id_estado_pedido` SMALLINT NOT NULL,
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `direccion_entrega` VARCHAR(255) NOT NULL,
  `telefono_contacto` VARCHAR(20) NOT NULL,
  `notas` VARCHAR(255) NULL DEFAULT NULL,
  `costo_envio` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `precio_total` DECIMAL(12,2) NOT NULL DEFAULT '0.00',
  `confirmado_en` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`id_pedido`),
  INDEX `fk_pedido_cliente` (`id_cliente` ASC) VISIBLE,
  INDEX `fk_pedido_estado` (`id_estado_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_pedido_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `borrador_bd`.`cliente` (`id_cliente`),
  CONSTRAINT `fk_pedido_estado`
    FOREIGN KEY (`id_estado_pedido`)
    REFERENCES `borrador_bd`.`estado_pedido` (`id_estado_pedido`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`comanda`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`comanda` (
  `id_comanda` BIGINT NOT NULL AUTO_INCREMENT,
  `id_pedido` BIGINT NOT NULL,
  `fecha_generacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_impresion` DATETIME NULL DEFAULT NULL,
  `estado_impresion` VARCHAR(20) NOT NULL DEFAULT 'pendiente',
  PRIMARY KEY (`id_comanda`),
  UNIQUE INDEX `id_pedido` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_comanda_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `borrador_bd`.`pedido` (`id_pedido`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`detalle_pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`detalle_pedido` (
  `id_detalle` BIGINT NOT NULL AUTO_INCREMENT,
  `id_pedido` BIGINT NOT NULL,
  `id_almuerzo` BIGINT NOT NULL,
  `cantidad` INT NOT NULL,
  `precio_unitario` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  INDEX `fk_detalle_pedido_pedido` (`id_pedido` ASC) VISIBLE,
  INDEX `fk_detalle_pedido_almuerzo` (`id_almuerzo` ASC) VISIBLE,
  CONSTRAINT `fk_detalle_pedido_almuerzo`
    FOREIGN KEY (`id_almuerzo`)
    REFERENCES `borrador_bd`.`almuerzo` (`id_almuerzo`),
  CONSTRAINT `fk_detalle_pedido_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `borrador_bd`.`pedido` (`id_pedido`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`detalle_pedido_componente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`detalle_pedido_componente` (
  `id_detalle_componente` BIGINT NOT NULL AUTO_INCREMENT,
  `id_detalle` BIGINT NOT NULL,
  `id_ingrediente` BIGINT NOT NULL,
  `tipo_componente` VARCHAR(20) NOT NULL,
  `cantidad` DECIMAL(12,3) NOT NULL DEFAULT '1.000',
  `precio_adicional` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_detalle_componente`),
  INDEX `fk_detalle_comp_detalle` (`id_detalle` ASC) VISIBLE,
  INDEX `fk_detalle_comp_ingrediente` (`id_ingrediente` ASC) VISIBLE,
  CONSTRAINT `fk_detalle_comp_detalle`
    FOREIGN KEY (`id_detalle`)
    REFERENCES `borrador_bd`.`detalle_pedido` (`id_detalle`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_detalle_comp_ingrediente`
    FOREIGN KEY (`id_ingrediente`)
    REFERENCES `borrador_bd`.`ingrediente` (`id_ingrediente`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`historial_estado_pedido`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`historial_estado_pedido` (
  `id_historial` BIGINT NOT NULL AUTO_INCREMENT,
  `id_pedido` BIGINT NOT NULL,
  `id_estado_pedido` SMALLINT NOT NULL,
  `fecha_cambio` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_usuario_responsable` BIGINT NULL DEFAULT NULL,
  `observacion` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_historial`),
  INDEX `fk_historial_pedido` (`id_pedido` ASC) VISIBLE,
  INDEX `fk_historial_estado` (`id_estado_pedido` ASC) VISIBLE,
  INDEX `fk_historial_usuario` (`id_usuario_responsable` ASC) VISIBLE,
  CONSTRAINT `fk_historial_estado`
    FOREIGN KEY (`id_estado_pedido`)
    REFERENCES `borrador_bd`.`estado_pedido` (`id_estado_pedido`),
  CONSTRAINT `fk_historial_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `borrador_bd`.`pedido` (`id_pedido`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_historial_usuario`
    FOREIGN KEY (`id_usuario_responsable`)
    REFERENCES `borrador_bd`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`menu_diario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`menu_diario` (
  `id_menu` BIGINT NOT NULL AUTO_INCREMENT,
  `fecha` DATE NOT NULL,
  `nombre` VARCHAR(100) NULL DEFAULT NULL,
  `activo` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_menu`),
  UNIQUE INDEX `fecha` (`fecha` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`menu_ingrediente`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`menu_ingrediente` (
  `id_menu` BIGINT NOT NULL,
  `id_ingrediente` BIGINT NOT NULL,
  `disponible_venta` TINYINT(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_menu`, `id_ingrediente`),
  INDEX `fk_menu_ingrediente_ingrediente` (`id_ingrediente` ASC) VISIBLE,
  CONSTRAINT `fk_menu_ingrediente_ingrediente`
    FOREIGN KEY (`id_ingrediente`)
    REFERENCES `borrador_bd`.`ingrediente` (`id_ingrediente`),
  CONSTRAINT `fk_menu_ingrediente_menu`
    FOREIGN KEY (`id_menu`)
    REFERENCES `borrador_bd`.`menu_diario` (`id_menu`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`metodo_pago`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`metodo_pago` (
  `id_metodo_pago` SMALLINT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_metodo_pago`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`movimiento_inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`movimiento_inventario` (
  `id_movimiento` BIGINT NOT NULL AUTO_INCREMENT,
  `id_ingrediente` BIGINT NOT NULL,
  `id_pedido` BIGINT NULL DEFAULT NULL,
  `tipo_movimiento` VARCHAR(20) NOT NULL,
  `cantidad` DECIMAL(12,3) NOT NULL,
  `fecha_movimiento` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `observacion` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`id_movimiento`),
  INDEX `fk_movimiento_ingrediente` (`id_ingrediente` ASC) VISIBLE,
  INDEX `fk_movimiento_pedido` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_movimiento_ingrediente`
    FOREIGN KEY (`id_ingrediente`)
    REFERENCES `borrador_bd`.`ingrediente` (`id_ingrediente`),
  CONSTRAINT `fk_movimiento_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `borrador_bd`.`pedido` (`id_pedido`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`pago`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`pago` (
  `id_pago` BIGINT NOT NULL AUTO_INCREMENT,
  `id_pedido` BIGINT NOT NULL,
  `id_metodo_pago` SMALLINT NOT NULL,
  `valor` DECIMAL(12,2) NOT NULL,
  `fecha_pago` DATETIME NULL DEFAULT NULL,
  `referencia` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`id_pago`),
  UNIQUE INDEX `id_pedido` (`id_pedido` ASC) VISIBLE,
  INDEX `fk_pago_metodo` (`id_metodo_pago` ASC) VISIBLE,
  CONSTRAINT `fk_pago_metodo`
    FOREIGN KEY (`id_metodo_pago`)
    REFERENCES `borrador_bd`.`metodo_pago` (`id_metodo_pago`),
  CONSTRAINT `fk_pago_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `borrador_bd`.`pedido` (`id_pedido`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`rol` (
  `id_rol` BIGINT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE INDEX `nombre` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `borrador_bd`.`usuario_rol`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `borrador_bd`.`usuario_rol` (
  `id_usuario` BIGINT NOT NULL,
  `id_rol` BIGINT NOT NULL,
  PRIMARY KEY (`id_usuario`, `id_rol`),
  INDEX `fk_usuario_rol_rol` (`id_rol` ASC) VISIBLE,
  CONSTRAINT `fk_usuario_rol_rol`
    FOREIGN KEY (`id_rol`)
    REFERENCES `borrador_bd`.`rol` (`id_rol`),
  CONSTRAINT `fk_usuario_rol_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `borrador_bd`.`usuario` (`id_usuario`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
