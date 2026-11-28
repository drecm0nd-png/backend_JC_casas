# Arquitectura y Diagrama de Componentes: JC Casas Restaurante

## 1. Estilo Arquitectónico General
El sistema está diseñado bajo una arquitectura de **Backend Monolito Modular**. Todo el núcleo lógico de la aplicación reside en un único despliegue (monolito), pero está estrictamente dividido en módulos independientes y desacoplados que se comunican entre sí mediante **interfaces bien definidas** (contratos de entrada/salida). 

* **Capa de Entrada / Exposición:** Un componente central de **API REST** actúa como *Gateway* o fachada única, exponiendo los servicios del backend hacia el cliente (Frontend Web/Android).
* **Capa de Persistencia (Externa al dominio):** La comunicación con la base de datos (PostgreSQL) se abstrae mediante el componente **Django ORM**, al cual acceden directamente los módulos que requieren persistencia de estado.
* **Integración de Hardware (Externa):** La salida física hacia cocina/reparto se gestiona mediante una dependencia hacia el componente externo **Impresora_Termica**.

---

## 2. Desglose de Componentes Internos (Monolito Modular)

### 2.1. `API REST` (Punto de Entrada)
* **Rol:** Orquestador y punto de contacto HTTP para las peticiones externas.
* **Interfaces que consume (Dependencias):**
  * `IAutenticacion` (hacia `Autenticacion`)
  * `IUsuario` (hacia `Usuario`)
  * `IMenu` (hacia `Menu`)
  * `IPedido` (hacia `Pedido`)

### 2.2. `Autenticacion`
* **Rol:** Gestiona la seguridad, el acceso y las credenciales del sistema. Funciona como un artefacto de soporte utilizado principalmente por el módulo de usuarios y expuesto a la API.
* **Interfaces que provee:**
  * `IAutenticacion`: Validación de tokens/sesiones hacia la API REST.
  * `ILogin`: Lógica de inicio de sesión.
  * `IRegistro`: Lógica de creación de cuentas.
  * `IRecuperacionContraseña`: Flujo de restablecimiento de claves.

### 2.3. `Usuario`
* **Rol:** Administra los perfiles, roles (Cliente, Administrador) y datos personales (nombre, teléfono, dirección, correo).
* **Interfaces que provee:**
  * `IUsuario`: Operaciones CRUD y consulta de datos del perfil hacia la `API REST`.
* **Interfaces que consume:**
  * `ILogin`, `IRegistro`, `IRecuperacionContraseña` (provenientes de `Autenticacion`).
* **Dependencias:** Se conecta directamente con **Django ORM** para persistir la información de los usuarios.

### 2.4. `Menu`
* **Rol:** Gestiona el catálogo diario de ingredientes (Principio, Proteína, Acompañamiento, Adicionales) y el control básico de existencias.
* **Decisión de Diseño (Nota Arquitectónica):** El sistema lleva únicamente un conteo simple de disponibilidad diaria para saber qué ofrecer. Se evita crear un módulo separado de inventario, almacén, compras, proveedores o mermas para prevenir la sobreingeniería.
* **Interfaces que provee:**
  * `IMenu`: Consulta y administración del menú hacia la `API REST`.
  * `IConteoIngredientes`: Interfaz dedicada al control y descuento de disponibilidad de insumos.
* **Dependencias:** Se conecta con **Django ORM** para leer y actualizar el estado y stock de los ingredientes.

### 2.5. `Pedido`
* **Rol:** Núcleo transaccional del sistema. Valida la estructura del almuerzo, consolida la orden y gestiona sus estados (`Recibido`, `En preparación`, `Listo`, `Entregado`).
* **Interfaces que provee:**
  * `IPedido`: Recepción y consulta de órdenes desde la `API REST`.
* **Interfaces que consume:**
  * `IComanda` (proveniente de `Comanda`) para disparar la generación del ticket al confirmar un pedido.
* **Dependencias Internas (Nota Arquitectónica):** Depende directamente de los módulos **`Usuario`** (para vincular los datos de entrega del cliente) y **`Menu`** (para validar disponibilidad y descontar ingredientes) antes de poder guardar un pedido.
* **Dependencias Externas:** Se conecta con **Django ORM** para almacenar la transacción del pedido.

### 2.6. `Comanda`
* **Rol:** Transforma la información de un pedido confirmado en un documento estructurado listo para cocina y despacho.
* **Interfaces que provee:**
  * `IComanda`: Recibe la solicitud de generación desde el componente `Pedido`.
* **Interfaces que consume:**
  * `I_Impresion` (proveniente de `Impresion`) para delegar la salida física del ticket.
* **Dependencias:** Se conecta con **Django ORM** para registrar el historial de comandas generadas.

### 2.7. `Impresion`
* **Rol:** Actúa como servicio adaptador/mediador encargado de formatear la comanda y gestionar la comunicación técnica hacia el hardware de impresión.
* **Interfaces que provee:**
  * `I_Impresion`: Expone el servicio de impresión al componente `Comanda`.
* **Dependencias:** Se comunica de forma externa con el componente **`Impresora_Termica`**.

---

## 3. Componentes Externos al Monolito

1. **`Django ORM`:** Capa de mapeo objeto-relacional encargada de traducir las operaciones de los módulos `Usuario`, `Menu`, `Pedido` y `Comanda` hacia la base de datos relacional (PostgreSQL).
2. **`Impresora_Termica`:** Dispositivo de hardware externo encargado de emitir físicamente la comanda en papel térmico para el área de cocina y el repartidor.

---

## 4. Flujo de Interacción Típico (Creación de Pedido)
1. El cliente envía la solicitud a través de **`API REST`** usando las interfaces `IAutenticacion` e `IPedido`.
2. El componente **`Pedido`** consulta los datos del cliente en **`Usuario`** y verifica/descuenta el stock en **`Menu`**.
3. **`Pedido`** guarda la transacción mediante **`Django ORM`** e invoca la interfaz `IComanda`.
4. **`Comanda`** registra el documento en **`Django ORM`** e invoca la interfaz `I_Impresion`.
5. **`Impresion`** envía la orden final al hardware **`Impresora_Termica`**.