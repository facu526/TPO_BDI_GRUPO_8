USE ComplejoDeportivo;
GO


SELECT 
    id_cliente,
    nombre,
    apellido,
    dni,
    telefono
FROM Cliente;



SELECT 
    id_cancha,
    nro_cancha,
    nombre,
    estado,
    precio_por_hora
FROM Cancha
WHERE estado = 'disponible';


SELECT 
    id_reserva,
    id_cliente,
    fecha,
    hora_inicio,
    hora_fin,
    monto_total
FROM Reserva
WHERE id_estado_reserva = 2;



SELECT 
    id_promocion,
    nombre,
    descuento_porcentaje,
    fecha_inicio,
    fecha_fin
FROM Promocion
WHERE '2026-06-15' BETWEEN fecha_inicio AND fecha_fin;



SELECT 
    id_pago,
    id_reserva,
    monto,
    fecha_hora
FROM Pago
WHERE monto > 10000;



SELECT 
    r.id_reserva,
    c.nombre,
    c.apellido,
    r.fecha,
    r.hora_inicio,
    r.hora_fin,
    r.monto_total
FROM Reserva r
JOIN Cliente c ON r.id_cliente = c.id_cliente;



SELECT 
    r.id_reserva,
    c.nombre + ' ' + c.apellido AS cliente,
    er.nombre AS estado_reserva,
    r.fecha,
    r.hora_inicio,
    r.hora_fin
FROM Reserva r
JOIN Cliente c ON r.id_cliente = c.id_cliente
JOIN Estado_Reserva er ON r.id_estado_reserva = er.id_estado_reserva;



SELECT 
    ca.id_cancha,
    ca.nombre AS cancha,
    ca.nro_cancha,
    s.nombre AS sede,
    d.nombre AS deporte,
    ca.precio_por_hora,
    ca.estado
FROM Cancha ca
JOIN Sede s ON ca.id_sede = s.id_sede
JOIN Deporte d ON ca.id_deporte = d.id_deporte;



SELECT 
    r.id_reserva,
    c.nombre + ' ' + c.apellido AS cliente,
    ca.nombre AS cancha,
    s.nombre AS sede,
    d.nombre AS deporte,
    r.fecha,
    r.hora_inicio,
    r.hora_fin
FROM Reserva r
JOIN Cliente c ON r.id_cliente = c.id_cliente
JOIN Reserva_Cancha rc ON r.id_reserva = rc.id_reserva
JOIN Cancha ca ON rc.id_cancha = ca.id_cancha
JOIN Sede s ON ca.id_sede = s.id_sede
JOIN Deporte d ON ca.id_deporte = d.id_deporte;



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



SELECT 
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    COUNT(r.id_reserva) AS cantidad_reservas
FROM Cliente c
JOIN Reserva r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido;



SELECT 
    mp.nombre AS metodo_pago,
    SUM(p.monto) AS total_cobrado
FROM Pago p
JOIN Metodo_Pago mp ON p.id_metodo_pago = mp.id_metodo_pago
GROUP BY mp.nombre;



SELECT 
    d.nombre AS deporte,
    COUNT(r.id_reserva) AS cantidad_reservas
FROM Reserva r
JOIN Reserva_Cancha rc ON r.id_reserva = rc.id_reserva
JOIN Cancha ca ON rc.id_cancha = ca.id_cancha
JOIN Deporte d ON ca.id_deporte = d.id_deporte
GROUP BY d.nombre;



SELECT 
    s.nombre AS sede,
    SUM(p.monto) AS total_cobrado
FROM Pago p
JOIN Reserva r ON p.id_reserva = r.id_reserva
JOIN Reserva_Cancha rc ON r.id_reserva = rc.id_reserva
JOIN Cancha ca ON rc.id_cancha = ca.id_cancha
JOIN Sede s ON ca.id_sede = s.id_sede
GROUP BY s.nombre;



SELECT 
    c.id_cliente,
    c.nombre + ' ' + c.apellido AS cliente,
    COUNT(r.id_reserva) AS cantidad_reservas
FROM Cliente c
JOIN Reserva r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido
HAVING COUNT(r.id_reserva) > 1;



SELECT 
    s.nombre AS sede,
    COUNT(ca.id_cancha) AS cantidad_canchas
FROM Sede s
JOIN Cancha ca ON s.id_sede = ca.id_sede
GROUP BY s.nombre
HAVING COUNT(ca.id_cancha) > 2;



SELECT 
    id_reserva,
    id_cliente,
    fecha,
    monto_total
FROM Reserva
WHERE monto_total > (
    SELECT AVG(monto_total)
    FROM Reserva
);



SELECT 
    id_cliente,
    nombre,
    apellido,
    telefono
FROM Cliente
WHERE id_cliente IN (
    SELECT id_cliente
    FROM Reserva
);



SELECT 
    ca.id_cancha,
    ca.nombre,
    ca.estado
FROM Cancha ca
WHERE EXISTS (
    SELECT 1
    FROM Reserva_Cancha rc
    WHERE rc.id_cancha = ca.id_cancha
);



SELECT 
    r.id_reserva,
    r.id_cliente,
    r.fecha,
    r.monto_total
FROM Reserva r
WHERE r.monto_total > (
    SELECT AVG(r2.monto_total)
    FROM Reserva r2
    WHERE r2.id_cliente = r.id_cliente
);
