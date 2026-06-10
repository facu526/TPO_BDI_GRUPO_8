USE ComplejoDeportivo;
GO


CREATE PROCEDURE SP_ListarReservasPorCliente
    @id_cliente INT
AS
BEGIN
    SELECT 
        r.id_reserva,
        c.nombre + ' ' + c.apellido AS cliente,
        er.nombre AS estado_reserva,
        r.fecha,
        r.hora_inicio,
        r.hora_fin,
        r.monto_total
    FROM Reserva r
    JOIN Cliente c ON r.id_cliente = c.id_cliente
    JOIN Estado_Reserva er ON r.id_estado_reserva = er.id_estado_reserva
    WHERE r.id_cliente = @id_cliente;
END;
GO

CREATE PROCEDURE SP_ListarReservasPorFecha
    @fecha DATE
AS
BEGIN
    SELECT 
        r.id_reserva,
        c.nombre + ' ' + c.apellido AS cliente,
        ca.nombre AS cancha,
        d.nombre AS deporte,
        r.fecha,
        r.hora_inicio,
        r.hora_fin,
        er.nombre AS estado_reserva
    FROM Reserva r
    JOIN Cliente c ON r.id_cliente = c.id_cliente
    JOIN Estado_Reserva er ON r.id_estado_reserva = er.id_estado_reserva
    JOIN Reserva_Cancha rc ON r.id_reserva = rc.id_reserva
    JOIN Cancha ca ON rc.id_cancha = ca.id_cancha
    JOIN Deporte d ON ca.id_deporte = d.id_deporte
    WHERE r.fecha = @fecha;
END;
GO


CREATE PROCEDURE SP_RegistrarPago
    @id_reserva INT,
    @id_metodo_pago INT,
    @id_estado_pago INT,
    @monto DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Pago (
        id_reserva,
        id_metodo_pago,
        id_estado_pago,
        monto,
        fecha_hora
    )
    VALUES (
        @id_reserva,
        @id_metodo_pago,
        @id_estado_pago,
        @monto,
        GETDATE()
    );

    SELECT 
        'Pago registrado correctamente' AS mensaje;
END;
GO




CREATE PROCEDURE SP_RegistrarReserva
    @id_cliente INT,
    @id_empleado INT,
    @id_estado_reserva INT,
    @id_cancha INT,
    @fecha DATE,
    @hora_inicio TIME,
    @hora_fin TIME,
    @monto_total DECIMAL(10,2)
AS
BEGIN
    DECLARE @id_reserva INT;

    INSERT INTO Reserva (
        id_cliente,
        id_empleado,
        id_estado_reserva,
        fecha,
        hora_inicio,
        hora_fin,
        monto_total
    )
    VALUES (
        @id_cliente,
        @id_empleado,
        @id_estado_reserva,
        @fecha,
        @hora_inicio,
        @hora_fin,
        @monto_total
    );

    SET @id_reserva = SCOPE_IDENTITY();

    INSERT INTO Reserva_Cancha (
        id_reserva,
        id_cancha
    )
    VALUES (
        @id_reserva,
        @id_cancha
    );

    SELECT 
        'Reserva registrada correctamente' AS mensaje,
        @id_reserva AS id_reserva_generada;
END;
GO


EXEC SP_ListarReservasPorCliente @id_cliente = 1;

EXEC SP_ListarReservasPorFecha @fecha = '2026-06-10';

EXEC SP_RegistrarPago 
    @id_reserva = 3,
    @id_metodo_pago = 1,
    @id_estado_pago = 3,
    @monto = 12000;

EXEC SP_RegistrarReserva
    @id_cliente = 2,
    @id_empleado = 1,
    @id_estado_reserva = 2,
    @id_cancha = 3,
    @fecha = '2026-06-20',
    @hora_inicio = '18:00',
    @hora_fin = '19:00',
    @monto_total = 12000;
