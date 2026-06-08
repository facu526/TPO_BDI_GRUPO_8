USE ComplejoDeportivo;
GO

-- VIEW 1: Reservas con datos del cliente y estado de la reserva
CREATE VIEW VW_Reservas_Cliente_Estado AS
SELECT 
    r.id_reserva,
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    c.dni,
    er.nombre AS estado_reserva,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.monto_total
FROM Reserva r
JOIN Cliente c ON r.id_cliente = c.id_cliente
JOIN Estado_Reserva er ON r.id_estado_reserva = er.id_estado_reserva;
GO

-- VIEW 2: Canchas con sede y deporte
CREATE VIEW VW_Canchas_Sede_Deporte AS
SELECT 
    ca.id_cancha,
    ca.nro_cancha,
    ca.nombre AS cancha,
    ca.estado,
    ca.precio_por_hora,
    s.nombre AS sede,
    s.direccion AS direccion_sede,
    d.nombre AS deporte
FROM Cancha ca
JOIN Sede s ON ca.id_sede = s.id_sede
JOIN Deporte d ON ca.id_deporte = d.id_deporte;
GO

-- VIEW 3: Pagos con metodo y estado
CREATE VIEW VW_Pagos_Metodo_Estado AS
SELECT 
    p.id_pago,
    p.id_reserva,
    mp.nombre AS metodo_pago,
    ep.nombre AS estado_pago,
    p.monto,
    p.fecha_hora
FROM Pago p
JOIN Metodo_Pago mp ON p.id_metodo_pago = mp.id_metodo_pago
JOIN Estado_Pago ep ON p.id_estado_pago = ep.id_estado_pago;
GO

SELECT * FROM VW_Reservas_Cliente_Estado;
SELECT * FROM VW_Canchas_Sede_Deporte;
SELECT * FROM VW_Pagos_Metodo_Estado;
