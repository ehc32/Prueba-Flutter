-- Crear tabla de invitaciones de tareas
CREATE TABLE task_invitations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  task_title TEXT NOT NULL,
  from_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  from_user_email TEXT NOT NULL,
  to_user_email TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_accepted BOOLEAN DEFAULT FALSE,
  is_declined BOOLEAN DEFAULT FALSE
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE task_invitations ENABLE ROW LEVEL SECURITY;

-- Crear políticas de seguridad para invitaciones
CREATE POLICY "Users can view invitations they sent" ON task_invitations
  FOR SELECT USING (auth.uid() = from_user_id);

CREATE POLICY "Users can view invitations they received" ON task_invitations
  FOR SELECT USING (to_user_email = (SELECT email FROM auth.users WHERE id = auth.uid()));

CREATE POLICY "Users can insert invitations" ON task_invitations
  FOR INSERT WITH CHECK (auth.uid() = from_user_id);

CREATE POLICY "Users can update invitations they received" ON task_invitations
  FOR UPDATE USING (to_user_email = (SELECT email FROM auth.users WHERE id = auth.uid()));

-- Crear índices para mejor rendimiento
CREATE INDEX idx_task_invitations_from_user_id ON task_invitations(from_user_id);
CREATE INDEX idx_task_invitations_to_user_email ON task_invitations(to_user_email);
CREATE INDEX idx_task_invitations_task_id ON task_invitations(task_id);
CREATE INDEX idx_task_invitations_created_at ON task_invitations(created_at DESC);
