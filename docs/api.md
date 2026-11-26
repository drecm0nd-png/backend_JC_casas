# Contrato de API - JCasas

Referencia para el frontend. Backend Django + DRF, monolito modular.

## Convenciones globales

- Base URL: `/api/v1`
- Autenticación: `Authorization: Bearer <access_jwt>` en toda ruta autenticada.
- Login y emisión/validación de JWT los gestiona el módulo `autenticacion` y **no** forman parte de este documento.
- Roles: `cliente` y `administrador`. Cocina no es un rol de sistema.
- Dinero: entero en COP, sin decimales, sin IVA.
- Fechas: ISO 8601 con zona horaria (ej. `2026-11-26T13:30:00-05:00`).
- IDs: enteros.
- Paginación: `{ "count", "next", "previous", "results" }` con `?page=`.
- Nunca se devuelven contraseñas ni hashes.

### Formato de error

```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": {}
  }
}
```

### Códigos HTTP comunes

| Código | Significado |
|---|---|
| 400 | Error de validación de entrada |
| 401 | No autenticado o token inválido/expirado |
| 403 | Autenticado sin permiso para la acción |
| 404 | Recurso no encontrado |
| 409 | Conflicto de estado o transición inválida |
| 500 | Error interno del servidor |
| 503 | Servicio de impresora no disponible |

---

## Módulo usuarios

Gestiona datos, credenciales y preferencias del usuario. No emite tokens.

| Método | Ruta | Rol | Datos | Respuesta | Errores |
|---|---|---|---|---|---|
| POST | `/usuarios/registro` | público | `nombre, email, password, telefono, direccion` | `201` usuario | 400, 409 |
| GET | `/usuarios/me` | cliente/admin | — | `200` perfil propio | 401 |
| PATCH | `/usuarios/me` | cliente/admin | `nombre?, telefono?, direccion?` | `200` perfil | 400, 401 |
| PATCH | `/usuarios/me/email` | cliente/admin | `email, password_actual` | `200` perfil | 400, 401, 409 |
| POST | `/usuarios/me/password` | cliente/admin | `password_actual, password_nueva` | `204` | 400, 401 |
| GET | `/usuarios/me/preferencias` | cliente/admin | — | `200` preferencias | 401 |
| PATCH | `/usuarios/me/preferencias` | cliente/admin | `notificaciones_email?, notificaciones_push?, notificaciones_whatsapp?` | `200` preferencias | 400, 401 |
| GET | `/usuarios/` | admin | `?q=&rol=&activo=&page=` | `200` lista paginada | 401, 403 |
| GET | `/usuarios/{id}/` | admin | — | `200` usuario | 401, 403, 404 |
| PATCH | `/usuarios/{id}/` | admin | `nombre?, rol?, activo?` | `200` usuario | 400, 401, 403, 404 |
| DELETE | `/usuarios/{id}/` | admin | — | `204` baja lógica | 401, 403, 404, 409 |

### Esquema de usuario

```json
{
  "id": 1,
  "nombre": "Ana Perez",
  "email": "ana@example.com",
  "telefono": "3001234567",
  "direccion": "Calle 1 #2-3",
  "rol": "cliente",
  "activo": true,
  "fecha_registro": "2026-11-26T13:30:00-05:00"
}
```

### Esquema de preferencias

```json
{
  "notificaciones_email": true,
  "notificaciones_push": false,
  "notificaciones_whatsapp": true
}
```

### Errores específicos

- `409` en `registro`/`me/email`: email ya registrado.
- `409` en `DELETE /usuarios/{id}/`: no se puede eliminar al propio administrador o usuario con pedidos activos.

---

## Módulo menu

Catálogos reutilizables de ingredientes y adicionales, y un precio fijo global del almuerzo.

| Método | Ruta | Rol | Datos | Respuesta | Errores |
|---|---|---|---|---|---|
| GET | `/menu/configuracion/` | auth | — | `200` configuración | 401 |
| PATCH | `/menu/configuracion/` | admin | `precio_fijo` | `200` configuración | 400, 401, 403 |
| GET | `/menu/almuerzos/` | auth | `?disponible=` | `200` almuerzos | 401 |
| GET | `/menu/almuerzos/{id}/` | auth | — | `200` almuerzo + ingredientes + adicionales | 401, 404 |
| POST | `/menu/almuerzos/` | admin | `nombre, descripcion, ingredientes_ids[], disponible` | `201` almuerzo | 400, 401, 403 |
| PATCH | `/menu/almuerzos/{id}/` | admin | campos parciales | `200` almuerzo | 400, 401, 403, 404 |
| DELETE | `/menu/almuerzos/{id}/` | admin | — | `204` baja lógica (`disponible=false`) | 401, 403, 404, 409 |
| GET | `/menu/ingredientes/` | auth | `?disponible=` | `200` ingredientes | 401 |
| POST | `/menu/ingredientes/` | admin | `nombre, disponible` | `201` ingrediente | 400, 401, 403 |
| PATCH | `/menu/ingredientes/{id}/` | admin | `nombre?, disponible?` | `200` ingrediente | 400, 401, 403, 404 |
| DELETE | `/menu/ingredientes/{id}/` | admin | — | `204` baja lógica | 401, 403, 404, 409 |
| GET | `/menu/adicionales/` | auth | `?disponible=` | `200` adicionales | 401 |
| POST | `/menu/adicionales/` | admin | `nombre, precio, disponible` | `201` adicional | 400, 401, 403 |
| PATCH | `/menu/adicionales/{id}/` | admin | campos parciales | `200` adicional | 400, 401, 403, 404 |
| DELETE | `/menu/adicionales/{id}/` | admin | — | `204` baja lógica | 401, 403, 404, 409 |

### Esquema de configuración

```json
{ "precio_fijo": 12000 }
```

### Esquema de almuerzo

```json
{
  "id": 1,
  "nombre": "Almuerzo del dia",
  "descripcion": "Arroz, proteina, ensalada y bebida",
  "precio_fijo": 12000,
  "disponible": true,
  "ingredientes": [
    { "id": 1, "nombre": "Arroz" },
    { "id": 2, "nombre": "Ensalada" }
  ],
  "adicionales": [
    { "id": 3, "nombre": "Huevo", "precio": 2000 },
    { "id": 4, "nombre": "Bebida extra", "precio": 3000 }
  ]
}
```

### Errores específicos

- `409` al eliminar un ingrediente/adicional/almuerzo en uso por un pedido activo.
- `400` si `precio_fijo` o `precio` son negativos.

---

## Módulo pedido

Solo un cliente autenticado puede crear pedidos. El total siempre lo calcula el servidor.

| Método | Ruta | Rol | Datos | Respuesta | Errores |
|---|---|---|---|---|---|
| POST | `/pedidos/` | cliente | ver body | `201` pedido `pendiente` | 400, 401, 409 |
| GET | `/pedidos/` | auth | `?estado=&desde=&hasta=&page=` | `200` lista (cliente: solo propios) | 401 |
| GET | `/pedidos/{id}/` | dueño/admin | — | `200` detalle + historial | 401, 403, 404 |
| POST | `/pedidos/{id}/confirmar` | cliente dueño | — | `200` estado `preparacion` | 401, 403, 404, 409 |
| POST | `/pedidos/{id}/cancelar` | cliente/admin | `motivo?` | `200` estado `cancelado` | 401, 403, 404, 409 |
| PATCH | `/pedidos/{id}/estado/` | admin | `estado` (`listo`/`entregado`) | `200` pedido | 400, 401, 403, 404, 409 |

### Body de creación

```json
{
  "nombre_cliente": "Ana Perez",
  "telefono": "3001234567",
  "direccion": "Calle 1 #2-3",
  "metodo_pago": "nequi",
  "notas": "sin cebolla",
  "items": [
    {
      "almuerzo_id": 1,
      "cantidad": 2,
      "adicionales": [
        { "adicional_id": 3, "cantidad": 1 }
      ]
    }
  ]
}
```

- `metodo_pago`: `nequi`, `daviplata` o `efectivo`. No se acepta tarjeta de crédito.
- Los adicionales se asocian a cada almuerzo y se cobran por almuerzo.
- `total = suma por almuerzo de (precio_fijo + adicionales de ese almuerzo)`.

### Esquema de pedido

```json
{
  "id": 10,
  "nombre_cliente": "Ana Perez",
  "telefono": "3001234567",
  "direccion": "Calle 1 #2-3",
  "metodo_pago": "nequi",
  "notas": "sin cebolla",
  "estado": "pendiente",
  "total": 28000,
  "fecha_creacion": "2026-11-26T13:30:00-05:00",
  "items": [
    {
      "almuerzo": {
        "id": 1,
        "nombre": "Almuerzo del dia",
        "precio_fijo": 12000,
        "ingredientes": [{ "id": 1, "nombre": "Arroz" }]
      },
      "cantidad": 2,
      "adicionales": [
        { "adicional_id": 3, "nombre": "Huevo", "precio": 2000, "cantidad": 1 }
      ],
      "subtotal": 28000
    }
  ],
  "historial": [
    { "estado": "pendiente", "fecha": "2026-11-26T13:30:00-05:00" }
  ]
}
```

### Transiciones de estado

```
pendiente --confirmar(cliente)--> preparacion --admin--> listo --admin--> entregado
pendiente --cancelar(cliente/admin)--> cancelado
preparacion/listo --cancelar(admin)--> cancelado
entregado: no cancelable
```

### Errores específicos

- `400`: método de pago inválido, cantidad <= 0, ítems vacíos, falta dirección/nombre.
- `409` en creación: almuerzo o adicional no disponible.
- `409` en `confirmar`: el pedido no está en `pendiente`.
- `409` en `cancelar`: pedido `entregado`, o cliente intentando cancelar fuera de `pendiente`.
- `409` en `estado`: transición no permitida.

---

## Módulo impresora

Integración real con hardware. El administrador imprime la comanda física y la envía a cocina.

| Método | Ruta | Rol | Datos | Respuesta | Errores |
|---|---|---|---|---|---|
| GET | `/impresora/estado/` | admin | — | `200` estado de hardware | 401, 403, 503 |
| GET | `/impresora/comandas/{pedido_id}/` | admin | — | `200` comanda digital | 401, 403, 404 |
| POST | `/impresora/comandas/{pedido_id}/imprimir` | admin | — | `201` trabajo | 401, 403, 404, 409, 503 |
| POST | `/impresora/trabajos/{id}/reimprimir` | admin | — | `201` trabajo | 401, 403, 404, 409, 503 |
| GET | `/impresora/trabajos/` | admin | `?estado=&pedido=&page=` | `200` lista paginada | 401, 403 |
| GET | `/impresora/trabajos/{id}/` | admin | — | `200` trabajo | 401, 403, 404 |

### Esquema de comanda (digital)

```json
{
  "pedido_id": 10,
  "fecha": "2026-11-26T13:30:00-05:00",
  "nombre_cliente": "Ana Perez",
  "total": 28000,
  "metodo_pago": "nequi",
  "notas": "sin cebolla",
  "items": [
    {
      "almuerzo": "Almuerzo del dia",
      "cantidad": 2,
      "ingredientes": ["Arroz", "Ensalada"],
      "adicionales": [{ "nombre": "Huevo", "cantidad": 1 }]
    }
  ]
}
```

### Esquema de trabajo de impresión

```json
{
  "id": 5,
  "pedido_id": 10,
  "comanda_id": 3,
  "estado": "en_cola",
  "fecha_creacion": "2026-11-26T13:31:00-05:00",
  "error": null
}
```

- `estado` del trabajo: `en_cola`, `imprimiendo`, `impreso`, `fallido`.

### Errores específicos

- `404`: pedido no existe o comanda aún no generada.
- `409`: pedido cancelado, o intento de imprimir una comanda ya impresa sin usar reimpresión.
- `503`: impresora no disponible o sin conexión.
