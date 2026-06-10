USE ComplejoDeportivo;
GO

CREATE OR ALTER TRIGGER TR_ValidarHorarioSede
ON Reserva
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Reserva_Cancha rc ON i.id_reserva = rc.id_reserva
        JOIN Cancha c ON rc.id_cancha = c.id_cancha
        JOIN Sede s ON c.id_sede = s.id_sede
        WHERE i.hora_inicio < s.horario_apertura 
           OR i.hora_fin > s.horario_cierre
    )
    BEGIN
        RAISERROR('El horario esta fuera del horario de atencion de la sede.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1 FROM inserted WHERE hora_inicio >= hora_fin
    )
    BEGIN
        RAISERROR('La hora de inicio debe ser anterior a la hora de fin.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    INSERT INTO Reserva (id_cliente, id_empleado, id_estado_reserva, fecha, hora_inicio, hora_fin, monto_total)
    SELECT id_cliente, id_empleado, id_estado_reserva, fecha, hora_inicio, hora_fin, monto_total
    FROM inserted;
END;
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Auditoria_Reserva')
BEGIN
    CREATE TABLE Auditoria_Reserva (
        id_auditoria INT IDENTITY(1,1) PRIMARY KEY,
        id_reserva INT NOT NULL,
        id_empleado INT NOT NULL,
        accion VARCHAR(20) NOT NULL,
        fecha_hora DATETIME DEFAULT GETDATE()
    );
END;
GO

CREATE OR ALTER TRIGGER TR_Auditar_Insert_Reserva
ON Reserva
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria_Reserva (id_reserva, id_empleado, accion, fecha_hora)
    SELECT id_reserva, id_empleado, 'INSERT', GETDATE()
    FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER TR_Auditar_Update_Reserva
ON Reserva
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria_Reserva (id_reserva, id_empleado, accion, fecha_hora)
    SELECT id_reserva, id_empleado, 'UPDATE', GETDATE()
    FROM inserted;
END;
GO

CREATE OR ALTER TRIGGER TR_Auditar_Delete_Reserva
ON Reserva
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria_Reserva (id_reserva, id_empleado, accion, fecha_hora)
    SELECT id_reserva, id_empleado, 'DELETE', GETDATE()
    FROM deleted;
END;
GO

CREATE TRIGGER TR_ConfirmarReserva_Auto
ON Pago
AFTER INSERT
AS
BEGIN
    UPDATE r
    SET r.id_estado_reserva = 2 
    FROM Reserva r
    JOIN inserted i ON r.id_reserva = i.id_reserva
    WHERE i.id_estado_pago = 3; 
END;
GO
