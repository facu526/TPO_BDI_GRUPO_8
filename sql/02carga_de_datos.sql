USE ComplejoDeportivo;
GO

INSERT INTO Estado_Pago (nombre) VALUES
('pendiente'),
('parcial'),
('pagado'),
('anulado');

INSERT INTO Sede (nombre, direccion, telefono, horario_apertura, horario_cierre) VALUES
('Sede Centro', 'Av. San Martin 1200', '1123456789', '08:00', '23:00'),
('Sede Norte', 'Las Heras 450', '1145678912', '09:00', '22:00'),
('Sede Sur', 'Av. Belgrano 2300', '1167891234', '08:30', '23:30');

INSERT INTO Cliente (nombre, apellido, dni, email, telefono, fecha_registro) VALUES
('Juan', 'Perez', '40111222', 'juanperez@mail.com', '1134567890', '2026-05-01'),
('Martina', 'Lopez', '42222333', 'martinalopez@mail.com', '1145678901', '2026-05-02'),
('Lucas', 'Garcia', '43555444', 'lucasgarcia@mail.com', '1156789012', '2026-05-03'),
('Sofia', 'Ramirez', '44888999', 'sofiaramirez@mail.com', '1167890123', '2026-05-04'),
('Mateo', 'Fernandez', '39123456', 'mateofernandez@mail.com', '1178901234', '2026-05-05'),
('Camila', 'Torres', '40555111', 'camilatorres@mail.com', '1189012345', '2026-05-06'),
('Nicolas', 'Molina', '41777222', 'nicolasmolina@mail.com', '1190123456', '2026-05-07'),
('Valentina', 'Sosa', '42999333', 'valentinasosa@mail.com', '1122223333', '2026-05-08'),
('Tomas', 'Acosta', '43333444', 'tomasacosta@mail.com', '1133334444', '2026-05-09'),
('Agustina', 'Rojas', '44666555', 'agustinarojas@mail.com', '1144445555', '2026-05-10');

INSERT INTO Empleado (nombre, apellido, dni, tipo, email, telefono, id_sede) VALUES
('Carlos', 'Gomez', '30111222', 'Administrador', 'carlos@mail.com', '1155511111', 1),
('Laura', 'Diaz', '31222333', 'Recepcionista', 'laura@mail.com', '1155522222', 1),
('Mariano', 'Castro', '32333444', 'Recepcionista', 'mariano@mail.com', '1155533333', 2),
('Paula', 'Moreno', '33444555', 'Encargada', 'paula@mail.com', '1155544444', 2),
('Diego', 'Silva', '34555666', 'Mantenimiento', 'diego@mail.com', '1155555555', 3);

INSERT INTO Deporte (nombre, descripcion) VALUES
('Futbol 5', 'Cancha de futbol reducido'),
('Padel', 'Cancha de padel'),
('Tenis', 'Cancha de tenis'),
('Basquet', 'Cancha de basquet');

INSERT INTO Estado_Reserva (nombre) VALUES
('pendiente'),
('confirmada'),
('cancelada'),
('finalizada');

INSERT INTO Cancha (nro_cancha, nombre, estado, precio_por_hora, id_sede, id_deporte) VALUES
(1, 'Cancha 1', 'disponible', 15000, 1, 1),
(2, 'Cancha 2', 'disponible', 15000, 1, 1),
(3, 'Cancha Padel', 'disponible', 12000, 1, 2),
(1, 'Cancha 1', 'disponible', 16000, 2, 1),
(2, 'Cancha Padel', 'disponible', 13000, 2, 2),
(3, 'Cancha Tenis', 'mantenimiento', 11000, 2, 3),
(1, 'Cancha Futbol', 'disponible', 14000, 3, 1),
(2, 'Cancha Basquet', 'disponible', 10000, 3, 4);

INSERT INTO Metodo_Pago (nombre, descripcion) VALUES
('efectivo', 'Pago en efectivo'),
('tarjeta', 'Pago con tarjeta'),
('transferencia', 'Pago por transferencia');

INSERT INTO Reserva (id_cliente, id_empleado, id_estado_reserva, fecha, hora_inicio, hora_fin, monto_total) VALUES
(1, 1, 2, '2026-06-10', '18:00', '19:00', 15000),
(2, 2, 2, '2026-06-10', '19:00', '20:00', 15000),
(3, 2, 1, '2026-06-11', '20:00', '21:00', 12000),
(4, 3, 2, '2026-06-11', '18:00', '19:00', 16000),
(5, 3, 4, '2026-06-08', '21:00', '22:00', 13000),
(6, 4, 2, '2026-06-12', '17:00', '18:00', 11000),
(7, 1, 3, '2026-06-09', '18:00', '19:00', 15000),
(8, 5, 2, '2026-06-13', '19:00', '20:00', 14000),
(9, 5, 1, '2026-06-14', '20:00', '21:00', 10000),
(10, 1, 2, '2026-06-15', '18:00', '19:00', 15000),
(1, 2, 4, '2026-06-01', '17:00', '18:00', 12000),
(3, 3, 2, '2026-06-16', '19:00', '20:00', 13000);

INSERT INTO Reserva_Cancha (id_reserva, id_cancha) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 1),
(8, 7),
(9, 8),
(10, 2),
(11, 3),
(12, 5);

INSERT INTO Pago (id_reserva, id_metodo_pago, id_estado_pago, monto, fecha_hora) VALUES
(1, 1, 3, 15000, '2026-06-10T18:10:00'),
(2, 2, 2, 5000, '2026-06-10T19:05:00'),
(4, 3, 3, 16000, '2026-06-11T18:15:00'),
(5, 1, 3, 13000, '2026-06-08T21:00:00'),
(6, 2, 3, 11000, '2026-06-12T17:20:00'),
(8, 3, 3, 14000, '2026-06-13T19:10:00'),
(10, 1, 3, 15000, '2026-06-15T18:05:00'),
(11, 2, 3, 12000, '2026-06-01T17:10:00'),
(12, 3, 2, 3000, '2026-06-16T19:10:00');

INSERT INTO Promocion (nombre, descuento_porcentaje, fecha_inicio, fecha_fin, id_deporte, id_sede) VALUES
('Promo futbol', 10, '2026-06-01', '2026-06-30', 1, NULL),
('Promo padel centro', 15, '2026-06-01', '2026-06-20', 2, 1),
('Promo sede norte', 20, '2026-06-05', '2026-06-25', NULL, 2),
('Promo tenis', 10, '2026-06-01', '2026-07-01', 3, NULL),
('Promo general', 5, '2026-06-01', '2026-12-31', NULL, NULL);

INSERT INTO Reserva_Promocion (id_reserva, id_promocion, monto_descuento_aplicado) VALUES
(1, 1, 1500),
(3, 2, 1800),
(4, 3, 3200),
(6, 4, 1100),
(10, 1, 1500),
(12, 3, 2600);

INSERT INTO Mantenimiento (id_cancha, fecha, hora_inicio, hora_fin, descripcion, estado) VALUES
(6, '2026-06-10', '10:00', '12:00', 'Cambio de red', 'finalizado'),
(3, '2026-06-12', '09:00', '10:30', 'Limpieza general', 'pendiente'),
(1, '2026-06-14', '08:00', '09:00', 'Revision de luces', 'pendiente'),
(8, '2026-06-15', '11:00', '13:00', 'Marcado de lineas', 'en proceso'),
(5, '2026-06-18', '09:00', '11:00', 'Arreglo de alambrado', 'pendiente');
