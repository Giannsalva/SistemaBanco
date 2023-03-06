create database BanquitoFiel;

use BanquitoFiel;

create table tiposUsuarios(
	Tipo_us int,
    Descripcion varchar(20),
    primary key (Tipo_Us)
);

create table usuarios(
	Usuario varchar(20),
    Tipo_Us int,
    Contraseña varchar(50),
    Estado bool,
    primary key (Usuario),
    foreign key (Tipo_Us) references tiposusuarios(Tipo_us)
);

create table tiposMovimientos(
	Tipo_mov int,
    Descripcion varchar(20),
    primary key (Tipo_mov)
);

create table generos(
	Cod_genero int,
    Descripcion varchar(20),
    primary key (Cod_genero)
);

create table nacionalidad(
	Cod_nacionalidad int,
    Descripcion varchar(20),
    primary key (Cod_nacionalidad)
);

create table provincias(
	Cod_provincia int,
    Descripcion varchar(20),
    primary key (Cod_provincia)
);

create table localidades(
	Cod_provincia int,
    Cod_localidad int,
    Descripcion varchar(20),
    primary key (Cod_provincia,Cod_localidad),
    foreign key (Cod_provincia) references provincias(Cod_provincia)
);

create table estadosPrestamos(
	Est_prestamo int,
    Descripcion varchar(20),
    primary key (Est_prestamo)
);

create table tiposCuentas(
	Tipo_cuenta int,
    Descripcion varchar(20),
    primary key (Tipo_cuenta)
);

create table clientes(
	Nro_Cliente int NOT NULL AUTO_INCREMENT,
    Dni varchar(10),
    Cuil varchar(15),
    Nombre varchar(30),
    Apellido varchar(30),
    Cod_Genero int,
    Cod_nacionalidad int,
    Fecha_nac varchar(10),
    Direccion varchar(50),
    Cod_provincia int,
    Cod_localidad int,
    Email varchar(80),
    Telefono char(11),
    Usuario varchar(30),
    Estado bool,
    primary key (Nro_Cliente),
    foreign key (Cod_Genero) references generos(Cod_genero),
    foreign key (Cod_nacionalidad) references nacionalidad(Cod_nacionalidad),
    foreign key (Cod_provincia) references provincias(Cod_provincia),
    foreign key (Cod_provincia,Cod_localidad) references localidades(Cod_provincia,Cod_localidad),
    foreign key (Usuario) references usuarios(Usuario)
);

create table cuentas(
	Nro_cuenta int NOT NULL AUTO_INCREMENT,
    Nro_cliente int,
    Fecha_creacion date,
    Tipo_cuenta int,
    Cbu varchar(50),
    Saldo float,
    Estado bool,
    primary key (Nro_cuenta),
    foreign key (Nro_cliente) references clientes(Nro_cliente)
);

create table prestamos(
	Nro_prestamo int NOT NULL AUTO_INCREMENT,
    Nro_cliente int,
    Fecha date,
    Imp_con_intereses float,
    Imp_solicitado float,
    Nro_cuenta_deposito int,
    Plazo_pago_meses int,
    Monto_pago_por_mes float,
    Cant_cuotas int,
    Est_prestamo int,
    primary key (Nro_prestamo),
    foreign key (Nro_cliente) references clientes(Nro_cliente),
    foreign key (Nro_cuenta_deposito) references cuentas(Nro_cuenta),
    foreign key (Est_prestamo) references estadosprestamos(Est_prestamo)
);

create table prestamosCuotas(
	Nro_prestamo int,
    Nro_cuota int,
    Monto_cuota float,
    Fecha_Vencimiento date,
    Fecha_Pago datetime,
    Pagado bool default false,
    primary key (Nro_prestamo,Nro_cuota),
    foreign key (Nro_prestamo) references prestamos(Nro_prestamo)
);

create table movimientos(
	Nro_Movimiento int NOT NULL AUTO_INCREMENT,
    Nro_cuenta int,
    Fecha datetime,
    Tipo_mov int,
    Importe float,
    Detalle varchar(80),
    primary key (Nro_Movimiento),
    foreign key (Nro_cuenta) references cuentas(Nro_cuenta)
);

/* Vistas */

CREATE VIEW vistaMovimientos AS
	SELECT Nro_Movimiento,Nro_cuenta,fecha,movimientos.Tipo_mov,tiposmovimientos.Descripcion,Importe,Detalle,DATE_FORMAT(fecha,'%d/%m/%Y %H:%i:%s') AS fecha_dmy 
    FROM movimientos JOIN tiposmovimientos ON tiposmovimientos.Tipo_mov = movimientos.Tipo_mov;
    

CREATE VIEW vistaPrestamos AS
    SELECT Nro_prestamo, fecha, Imp_con_intereses, Imp_solicitado, Nro_cuenta_deposito, Plazo_pago_meses, Monto_pago_por_mes, Cant_cuotas, estadosPrestamos.Descripcion, estadosPrestamos.Est_prestamo,Nro_cliente, DATE_FORMAT(fecha,'%d/%m/%Y') AS fecha_dmy
	FROM prestamos INNER JOIN estadosPrestamos ON prestamos.Est_prestamo = estadosPrestamos.Est_prestamo WHERE prestamos.Est_prestamo = 1 OR prestamos.Est_prestamo = 2  ;
 
CREATE VIEW vistaSolicitudes AS
    SELECT Nro_prestamo, fecha, Imp_con_intereses, Imp_solicitado, Nro_cuenta_deposito, Plazo_pago_meses, Monto_pago_por_mes, Cant_cuotas, estadosPrestamos.Descripcion, estadosPrestamos.Est_prestamo,Nro_cliente, DATE_FORMAT(fecha,'%d/%m/%Y') AS fecha_dmy
	FROM prestamos INNER JOIN estadosPrestamos ON prestamos.Est_prestamo = estadosPrestamos.Est_prestamo WHERE prestamos.Est_prestamo = 3  ;

create view vistaCuentasCBU AS
	Select a.Nro_cuenta, a.Nro_Cliente, a.Cbu, a.Estado
    from cuentas as a inner join clientes as b on a.Nro_cliente = b.Nro_Cliente;
/* procedimiento almacenado para hacer el alta de un cliente junto con su usuario en la tabla usuario*/


DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spAltaCliente(
    IN _Dni varchar(10),
    IN _Cuil varchar(15),
    IN _Nombre varchar(30),
    IN _Apellido varchar(30),
    IN _Cod_Genero int,
    IN _Cod_nacionalidad int,
    IN _Fecha_nac varchar(10),
    IN _Direccion varchar(50),
    IN _Cod_provincia int,
    IN _Cod_localidad int,
    IN _Email varchar(80),
    IN _Telefono char(11),
    IN _Usuario varchar(30),
    IN _Contraseña varchar(50),
    IN _Estado bool
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		SHOW ERRORS LIMIT 1;
    ROLLBACK;
    END;

    START TRANSACTION;

	INSERT INTO usuarios(Usuario,Tipo_Us,Contraseña,Estado) VALUES(_Usuario,2,_Contraseña,1); 
    
	INSERT INTO clientes (Dni,Cuil,Nombre,Apellido,Cod_Genero,Cod_nacionalidad,Fecha_nac,Direccion,Cod_provincia,Cod_localidad,Email,Telefono,Usuario,Estado)
	VALUES (_Dni,_Cuil,_Nombre,_Apellido,_Cod_Genero,_Cod_nacionalidad,_Fecha_nac,_Direccion,_Cod_provincia,_Cod_localidad,_Email,_Telefono,_Usuario,_Estado);

    COMMIT WORK;

END$$
DELIMITER ;


/* procedimiento almacenado para hacer el alta de cuenta y devuelve el nro de cuenta asignado o error con su cod -1 */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spAltaCuenta(
  IN _Nro_cliente int(11),
  IN _Tipo_cuenta int(11),
  IN _Cbu varchar(50),
  IN _Saldo float,
  IN _Estado tinyint(1)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;

	INSERT INTO cuentas(Nro_cliente,Fecha_creacion,Tipo_cuenta,Cbu,Saldo,Estado) VALUES(_Nro_cliente,CURDATE(),_Tipo_cuenta,_Cbu,_Saldo,1); 
    
	SELECT LAST_INSERT_ID() INTO @Nro_cuenta;
    
	/* Registro el movimiento */
	INSERT INTO movimientos (Nro_cuenta,Fecha,Tipo_mov,Importe,Detalle)
	VALUES (@Nro_cuenta,NOW(),1,_Saldo,'Alta Cuenta con Saldo Inicial');
    
    SELECT @Nro_cuenta AS NRO;
    
    COMMIT WORK;

END$$
DELIMITER ;

/* procedimiento almacenado para generar las cuotas del prestamo aprobado */

DELIMITER $$
CREATE PROCEDURE spGenerarCuotasPrestamo(IN _Nro_prestamo int)
BEGIN
  SELECT Cant_cuotas INTO @Nro_Cuota FROM prestamos WHERE Nro_prestamo=_Nro_prestamo;
  WHILE @Nro_Cuota > 0 DO
    INSERT INTO prestamoscuotas (Nro_prestamo,Nro_cuota,Monto_cuota,Fecha_Vencimiento,Pagado)
    SELECT Nro_prestamo,@Nro_Cuota,Monto_pago_por_mes,DATE_ADD(CURDATE(), INTERVAL @Nro_Cuota MONTH),false
    FROM prestamos 
    WHERE Nro_prestamo=_Nro_prestamo;
	/*siguiente cuota*/
    SET @Nro_Cuota = @Nro_Cuota - 1;
  END WHILE;
END$$
DELIMITER ;

/* spAltaPrestamo */
/* Realiza un Alta prestamo en estado Pendiente */
/* Retornos: N>0 (exitoso: nro de prestamo)    -1 (Error Sql) */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spAltaPrestamo(
  IN _Nro_cliente int,
  IN _Imp_solicitado float,
  IN _Imp_con_intereses float,
  IN _Nro_cuenta_deposito int,
  IN _Plazo_pago_meses int,
  IN _Cant_cuotas int
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;
    
	INSERT INTO prestamos
	(Nro_cliente,Fecha,Imp_con_intereses,Imp_solicitado,Nro_cuenta_deposito,Plazo_pago_meses,Monto_pago_por_mes,Cant_cuotas,Est_prestamo)
	VALUES
	(_Nro_cliente,CURDATE(),_Imp_con_intereses,_Imp_solicitado,_Nro_cuenta_deposito,_Plazo_pago_meses,ROUND(_Imp_con_intereses/_Cant_cuotas,2),_Cant_cuotas,3);
    

	SELECT LAST_INSERT_ID() INTO @Nro_prestamo;
    
    SELECT @Nro_prestamo AS NRO;

    COMMIT WORK;

END$$
DELIMITER ;


/* spAprobarPrestamo */
/* Aprueba el prestamo, actualizando su estado a aprobado, */
/* actualiza el saldo en la cuenta, agrega un movimiento y genera las cuotas */
/* Retornos: 1 (exitoso)    0 (No hizo nada)    -1 (Error Sql) */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spAprobarPrestamo(
  IN _Nro_prestamo int(11)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;
    
    /* Guardo en variables datos para actualizacion de tablas */
    SELECT Est_prestamo, Imp_solicitado, Nro_cuenta_deposito INTO @estado_anterior, @Imp_solicitado, @Nro_cuenta  FROM prestamos
    WHERE Nro_prestamo = _Nro_prestamo ;
    
    /* Si el estado anterior es distinto de aprobado */
    IF ( @estado_anterior <> 1 ) THEN

		/* Pongo estado del prestamo en aprobado */
		UPDATE prestamos SET Est_prestamo = 1 WHERE Nro_prestamo = _Nro_prestamo;

		/* Actualizo saldo cuenta */
        UPDATE cuentas SET saldo = saldo + @Imp_solicitado
        WHERE Nro_cuenta = @Nro_cuenta ;
        
		/* Registro el movimiento */
		INSERT INTO movimientos (Nro_cuenta,Fecha,Tipo_mov,Importe,Detalle)
		VALUES (@Nro_cuenta,NOW(),2,@Imp_solicitado,'Prestamo Aprobado y Deposito');
        
        /* Genero las cuotas a pagar */
        CALL spGenerarCuotasPrestamo(_Nro_prestamo);
        
       	SELECT 1 AS NRO;
 
	ELSE 
    
		SELECT 0 AS NRO;
        
    END IF;

    COMMIT WORK;

END$$
DELIMITER ;

/* spRechazarPrestamo */
/* Rechaza el prestamo, actualizando el estado a rechazado, */
/* Retornos: 1 (exitoso)    0 (No hizo nada)    -1 (Error Sql) */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spRechazarPrestamo(
  IN _Nro_prestamo int(11)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		/* SHOW ERRORS LIMIT 1; */
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;
    
    /* Guardo en variables datos para actualizacion de tablas */
    SELECT Est_prestamo, Imp_solicitado, Nro_cuenta_deposito INTO @estado_anterior, @Imp_solicitado, @Nro_cuenta  FROM prestamos
    WHERE Nro_prestamo = _Nro_prestamo ;
    
    /* Si el estado anterior es distinto de aprobado */
    IF ( @estado_anterior <> 2 ) THEN

		/* Pongo estado del prestamo en rechazado */
		UPDATE prestamos SET Est_prestamo = 2 WHERE Nro_prestamo = _Nro_prestamo;

       	SELECT 1 AS NRO;
 
	ELSE 
    
		SELECT 0 AS NRO;
        
    END IF;

    COMMIT WORK;

END$$
DELIMITER ;

/* spPagarCuotaPrestamo */
/* Pone el estado en Pagado en la tabla prestamoCuotas,  */
/* descuenta la cuota del saldo en la cuenta y se agrega un movimiento */
/* Retornos: 1 (exitoso)    0 (No hizo nada)    -1 (Error Sql) */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spPagarCuotaPrestamo(
  IN _Nro_prestamo int(11),
  IN _Nro_cuota int
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;
    
    /* Guardo en variables datos para actualizacion de tablas */
    SELECT Pagado, Monto_cuota,prestamos.Nro_cuenta_deposito INTO @Pagado, @Monto_cuota,@Nro_Cuenta  FROM prestamosCuotas
	JOIN prestamos ON prestamos.Nro_prestamo = prestamoscuotas.Nro_prestamo
    WHERE prestamoscuotas.Nro_prestamo = _Nro_prestamo AND Nro_Cuota = _Nro_Cuota;
    
    SELECT saldo into @Saldo from cuentas where Nro_Cuenta = @Nro_Cuenta ;
    
    /* Si el estado anterior es distinto de aprobado */
    IF ( @Pagado <> true AND @Saldo >= @Monto_cuota) THEN

		/* Pongo la cuota del prestamo en pagado*/
		UPDATE prestamosCuotas SET Pagado = true
        WHERE Nro_prestamo = _Nro_prestamo AND Nro_Cuota = _Nro_Cuota;

		/* Actualizo saldo cuenta */
        UPDATE cuentas SET saldo = saldo - @Monto_cuota
        WHERE Nro_Cuenta = @Nro_Cuenta ;
        
        UPDATE prestamos SET Cant_cuotas = Cant_cuotas - 1 WHERE Nro_prestamo = _Nro_prestamo;
        
		/* Registro el movimiento */
		INSERT INTO movimientos (Nro_cuenta,Fecha,Tipo_mov,Importe,Detalle)
		VALUES (@Nro_cuenta,NOW(),3,@Monto_cuota*(-1),
        CONCAT('Pago Cuota ',_Nro_Cuota, '  Prestamo No',_Nro_prestamo));
        
       
       SELECT 1 AS NRO;
 
	ELSE
    
		SELECT 0 AS NRO;
        
    END IF;

    COMMIT WORK;

END$$
DELIMITER ;


/* spEjecutarTransferencia */
/* Ejecuta transferencia de fondos, actualizando el saldo de ambas cuentas,  */
/* y agrega un movimiento en cada cuenta*/
/* Retornos: 1 (exitoso)   -1 (Error Sql) */

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spEjecutarTransferencia(
  IN _Nro_cuenta_origen int(11),
  IN _Nro_cuenta_destino int(11),
  IN _Monto float
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;
    
    Select saldo into @Saldo from cuentas WHERE Nro_Cuenta = _Nro_Cuenta_Origen ;
    
    IF (@Saldo >= _Monto) THEN
    
		/* Actualizo saldo de la cuenta origen*/
		UPDATE cuentas SET saldo = saldo - _Monto
		WHERE Nro_Cuenta = _Nro_Cuenta_Origen ;
		
		/* Registro el movimiento de la cuenta origen */
		INSERT INTO movimientos (Nro_cuenta,Fecha,Tipo_mov,Importe,Detalle)
		VALUES (_Nro_Cuenta_Origen,NOW(),4,_Monto*(-1),CONCAT('Transferencia a la cuenta ',_Nro_cuenta_Destino));
	   
		/* Actualizo saldo de la cuenta destino*/
		UPDATE cuentas SET saldo = saldo + _Monto
		WHERE Nro_Cuenta = _Nro_Cuenta_Destino ;
		
		/* Registro el movimiento de la cuenta origen */
		INSERT INTO movimientos (Nro_cuenta,Fecha,Tipo_mov,Importe,Detalle)
		VALUES (_Nro_cuenta_destino,NOW(),4,_Monto,CONCAT('Transferencia de la cuenta ',_Nro_cuenta_Origen));
		
		SELECT 1 AS NRO;
	
    ELSE
		SELECT 0 AS NRO;
    END IF;
    
    COMMIT WORK;

END$$
DELIMITER ;

/* 
	spBajacliente
    - Elimina un cliente, su usuario y sus cuentas a partir del dni
    - Exitoso 1 - Fallo -1
*/

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE spBajaCliente(
  IN _Dni varchar(10)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT -1 AS NRO;	/* SI HAY ERROR DEVUELVE -1 */
    ROLLBACK;
    END;

    START TRANSACTION;
    
	SELECT Nro_Cliente, Usuario INTO @Nro_Cliente, @Usuario FROM clientes WHERE Dni = _Dni;
	UPDATE clientes SET Estado = 0 WHERE Nro_Cliente = @Nro_Cliente; 
	UPDATE usuarios SET Estado = 0 WHERE Usuario = @Usuario;

	SELECT Nro_Cuenta INTO @Nro_Cuenta FROM cuentas WHERE Nro_Cliente = @Nro_Cliente;
	UPDATE cuentas SET Estado = 0 WHERE Nro_Cuenta = @Nro_Cuenta;
    
	SELECT @Nro_Cliente AS NRO;

    COMMIT WORK;

END$$
DELIMITER ;

/* Carga de datos */

INSERT INTO tiposUsuarios (Tipo_us,Descripcion) VALUES ('1','Admin');
INSERT INTO tiposUsuarios (Tipo_us,Descripcion) VALUES ('2','Cliente');


INSERT INTO usuarios(Usuario,Tipo_Us,Contraseña,Estado) 
SELECT 'admin',1,'admin',1;

INSERT INTO generos (Cod_genero,Descripcion) VALUES ('1','Masculino');
INSERT INTO generos (Cod_genero,Descripcion) VALUES ('2','Femenino');
INSERT INTO generos (Cod_genero,Descripcion) VALUES ('3','Otro');


INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('1','Argentina');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('2','Uruguay');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('3','Chile');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('4','Bolivia');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('5','Paraguay');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('6','Peru');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('7','Colombia');
INSERT INTO nacionalidad (Cod_nacionalidad,Descripcion) VALUES ('8', 'Brasil');


INSERT INTO provincias (Cod_provincia,Descripcion) VALUES ('1','Buenos Aires');
INSERT INTO provincias (Cod_provincia,Descripcion) VALUES ('2','Cordoba');
INSERT INTO provincias (Cod_provincia,Descripcion) VALUES ('3','Santa Fe');
INSERT INTO provincias (Cod_provincia,Descripcion) VALUES ('4','Entre Rios');
INSERT INTO provincias (Cod_provincia,Descripcion) VALUES ('5','Corrientes');



INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('1','1','Tígre');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('1','2','San Isidro');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('1','3','Escobar');

INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('2','1','Villa María');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('2','2','Cosquín');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('2','3','Mina Clavero');

INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('3','1','Rosario');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('3','2','San Lorenzo');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('3','3','Rafaela');

INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('4','1','Paraná');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('4','2','Colón');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('4','3','Concordía');

INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('5','1','Saladas');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('5','2','Yapeyú');
INSERT INTO localidades (Cod_provincia,Cod_localidad,Descripcion) VALUES ('5','3','Empedrado');




INSERT INTO tiposMovimientos (Tipo_Mov,Descripcion) VALUES ('1','Alta de cuenta');
INSERT INTO tiposMovimientos (Tipo_Mov,Descripcion) VALUES ('2','Alta de Prestamo');
INSERT INTO tiposMovimientos (Tipo_Mov,Descripcion) VALUES ('3','Pago de Prestamo');
INSERT INTO tiposMovimientos (Tipo_Mov,Descripcion) VALUES ('4','Transferencia');


INSERT INTO tiposCuentas (Tipo_cuenta,Descripcion) VALUES ('1','Caja de Ahorro');
INSERT INTO tiposCuentas (Tipo_cuenta,Descripcion) VALUES ('2','Cuenta Corriente');


INSERT INTO estadosPrestamos (Est_prestamo,Descripcion) VALUES ('1','Aprobado');
INSERT INTO estadosPrestamos (Est_prestamo,Descripcion) VALUES ('2','Rechazado');
INSERT INTO estadosPrestamos (Est_prestamo,Descripcion) VALUES ('3','Pendiente');



CALL spAltaCliente('42536985','20425369857','Maria','Suarez',2,1,'9/11/1998','Garcia 1234',1,1,'Maria@gmail.com','1136985164','MariSua','1234',1);
CALL spAltaCliente('219863578','192198635786','Juan','Rez',1,2,'4/1/1988','Marquez 1658',2,1,'Juan@gmail.com','1169835476','JuanRez','1234',1);
CALL spAltaCliente('19632004','16196320047','Carlos','Garcia',2,3,'4/10/1972','Gilguero 5562',3,1,'Carlos@gmail.com','1188635492','CarlosCia','1234',1);
CALL spAltaCliente('35986584','19359865843','Macarena','Peralta',2,4,'1/1/1999','Azucenas 5623',4,1,'Macarena@gmail.com','1154789625','MacaPer','1234',1);
CALL spAltaCliente('22560089','19225600895','Karina','Galmarini',2,5,'12/11/1975','Las Violetas 4521',5,1,'Karina@gmail.com','1142006933','KarinaGalma','1234',1);
CALL spAltaCliente('32960557','17329605574','Facundo','Olmos',1,1,'5/5/2000','Golondrina 1115',1,2,'Facundo@gmail.com','110300478','FacuOlmos','1234',1);
CALL spAltaCliente('40963663','20409636632','Carla','Pereyra',2,2,'6/9/1965','Sarmiento 1644',2,2,'Carla@gmail.com','1125229871','CarlaEyra','1234',1);
CALL spAltaCliente('22690056','14226900563','Eugenia','Prado',2,4,'11/11/1953','Cabral 2134',3,2,'Eugenia@gmail.com','1134996870','EugePrado','1234',1);
CALL spAltaCliente('11369856','14113698566','Julieta','Ricardi',2,8,'24/2/1978','Picaflor 8859',4,2,'Julieta@gmail.com','1154112058','JuliRicardi','1234',1);
CALL spAltaCliente('40632632','19406326322','Fernando','Loto',1,1,'1/8/1978','Madreselvas 2939',1,3,'Fernando@gmail.com','1161645265','FerLoto','1234',1);
CALL spAltaCliente('43395566','20433955667','Juliana','Gallo',2,1,'11/6/2001','Las Rosas 2010',1,3,'Juliana@gmail.com','1155489632','JuliGallo','1234',1);
CALL spAltaCliente('35965896','19359658967','Damian','Retamar',1,5,'25/12/2001','Las Violetas 4614',5,2,'Damian@gmail.com','1145963002','DamianMar','1234',1);
CALL spAltaCliente('29365963','15293659636','Pedro','Monzon',1,1,'6/10/1954','Horneros 5569',2,3,'Pedro@gmail.com','1147899896','PedroMon','1234',1);
CALL spAltaCliente('30596001','16293659632','Matias','Rodolfi',1,7,'12/12/1981','Tapia 2653',3,3,'Matias@gmail.com','1141587258','MatiRodolfi','1234',1);
CALL spAltaCliente('42823977','20428239777','Silvia','Ponce',2,1,'31/1/1984','Sansouci 4321',4,3,'Silvia@gmail.com','1125031718','SilviPonce','1234',1);


CALL spAltaCuenta(5,1,'000020302345',20000,1);
CALL spAltaCuenta(1,1,'000298329136',40000,1);
CALL spAltaCuenta(2,1,'000034349340',20000,1);
CALL spAltaCuenta(2,1,'000094984329',20000,1);
CALL spAltaCuenta(2,2,'000923949123',30000,1);
CALL spAltaCuenta(3,2,'000928395489',40000,1);

/* sp para crear prestamos en estado pendiente*/
CALL spAltaPrestamo(1,20000,40000,1,12,12);
CALL spAltaPrestamo(3,40000,60000,1,6,6);
CALL spAltaPrestamo(6,60000,80000,2,9,9);
CALL spAltaPrestamo(4,80000,100000,2,24,24);
CALL spAltaPrestamo(2,100000,120000,3,12,12);
CALL spAltaPrestamo(5,10000,30000,3,6,6);
CALL spAltaPrestamo(7,30000,50000,4,24,24);
CALL spAltaPrestamo(8,50000,70000,4,12,12);
CALL spAltaPrestamo(9,70000,90000,5,6,6);
CALL spAltaPrestamo(10,90000,110000,5,9,9);
CALL spAltaPrestamo(11,120000,140000,6,12,12);
CALL spAltaPrestamo(12,140000,160000,6,12,12);
CALL spAltaPrestamo(13,160000,180000,1,24,24);
CALL spAltaPrestamo(14,180000,200000,2,9,9);
CALL spAltaPrestamo(15,130000,150000,3,6,6);
CALL spAltaPrestamo(1,150000,170000,4,12,12);

/* sp para generar movimientos (el reachazado no genera ningun movimiento)*/

CALL spAprobarPrestamo(2);
CALL spAprobarPrestamo(6);
CALL spAprobarPrestamo(10);
CALL spAprobarPrestamo(14);

CALL spEjecutarTransferencia(1,3,5000);
CALL spEjecutarTransferencia(5,4,29000);
CALL spEjecutarTransferencia(4,6,3000);
CALL spEjecutarTransferencia(3,5,4000);



/* cambio las fechas para que se filtren mejor los resportes*/
update prestamos set fecha = '2020-01-01' where Nro_prestamo = 1 ;
update prestamos set fecha = '2020-03-15' where Nro_prestamo = 2 ;
update prestamos set fecha = '2020-12-30' where Nro_prestamo = 3 ;
update prestamos set fecha = '2020-09-01' where Nro_prestamo = 4 ;
update prestamos set fecha = '2021-01-15' where Nro_prestamo = 5 ;
update prestamos set fecha = '2021-03-30' where Nro_prestamo = 6 ;
update prestamos set fecha = '2021-12-01' where Nro_prestamo = 7 ;
update prestamos set fecha = '2021-09-15' where Nro_prestamo = 8 ;
update prestamos set fecha = '2022-01-30' where Nro_prestamo = 9 ;
update prestamos set fecha = '2022-03-01' where Nro_prestamo = 10 ;
update prestamos set fecha = '2022-12-15' where Nro_prestamo = 11 ;
update prestamos set fecha = '2022-09-30' where Nro_prestamo = 12 ;
update prestamos set fecha = '2020-06-01' where Nro_prestamo = 13 ;
update prestamos set fecha = '2021-06-15' where Nro_prestamo = 14 ;
update prestamos set fecha = '2022-06-30' where Nro_prestamo = 15 ;
update prestamos set fecha = '2022-07-11' where Nro_prestamo = 16 ;

update movimientos set fecha = '2020-02-11' where Nro_movimiento = 1 ;
update movimientos set fecha = '2020-03-21' where Nro_movimiento = 2 ;
update movimientos set fecha = '2020-04-12' where Nro_movimiento = 3 ;
update movimientos set fecha = '2020-05-16' where Nro_movimiento = 4 ;
update movimientos set fecha = '2021-02-16' where Nro_movimiento = 5 ;
update movimientos set fecha = '2021-03-12' where Nro_movimiento = 6 ;
update movimientos set fecha = '2021-04-21' where Nro_movimiento = 7 ;
update movimientos set fecha = '2021-05-11' where Nro_movimiento = 8 ;
update movimientos set fecha = '2022-02-11' where Nro_movimiento = 9 ;
update movimientos set fecha = '2022-03-12' where Nro_movimiento = 10 ;
update movimientos set fecha = '2020-01-01' where Nro_movimiento = 11 ;
update movimientos set fecha = '2021-06-15' where Nro_movimiento = 12 ;
update movimientos set fecha = '2022-12-30' where Nro_movimiento = 13 ;
update movimientos set fecha = '2020-06-01' where Nro_movimiento = 14 ;
update movimientos set fecha = '2021-12-15' where Nro_movimiento = 15 ;
update movimientos set fecha = '2022-06-30' where Nro_movimiento = 16 ;
update movimientos set fecha = '2020-12-01' where Nro_movimiento = 17 ;
update movimientos set fecha = '2021-01-15' where Nro_movimiento = 18 ;
update movimientos set fecha = '2022-04-21' where Nro_movimiento = 19 ;
update movimientos set fecha = '2022-05-12' where Nro_movimiento = 20 ;
update movimientos set fecha = '2020-07-26' where Nro_movimiento = 21 ;
update movimientos set fecha = '2020-09-14' where Nro_movimiento = 22 ;


