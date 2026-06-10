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


USE ComplejoDeportivo;
GO

CREATE OR ALTER PROCEDURE sp_CrearReserva
    @id_cliente INT,
    @id_empleado INT,
    @id_cancha INT,
    @fecha DATE,
    @hora_inicio TIME,
    @hora_fin TIME,
    @id_promocion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @precio_hora DECIMAL(10,2);
    DECLARE @descuento DECIMAL(5,2);
    DECLARE @monto_total DECIMAL(10,2);
    DECLARE @id_estado_reserva INT;
    DECLARE @id_reserva INT;

    SELECT @precio_hora = precio_por_hora
    FROM Cancha
    WHERE id_cancha = @id_cancha;

    IF @precio_hora IS NULL
    BEGIN
        RAISERROR('La cancha especificada no existe.', 16, 1);
        RETURN;
    END;

    SET @monto_total = @precio_hora * DATEDIFF(HOUR, @hora_inicio, @hora_fin);

    IF @id_promocion IS NOT NULL
    BEGIN
        SELECT @descuento = descuento_porcentaje
        FROM Promocion
        WHERE id_promocion = @id_promocion
          AND @fecha BETWEEN fecha_inicio AND fecha_fin;

        IF @descuento IS NOT NULL
            SET @monto_total = @monto_total * (1 - @descuento / 100);
    END;

    SELECT @id_estado_reserva = id_estado_reserva
    FROM Estado_Reserva
    WHERE nombre = 'confirmada';

    INSERT INTO Reserva (id_cliente, id_empleado, id_estado_reserva, fecha, hora_inicio, hora_fin, monto_total)
    VALUES (@id_cliente, @id_empleado, @id_estado_reserva, @fecha, @hora_inicio, @hora_fin, @monto_total);

    SET @id_reserva = SCOPE_IDENTITY();

    INSERT INTO Reserva_Cancha (id_reserva, id_cancha)
    VALUES (@id_reserva, @id_cancha);

    IF @id_promocion IS NOT NULL AND @descuento IS NOT NULL
    BEGIN
        INSERT INTO Reserva_Promocion (id_reserva, id_promocion, monto_descuento_aplicado)
        VALUES (@id_reserva, @id_promocion, @monto_total * (@descuento / 100));
    END;

    SELECT @id_reserva AS id_reserva_creada;
END;
GO

CREATE OR ALTER PROCEDURE sp_ConsultarDisponibilidad
    @id_sede INT,
    @fecha DATE,
    @hora TIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.id_cancha,
        c.nro_cancha,
        c.nombre AS cancha,
        d.nombre AS deporte,
        c.precio_por_hora,
        CASE 
            WHEN m.id_mantenimiento IS NOT NULL AND m.estado IN ('programado', 'en proceso') 
                THEN 'En mantenimiento'
            WHEN r.id_reserva IS NOT NULL 
                THEN 'Reservado'
            ELSE 'Disponible'
        END AS disponibilidad
    FROM Cancha c
    JOIN Deporte d ON c.id_deporte = d.id_deporte
    LEFT JOIN Mantenimiento m ON c.id_cancha = m.id_cancha 
        AND m.fecha = @fecha 
        AND @hora BETWEEN m.hora_inicio AND m.hora_fin
        AND m.estado IN ('programado', 'en proceso')
    LEFT JOIN Reserva_Cancha rc ON c.id_cancha = rc.id_cancha
    LEFT JOIN Reserva r ON rc.id_reserva = r.id_reserva 
        AND r.fecha = @fecha 
        AND @hora BETWEEN r.hora_inicio AND r.hora_fin
        AND r.id_estado_reserva IN (SELECT id_estado_reserva FROM Estado_Reserva WHERE nombre IN ('pendiente', 'confirmada'))
    WHERE c.id_sede = @id_sede
      AND c.estado = 'disponible'
    ORDER BY c.nro_cancha;
END;
GO

CREATE OR ALTER PROCEDURE sp_RegistrarPago
    @id_reserva INT,
    @id_metodo_pago INT,
    @monto DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @monto_total_reserva DECIMAL(10,2);
    DECLARE @total_pagado DECIMAL(10,2);
    DECLARE @id_estado_pago_pagado INT;
    DECLARE @id_estado_pago_parcial INT;
    DECLARE @id_estado_reserva_confirmada INT;

    SELECT @monto_total_reserva = monto_total
    FROM Reserva
    WHERE id_reserva = @id_reserva;

    IF @monto_total_reserva IS NULL
    BEGIN
        RAISERROR('La reserva especificada no existe.', 16, 1);
        RETURN;
    END;

    SELECT @total_pagado = ISNULL(SUM(monto), 0)
    FROM Pago
    WHERE id_reserva = @id_reserva
      AND id_estado_pago IN (SELECT id_estado_pago FROM Estado_Pago WHERE nombre = 'pagado');

    IF @total_pagado + @monto > @monto_total_reserva
    BEGIN
        RAISERROR('El monto total pagado no puede superar el monto de la reserva.', 16, 1);
        RETURN;
    END;

    SELECT @id_estado_pago_pagado = id_estado_pago FROM Estado_Pago WHERE nombre = 'pagado';
    SELECT @id_estado_pago_parcial = id_estado_pago FROM Estado_Pago WHERE nombre = 'parcial';

    INSERT INTO Pago (id_reserva, id_metodo_pago, id_estado_pago, monto, fecha_hora)
    VALUES (
        @id_reserva,
        @id_metodo_pago,
        CASE WHEN @total_pagado + @monto >= @monto_total_reserva THEN @id_estado_pago_pagado ELSE @id_estado_pago_parcial END,
        @monto,
        GETDATE()
    );

    IF @total_pagado + @monto >= @monto_total_reserva
    BEGIN
        SELECT @id_estado_reserva_confirmada = id_estado_reserva FROM Estado_Reserva WHERE nombre = 'confirmada';
        
        UPDATE Reserva
        SET id_estado_reserva = @id_estado_reserva_confirmada
        WHERE id_reserva = @id_reserva;
    END;

    SELECT 'Pago registrado exitosamente' AS mensaje;
END;
GO

CREATE OR ALTER PROCEDURE sp_ReporteIngresos
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @id_sede INT = NULL,
    @id_deporte INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.nombre AS sede,
        d.nombre AS deporte,
        ca.nro_cancha,
        COUNT(DISTINCT r.id_reserva) AS cantidad_reservas,
        SUM(p.monto) AS total_cobrado
    FROM Pago p
    JOIN Reserva r ON p.id_reserva = r.id_reserva
    JOIN Reserva_Cancha rc ON r.id_reserva = rc.id_reserva
    JOIN Cancha ca ON rc.id_cancha = ca.id_cancha
    JOIN Sede s ON ca.id_sede = s.id_sede
    JOIN Deporte d ON ca.id_deporte = d.id_deporte
    WHERE p.fecha_hora BETWEEN @fecha_desde AND @fecha_hasta
      AND p.id_estado_pago IN (SELECT id_estado_pago FROM Estado_Pago WHERE nombre = 'pagado')
      AND (@id_sede IS NULL OR ca.id_sede = @id_sede)
      AND (@id_deporte IS NULL OR ca.id_deporte = @id_deporte)
    GROUP BY s.nombre, d.nombre, ca.nro_cancha
    ORDER BY total_cobrado DESC;
END;
GO
