# Contexto del Proyecto: Sistema de Información JC Casas Restaurante

## 1. Descripción General del Proyecto
* **Nombre del Sistema:** Sistema de Información para la Gestión de Pedidos del Negocio de Comidas JC Casas Restaurante.
* **Cliente / Negocio:** Restaurante JC Casas (propietario: Julio), ubicado en el barrio Prado Vegas, Soacha, Cundinamarca.
* **Especialidad:** Venta de almuerzos tipo "corrientazo" (y desayunos) con servicio en local y a domicilio.
* **Propósito:** Desarrollar una aplicación web *responsive* (y compatible con Android) a la medida para sistematizar la toma de pedidos, digitalizar el menú diario, automatizar el descuento básico de insumos y generar comandas electrónicas/impresas, reemplazando el proceso manual actual (llamadas, WhatsApp y libreta física).
* **Equipo de Desarrollo:** Grupo 3229879 - Programa Análisis y Desarrollo de Software (SENA - Centro Industrial y de Desarrollo Empresarial de Soacha).

---

## 2. Contexto Operativo y del Negocio
* **Cobertura Geográfica:** Local (Barrio Prado Vegas, conjuntos residenciales aledaños, Ciudad Verde y una parte de Hogares Soacha).
* **Horario de Atención:** Lunes a domingo, de **7:00 a.m. a 4:30 p.m.** (Hora pico de pedidos: 12:00 p.m. a 2:00 p.m.). El sistema solo permite realizar pedidos dentro del horario operativo.
* **Volumen y Tiempos:**
  * Capacidad estimada: ~100 almuerzos diarios.
  * Tiempo objetivo de entrega: Mantener o mejorar el rango actual de **20 a 25 minutos** (reduciendo el tiempo actual de gestión/toma de pedidos que ronda los 35 minutos).
* **Precios Estandarizados (Configurables por el administrador):**
  * Almuerzo en local: **$13.000 COP**.
  * Almuerzo a domicilio: **$14.500 COP** (incluye tarifa fija de domicilio de **$1.500 COP**).
* **Métodos de Pago:** Efectivo, Nequi y Daviplata (se proyecta que el 80%-85% sea pago electrónico, registrado manualmente en el sistema sin pasarela integrada).
* **Identidad Visual:** El negocio utiliza colores amaderados (a tener en cuenta para la paleta global del sistema).

---

## 3. Actores y Roles del Sistema
1. **Cliente:** Consulta el menú del día, se registra/autentica, arma su pedido de almuerzo y lo confirma.
2. **Administrador (Propietario/Encargado):** Gestiona el menú diario (disponibilidad de ingredientes), administra precios, visualiza pedidos en tiempo real, actualiza estados, consulta historial de ventas y opera el dispositivo móvil que actúa como **agente de impresión**.
3. **Sistema (Actor Interno):** Valida la estructura del almuerzo, descuenta automáticamente el inventario de ingredientes, genera la comanda digital y envía la orden de impresión.
4. **Cocina y Repartidor (Actores Físicos/Logísticos):** No interactúan directamente con la interfaz del software; operan a partir de la **comanda física impresa**.

---

## 4. Reglas de Negocio Críticas (Lógica Core)
* **Estructura Obligatoria del Almuerzo (RN7, RF2):** Todo pedido de almuerzo debe contener obligatoriamente:
  1. Un (1) **Principio**
  2. Una (1) **Proteína**
  3. Un (1) **Acompañamiento**
* **Regla de Adicionales (RN8):** Solo se permite agregar ingredientes adicionales (o partes extra del almuerzo) *después* de haber completado la estructura base obligatoria de un almuerzo completo (no se venden partes sueltas por separado).
* **Dinámica del Menú e Inventario (RN1, RN3, RN13-RN15):**
  * El menú cambia diariamente (o de forma abrupta durante el día si se agota o daña algún alimento).
  * Cada pedido confirmado descuenta automáticamente la cantidad disponible de los ingredientes seleccionados.
  * Si un ingrediente llega a 0 (insuficiente), se bloquea/oculta automáticamente del menú.
* **Flujo de Estados del Pedido (RN18, RN19):** Los pedidos se atienden estrictamente por orden de llegada y pasan por 4 estados:
  1. `Recibido`
  2. `En preparación`
  3. `Listo`
  4. `Entregado`
* **Datos Mínimos del Cliente (RN12):** Nombre completo, teléfono de contacto, dirección de entrega y correo electrónico (identificador único para login/recuperación).
* **Comanda Física (RN10, RN16, RN17):** Cada pedido confirmado genera una única comanda con el detalle del almuerzo y datos del cliente, la cual se envía a imprimir automáticamente.

---

## 5. Requerimientos Funcionales (RF) y Casos de Uso (CU)
* **Gestión de Usuarios (CU11-CU15 / RF5, RF12-RF14):** Registro de clientes, inicio de sesión (persistente para agilizar futuros pedidos), cierre de sesión y recuperación de contraseña mediante enlace al correo.
* **Gestión de Menú (CU3, CU8 / RF3, RF4):** Visualización del menú categorizado (Principio, Proteína, Acompañamiento, Adicionales) para el cliente; CRUD de ingredientes y control de stock diario para el administrador.
* **Gestión de Pedidos (CU1, CU2, CU9, CU10 / RF1, RF2, RF8, RF9, RF10):** Creación y validación de pedidos, selección de método de pago (Efectivo, Nequi, Daviplata), seguimiento de estados y consulta de historial de pedidos/ventas.
* **Comandas e Impresión (CU4-CU7 / RF6, RF7, RF11):** Generación automática de comanda, descuento de stock en tiempo real, impresión en impresora térmica y opción de reimpresión manual en caso de fallo.

---

## 6. Arquitectura, Stack Tecnológico y Diseño (RNF)
* **Base de Datos:** PostgreSQL (antepenúltima versión).
* **Comunicación:** API REST bajo protocolo HTTPS estándar (códigos 200, 201, 400, 401, 404, 500).
* **Entorno / Plataformas:** Aplicación Web *Responsive* (PC, Tablet, Móvil) y despliegue compatible con sistema operativo Android.
* **Hardware e Integración:** El dispositivo móvil del administrador/encargado actúa como **agente mediador** (vía Bluetooth o Wi-Fi) para enviar las comandas desde el backend hacia una **impresora térmica**.
* **UI/UX:** Debe seguir estrictamente las guías de diseño de **Google Material Design 3 (M3)**, con una interfaz altamente intuitiva (pensada para usuarios con baja familiaridad digital) y tonos amaderados acordes al local.
* **Rendimiento y Confiabilidad:**
  * Tiempo de respuesta máximo: **< 3 segundos**.
  * Concurrencia: Soportar entre **50 y 100 usuarios simultáneos** en su primera versión.
  * Tolerancia a fallos: Garantizar que los pedidos confirmados no se pierdan ante intermitencias de red.
* **Ayuda en el Sistema:** Debe incluir sección de ayuda con manuales en PDF didácticos (administrativo, regulación, seguridad) y navegación guiada (tooltips/recuadros) para nuevos usuarios.

---

## 7. Exclusiones del Alcance (MVP / Fase 1)
Para mantener el enfoque del proyecto, **NO** se debe implementar en esta versión:
* Pasarelas de pago electrónico integradas (solo se registra el medio elegido).
* Geolocalización en tiempo real ni cálculo/optimización de rutas para repartidores.
* Integración con plataformas externas (Rappi, Didi Food, etc.).
* Inteligencia artificial, recomendaciones automáticas o análisis predictivo avanzado de inventario.