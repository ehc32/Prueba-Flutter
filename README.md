# Task Manager - Aplicación de Tareas con Flutter y Supabase

Una aplicación moderna de gestión de tareas construida con Flutter y Supabase, que incluye autenticación completa y operaciones CRUD para tareas.

## 🚀 Características

- **Autenticación completa**: Registro e inicio de sesión con Supabase Auth
- **Gestión de tareas**: Crear, leer, actualizar y eliminar tareas
- **Diseño moderno**: Interfaz Material Design 3 con tema personalizable
- **Funcionalidades avanzadas**:
  - Fechas de vencimiento para tareas
  - Marcado de tareas como completadas
  - Estadísticas de tareas pendientes y completadas
  - Gestos de deslizamiento para editar/eliminar
  - Indicadores de tareas vencidas

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo móvil
- **Supabase**: Backend como servicio (BaaS)
- **Riverpod**: Gestión de estado
- **Go Router**: Navegación
- **Material Design 3**: Sistema de diseño

## 📋 Requisitos Previos

- Flutter SDK (versión 3.0 o superior)
- Dart SDK
- Cuenta de Supabase
- Android Studio / VS Code

## ⚙️ Configuración

### 1. Configurar Supabase

1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Ve a Settings > API y copia:
   - Project URL
   - anon/public key

### 2. Configurar la Base de Datos

En tu proyecto de Supabase, ejecuta el siguiente SQL para crear la tabla de tareas:

```sql
-- Crear tabla de tareas
CREATE TABLE tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  due_date TIMESTAMP WITH TIME ZONE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Crear políticas de seguridad
CREATE POLICY "Users can view their own tasks" ON tasks
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own tasks" ON tasks
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own tasks" ON tasks
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own tasks" ON tasks
  FOR DELETE USING (auth.uid() = user_id);
```

### 3. Configurar las Credenciales

1. Abre el archivo `lib/config/supabase_config.dart`
2. Reemplaza las credenciales con las de tu proyecto:

```dart
class SupabaseConfig {
  static const String url = 'TU_URL_DE_SUPABASE';
  static const String anonKey = 'TU_ANON_KEY_DE_SUPABASE';
}
```

### 4. Instalar Dependencias

```bash
flutter pub get
```

### 5. Ejecutar la Aplicación

```bash
flutter run
```

## 📱 Uso de la Aplicación

### Registro e Inicio de Sesión
1. Al abrir la aplicación, verás la pantalla de login
2. Puedes registrarte con un nuevo correo o iniciar sesión si ya tienes cuenta
3. La aplicación redirigirá automáticamente a la pantalla de tareas después de la autenticación

### Gestión de Tareas
- **Crear tarea**: Toca el botón flotante "+" en la pantalla principal
- **Editar tarea**: Desliza hacia la izquierda en una tarea y toca "Editar"
- **Eliminar tarea**: Desliza hacia la izquierda en una tarea y toca "Eliminar"
- **Marcar como completada**: Toca el checkbox de la tarea
- **Ver estadísticas**: Las estadísticas se muestran en la parte superior de la pantalla

## 🏗️ Estructura del Proyecto

```
lib/
├── config/
│   └── supabase_config.dart          # Configuración de Supabase
├── core/
│   └── providers/
│       └── auth_provider.dart        # Provider de autenticación
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── register_screen.dart
│   │       └── widgets/
│   │           └── auth_text_field.dart
│   └── tasks/
│       ├── domain/
│       │   └── models/
│       │       └── task.dart         # Modelo de tarea
│       └── presentation/
│           ├── providers/
│           │   └── tasks_provider.dart
│           ├── screens/
│           │   ├── tasks_screen.dart
│           │   ├── add_task_screen.dart
│           │   └── edit_task_screen.dart
│           └── widgets/
│               ├── task_card.dart
│               └── task_stats_card.dart
└── main.dart                         # Punto de entrada
```

## 🎨 Personalización

### Temas
La aplicación usa Material Design 3 con un tema personalizable. Puedes modificar los colores en `main.dart`:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF6750A4), // Cambia este color
  brightness: Brightness.light,
),
```

### Estilos
Los estilos están definidos en los widgets individuales y pueden ser personalizados según tus necesidades.

## 🔧 Solución de Problemas

### Error de Conexión a Supabase
- Verifica que las credenciales en `supabase_config.dart` sean correctas
- Asegúrate de que tu proyecto de Supabase esté activo

### Error de Permisos
- Verifica que las políticas RLS estén configuradas correctamente
- Asegúrate de que el usuario esté autenticado

### Problemas de Compilación
- Ejecuta `flutter clean` y luego `flutter pub get`
- Verifica que todas las dependencias estén actualizadas

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o un pull request para sugerir mejoras.

## 📞 Soporte

Si tienes alguna pregunta o problema, no dudes en abrir un issue en el repositorio.
