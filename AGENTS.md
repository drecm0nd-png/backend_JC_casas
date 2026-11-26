# AGENTS.md

Backend Django + DRF, monolito modular. **Estado real: esqueleto**: las 5 apps (`usuarios`, `autenticacion`, `menu`, `pedido`, `impresora`) tienen `models.py`/`views.py`/`tests.py` de plantilla; no hay `services.py`, `serializers.py`, `urls.py` por app, ni JWT configurado, ni frontend en este repo. No asumas que lo documentado ya existe.

## Punto de retorno (retomar en otro dispositivo)

- Fase actual: **cierre de reglas de negocio**, todavía sin código de negocio. Resolver primero los `Pendiente de definir` de `docs/reglas-negocio.md`.
- Orden de implementación acordado: `menu` → `pedido` → `impresora`. `pedido` debe consumir solo servicios de `menu`, no sus modelos.
- Leer en este orden: `docs/reglas-negocio.md` (reglas confirmadas por el usuario; mandan sobre los otros documentos), `docs/contexto_del_proyecto_jc_casas_restaurante.md`, `docs/arquitectura_y_diagrama_de_componentes.md`, `docs/jc_casas_bd.sql` (borrador MySQL, solo referencia) y `docs/api.md` (contrato a reconciliar).
- Los diagramas binarios antiguos (`docs/diagramas/*.png`/`.pdf`) fueron sustituidos en el working tree por los `.md`/`.sql` anteriores.
- Conflictos vigentes: el documento de contexto dice horario `7:00–16:30`, envío `1.500` y comanda automática; las reglas confirmadas dicen `12:00–17:00`, envío `2.500` y comanda manual. Preferir `docs/reglas-negocio.md` hasta nuevo aviso.
- La arquitectura propuesta separa `Comanda` e `Impresion`, pero en código solo existe la app `impresora`. No asumas que `comanda` está implementada.
- `docs/jc_casas_bd.sql` es MySQL Workbench (`borrador_bd`), no una migración Django ni compatible directamente con el SQLite actual.

## Setup y verificación (PowerShell/Windows)

- No hay `.venv` ni `db.sqlite3` versionados: `python -m venv .venv`; `.\.venv\Scripts\Activate.ps1`; `pip install -r requirements.txt`; `python manage.py migrate`.
- Chequeo: `python manage.py check`; tests: `python manage.py test`; test puntual: `python manage.py test app.tests.Clase.metodo`.
- `requirements.txt` fija Django 5.2.19; sin venv, el `python` global de esta máquina tiene otra versión (6.1). Usa el venv.

## Trampas del estado actual

- `config/settings.py` usa SQLite (`db.sqlite3`) aunque `psycopg` esté en requirements; `SECRET_KEY` está hardcodeada y `DEBUG=True`.
- `.env` está en `.gitignore`, pero no hay loader de `.env`: las variables no se cargan solas.
- `djangorestframework_simplejwt` y `drf-spectacular` están instalados pero no en `INSTALLED_APPS`; `config/urls.py` solo expone `admin/`. `bcrypt` no está en requirements.

## Convenciones del proyecto

- Lógica de negocio en `services.py` de cada app, nunca en vistas; no importes modelos de otra app directamente: usa sus servicios/API.
- Auth planificada: JWT propia en `autenticacion`, contraseñas con bcrypt (agregar dependencia antes de usarla); `usuarios` no emite tokens.
- Contrato de API en `docs/api.md` (`/api/v1`, Bearer JWT, errores `{error:{code,message,details}}`); reglas vigentes en `docs/reglas-negocio.md` (leer antes de tocar `pedido`). Ese contrato aún no está reconciliado con las reglas nuevas: historial oculto al cliente y nombre/teléfono del pedido tomados del perfil. Total calculado en servidor; `entregado` no se cancela.
- Seguridad: sin secretos en código, toda ruta que modifica datos exige autenticación, valida entradas y nunca devuelvas contraseñas/hashes.
- Commits Conventional en español (`feat:`, `chore:`, `fix:`, `docs:`). Responde en español; comentarios y commits en español; identificadores en inglés o español sin tildes.
