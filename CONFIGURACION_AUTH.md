# Configuración de Autenticación - App FAM

## 🚀 Configuración del Backend

### 1. Crear archivo .env en la carpeta backend_fam/

```env
# Configuración de la base de datos
DB_HOST=localhost
DB_PORT=3306
DB_NAME=fam_db
DB_USER=root
DB_PASSWORD=tu_password_mysql

# JWT Secret (cambia esto por una clave secreta más segura)
JWT_SECRET=mi_clave_super_secreta_jwt_123456789

# Puerto del servidor
PORT=4000
```

### 2. Instalar dependencias del backend
```bash
cd backend_fam
npm install
```

### 3. Configurar base de datos MySQL
- Crear una base de datos llamada `fam_db`
- Ajustar las credenciales en el archivo .env

### 4. Iniciar el servidor backend
```bash
npm start
```

## 📱 Configuración de la App Flutter

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar URL del backend
En el archivo `lib/services/auth_service.dart`, línea 7, ajusta la URL según tu configuración:

```dart
// Para emulador Android
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Para dispositivo físico (cambiar por tu IP local)
static const String baseUrl = 'http://192.168.1.100:3000/api';

// Para web
static const String baseUrl = 'http://localhost:3000/api';
```

### 3. Ejecutar la app
```bash
flutter run
```

## 🔐 Funcionalidades Implementadas

### Backend (Node.js + Express + Sequelize)
- ✅ Registro de usuarios
- ✅ Login con JWT
- ✅ Middleware de autenticación
- ✅ Verificación de tokens
- ✅ Endpoint de perfil de usuario
- ✅ Encriptación de contraseñas con bcrypt

### Frontend (Flutter)
- ✅ Pantalla de splash con verificación de autenticación
- ✅ Pantalla de login
- ✅ Pantalla de registro
- ✅ Servicio de autenticación
- ✅ Almacenamiento local de tokens
- ✅ Navegación automática según estado de autenticación
- ✅ Botón de logout en pantalla principal

## 📋 Flujo de Autenticación

1. **Al abrir la app**: Se muestra la pantalla de splash
2. **Verificación**: Se verifica si hay un token válido guardado
3. **Si está logueado**: Va directo a la pantalla principal
4. **Si no está logueado**: Va a la pantalla de login
5. **Login exitoso**: Se guarda el token y va a la pantalla principal
6. **Logout**: Se elimina el token y va a la pantalla de login

## 🛠️ Estructura de Archivos Creados

```
lib/
├── services/
│   └── auth_service.dart          # Servicio de autenticación
├── pantallas/
│   ├── login.dart                 # Pantalla de login
│   ├── register.dart              # Pantalla de registro
│   └── splash.dart                # Pantalla de carga inicial
└── main.dart                      # Actualizado para usar splash

backend_fam/
├── src/
│   ├── controllers/
│   │   └── user.controller.js     # Agregada función getUserProfile
│   └── routes/
│       └── user.routes.js         # Agregada ruta /profile
└── .env.example                   # Ejemplo de configuración
```

## 🚨 Notas Importantes

1. **Seguridad**: Cambia el JWT_SECRET por una clave más segura
2. **URL del backend**: Ajusta la URL según tu entorno (emulador/dispositivo físico)
3. **Base de datos**: Asegúrate de que MySQL esté ejecutándose
4. **Puerto**: El backend corre en el puerto 3000 por defecto

## 🔐 Sistema de Roles

### Roles Disponibles:
- **`usuario`**: Usuario normal (por defecto)
- **`fam`**: Miembro de FAM Bolivia
- **`admin`**: Administrador del sistema

### Registro de Usuarios:

#### Registro Normal (público):
```json
POST /api/auth/register
{
  "name": "Juan Pérez",
  "email": "juan@email.com",
  "password": "password123",
  "role": "usuario"  // o "fam"
}
```

#### Registro de Administradores (solo admins):
```json
POST /api/auth/register-admin
Authorization: Bearer <token_admin>
{
  "name": "Admin User",
  "email": "admin@fam.com",
  "password": "admin123",
  "role": "admin"
}
```

### Pruebas con Postman:

1. **Registro normal**:
   ```json
   {
     "name": "Jose Brochi",
     "email": "Brochi@fam.com",
     "password": "brochi123",
     "role": "fam"
   }
   ```

2. **Login**:
   ```json
   {
     "email": "Brochi@fam.com",
     "password": "brochi123"
   }
   ```

3. **Verificar perfil**:
   ```
   GET /api/users/profile
   Authorization: Bearer <token>
   ```

## 🧪 Pruebas

1. Registra un nuevo usuario con rol "fam"
2. Inicia sesión con las credenciales
3. Verifica que el rol se muestre correctamente en la app
4. Verifica que puedas acceder a la pantalla principal
5. Prueba el logout
6. Verifica que al cerrar y abrir la app, mantenga la sesión

## 🎨 Interfaz de Usuario

- **Selector de rol** en el registro (Usuario Normal / Miembro FAM)
- **Información del usuario** en la pantalla principal
- **Badge de rol** con colores:
  - 🟢 Verde: Usuario Normal
  - 🔵 Azul: Miembro FAM
  - 🔴 Rojo: Administrador

## 🏛️ Sistema de Navegación Municipal

### Flujo de Navegación:
1. **Pantalla Principal** → Botón "VER DEPARTAMENTOS"
2. **Lista de Departamentos** → Seleccionar departamento
3. **Asociaciones del Departamento** → Seleccionar asociación
4. **Miembros de la Asociación** → Ver información detallada

### Endpoints Implementados:

#### Departamentos:
```
GET /api/departamentos/public
Authorization: Bearer <token>
```

#### Asociaciones por Departamento:
```
GET /api/asociaciones/departamento/:departamentoId
Authorization: Bearer <token>
```

#### Miembros por Asociación:
```
GET /api/miembros/asociacion/:asociacionId
Authorization: Bearer <token>
```

### Filtros de Información por Rol:

#### Para Usuarios Normales:
- **Asociaciones**: alias, nombre, municipio, teléfono_publico, fax, correo_publico, direccion
- **Miembros**: alias, nombre, municipio, teléfono_publico, fax, correo_publico, direccion

#### Para Usuarios FAM y Admin:
- **Asociaciones**: Todos los campos + presidente, teléfono_personal, correo_personal, tipo, estado
- **Miembros**: Todos los campos + teléfono_personal, correo_personal, tipo_miembro, estado

### Registro de Usuarios:

#### Usuarios Normales (Público):
```json
POST /api/auth/register
{
  "name": "Juan Pérez",
  "email": "juan@email.com",
  "password": "password123"
}
```
*Solo pueden registrarse como usuarios normales*

#### Usuarios FAM (Solo Admins):
```json
POST /api/auth/register-fam
Authorization: Bearer <token_admin>
{
  "name": "Maria FAM",
  "email": "maria@fam.com",
  "password": "fam123"
}
```
*Solo administradores pueden crear usuarios FAM*

¡Listo! Tu app ahora tiene un sistema completo de navegación municipal con autenticación y filtros de información por roles. 🎉
