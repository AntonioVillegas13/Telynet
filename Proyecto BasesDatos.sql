USE MASTER 
GO
DROP DATABASE IF EXISTS Telynet_P1
GO
create database Telynet_P1
GO
use Telynet_P1
go 

-- ELABORACIÓN DE LA REGLA PARA RUC CON FORMATO DEL SRI
-- se verifica que termine los 3 ultimos digitos en 001 y que los dos primeros digitos sean de las provincias 1 a 24
-- AUTOR: leonardo Carvajal 
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP RULE IF EXISTS ruc_rule
Go

CREATE RULE ruc_rule 
AS @ruc LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
   AND CAST(LEFT(@ruc,2) AS INT) BETWEEN 1 AND 24
   AND SUBSTRING(@ruc,11,3) = '001'
GO

-- ELABORACIÓN DEL TIPO DE DATO PARA EL RUC
-- AUTOR: Leonardo Carvajal  
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN:07/05/2023
DROP TYPE IF EXISTS ruc
GO

CREATE TYPE ruc FROM CHAR(13) NOT NULL;
GO
-- ENLAZAR LA REGLA ruc_rule AL TIPO DE DATO ruc
-- AUTOR: Leonardo Carvajal  
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN:07/05/2023
EXEC sp_bindrule ruc_rule,'ruc';
GO

-- ELABORACIÓN DE UNA REGLA PARA LA CEDULA QUE PERMITA INGRESAR SOLO 10 NÚMEROS
-- Y QUE CONTROLE LOS DOS PRIMEROS CARACTERES SEGUN LAS PROVINCIAS EXISTENTES
-- ADEMAS DEL CONTROL DE VERIFICACION DEL ULTIMO DIGITO
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP RULE IF EXISTS cedula_rule
GO

CREATE RULE cedula_rule
AS @cedula LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 
    AND CAST(LEFT(@cedula,2) AS INT) BETWEEN 1 AND 24 OR CAST(LEFT(@cedula,2) AS INT) = 30
    AND CAST(SUBSTRING(@cedula,3,1) AS INT) < 6
    AND RIGHT(@cedula,1) = CAST(
        ((11 - (
            CAST(LEFT(@cedula,1) AS INT) * 2 +
            CAST(SUBSTRING(@cedula,2,1) AS INT) * 1 +
            CAST(SUBSTRING(@cedula,3,1) AS INT) * 2 +
            CAST(SUBSTRING(@cedula,4,1) AS INT) * 1 +
            CAST(SUBSTRING(@cedula,5,1) AS INT) * 2 +
            CAST(SUBSTRING(@cedula,6,1) AS INT) * 1 +
            CAST(SUBSTRING(@cedula,7,1) AS INT) * 2 +
            CAST(SUBSTRING(@cedula,8,1) AS INT) * 1
        ) % 11))
        % 10 AS VARCHAR(1));
GO

-- ELABORACIÓN DEL TIPO DE DATO PARA LA CEDULA
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TYPE IF EXISTS cedula
GO

CREATE TYPE cedula FROM CHAR(10) NOT NULL;
GO
----ENLACE DE LA REGLA cedula_rule AL TIPO DE DATO cedula
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
EXEC sp_bindrule cedula_rule,'cedula';
GO

-- ELABORACIÓN DE UNA REGLA PARA EL MAIL QUE CONTROLE QUE SE INGRESE DATOS QUE TENGAN @ Y EL PUNTO (.)
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP RULE IF EXISTS mail_rule
Go

CREATE RULE mail_rule 
AS @mail LIKE '%_@__%.__%'; 
GO

-- ELABORACIÓN DEL TIPO DE DATO PARA EL MAIL
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TYPE IF EXISTS mail
GO

CREATE TYPE mail FROM VARCHAR(50) NOT NULL;
GO

-- ENLAZAR LA REGLA mail_rule AL TIPO DE DATO mail
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
EXEC sp_bindrule mail_rule,'mail';
GO

-- ELABORACIÓN DE LA REGLA PARA LA FACTURA
-- AUTOR: leonardo Carvajal 
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP RULE IF EXISTS factura_rule
Go

CREATE RULE factura_rule 
AS @factura LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
GO

-- ELABORACIÓN DEL TIPO DE DATO PARA LA FACTURA
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TYPE IF EXISTS factura
GO

CREATE TYPE factura FROM CHAR(15) NOT NULL;
GO

-- ENLAZAR LA REGLA factura_rule AL TIPO DE DATO factura
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
EXEC sp_bindrule factura_rule,'factura';
GO

-- CREACION DE LA TABLA DE CATEGORIAS
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Categorias
GO

CREATE TABLE Categorias(
	[Id_categoria] [int] IDENTITY(1,1) NOT NULL,
	[Nombre_categoria] [varchar](50) NOT NULL,
	[Descripcion] [varchar](150) NULL,
 CONSTRAINT [PK_Categorias] PRIMARY KEY (Id_categoria)
 ) 
GO

-- CREACION DE LA TABLA DE PRODUCTOS
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Productos
GO

CREATE TABLE Productos(
	[Id_producto] [int] IDENTITY(1,1) NOT NULL,
	[Id_categoria] [int] NOT NULL,
	[Nombre_producto] [varchar](100) NOT NULL,
	[Valor_unitario] [money] DEFAULT 0 NULL,
	[Stock] [int] DEFAULT 0 NULL,
	[Stock_minimo] [int] DEFAULT 5 NULL,
	[Stock_maximo] [int] DEFAULT 15 NULL,
 CONSTRAINT PK_Productos PRIMARY KEY (Id_producto),
 CONSTRAINT FK_Productos_Categorias FOREIGN KEY(Id_categoria) REFERENCES Categorias(Id_categoria)
)
GO

DROP TABLE IF EXISTS Notificaciones_productos
GO
-- Tabla en la cual se registran aquellos productos cuyo stock sean menores al stock minimo
-- Esta tabla historica permitira consultar los productos que requieren una compra del mismo e informar a Telynet
CREATE TABLE Notificaciones_productos(
    [Id_notificacion_producto] [int] IDENTITY(1,1) NOT NULL,
	[Id_producto] [int] NOT NULL,
	[Fecha_notificacion] date NOT NULL,
	[Stock_actual] [int] DEFAULT 0 NOT NULL,
	[Stock_minimo] [int] DEFAULT 0 NOT NULL,
	[Stock_maximo] [int] DEFAULT 0 NOT NULL,
 CONSTRAINT PK_Notificaciones_productos PRIMARY KEY (Id_notificacion_producto),
 CONSTRAINT FK_Notificaciones_Productos_Categorias FOREIGN KEY(Id_producto) REFERENCES Productos(Id_producto)
)
GO

-- CREACION DE LA TABLA DE PROVEEDORES
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Proveedores
GO

CREATE TABLE Proveedores(
	[Ruc] ruc NOT NULL,  -- se asocia a tipo de dato ruc creado por usuario
	[Nombre] [varchar](30) NOT NULL,
	[Direccion] [varchar](50) NULL,
	[Telefono_fijo] [char](9) NULL,
	[Telefono_celular] [char](10) NOT NULL,
	[Web] [varchar](30) NULL,
	[Mail] mail NOT NULL,  -- se asocia a tipo de dato mail creado por usuario
 CONSTRAINT PK_Proveedores PRIMARY KEY (Ruc),
 CONSTRAINT CK_Proveedores_Telefono_f CHECK(Telefono_fijo IS NULL OR (LEN(Telefono_fijo)=9 AND Telefono_fijo LIKE
'[0][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')),
 CONSTRAINT CK_Proveedores_Telefono_c CHECK(LEN(Telefono_celular)=10 AND Telefono_celular LIKE
'[0][9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
 )
GO

-- CREACION DE LA TABLA DE COMPRAS
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Compras
GO

CREATE TABLE Compras(
	[Id_compra] [int] IDENTITY(1,1) NOT NULL,
	[Id_producto] [int] NOT NULL,
	[Ruc] ruc NOT NULL, -- se asocia a tipo de dato ruc creado por usuario
	[Fecha] [date] DEFAULT GETDATE() NOT NULL,
	[Cantidad] [smallint] DEFAULT 1 NOT NULL,
	[Valor] [money] DEFAULT 0 NOT NULL,
	[Factura_compra] factura NOT NULL, -- se asocia a tipo de dato factura creado por usuario
 CONSTRAINT PK_Compras PRIMARY KEY (Id_compra),
 CONSTRAINT FK_Compras_Productos FOREIGN KEY(Id_producto) REFERENCES Productos (Id_producto),
 CONSTRAINT FK_Compras_Proveedores FOREIGN KEY(Ruc) REFERENCES Proveedores (Ruc),
 CONSTRAINT CH_Compras_Fecha CHECK (Fecha <= GETDATE() 
	AND TRY_CONVERT(DATE, Fecha) IS NOT NULL)
)
GO

-- CREACION DE LA TABLA DE CLIENTES
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Clientes
GO

CREATE TABLE Clientes(
	[Cedula_cliente] cedula NOT NULL,
	[Nombre_cliente] [varchar](50) NOT NULL,
	[Mail] mail NOT NULL,
	[Direccion] [varchar](30) NULL,
	[Telefono_celular] [char](10) NOT NULL,
 CONSTRAINT [PK_Clientes] PRIMARY KEY (Cedula_cliente),
 CONSTRAINT CK_Clientes_Telefono_c CHECK(LEN(Telefono_celular)=10 AND Telefono_celular LIKE
'[0][1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
 )
 GO

-- CREACION DE LA TABLA DE VENTAS
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Ventas
GO

CREATE TABLE Ventas(
	[Numero_factura] factura NOT NULL,
	[Id_producto] [int] NOT NULL,
	[Cedula_cliente] cedula NOT NULL,
	[Cantidad] [smallint] DEFAULT 1 NOT NULL,
	[Descuento] [float] DEFAULT 0 NULL,
	[Monto_final] [money] DEFAULT 0 NOT NULL,
	[Fecha_venta] [date] DEFAULT GETDATE() NOT NULL,
 CONSTRAINT PK_Ventas PRIMARY KEY (Numero_factura, Id_producto),
 CONSTRAINT FK_Ventas_Clientes FOREIGN KEY(Cedula_cliente) REFERENCES Clientes (Cedula_cliente),
 CONSTRAINT FK_Ventas_Productos FOREIGN KEY(Id_producto) REFERENCES Productos (Id_producto),
 CONSTRAINT CK_Ventas_Descuento CHECK (Descuento between 0 and 0.1)
 )
GO

-- CREACION DE LA TABLA DE NOVEDADES
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Novedades
GO

CREATE TABLE Novedades(
	[Id_novedad] [int] IDENTITY(1,1) NOT NULL,
	[Cedula_cliente] cedula NOT NULL,
	[Descripcion_novedad] [varchar](200) NOT NULL,
	[Fecha_novedad] [date] DEFAULT GETDATE() NOT NULL,
 CONSTRAINT PK_Novedades PRIMARY KEY (Id_novedad), 
 CONSTRAINT FK_Novedades_Clientes FOREIGN KEY(Cedula_cliente) REFERENCES Clientes (Cedula_cliente),
 CONSTRAINT CH_Novedades_Fecha_novedad CHECK (Fecha_novedad <= GETDATE() 
	AND TRY_CONVERT(DATE, Fecha_novedad) IS NOT NULL)
)
GO

-- CREACION DE LA TABLA DE TECNICOS
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Tecnicos
GO

CREATE TABLE Tecnicos(
	[Cedula_tecnico] cedula NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Cargo] [varchar](20) NOT NULL,
	[Telefono_celular] [char](10) NOT NULL,
	[Direccion] [varchar](50) NULL,
 CONSTRAINT [PK_Tecnicos] PRIMARY KEY (Cedula_tecnico),
 CONSTRAINT CK_Tecnicos_Telefono_c CHECK(LEN(Telefono_celular)=10 AND Telefono_celular LIKE
 '[0][9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
)
GO

-- CREACION DE LA TABLA DE ATENCIONES
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Atenciones
GO

CREATE TABLE Atenciones(
	[Id_novedad] [int] NOT NULL,
	[Cedula_tecnico] [char](10) NOT NULL,
	[Fecha_asignacion] [date] DEFAULT GETDATE() NOT NULL,
 CONSTRAINT [PK_Atenciones] PRIMARY KEY (Id_novedad, Cedula_tecnico),
 CONSTRAINT FK_Atenciones_Novedades FOREIGN KEY(Id_novedad) REFERENCES Novedades (Id_novedad),
 CONSTRAINT FK_Atenciones_Tecnicos  FOREIGN KEY(Cedula_tecnico) REFERENCES Tecnicos (Cedula_tecnico),
 CONSTRAINT CH_Atenciones_Fecha_novedad CHECK (Fecha_asignacion <= GETDATE() 
	AND TRY_CONVERT(DATE, Fecha_asignacion) IS NOT NULL)
)
GO

-- CREACION DE LA TABLA DE DETALLE ATENCIONES
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TABLE IF EXISTS Detalle_atenciones
GO

CREATE TABLE Detalle_atenciones(
	[Id_detalle_atencion] [int] IDENTITY(1,1) NOT NULL,
	[Id_novedad] [int] NOT NULL,
	[Cedula_tecnico] cedula NOT NULL,
	[Fecha_atencion] [date] DEFAULT GETDATE() NOT NULL,
	[Observacion] [varchar](200) NOT NULL,
	[Estado] [varchar](10) NOT NULL,
 CONSTRAINT PK_Detalle_atenciones PRIMARY KEY (Id_detalle_atencion),
 CONSTRAINT FK_Detalle_atenciones_Atenciones FOREIGN KEY(Id_novedad, Cedula_tecnico) REFERENCES Atenciones (Id_novedad, Cedula_tecnico),
 CONSTRAINT CH_Detalle_Atenciones_Fecha_atencion CHECK (Fecha_atencion<= GETDATE() 
	AND TRY_CONVERT(DATE, Fecha_atencion) IS NOT NULL),
 CONSTRAINT CH_Detalle_Atenciones_Estado CHECK (Estado IN ('Abierto', 'Parcial', 'Problema', 'Resuelto')) 
)
GO

-- **************************************************************************************************
-- CREACION DE TRIGGER DE ACUERDO A REGLAS DE NEGOCIO
-- **************************************************************************************************

-- Trigger que se dispara cuando se inserta o actualiza el stock con un valor menor al stock minimo
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TRIGGER IF EXISTS tr_stock_minimo;
GO

CREATE TRIGGER tr_stock_minimo 
ON Productos
FOR INSERT, UPDATE
AS
BEGIN
    BEGIN TRANSACTION; -- Inicio de la transacción

    IF EXISTS (
        SELECT * FROM inserted dato
        WHERE dato.Stock < dato.Stock_minimo
    )
    BEGIN
        -- Se insertan en la tabla de notificaciones aquellos registros de productos que estén por debajo del valor del stock mínimo
        DECLARE @Fecha_venta date;
        DECLARE @Id_prod int;
        SELECT @Id_prod = dato.Id_producto FROM inserted dato;
        SELECT @Fecha_venta = V.Fecha_venta FROM Ventas V WHERE V.Id_producto = @Id_prod;

        INSERT INTO Notificaciones_productos (Id_producto, Fecha_notificacion, Stock_actual, Stock_minimo, Stock_maximo)
        SELECT dato.Id_producto, @Fecha_venta, dato.Stock, dato.Stock_minimo, dato.Stock_maximo
        FROM inserted dato;
    END
    ELSE
    BEGIN
        COMMIT; -- Confirmar la transacción si no se cumple la condición
    END

    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK; -- Rollback si se cumple la condición
    END
END;
GO



-- trigger que se dispara cuando se inserta o actualiza un registro en la tabla de compras, 
-- entonces se actualiza sumando el stock en la tabla de productos
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TRIGGER IF EXISTS tr_actualiza_stock_compra;
GO

CREATE TRIGGER tr_actualiza_stock_compra 
ON Compras
FOR INSERT, UPDATE
AS
BEGIN
    BEGIN TRANSACTION; -- Inicio de la transacción

    DECLARE @v_id_producto int;
    SELECT @v_id_producto = Id_producto FROM inserted;

    IF EXISTS (
        SELECT * FROM inserted Dato
        INNER JOIN Productos P ON Dato.Id_producto = P.Id_producto
    )
    BEGIN
        BEGIN TRY
            -- Actualizar el stock del producto
            UPDATE Productos
            SET Stock = (SELECT dato.Cantidad + Stock
                         FROM inserted dato
                         WHERE dato.Id_producto = Id_producto)
            WHERE Id_producto = @v_id_producto;

            COMMIT; -- Confirmar la transacción
        END TRY
        BEGIN CATCH
            ROLLBACK; -- Rollback en caso de error
            THROW; -- Lanzar la excepción
        END CATCH
    END
    ELSE
    BEGIN
        COMMIT; -- Confirmar la transacción si no se cumple la condición
    END
END;
GO


-- trigger que se dispara cuando se elimina un registro en la tabla de compras, 
-- entonces se actualiza restando el stock en la tabla de productos
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TRIGGER IF EXISTS tr_actualiza_stock_compra_elimina;
GO

CREATE TRIGGER tr_actualiza_stock_compra_elimina 
ON Compras
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    DECLARE @v_id_producto INT;
    SELECT @v_id_producto = Id_producto FROM deleted;

    IF EXISTS (
        SELECT *
        FROM deleted Dato
        INNER JOIN Productos P ON Dato.Id_producto = P.Id_producto
    )
    BEGIN
        UPDATE Productos
        SET Stock = Stock - (SELECT dato.Cantidad FROM deleted dato WHERE dato.Id_producto = Id_producto)
        WHERE Id_producto = @v_id_producto;
    END;

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK;
    END;
    ELSE
    BEGIN
        COMMIT;
    END;
END;
GO

-- trigger que se dispara cuando se inserta o actualiza un registro en la tabla de ventas,
-- entonces se actualiza restando el stock de la tabla de productos
-- a su vez actualiza el campo monto_final 
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TRIGGER IF EXISTS tr_actualiza_stock_venta 
GO

CREATE TRIGGER tr_actualiza_stock_venta 
ON Ventas
FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @v_stock int
	DECLARE @v_cantidad int

	SELECT @v_stock = P.Stock FROM inserted dato INNER JOIN Productos P ON dato.Id_producto = P.Id_producto
	SELECT @v_cantidad = Cantidad from inserted

--	print @v_stock 
--	print @v_cantidad  


	IF EXISTS (
		SELECT * FROM inserted dato
		INNER JOIN Productos P ON dato.Id_producto = P.Id_producto
	) 
	BEGIN
	    IF @v_stock < @v_cantidad
        BEGIN
			RAISERROR ('ERROR.  No existe el suficiente stock para la venta',16,1);
			ROLLBACK TRANSACTION;
		END
		ELSE
		BEGIN
			DECLARE @v_numero_factura factura;
			DECLARE @v_id_producto int;
			Select @v_numero_factura = Numero_factura, @v_id_producto = Id_producto from inserted;

			UPDATE Productos
			SET Stock= (
					SELECT Stock - dato.Cantidad
					FROM inserted dato
					Where dato.Id_producto = Id_producto AND Stock >= dato.cantidad
			  ) where Id_producto = @v_id_producto

			UPDATE Ventas
			SET Monto_final = (
				SELECT (dato.cantidad * P.Valor_unitario)*(1 - dato.Descuento)
				FROM inserted dato
				INNER JOIN Productos P ON dato.Id_producto = P.Id_producto) 
			WHERE Ventas.Numero_factura = @v_numero_factura
			AND Ventas.Id_producto = @v_id_producto
		END
	END
END;
GO


-- trigger que se dispara cuando se elimina un registro en la tabla de ventas,
-- entonces se actualiza sumando el stock de la tabla de productos
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
DROP TRIGGER IF EXISTS tr_actualiza_stock_venta_elimina;
GO

CREATE TRIGGER tr_actualiza_stock_venta_elimina 
ON Ventas
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    DECLARE @v_id_producto INT;
    SELECT @v_id_producto = Id_producto FROM deleted;

    IF EXISTS (
        SELECT *
        FROM deleted dato
        INNER JOIN Productos P ON dato.Id_producto = P.Id_producto
    )
    BEGIN
        UPDATE Productos
        SET Stock = Stock + (SELECT dato.Cantidad FROM deleted dato WHERE dato.Id_producto = Id_producto)
        WHERE Id_producto = @v_id_producto;
    END;

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK;
    END;
    ELSE
    BEGIN
        COMMIT;
    END;
END;
GO


-- trigger que se dispara un mail cuando se inserta un registro en la tabal de notificaciones productos,
-- ese registro se inserta, cuando el stock del producto es menor al stock_minimo 
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023

DROP TRIGGER IF EXISTS tr_enviar_mail;
GO

CREATE TRIGGER tr_enviar_mail
ON Notificaciones_productos
AFTER INSERT
AS 
BEGIN        
    SET NOCOUNT ON;
    
    DECLARE @body NVARCHAR(MAX);
    
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        SELECT @body = 'Notificacion de alerta. El stock del ID producto No. : ' + CAST(Id_producto AS VARCHAR(5)) +
            ' está por debajo del stock mínimo. Stock actual es: ' + CAST(Stock_actual AS VARCHAR(5)) +
            ' El stock mínimo es: ' + CAST(Stock_minimo AS VARCHAR(5))
        FROM inserted;
        
        EXEC msdb.dbo.sp_send_dbmail
            @recipients = 'luis.carvajal.jimenez@udla.edu.ec',
            @subject = 'Notificación de stock mínimo sobrepasado',
            @body = @body;
    END
END
GO

GO


-- **************************************************************************************************
-- DATOS BASE PARA VERIFICAR FUNCIONAMIENTO
-- **************************************************************************************************
INSERT INTO Categorias (Nombre_categoria, Descripcion)
     VALUES ('Bienes de Telecomunicacion', 'Productos de Venta de Telynet relacionadas a Telecomunicaciones')
GO
INSERT INTO Categorias (Nombre_categoria, Descripcion)
     VALUES ('Domotica', 'Productos de Venta de Telynet relacionadas a Domotica')
GO
INSERT INTO Categorias (Nombre_categoria, Descripcion)
     VALUES ('Servicios de Intenet Personas', 'Servicios de internet a personas o familias')
GO
INSERT INTO Categorias (Nombre_categoria, Descripcion)
     VALUES ('Servicios de Internet Empresas', 'Banda ancha a empresas')
GO
INSERT INTO Categorias (Nombre_categoria, Descripcion)
     VALUES ('Bienes de IoT', 'Productos de Venta de Telynet relacionadas a IoT')
GO

INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Router Cisco B-125', 1, 250.00, 10)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Access Point Ubiquit Unifi 6 Pro', 1, 200.00, 10)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Sistema Wifi TP-LINK Deco Wesh (DECOS4)', 1, 135.00, 10)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Amplificador WIFI 300Mb/extensor de alcance nalambrico', 1, 35.00, 20)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Sensor inalambrico WIFI para puertas y ventanas', 2, 20.00, 20)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Interruptor triple smart WIFI Dexel', 2, 28.00, 50)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Minienchufe inteligente WIFI conpatible con Alexa y Google', 2, 35.00, 50)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Interruptor WIFI de pared inteligente MOESGO', 2, 40.00, 50)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Nexx Interruptor inteligente NHE/S100/Empotrable', 2, 16.00, 50)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Adaptador WIFI UBold PRO Smart Deadbolt + bridge con bluetooth ', 2, 200.00, 50)
GO
INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
     VALUES ('Xiaomi Sensor de movimiento, puertas y ventanas, sensor 2', 2, 15.00, 50)
GO
-- select * from Productos;
--select * from Notificaciones_productos

INSERT INTO Proveedores (Ruc, Nombre, Direccion, Telefono_fijo, Telefono_celular, mail)
     VALUES ('1790610319001', 'TELALCA', null, null,'0994568213', 'contacto@telalca.com');
GO
INSERT INTO Proveedores (Ruc, Nombre, Direccion, Telefono_fijo, Telefono_celular, mail)
     VALUES ('1792078932001', 'TIENDAMANIA', null, null,'0987937005', 'contacto@tiendamania.com');
GO
INSERT INTO Proveedores (Ruc, Nombre, Direccion, Telefono_fijo, Telefono_celular, mail)
     VALUES ('0991327371001', 'TELCONET S.A.', null, null,'0983762065', 'contacto@telconet.com');
GO
INSERT INTO Proveedores (Ruc, Nombre, Direccion, Telefono_fijo, Telefono_celular, mail)
     VALUES ('1768152560001 ', 'CNT EP', null, null,'0996183293', 'contacto@cnt.com.ec');
GO
-- Select from Proveedores
--select * from productos
INSERT INTO Compras (Id_producto, Ruc, Cantidad, Valor, Factura_compra)
     VALUES (1, '1790610319001', 5, 200.00, '130001120000239')
GO
INSERT INTO Compras (Id_producto, Ruc, Cantidad, Valor, Factura_compra)
     VALUES (5, '1792078932001', 5, 15.00, '130120000022450')
GO
INSERT INTO Compras (Id_producto, Ruc, Cantidad, Valor, Factura_compra)
     VALUES (6, '1792078932001', 5, 20.00, '130120000022450')
GO
INSERT INTO Compras (Id_producto, Ruc, Cantidad, Valor, Factura_compra)
     VALUES (7, '1792078932001', 5, 27.00, '130120000022450')
GO
-- select * from Compras

INSERT INTO Clientes (Cedula_cliente, Nombre_cliente, mail, telefono_celular)
     VALUES ('1718658154', 'Leonardo Carvajal J', 'luis_leo@live.com', '0995674619')
GO
INSERT INTO Clientes (Cedula_cliente, Nombre_cliente, mail, telefono_celular)
     VALUES ('1784559964', 'Carlos Rosero', 'carlos.rosero@gmail.com', '0992769943')
GO
INSERT INTO Clientes (Cedula_cliente, Nombre_cliente, mail, telefono_celular)
     VALUES ('1719142905', 'Patricio Jaramillo Alvear', 'patricioja43@gmail.com', '0994279967')
GO
INSERT INTO Clientes (Cedula_cliente, Nombre_cliente, mail, telefono_celular)
     VALUES ('1752365841', 'Silvia Perez O', 'silvia.perez@hotmail.com', '0896079101')
GO
INSERT INTO Clientes (Cedula_cliente, Nombre_cliente, mail, telefono_celular)
     VALUES ('0701396830', 'Alvaro Gabriel Alonso', 'gabrielalonso3@gmail.com', '0984640233')
GO
INSERT INTO Clientes (Cedula_cliente, Nombre_cliente, mail, telefono_celular)
     VALUES ('1716742683', 'Maria Emilia Larrea', 'mari.emilialarrea@outlook.com', '0985116836')
GO
-- select * from Clientes
-- select * from productos
-- select * from Ventas
-- select * from Notificaciones_productos
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento,Fecha_venta)
     VALUES ('140130000250148', 1, '1718658154', 1, 0.05, '2023-02-15')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento,Fecha_venta)
     VALUES ('140130000250148', 2, '1718658154', 1, 0.05, '2023-02-15')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento,Fecha_venta)
     VALUES ('140130000250148', 5, '1718658154', 5, 0.05, '2023-02-15')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta)
     VALUES ('140130000250149', 5, '1716742683', 5, 0, '2023-02-20')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta)
     VALUES ('140130000250149', 6, '1716742683', 2, 0, '2023-02-20')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta)
     VALUES ('140130000250149', 7, '1716742683', 1, 0, '2023-02-20')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta)
     VALUES ('140130000250150', 1, '0701396830', 4, 0, '2023-02-23')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta)
     VALUES ('140130000250151', 5, '1752365841', 5, 0.05, '2023-02-25')
GO
INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta)
     VALUES ('140130000250152', 5, '1719142905', 4, 0, '2023-02-28')
GO


-- ejemplo para verificar que notifica bajo el stock minimo
 INSERT INTO Ventas (Numero_factura, Id_producto, Cedula_cliente, Cantidad, Descuento, Fecha_venta) 
 VALUES ('140130000250153', 5, '1784559964', 2, 0, '2023-03-02')
GO




-- select * from productos 
-- SELECT * FROM VENTAS
-- select * from Notificaciones_productos

INSERT INTO Novedades (Cedula_cliente, Descripcion_novedad, Fecha_novedad)
     VALUES ('1718658154', 'El router presenta una intermitencia y cliente indica que recibe senal','2023-04-10')
GO
INSERT INTO Novedades (Cedula_cliente, Descripcion_novedad, Fecha_novedad)
     VALUES ('1716742683', 'Servicio con intermitencia ','2023-04-25')
GO
INSERT INTO Novedades (Cedula_cliente, Descripcion_novedad, Fecha_novedad)
     VALUES ('1716742683', 'Presenta fallas a veces','2023-04-28')
GO


INSERT INTO Tecnicos (Cedula_tecnico, Nombre, Cargo, Telefono_celular)
     VALUES ('1710511898', 'Miguel Jaya', 'Ingeniero de Soporte', '0973340022')
GO
INSERT INTO Tecnicos (Cedula_tecnico, Nombre, Cargo, Telefono_celular)
     VALUES ('1784559964', 'Carlos Beltran', 'Tecnico de Soporte', '0984259444')
GO
INSERT INTO Tecnicos (Cedula_tecnico, Nombre, Cargo, Telefono_celular)
     VALUES ('1712345678', 'Patricio Chiriboga', 'Tecnico de Soporte', '0980430318')
GO

INSERT INTO Atenciones (Id_novedad, Cedula_tecnico, Fecha_asignacion)
     VALUES (1, '1710511898','2023-04-21')
GO
INSERT INTO Atenciones (Id_novedad, Cedula_tecnico, Fecha_asignacion)
     VALUES (2, '1784559964','2023-04-28')
GO
INSERT INTO Atenciones (Id_novedad, Cedula_tecnico, Fecha_asignacion)
     VALUES (3, '1712345678','2023-04-29')
GO

-- select * from novedades
INSERT INTO Detalle_atenciones (Id_novedad, Cedula_tecnico, Fecha_atencion, Observacion, Estado)
     VALUES (1, '1710511898', '2023-04-29', 'Revision preliminar', 'Abierto');
GO
INSERT INTO Detalle_atenciones (Id_novedad, Cedula_tecnico, Fecha_atencion, Observacion, Estado)
     VALUES (3, '1712345678', '2023-05-02', 'Limpieza ', 'Resuelto');
GO


/*
select * from Categorias
select * from Clientes
select * from Compras
select * FROM Ventas
select * from Productos
select * from Proveedores
select * from Notificaciones_productos
select * from Novedades
Select * from Tecnicos
Select * from Atenciones
Select * from Detalle_atenciones
*/	

-- **************************************************************************************************
-- REQUERIMIENTO DEL NEGOCIO
-- **************************************************************************************************

-- **************************************************************************************************
-- Responder rapidamente a los solicitudes de los clientes
-- Se crea objeto programable para identificar las novedades que no estan resueltas
-- **************************************************************************************************
DROP PROCEDURE IF EXISTS sp_consulta_requerimientos_pendientes
GO

CREATE PROCEDURE sp_consulta_requerimientos_pendientes
AS
BEGIN
	Select C.Cedula_cliente, C.Nombre_cliente, N.Descripcion_novedad, N.Fecha_novedad, DT.Observacion, DT.Estado
	from Clientes C
	INNER JOIN Novedades N ON C.Cedula_cliente = N.Cedula_cliente
	INNER JOIN Atenciones A ON N.Id_novedad = A.Id_novedad
	LEFT JOIN Detalle_Atenciones DT ON A.Id_novedad = DT.Id_novedad and A.Cedula_tecnico = DT.Cedula_tecnico
	WHERE A.Id_novedad NOT IN (SELECT DT.Id_novedad   from Detalle_atenciones DT where DT.Estado = 'Resuelto')
END
GO


-- **************************************************************************************************
-- Resolver los problemas de los clientes de manera efectiva
-- **************************************************************************************************
DROP PROCEDURE IF EXISTS sp_consulta_tiempo_requerimientos 
GO

CREATE PROCEDURE sp_consulta_tiempo_requerimientos 
@Fecha_corte date 
AS
BEGIN
	IF @fecha_corte IS NULL  
	BEGIN  
		PRINT 'ERROR: Debe especificar una fecha de corte.'  
		RETURN  
	END 

	Select C.Cedula_cliente, C.Nombre_cliente,N.Fecha_novedad, DATEDIFF(DAY, N.Fecha_novedad ,@Fecha_corte) Nro_dias_no_atendidos
	from Clientes C
	INNER JOIN Novedades N ON C.Cedula_cliente = N.Cedula_cliente
	INNER JOIN Atenciones A ON N.Id_novedad = A.Id_novedad
	LEFT JOIN Detalle_Atenciones DT ON A.Id_novedad = DT.Id_novedad and A.Cedula_tecnico = DT.Cedula_tecnico
	WHERE A.Id_novedad NOT IN (SELECT DT.Id_novedad   from Detalle_atenciones DT where DT.Estado = 'Resuelto')
END
GO

-- **************************************************************************************************
-- Productos mas vendidos
-- **************************************************************************************************
DROP PROCEDURE IF EXISTS sp_consulta_productos_mas_vendidos
GO

CREATE PROCEDURE sp_consulta_productos_mas_vendidos
AS
BEGIN
	SELECT TOP 5 Nombre_producto, sum(V.cantidad) as Nro_Productos_vendidos
	FROM Productos P
	INNER JOIN Ventas V ON P.Id_producto = V.Id_producto
	GROUP BY Nombre_producto
	ORDER BY sum(V.cantidad)  desc
END

-- **************************************************************************************************
-- Inventario de los productos de la empresa
-- **************************************************************************************************
DROP PROCEDURE IF EXISTS sp_consulta_inventario
GO

CREATE PROCEDURE sp_consulta_inventario
AS
BEGIN
	SELECT Id_producto, Nombre_producto, Stock, Stock_Minimo
	FROM Productos
	if exists (Select * from Notificaciones_productos)
	BEGIN
		SELECT P.Id_producto, P.Nombre_producto, NP.Fecha_notificacion, (NP.Stock_actual-NP.Stock_minimo) as Diferencia
		FROM Notificaciones_productos NP
		INNER JOIN Productos P ON NP.Id_producto =  P.Id_producto
	END
END
GO

-- **************************************************************************************************
--MENU DE OPCIONES 
-- **************************************************************************************************
DROP PROCEDURE IF EXISTS sp_menu 
GO

CREATE PROCEDURE sp_menu
AS
BEGIN
	Print('    MENU DE OPCIONES');
	Print('                       ');
	Print('1. Requerimientos Pendientes');
	Print('2. Nro de dias de Novedades no resueltas');
	Print('3. Productos mas vendidos');
	Print('4. Inventario de los Productos');
END
GO

DROP PROCEDURE IF EXISTS sp_ejecuta_menu 
GO

CREATE PROCEDURE sp_ejecuta_menu
@opcion int
AS
BEGIN
	IF @opcion=1
	BEGIN
		EXEC sp_consulta_requerimientos_pendientes
	END
	IF @opcion=2
	BEGIN
		DECLARE @Fecha_corte date;
		SET @Fecha_corte = GETDATE();
		EXEC sp_consulta_tiempo_requerimientos @fecha_corte
	END
	IF @opcion=3
	BEGIN
		EXEC sp_consulta_productos_mas_vendidos
	END
	IF @opcion=4
	BEGIN
		EXEC sp_consulta_inventario
	END

END
GO

-- Cambiar modo de autentificacion a SQL Y Windows
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
--USE [Telynet_P1]
--GO
--EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
--GO

-- Creacion de Login Usuarios,Usuario2,Usuario3
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
--USE [master]
--GO
--CREATE LOGIN [Usuarios] WITH PASSWORD=N'ecuatorianos.' MUST_CHANGE, DEFAULT_DATABASE=[Telynet_P1], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
--GO
--USE [master]
--GO
--CREATE LOGIN [Usuario2] WITH PASSWORD=N'1234' MUST_CHANGE, DEFAULT_DATABASE=[Telynet_P1], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
--GO
--USE [master]
--GO
--CREATE LOGIN [Usuario3] WITH PASSWORD=N'12345' MUST_CHANGE, DEFAULT_DATABASE=[Telynet_P1], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
--GO

-- Creacion de Usuario Tecnico,Pasanteventas,
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
--USE [Telynet_P1]
--GO
--CREATE USER [Tecnico] FOR LOGIN [Usuarios]
--GO
--CREATE USER [Pasanteventas] FOR LOGIN [Usuario2]
--GO
--CREATE USER [Administradorcompras] FOR LOGIN [Usuario3]
--GO

-- Creacion de Permisos
-- AUTOR: Leonardo Carvajal
-- FECHA CREACIÓN: 07/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 07/05/2023
/*
use [Telynet_P1]
GO
GRANT ALTER ON [dbo].[Ventas] TO [Pasanteventas]
GO
use [Telynet_P1]
GO
GRANT INSERT ON [dbo].[Ventas] TO [Pasanteventas]
GO
use [Telynet_P1]
GO
GRANT SELECT ON [dbo].[Ventas] TO [Pasanteventas]
GO
use [Telynet_P1]
GO
GRANT UPDATE ON [dbo].[Ventas] TO [Pasanteventas]
GO
use [Telynet_P1]
GO
GRANT SELECT ON [dbo].[Novedades] TO [Tecnico]
GO
use [Telynet_P1]
GO
use [Telynet_P1]
GO
GRANT ALTER ON [dbo].[Compras] TO [Administradorcompras]
GO
use [Telynet_P1]
GO
GRANT CONTROL ON [dbo].[Compras] TO [Administradorcompras]
GO
use [Telynet_P1]
GO
GRANT DELETE ON [dbo].[Compras] TO [Administradorcompras]
GO
use [Telynet_P1]
GO
GRANT INSERT ON [dbo].[Compras] TO [Administradorcompras]
GO
use [Telynet_P1]
GO
GRANT SELECT ON [dbo].[Compras] TO [Administradorcompras]
GO
use [Telynet_P1]
GO
GRANT UPDATE ON [dbo].[Compras] TO [Administradorcompras]
GO
*/


-- **************************************************************************************************
--PRESENTACION DEL MENU Y EJECUCION DE OPCION ELEGIDA 
-- **************************************************************************************************
-- presenta las opciones del menu
exec sp_menu
GO

-- presenta los resultados de la opcion que se ingresa como parametro
exec sp_ejecuta_menu 4
GO




-- Storage Procedure  que se permite el ingreso de un nuevo producto, a traves del nombre de la categoria en lugar de usar el id.
-- entonces se actualiza sumando el stock de la tabla de productos
-- AUTOR: Antonio Villegas
-- FECHA CREACIÓN: 21/05/2023
-- FECHA ÚLTIMA MODIFICACIÓN: 21/05/2023



DROP PROCEDURE IF EXISTS  sp_ingreso_datos
go
CREATE PROCEDURE sp_ingreso_datos
    @nombreCategoria VARCHAR(50),
	@nombreProducto VARCHAR(100),
	@valorUnitario MONEY,
	@stock int
AS
BEGIN
    -- Cuerpo del Stored Procedure
    -- Puedes realizar operaciones con los parámetros recibidos
    
    IF @nombreCategoria = 'Bienes de Telecomunicacion'
    BEGIN
        -- Lógica si @Param1 es igual a 'Valor1'
        -- Puedes agregar instrucciones SQL aquí

			INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
		 VALUES ( @nombreProducto,(SELECT Id_categoria FROM Categorias  where Nombre_categoria='Bienes de Telecomunicacion'), @valorUnitario, @stock)

		--sp_help productos
  --      SELECT * FROM Categorias where Nombre_categoria='Bienes de Telecomunicacion'
    END
    ELSE IF @nombreCategoria = 'Domotica'
    BEGIN
        -- Lógica si @Param1 es igual a 'Valor2'
        -- Puedes agregar instrucciones SQL aquí

			INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
		 VALUES ( @nombreProducto,(SELECT Id_categoria FROM Categorias  where Nombre_categoria='Domotica'), @valorUnitario, @stock)

             --SELECT * FROM Categorias where Nombre_categoria='Domotica'

    END
	 ELSE IF @nombreCategoria = 'Servicios de Intenet Personas'
    BEGIN
        -- Lógica si @Param1 es igual a 'Valor2'
        -- Puedes agregar instrucciones SQL aquí
          	INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
		 VALUES ( @nombreProducto,(SELECT Id_categoria FROM Categorias  where Nombre_categoria='Servicios de Intenet Personas'), @valorUnitario, @stock)
		  
		  --SELECT * FROM Categorias where Nombre_categoria='Servicios de Intenet Personas'

    END
    ELSE IF @nombreCategoria = 'Servicios de Internet Empresas'
    BEGIN
        -- Lógica si @Param1 es igual a 'Valor2'
        -- Puedes agregar instrucciones SQL aquí
         	INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
		 VALUES ( @nombreProducto,(SELECT Id_categoria FROM Categorias  where Nombre_categoria='Servicios de Internet Empresas'), @valorUnitario, @stock)
		 --SELECT * FROM Categorias where Nombre_categoria='Servicios de Internet Empresas'

    END
    ELSE IF @nombreCategoria = 'Bienes de IoT'
    BEGIN
        -- Lógica si @Param1 es igual a 'Valor2'
        -- Puedes agregar instrucciones SQL aquí
         	INSERT INTO Productos (Nombre_producto, Id_categoria, Valor_Unitario, Stock)
		 VALUES ( @nombreProducto,(SELECT Id_categoria FROM Categorias  where Nombre_categoria='Bienes de IoT'), @valorUnitario, @stock)

    END
   
    ELSE
    BEGIN
        -- Lógica si @Param1 no coincide con ninguno de los casos anteriores
        -- Puedes agregar instrucciones SQL aquí
        Print 'Opcion Invalida'
    END
END
GO



exec sp_ingreso_datos   @nombreCategoria = 'Bienes de Telecomunicacion', @nombreProducto='TESTtele' ,@valorUnitario=3.00, @stock=23


select * from Productos

delete from Productos
where Id_producto in(
select TOP 8  Id_producto
from Productos
order by Id_producto DESC

)






