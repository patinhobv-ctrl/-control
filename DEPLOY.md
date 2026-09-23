# Deploy a Internet — StockControl

## Opción 1: Prueba inmediata (1 minuto, sin cuenta)
En tu PC donde corre `php artisan serve`:

```powershell
npx --yes localtunnel --port 8000
```
Te da URL tipo `https://rotten-horses-end.loca.lt`
- Todas las sucursales entran a `https://TU-URL.loca.lt/dashboard.html`
- Login: `admin@empresa.com` / `password`
- El dashboard ya usa `location.origin` así que funciona automático.
- **Temporal:** cambia cada vez que reiniciás el túnel.

---

## Opción 2: Producción permanente en Render (gratis) — Recomendado

### A. Preparar GitHub
1. Crear repo en https://github.com/new (ej: `stockcontrol`)
2. En tu PC:
```powershell
winget install --id Git.Git --accept-source-agreements --accept-package-agreements
# reiniciar PowerShell
cd "C:\Users\User\OneDrive\Documentos\Default Project\stock-control"
git init
git add .
git commit -m "StockControl v1"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/stockcontrol.git
git push -u origin main
```
*Si no querés CLI, subí los archivos vía web en GitHub: Add file → Upload files*

### B. Deploy en Render
1. Ir a https://dashboard.render.com → New + → Blueprint
2. Conectar tu repo `stockcontrol`
3. Render detecta `render.yaml` y crea:
   - **Web Service** `stockcontrol` (Docker, plan Free)
   - **PostgreSQL** `stockcontrol-db` (Free)
4. Env vars ya están en `render.yaml`. Render genera `APP_KEY` automático.
5. Deploy tarda 4-6 min. Al terminar te da URL fija:
   `https://stockcontrol-xxxx.onrender.com`
6. Entrar a `https://TU-URL.onrender.com/dashboard.html`

### C. Primera carga de datos
Por defecto la BD queda vacía (sin seed). Para cargar datos de prueba una vez:
- En Render → tu servicio → Environment → agregar `SEED_DB=true` → Save → redeploy
- Luego quitar `SEED_DB` para no re-seedear.

O vía shell de Render:
```
php artisan db:seed --force
```

### D. Variables importantes en Render
- `APP_URL` se setea automático a tu host
- `DATABASE_URL` viene de la BD
- Para cambiar moneda/empresa, usá el menú Configuración en el dashboard (se guarda en navegador)

---

## Notas
- Health check: `/up` (ya configurado en `bootstrap/app.php`)
- Puerto: Render inyecta `$PORT` (10000), el Dockerfile lo usa
- Logs: `php artisan` escribe a `storage/logs/laravel.log` y a stdout (visible en Render → Logs)
- Si ves `APP_KEY` error, el `start.sh` lo genera automático
