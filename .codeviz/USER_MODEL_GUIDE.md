# User Model - Guía de Implementación

## 📋 Descripción

Se creó el modelo `User` completo que faltaba en el proyecto. Este modelo representa la entidad USUARIOS en Firestore con todos sus campos y relaciones.

**Ubicación:** `lib/features/profile/data/user.dart`

## 📊 Estructura del Modelo

### Campos Principales

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `uid` | String | ID único del usuario (Firebase UID) |
| `email` | String | Correo electrónico |
| `nombre` | String | Nombre completo del usuario |
| `phoneNumber` | String | Número de teléfono |
| `photoUrl` | String | URL de la foto de perfil |

### Suscripción y Premium

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `tier` | String | Nivel de suscripción (Estudiante, Residente, Inversionista, Empresario) |
| `isPremium` | bool | Si el usuario tiene acceso premium |
| `premiumSince` | DateTime? | Fecha cuando inició el tier premium |

### Preferencias y Estado

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `status` | String | Estado del usuario (active, suspended, etc.) |
| `isUserMode` | bool | Modo de usuario (vs. admin) |
| `notificationsEnabled` | bool | Notificaciones push habilitadas |
| `locationEnabled` | bool | Compartir ubicación habilitado |
| `isAdmin` | bool | Es administrador |
| `fcmToken` | String | Token FCM para push notifications |

### Gestión de Cuenta

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `scheduledForDeletion` | bool | Cuenta programada para eliminación |
| `deletionScheduledAt` | DateTime? | Fecha de eliminación programada |
| `createdAt` | DateTime? | Fecha de creación |
| `updatedAt` | DateTime? | Fecha de última actualización |

## 💻 Métodos Disponibles

### Serialización

```dart
// Crear desde Firestore
User user = User.fromMap(firestoreData, uid);

// Convertir a mapa para Firestore
Map<String, dynamic> data = user.toMap();

// Copiar con cambios parciales
User updated = user.copyWith(
  nombre: 'Nuevo Nombre',
  tier: 'Inversionista',
);
```

### UserService - Métodos para User

```dart
// Obtener usuario completo
User? user = await userService.getUser(uid);

// Stream en tiempo real
userService.streamUser(uid).listen((user) {
  if (user != null) {
    print('Usuario: ${user.nombre}');
  }
});

// Actualizar usuario
await userService.updateUser(updatedUser);
```

### UserService - Métodos Existentes

Los métodos anteriores siguen disponibles:

```dart
// Datos crudos de Firestore
Map<String, dynamic>? data = await userService.getUserData(uid);
Stream<Map<String, dynamic>?> dataStream = userService.streamUserData(uid);

// Actualizar perfil específico
await userService.updateProfile(
  uid: uid,
  nombre: 'Juan',
  photoUrl: 'https://...',
);

// Preferencias
await userService.updateNotificationPreference(uid: uid, enabled: false);
await userService.updateLocationPreference(uid: uid, enabled: true);

// Creación
await userService.createUserDocument(
  uid: uid,
  nombre: 'Juan Pérez',
  email: 'juan@example.com',
  photoUrl: 'https://...',
);

// Tokens FCM
await userService.saveFcmToken(token);
await userService.clearFcmToken();

// Eliminación
await userService.scheduleAccountDeletion(uid);
await userService.deleteUserDocument(uid);
```

## 🔄 Estructura de Firestore

```
usuarios/
  {uid}
    - uid: string
    - email: string
    - nombre: string
    - phoneNumber: string
    - photoUrl: string
    - tier: string (Estudiante, Residente, Inversionista, Empresario)
    - isPremium: boolean
    - premiumSince: timestamp (nullable)
    - status: string (active, suspended, etc.)
    - isUserMode: boolean
    - notificationsEnabled: boolean
    - locationEnabled: boolean
    - isAdmin: boolean
    - fcmToken: string
    - scheduledForDeletion: boolean
    - deletionScheduledAt: timestamp (nullable)
    - createdAt: timestamp
    - updatedAt: timestamp
```

### Subcollections

```
usuarios/{uid}/
  siguiendo/
    {targetUserId}
      - followedAt: timestamp
  
  favoritos/
    {propertyId}
      - addedAt: timestamp
```

## 📌 Integración con SessionUser

La clase `SessionUser` (en `lib/core/session/session_user.dart`) sigue siendo un modelo ligero para:
- Mantener datos de sesión activa
- Usar en contextos de estado global
- Pasar por parámetros cuando solo necesitas uid/email

La clase `User` es para:
- Cargar/guardar datos completos de Firestore
- Operaciones CRUD en el perfil
- Acceder a preferencias y configuración

## 🎯 Casos de Uso

### 1. Obtener perfil completo del usuario actual

```dart
final currentUid = authService.currentUser?.uid;
if (currentUid != null) {
  final user = await userService.getUser(currentUid);
  if (user != null) {
    print('Nombre: ${user.nombre}');
    print('Tier: ${user.tier}');
    print('Premium: ${user.isPremium}');
  }
}
```

### 2. Actualizar múltiples campos

```dart
User? user = await userService.getUser(uid);
if (user != null) {
  User updated = user.copyWith(
    nombre: 'Nuevo Nombre',
    photoUrl: 'nueva_url',
    notificationsEnabled: false,
  );
  await userService.updateUser(updated);
}
```

### 3. Escuchar cambios en tiempo real

```dart
userService.streamUser(uid).listen((user) {
  if (user != null) {
    setState(() {
      _user = user;
    });
  }
});
```

### 4. Verificar si es usuario premium

```dart
User? user = await userService.getUser(uid);
if (user?.isPremium ?? false) {
  // Usuario es premium
}
```

## 🔒 Notas de Seguridad

- Los campos `isAdmin`, `scheduledForDeletion` deben ser protegidos en Firestore Rules
- El campo `fcmToken` debe sincronizarse de forma segura
- La suscripción (`tier`, `isPremium`) es sincronizada automáticamente por `subscription_service.dart`
- Los cambios en USUARIOS deben validarse en las reglas de seguridad

## 🚀 Próximos Pasos

1. ✅ Crear modelo User
2. ✅ Agregar métodos a UserService
3. ⏳ Integrar User en ProfileController
4. ⏳ Reemplazar Map<String, dynamic> con User donde sea posible
5. ⏳ Actualizar tests
6. ⏳ Revisar Firestore Rules para este modelo
