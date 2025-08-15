-- Insertar 10 invitaciones de ejemplo
-- Usuario que envía: a8a45a09-e14c-4235-857b-d46cf584bbf6
-- Tarea: 5a35ec15-34b8-475c-9e6d-cdd69234c4b8

INSERT INTO task_invitations (
  task_id,
  task_title,
  from_user_id,
  from_user_email,
  to_user_email,
  created_at,
  is_accepted,
  is_declined
) VALUES 
-- Invitaciones pendientes (sin respuesta)
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'maria.garcia@empresa.com',
  NOW() - INTERVAL '2 days',
  false,
  false
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'juan.perez@empresa.com',
  NOW() - INTERVAL '1 day',
  false,
  false
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'ana.rodriguez@empresa.com',
  NOW() - INTERVAL '12 hours',
  false,
  false
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'carlos.lopez@empresa.com',
  NOW() - INTERVAL '6 hours',
  false,
  false
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'lucia.martinez@empresa.com',
  NOW() - INTERVAL '3 hours',
  false,
  false
),
-- Invitaciones aceptadas
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'pedro.gonzalez@empresa.com',
  NOW() - INTERVAL '5 days',
  true,
  false
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'sofia.hernandez@empresa.com',
  NOW() - INTERVAL '4 days',
  true,
  false
),
-- Invitaciones rechazadas
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'roberto.diaz@empresa.com',
  NOW() - INTERVAL '7 days',
  false,
  true
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'elena.morales@empresa.com',
  NOW() - INTERVAL '6 days',
  false,
  true
),
(
  '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
  'Desarrollar nueva funcionalidad de chat',
  'a8a45a09-e14c-4235-857b-d46cf584bbf6',
  'desarrollador@empresa.com',
  'miguel.torres@empresa.com',
  NOW() - INTERVAL '8 days',
  false,
  true
);

-- También puedes insertar algunas invitaciones recibidas por el usuario
-- (simulando que otros usuarios inviten al usuario principal)
-- Nota: Para esto necesitarías tener otros usuarios registrados en auth.users
-- Por ahora, estas invitaciones solo funcionarán si esos usuarios existen

-- INSERT INTO task_invitations (
--   task_id,
--   task_title,
--   from_user_id,
--   from_user_email,
--   to_user_email,
--   created_at,
--   is_accepted,
--   is_declined
-- ) VALUES 
-- -- Invitaciones recibidas por el usuario principal
-- (
--   '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
--   'Revisar documentación del proyecto',
--   'b9b56b1a-f25d-5346-968c-e57df695cc7a',
--   'maria.garcia@empresa.com',
--   'desarrollador@empresa.com',
--   NOW() - INTERVAL '1 day',
--   false,
--   false
-- ),
-- (
--   '5a35ec15-34b8-475c-9e6d-cdd69234c4b8',
--   'Participar en reunión de equipo',
--   'c0c67c2b-g36e-6457-079d-f68ef706dd8b',
--   'juan.perez@empresa.com',
--   'desarrollador@empresa.com',
--   NOW() - INTERVAL '6 hours',
--   false,
--   false
-- );
