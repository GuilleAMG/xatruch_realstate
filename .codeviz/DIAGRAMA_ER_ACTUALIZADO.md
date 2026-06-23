# Diagrama Entidad-Relación Actualizado (2026-06-05)

```mermaid
erDiagram
    USUARIOS {
        string uid PK
        string email
        string nombre
        string phoneNumber
        string photoUrl
        string tier
        boolean isPremium
        timestamp premiumSince
        timestamp updatedAt
    }
    
    PROPIEDADES {
        string id PK
        string sellerId FK
        string title
        string location
        string department
        string municipality
        string propertyType
        number price
        array imageUrls
        array videoUrls
        string description
        number bedrooms
        number bathrooms
        number area
        boolean hasElectricity
        boolean hasWater
        number latitude
        number longitude
        timestamp expiresAt
        boolean isSold
        string buyerName
        string buyerId FK
        number soldPrice
        timestamp soldAt
        timestamp createdAt
    }
    
    CHATS {
        string id PK
        array participants
        map participantNames
        map participantAvatars
        object lastMessage
        array pinnedBy
        array archivedBy
        array deletedBy
    }
    
    MENSAJES {
        string id PK
        string senderId FK
        string chatId FK
        string content
        timestamp timestamp
        string type
        string mediaUrl
    }
    
    NOTIFICACIONES {
        string id PK
        string userId FK
        string title
        string body
        timestamp timestamp
        string type
        string relatedId FK
        boolean isRead
        string senderName
        string senderPhoto
    }
    
    FAVORITOS {
        string propertyId FK
        string userId FK
        timestamp addedAt
    }
    
    SIGUIENDO {
        string userId FK
        string targetUserId FK
        timestamp followedAt
    }
    
    REPORTES {
        string id PK
        string reporterId FK
        string reportedId
        string reportedUserId FK
        string reportType
        string reason
        string description
        timestamp createdAt
        string status
    }
    
    USUARIOS ||--o{ PROPIEDADES : "vende"
    USUARIOS ||--o{ PROPIEDADES : "compra"
    USUARIOS ||--o{ CHATS : "participa"
    USUARIOS ||--o{ MENSAJES : "envia"
    USUARIOS ||--o{ NOTIFICACIONES : "recibe"
    USUARIOS ||--o{ FAVORITOS : "tiene"
    USUARIOS ||--o{ SIGUIENDO : "sigue"
    USUARIOS ||--o{ REPORTES : "reporta"
    USUARIOS ||--o{ REPORTES : "es_reportado"
    
    PROPIEDADES ||--o{ FAVORITOS : "es_favorita"
    PROPIEDADES ||--o{ NOTIFICACIONES : "referencia"
    
    CHATS ||--o{ MENSAJES : "contiene"
    MENSAJES ||--o{ NOTIFICACIONES : "referencia"
```

## Tabla Comparativa: Antes vs Después

| Entidad | Cambio | Detalles |
|---------|--------|---------|
| **PROPIEDADES** | 🟢 EXPANDIDO | +17 campos nuevos (detalles, multimedia, geolocalización, venta) |
| **USUARIOS** | 🟡 FALTA MODELO | Solo existe SessionUser (uid, email, displayName, phoneNumber) |
| **NOTIFICACIONES** | 🟢 MEJORADO | +3 campos (isRead, senderName, senderPhoto) |
| **MENSAJES** | 🟢 MEJORADO | +2 campos (type para multimedia, mediaUrl) |
| **CHATS** | 🟢 MEJORADO | +4 campos (lastMessage embedded, pinnedBy, archivedBy, deletedBy) |
| **FAVORITOS** | 🟢 NORMALIZADO | Estructura confirmada como subcollection |
| **SIGUIENDO** | 🟢 CONFIRMADO | Estructura de subcollection validada |
| **REPORTES** | 🟢 MEJORADO | +2 campos (reason, status) |
| **SUBSCRIPTIONS** | 🆕 NUEVO | Almacenado en USUARIOS (tier, isPremium, premiumSince) |
| **PAYMENTS** | 🔴 EXTERNO | Gestionado por RevenueCat (no en Firestore) |

## Relaciones Principales

```
USUARIOS (uid) ──────┐
                    ├─→ PROPIEDADES (como sellerId)
                    ├─→ PROPIEDADES (como buyerId)
                    ├─→ CHATS (participante)
                    ├─→ MENSAJES (senderId)
                    ├─→ NOTIFICACIONES (userId)
                    ├─→ FAVORITOS (userId) → PROPIEDADES
                    ├─→ SIGUIENDO (userId) → USUARIOS (targetUserId)
                    └─→ REPORTES (reporterId/reportedUserId)

CHATS (id) ──────────→ MENSAJES
          └─────────→ USUARIOS (participants)

PROPIEDADES (id) ────→ NOTIFICACIONES (relatedId)
             └──────→ FAVORITOS
```

## Cambios Críticos por Impacto

### 🔴 Alto Impacto
1. **USUARIOS sin modelo completo** - La mayoría de operaciones dependen de este modelo
2. **Nuevos campos en PROPIEDADES** - Requieren actualización de Firestore rules

### 🟡 Medio Impacto
1. **Campo relatedId en NOTIFICACIONES** - Requiere validación de FK en rules
2. **Embedded lastMessage en CHATS** - Potencial sincronización duplicada

### 🟢 Bajo Impacto
1. **type en MENSAJES** - Cambio compatible hacia atrás
2. **SUBSCRIPTIONS en USUARIOS** - Datos adicionales sin conflicto

## Próximas Acciones

1. ✅ Leer modelos existentes
2. ✅ Comparar con diagrama anterior
3. ⏳ **Crear modelo completo USUARIOS**
4. ⏳ Validar Firestore rules con nueva estructura
5. ⏳ Crear índices necesarios
6. ⏳ Documentar campos de auditoría (createdAt, updatedAt)
7. ⏳ Revisar campos redundantes (isFavorite en PROPIEDADES)
