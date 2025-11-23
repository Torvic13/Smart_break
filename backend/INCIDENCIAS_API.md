# Documentación de Endpoints - Incidencias

## Base URL
```
http://localhost:3000/api/v1
```

## Endpoints

### 1. Obtener incidencias no resueltas de un espacio
**GET** `/incidencias/espacio/:idEspacio`

**Descripción**: Obtiene todas las incidencias no resueltas reportadas para un espacio específico.

**Parámetros**:
- `idEspacio` (path param, string): ID del espacio

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Respuesta Exitosa (200)**:
```json
[
  {
    "idIncidencia": "uuid",
    "idEspacio": "123",
    "tipoIncidencia": "Ruido excesivo",
    "descripcion": "Hay mucho ruido",
    "fechaReporte": "2025-11-23T10:30:00Z",
    "usuarioReporte": "user-id",
    "resuelta": false,
    "fechaResolucion": null,
    "notas": ""
  }
]
```

---

### 2. Crear nueva incidencia
**POST** `/incidencias`

**Descripción**: Crea una nueva incidencia reportada por el usuario autenticado.

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Body**:
```json
{
  "idEspacio": "123",
  "tipoIncidencia": "Ruido excesivo",
  "descripcion": "Hay mucho ruido en el espacio"
}
```

**Tipos de incidencia válidos**:
- Daño en infraestructura
- Falta de limpieza
- Ruido excesivo
- Problemas de temperatura
- Falta de servicios (WiFi, enchufes)
- Seguridad
- Otro

**Respuesta Exitosa (201)**:
```json
{
  "message": "Incidencia reportada exitosamente",
  "incidencia": {
    "idIncidencia": "uuid",
    "idEspacio": "123",
    "tipoIncidencia": "Ruido excesivo",
    "descripcion": "Hay mucho ruido",
    "fechaReporte": "2025-11-23T10:30:00Z",
    "usuarioReporte": "user-id",
    "resuelta": false,
    "fechaResolucion": null,
    "notas": ""
  }
}
```

**Errores**:
- **400**: Falta algún campo obligatorio
- **401**: Usuario no autenticado
- **404**: Espacio no encontrado

---

### 3. Listar todas las incidencias (solo admin)
**GET** `/incidencias`

**Descripción**: Obtiene todas las incidencias del sistema.

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Respuesta Exitosa (200)**:
```json
[
  {
    "idIncidencia": "uuid",
    "idEspacio": "123",
    "tipoIncidencia": "Ruido excesivo",
    "descripcion": "Hay mucho ruido",
    "fechaReporte": "2025-11-23T10:30:00Z",
    "usuarioReporte": "user-id",
    "resuelta": false,
    "fechaResolucion": null,
    "notas": ""
  }
]
```

---

### 4. Resolver una incidencia (solo admin)
**PATCH** `/incidencias/:idIncidencia/resolver`

**Descripción**: Marca una incidencia como resuelta.

**Parámetros**:
- `idIncidencia` (path param, string): ID de la incidencia

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Body** (opcional):
```json
{
  "notas": "Se limpió el espacio"
}
```

**Respuesta Exitosa (200)**:
```json
{
  "message": "Incidencia resuelta",
  "incidencia": {
    "idIncidencia": "uuid",
    "idEspacio": "123",
    "tipoIncidencia": "Ruido excesivo",
    "descripcion": "Hay mucho ruido",
    "fechaReporte": "2025-11-23T10:30:00Z",
    "usuarioReporte": "user-id",
    "resuelta": true,
    "fechaResolucion": "2025-11-23T11:00:00Z",
    "notas": "Se limpió el espacio"
  }
}
```

---

### 5. Eliminar una incidencia (solo admin)
**DELETE** `/incidencias/:idIncidencia`

**Descripción**: Elimina una incidencia del sistema.

**Parámetros**:
- `idIncidencia` (path param, string): ID de la incidencia

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Respuesta Exitosa (200)**:
```json
{
  "message": "Incidencia eliminada"
}
```

---

### 6. Obtener incidencias reportadas por un usuario
**GET** `/incidencias/usuario/:idUsuario`

**Descripción**: Obtiene todas las incidencias reportadas por un usuario específico.

**Parámetros**:
- `idUsuario` (path param, string): ID del usuario

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Respuesta Exitosa (200)**:
```json
[
  {
    "idIncidencia": "uuid",
    "idEspacio": "123",
    "tipoIncidencia": "Ruido excesivo",
    "descripcion": "Hay mucho ruido",
    "fechaReporte": "2025-11-23T10:30:00Z",
    "usuarioReporte": "user-id",
    "resuelta": false,
    "fechaResolucion": null,
    "notas": ""
  }
]
```

---

## Códigos de Estado HTTP

| Código | Significado |
|--------|-------------|
| 200 | Éxito |
| 201 | Creado exitosamente |
| 400 | Solicitud inválida |
| 401 | No autenticado |
| 404 | No encontrado |
| 500 | Error del servidor |

---

## Notas de Implementación

- Todos los endpoints requieren autenticación vía JWT (token)
- Los endpoints de admin (resolver, eliminar, listar todos) requieren rol `admin`
- El `usuarioReporte` se obtiene del token JWT (`req.user.idUsuario`)
- Las incidencias se filtran por `resuelta: false` en el endpoint de obtener por espacio
- Los timestamps se guardan en UTC (ISO 8601)
