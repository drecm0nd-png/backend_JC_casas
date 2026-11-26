# AGENTS.md

Backend Django + DRF monolítico modular. **Estado actual: esqueleto.** Las apps existen pero `models.py`/`views.py` siguen con plantillas vacías, no hay `services.py`, `serializers.py`, `urls.py` por app ni frontend en este repo. No asumas que una regla "de destino" ya está implementada.

## Comandos (PowerShell, Windows)

- Activar venv: `.\.venv\Scripts\Activate.ps1`
- Chequeo: `python manage.py check`
- Tests: `python manage.py test` (un test puntual: `python manage.py test app.tests.Clase.metodo`)
- Migraciones: `python manage.py makemigrations` luego `python manage.py migrate`
- Servidor: `python manage.py runserver`
- No hay `db.sqlite3` todavía; se crea con `migrate`.

## Discrepancias con el plan (verificadas)

- `config/settings.py` usa **SQLite** (`db.sqlite3`), no PostgreSQL, aunque `psycopg` está en `requirements.txt`. Cambiar solo si se pide.
- `SECRET_KEY` está hardcodeada y `DEBUG = True`. Al tocar settings, mover a variables de entorno.
- No hay JWT configurado aún: `rest_framework_simplejwt` y `drf-spectacular` están instalados pero ausentes de `INSTALLED_APPS` y de `config/urls.py` (que solo expone `admin/`).
- `bcrypt` **no** está en `requirements.txt`; no lo uses sin agregarlo.
- El frontend React no está en este repositorio.

## Arquitectura (convenciones del proyecto)

- Apps: `usuarios`, `autenticacion`, `menu`, `pedido`, `impresora`. `config/` es el proyecto Django.
- Lógica de negocio en `services.py` de cada app, **nunca** en las vistas.
- Ningún módulo importa modelos de otro módulo directamente; usa la API/servicios del módulo.
- Autenticación JWT propia en `autenticacion`; contraseñas con bcrypt (cuando se implemente).

## Seguridad (obligatorio)

- Sin secretos en código: variables de entorno (`.env` está en `.gitignore`).
- Toda ruta que modifique datos exige autenticación.
- Validar todas las entradas antes de usarlas.
- Nunca devolver contraseñas ni hashes en respuestas.

## Reglas de negocio

- Reglas detalladas (roles, estados, total, pago, comanda): ver `docs/reglas-negocio.md`; leerlo antes de implementar pedidos.
- El total del pedido se calcula en el servidor; nunca confiar en el precio enviado por el frontend.
- Un pedido en estado "entregado" no puede cancelarse.

## Convenciones de trabajo

- Commits tipo Conventional Commits en español (`feat:`, `chore:`, `fix:`), p. ej. `chore(esqueleto): ...`.
- Ramas actuales: `main`, `develop`, `chore/configuracion_inicial`.

## Idioma

- Responde siempre en español, salvo que se pida otro idioma.
- Escribe los comentarios del código y los mensajes de commit en español.
- Los nombres de variables, funciones y archivos van en inglés o en español sin tildes, según las convenciones del proyecto.
