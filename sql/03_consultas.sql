CREATE DATABASE ComplejoDeportivo;
GO

USE ComplejoDeportivo;
GO

CREATE TABLE Estado_Pago (
    id_estado_pago INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE Sede (
    id_sede INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    telefono VARCHAR(30),
    horario_apertura TIME NOT NULL,
    horario_cierre TIME NOT NULL,
    CHECK (horario_cierre > horario_apertura)
);
GO

CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    telefono VARCHAR(30),
    fecha_registro DATE NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(20) NOT NULL UNIQUE,
    tipo VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    telefono VARCHAR(30),
    id_sede INT NOT NULL,

    FOREIGN KEY (id_sede) REFERENCES Sede(id_sede)
);
GO

CREATE TABLE Deporte (
    id_deporte INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);
GO

CREATE TABLE Estado_Reserva (
    id_estado_reserva INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE
);
GO

CREATE TABLE Cancha (
    id_cancha INT IDENTITY(1,1) PRIMARY KEY,
    nro_cancha INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    estado VARCHAR(30) NOT NULL,
    precio_por_hora DECIMAL(10,2) NOT NULL,
    id_sede INT NOT NULL,
    id_deporte INT NOT NULL,

    FOREIGN KEY (id_sede) REFERENCES Sede(id_sede),
    FOREIGN KEY (id_deporte) REFERENCES Deporte(id_deporte),

    UNIQUE (id_sede, nro_cancha),
    CHECK (precio_por_hora >= 0),
    CHECK (estado IN ('disponible', 'mantenimiento', 'inactiva'))
);
GO

CREATE TABLE Reserva (
    id_reserva INT IDENTITY(1,1) PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    id_estado_reserva INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_estado_reserva) REFERENCES Estado_Reserva(id_estado_reserva),

    CHECK (hora_fin > hora_inicio),
    CHECK (monto_total >= 0)
);
GO

CREATE TABLE Reserva_Cancha (
    id_reserva INT NOT NULL,
    id_cancha INT NOT NULL,

    PRIMARY KEY (id_reserva, id_cancha),

    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
    FOREIGN KEY (id_cancha) REFERENCES Cancha(id_cancha)
);
GO

CREATE TABLE Metodo_Pago (
    id_metodo_pago INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(150)
);
GO

CREATE TABLE Pago (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    id_estado_pago INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
    FOREIGN KEY (id_metodo_pago) REFERENCES Metodo_Pago(id_metodo_pago),
    FOREIGN KEY (id_estado_pago) REFERENCES Estado_Pago(id_estado_pago),

    CHECK (monto > 0)
);
GO

CREATE TABLE Promocion (
    id_promocion INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descuento_porcentaje DECIMAL(5,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    id_deporte INT NULL,
    id_sede INT NULL,

    FOREIGN KEY (id_deporte) REFERENCES Deporte(id_deporte),
    FOREIGN KEY (id_sede) REFERENCES Sede(id_sede),

    CHECK (descuento_porcentaje BETWEEN 0 AND 100),
    CHECK (fecha_fin >= fecha_inicio)
);
GO

CREATE TABLE Reserva_Promocion (
    id_reserva INT NOT NULL,
    id_promocion INT NOT NULL,
    monto_descuento_aplicado DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (id_reserva, id_promocion),

    FOREIGN KEY (id_reserva) REFERENCES Reserva(id_reserva),
    FOREIGN KEY (id_promocion) REFERENCES Promocion(id_promocion),

    CHECK (monto_descuento_aplicado >= 0)
);
GO

CREATE TABLE Mantenimiento (
    id_mantenimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_cancha INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    descripcion VARCHAR(250),
    estado VARCHAR(30) NOT NULL,

    FOREIGN KEY (id_cancha) REFERENCES Cancha(id_cancha),

    CHECK (hora_fin > hora_inicio),
    CHECK (estado IN ('pendiente', 'en proceso', 'finalizado', 'cancelado'))
);
GO

CREATE TRIGGER TR_Reserva_Superpuesta
ON Reserva_Cancha
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Reserva r1 ON i.id_reserva = r1.id_reserva
        JOIN Estado_Reserva er1 ON r1.id_estado_reserva = er1.id_estado_reserva
        JOIN Reserva_Cancha rc ON rc.id_cancha = i.id_cancha
        JOIN Reserva r2 ON rc.id_reserva = r2.id_reserva
        JOIN Estado_Reserva er2 ON r2.id_estado_reserva = er2.id_estado_reserva
        WHERE r1.id_reserva <> r2.id_reserva
          AND r1.fecha = r2.fecha
          AND er1.nombre <> 'cancelada'
          AND er2.nombre <> 'cancelada'
          AND r1.hora_inicio < r2.hora_fin
          AND r1.hora_fin > r2.hora_inicio
    )
    BEGIN
        RAISERROR('La cancha ya tiene una reserva en ese horario.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

