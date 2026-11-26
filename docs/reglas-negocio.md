# Reglas de negocio - JCasas

## Roles
- Roles del sistema: `cliente` y `administrador`.
- Cocina NO es un rol de sistema: solo interactúa con la comanda física.
- El cliente confirma el pedido; el administrador avanza los estados.

## Estados del pedido
- `pendiente`: pedido creado y no confirmado; el cliente puede cancelarlo.
- Al confirmar el cliente, el pedido pasa directo a `preparacion`.
- `preparacion` -> `listo` -> `entregado` (avanzados por el administrador).
- `cancelado`: estado terminal.
- El administrador puede cancelar en cualquier estado excepto `entregado`.
- Un pedido `entregado` no puede cancelarse.

## Cálculo del total
- El almuerzo tiene un precio fijo configurable en el servidor.
- Los adicionales se asocian a cada almuerzo; se cobran por cada almuerzo.
- total = suma por almuerzo de (precio_fijo + adicionales de ese almuerzo).
- Moneda: COP. Sin IVA. Sin redondeo.
- El total se calcula en el servidor; nunca se confía en el precio del frontend.

## Pago
- Métodos permitidos: Nequi, Daviplata, Efectivo.
- No se acepta tarjeta de crédito.

## Entrega
- Todo pedido es a domicilio; se usa el nombre del cliente, no número de mesa.

## Comanda / impresora
- Existe comanda digital en el sistema y comanda física.
- El administrador imprime la comanda física y la envía a cocina.
- La comanda incluye: fecha/hora, id del pedido, nombre del cliente, total,
  método de pago, notas del pedido, y el detalle de cada almuerzo con sus
  ingredientes y sus adicionales.

## Restricciones de datos
- Nunca se devuelven contraseñas ni hashes en respuestas.
- Toda ruta que modifique datos exige autenticación.
