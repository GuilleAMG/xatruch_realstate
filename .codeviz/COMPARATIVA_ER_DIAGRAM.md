# Comparativa: Diagrama ER Anterior vs Actual

## Resumen de Cambios Detectados

### 1. **PROPIEDADES (Property)**
**Campos anteriores:**
- id (PK)
- sellerId (FK)
- title
- price
- dateCreatedAt

**Cambios realizados:**
- ✅ Agregados: `location`, `department`, `municipality`, `propertyType`
- ✅ Agregados campos multimedia: `imageUrls[]`, `videoUrls[]`
- ✅ Agregados detalles: `description`, `bedrooms`, `bathrooms`, `area`
- ✅ Agregados servicios: `hasElectricity`, `hasWater`
- ✅ Agregados geolocalización: `latitude`, `longitude`
- ✅ Agregados control de vigencia: `expiresAt`
- ✅ Agregados campos de venta: `isSold`, `buyerName`, `buyerId`, `soldPrice`, `soldAt`
- ✅ Agregado: `isFavorite` (booleano local)

### 2. **USUARIOS (USUARIOS)**
**Diagrama anterior incluía:**
- uid (PK)
- nombre
- email
- phoneNumber
- status
- isUserMode
- notificationsEnabled

**Nota importante:**
- El código actual solo tiene `SessionUser` (modelo de sesión)
- Falta el modelo completo de usuario en Firestore
- **RECOMENDACIÓN:** Crear entidad USUARIOS completa con todos los campos

### 3. **NOTIFICACIONES (AppNotification)**
**Campos anteriores:**
- id (PK)
- userId (FK)
- type
- title
- timestamp

**Cambios realizados:**
- ✅ Agregados: `body`, `isRead`
- ✅ Agregados: `senderName`, `senderPhoto`
- ✅ Agregado: `relatedId` (FK a Property o Chat)

### 4. **MENSAJES (Message)**
**Campos anteriores:**
- id (PK)
- senderId (FK)
- content
- timestamp

**Cambios realizados:**
- ✅ Agregados: `type` (text, image, video)
- ✅ Agregado: `mediaUrl`

### 5. **CHATS (Chat)**
**Campos anteriores:**
- id (PK)
- participants[]
- participantNames{}
- participantAvatars{}
- updateAt

**Cambios realizados:**
- ✅ Agregado: `lastMessage` (embedded Message)
- ✅ Agregados: `pinnedBy[]`, `archivedBy[]`, `deletedBy[]`
- ⚠️ Cambio: Almacenan datos desnormalizados (otherUserName, otherUserAvatar)

### 6. **FAVORITOS (Subcollection)**
**Diagrama anterior:**
- id (PK)
- propertyId (FK)
- dateAdded

**Estructura actual (Firestore):**
```
usuarios/{uid}/favoritos/{propertyId}
  - addedAt: timestamp
```
- ✅ Implementado como subcollection
- ✅ Relación implícita uid → propertyId
- ✅ Cada doc tiene `addedAt`
- ✅ Campo `isFavorite` en Property para cache local

### 7. **SIGUIENDO (Subcollection)**
**Diagrama anterior:**
- targetUserId (PK)
- followedUserId (PK)

**Estructura actual (Firestore):**
```
usuarios/{uid}/siguiendo/{targetUserId}
  - followedAt: timestamp
```
- ✅ Implementado como subcollection
- ✅ `uid` es quien sigue, `targetUserId` es a quién sigue
- ✅ Cada doc tiene `followedAt`
- ✅ Método para obtener followers usando collectionGroup query

### 8. **REPORTES (Report)**
**Campos anteriores:**
- id (PK)
- reporterId (FK)
- reportedUserId (FK)
- reportType

**Cambios realizados:**
- ✅ Agregados: `reason`, `description`
- ✅ Agregado: `createdAt`
- ✅ Agregado: `status` (pending, reviewed, resolved)

---

## 9. **SUBSCRIPTIONS (Campos en USUARIOS)**
**Implementación:**
- Almacenados directamente en documentos de USUARIOS
- Campos: `tier`, `isPremium`, `premiumSince`, `updatedAt`
- Tiers: 'Estudiante' (free), 'Residente' (110), 'Inversionista' (320), 'Empresario' (670)
- Sincronizados desde RevenueCat

## 10. **PAYMENTS (Externo - RevenueCat)**
**Implementación:**
- No hay tabla PAYMENTS en Firestore
- Gestionado completamente por RevenueCat SDK
- Solo se sincroniza el estado del tier a Firestore
- No se requiere almacenar historial de transacciones localmente

---

## Estructura de Colecciones Firestore Detectada

```
usuarios/
  {uid}
    - email: string
    - nombre: string
    - phoneNumber: string
    - photoUrl: string (observado en notifications)
    - tier: string (Estudiante, Residente, Inversionista, Empresario)
    - isPremium: boolean
    - premiumSince: timestamp
    - updatedAt: timestamp
    
    siguiendo/
      {targetUserId}
        - followedAt: timestamp
    
    favoritos/
      {propertyId}
        - addedAt: timestamp

propiedades/
  {id}
    - title: string
    - location: string
    - department: string
    - municipality: string
    - propertyType: string
    - price: number
    - imageUrls: array
    - videoUrls: array
    - description: string
    - bedrooms: number
    - bathrooms: number
    - area: number
    - hasElectricity: boolean
    - hasWater: boolean
    - latitude: number
    - longitude: number
    - sellerId: string (FK usuarios)
    - sellerName: string
    - expiresAt: timestamp
    - isSold: boolean
    - buyerName: string
    - buyerId: string (FK usuarios)
    - soldPrice: number
    - soldAt: timestamp
    - createdAt: timestamp

chats/
  {id}
    - participants: array [uid1, uid2]
    - participantNames: map {uid: name}
    - participantAvatars: map {uid: photoUrl}
    - lastMessage: embedded Message object
    - pinnedBy: array
    - archivedBy: array
    - deletedBy: array
    
    messages/
      {msgId}
        - senderId: string (FK usuarios)
        - content: string
        - timestamp: timestamp
        - type: string (text, image, video)
        - mediaUrl: string (optional)

notificaciones/
  {id}
    - userId: string (FK usuarios - recipient)
    - title: string
    - body: string
    - timestamp: timestamp
    - type: string (favorite, message, property_sold, new_post, etc)
    - relatedId: string (FK propiedades o chats)
    - isRead: boolean
    - senderName: string
    - senderPhoto: string

reportes/
  {id}
    - reporterId: string (FK usuarios)
    - reportedId: string (FK propiedades o mensajes)
    - reportedUserId: string (FK usuarios - optional)
    - reportType: string (property, message, user)
    - reason: string
    - description: string
    - createdAt: timestamp
    - status: string (pending, reviewed, resolved)
```

---

## Recomendaciones y Próximos Pasos

### 1. **CRÍTICO: Crear modelo USUARIOS completo**
- El código actual solo tiene `SessionUser` para sesión
- Necesita modelo completo con todos los campos de perfil
- Incluir: email, nombre, phoneNumber, photoUrl, tier, isPremium, etc.

### 2. **Documentar Firestore Rules**
- Verificar que las reglas de seguridad reflejen esta estructura
- Validar permisos en subcollections (siguiendo, favoritos)
- Revisar que los campos sean accesibles según roles

### 3. **Considerar normalización**
- `isFavorite` en Property es redundante si existe `usuarios/{uid}/favoritos/{propertyId}`
- Decidir: ¿caché local o eliminar campo?

### 4. **Revisar indexes necesarios**
- Query en `propiedades` por `sellerId`
- Query en `reportes` por estado y tipo
- CollectionGroup en `siguiendo` para obtener followers

### 5. **Documentar campos de auditoría**
- Considerar agregar `createdAt` y `updatedAt` a todas las entidades
- Ya existe en algunos modelos (Property, Report)
- Estandarizar formato

