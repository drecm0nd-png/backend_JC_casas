# Reglas de negocio - JCasas

Estado: reglas confirmadas por el usuario el 2026-11-26. Los puntos sin cerrar se marcan como **Pendiente de definir** y bloquean la implementación de `pedido`/`impresora`.

## Roles y cuentas

- Roles del sistema: `cliente` y `administrador`. Cocina NO es un rol de sistema: solo interactúa con la comanda física.
- Un usuario puede tener ambos roles. Si tiene `administrador`, se desbloquean más endpoints; puede seguir actuando como cliente.
- Los administradores los crea otro administrador. **Pendiente de definir:** cómo se crea el primer administrador.
- El administrador puede desactivar clientes. **Pendiente de definir:** qué pasa con pedidos `pendiente`/`preparacion` de ese cliente.
- El cliente confirma el pedido; el administrador gestiona estados, rechazos, reaperturas, comandas e impresión.
- Toda ruta que modifica datos exige autenticación. Nunca se devuelven contraseñas ni hashes.

## Estados del pedido

- Estados: `pendiente`, `preparacion`, `listo`, `entregado`, `cancelado`.
- Flujo normal: `pendiente` --confirmar(cliente)--> `preparacion` --admin--> `listo` --admin--> `entregado`.
- `cancelado` es terminal, salvo reapertura decidida por el administrador.
- El cliente puede cancelar hasta antes de `entregado`, incluso en `preparacion` o `listo`. `entregado` no se cancela. Esta regla sustituye la idea anterior de que un pedido confirmado no era cancelable.
- El pedido confirmado sí se puede modificar. **Pendiente de definir:** qué campos se pueden modificar y hasta qué estado.
- El administrador puede avanzar estados, rechazar un pedido `pendiente` y reabrir pedidos. **Pendiente de definir:** si rechazar equivale a `cancelado`, desde qué estados se reabre y a cuál estado vuelve (`pendiente`/`preparacion`), y si se puede reabrir `entregado`.
- Se guarda historial de estados con fecha y usuario; el cliente no lo ve. **Pendiente de definir:** si el historial se elimina del detalle de cliente en `docs/api.md`.
- El motivo de cancelación es opcional y lo ve el administrador en el panel con el estado del pedido.

## Pago

- Métodos permitidos: Nequi, Daviplata, Efectivo. No se acepta tarjeta de crédito.
- El pago se hace directamente entre repartidor y cliente; confirmar el pedido no exige pago previo.
- No se manejan reembolsos ni notas de crédito.
- **Pendiente de definir:** si se conserva alguna bandera/estado `pagado` o solo se registra `metodo_pago`.

## Estructura del almuerzo y adicionales

- Cada almuerzo se arma con una opción por parte: `principio`, `proteina`, `acompanamiento`.
- El cliente puede quitar un ingrediente solo si lo cambia por otro; las notas se usan para solicitudes como doble porción.
- Los adicionales son opcionales y se registran al final del pedido con cantidad individual.
- Ejemplo: 3 almuerzos = 42.000; gaseosa 1 L = 3.000; total = 45.000.
- Tope: máximo 3 unidades del mismo adicional. **Pendiente de definir:** si el tope es por pedido o por almuerzo.
- **Pendiente de definir:** si los adicionales se asocian al pedido completo o a cada almuerzo; y si las tres partes del almuerzo son obligatorias o puede haber más de una opción por parte.

## Horario y entrega

- Solo se puede pedir para el día actual.
- Horario de atención: 12:00 a 17:00. **Pendiente de definir:** zona horaria (¿Colombia, -05:00?), si el límite aplica al crear/confirmar/imprimir y qué pasa con pedidos `pendiente` a las 17:00.
- Toda entrega es a domicilio; se usa el nombre del cliente, no número de mesa.
- Nombre y teléfono se toman del perfil; dirección se toma del pedido. Se congelan en el pedido aunque el perfil cambie después.
- **Pendiente de definir:** si el servidor ignora/sobrescribe `nombre_cliente` y `telefono` enviados en `POST /pedidos/`.

## Cálculo del total

- Dinero: entero en COP, sin IVA y sin redondeo.
- `precio_fijo` es por unidad de almuerzo y se suma al final del pedido, más los adicionales.
- El precio mostrado al cliente ya incluye el envío: 12.000 base + 2.500 envío = 14.500. El administrador modifica esa configuración en su panel.
- **Pendiente de definir:** si el envío se cobra por almuerzo o una sola vez por pedido.
- Fórmula vigente: `total = (precio_almuerzo_con_envio * cantidad_de_almuerzos) + suma(adicionales)`.
- El total queda congelado con los precios del momento de crear el pedido; un pedido `pendiente` conserva esos precios si cambia la configuración.
- Si se modifica un pedido, el recálculo usa los precios congelados.
- El total se calcula siempre en el servidor; nunca se confía en el precio enviado por el frontend.

## Comanda / impresora

- Existe comanda digital en el sistema y comanda física.
- La impresión siempre la dispara manualmente el administrador. Solo el administrador puede reimprimir.
- Si la impresora falla, los pedidos se atienden por orden de llegada hasta que se pueda seguir. **Pendiente de definir:** reintento automático o reimpresión manual.
- Se imprime una sola comanda para cocina; al cliente le llega esa misma y el registro queda en el sistema.
- La comanda incluye: fecha/hora, id del pedido, nombre del cliente, teléfono, dirección, total, método de pago, notas del pedido y el detalle de cada almuerzo con sus ingredientes y adicionales.
- No se imprime comanda de cancelación cuando el pedido ya está impreso.
- **Pendiente de definir:** si se incluyen cantidades y subtotales por almuerzo.

## Bloqueos antes de implementar

- Confirmar la matriz de cancelación/modificación por estado y rol.
- Definir rechazo, reapertura e historial visible.
- Definir pago: solo `metodo_pago` o también bandera `pagado`.
- Definir envío: por almuerzo o por pedido.
- Definir adicionales: ámbito, tope y estructura de partes del almuerzo.
- Definir horario, datos del pedido y reintento de impresora.
