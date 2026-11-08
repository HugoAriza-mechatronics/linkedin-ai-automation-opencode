# Instalación

## Requisitos

- [OpenCode](https://opencode.ai) instalado y funcionando.
- Un modelo configurado con crédito.
- Opcional: [Composio](https://composio.dev) + LinkedIn para publicación automática.
- Opcional: Windows para programar la tarea diaria.

## Método A — Catálogo HTTP (recomendado)

La skill se actualiza sola cuando el repo publica una nueva versión.

### 1. Pide a oc que la instale

Copia y pega:

```text
Instálame la skill content-series y el comando /serie.

1. Agrega a mi configuración global de OpenCode (opencode.json):
"skills": ["https://hugoariza-mechatronics.github.io/linkedin-ai-automation-opencode/"]

2. Agrega este comando:
"commands": {
  "serie": {
    "description": "Crea una serie de contenido para LinkedIn",
    "template": "Carga la skill content-series y ejecuta su onboarding completo."
  }
}

3. Muéstrame qué archivos modificaste.
```

### 2. Verifica

```bash
opencode mcp list
```

No es necesario para skills, pero confirma que el servicio está arriba. Luego escribe `/serie` en el chat.

> Si el comando no aparece, revisa que el archivo de configuración sea JSON válido y que la URL termine en `/`.

## Método B — Clonar el repo

```bash
git clone https://github.com/HugoAriza-mechatronics/linkedin-ai-automation-opencode
```

Copia la skill:

```powershell
# Global (todos los proyectos)
Copy-Item -Recurse .\content-series "$env:USERPROFILE\.config\opencode\skills\content-series"

# O solo para un proyecto
Copy-Item -Recurse .\content-series ".\.opencode\skills\content-series"
```

Copia el comando:

```powershell
# Ejecuta esto desde la carpeta de tu proyecto, con el repo clonado al lado
$repo = ".\linkedin-ai-automation-opencode"
New-Item -ItemType Directory -Force .\.opencode\commands | Out-Null
Copy-Item -Path "$repo\.opencode\commands\serie.md" -Destination .\.opencode\commands\serie.md
```

> Si trabajas directamente dentro de la carpeta clonada, el comando ya está en `.opencode/commands/serie.md` y no necesitas copiarlo.

Escribe `/serie`.

## Primer uso

El onboarding te preguntará:

1. Nombre y profesión
2. Tema de la serie y público
3. Idioma y tono
4. Cantidad de días
5. Idioma de los recursos
6. Modo de publicación (manual o automático)
7. Hora y zona horaria

Al terminar, crea:

```
contenido/
├── config.json
├── temario.md
└── posts/
automatizacion/
├── run-dia.ps1
├── publicar-dia.ps1
├── setup-windows.ps1
├── instrucciones-dia.md
├── instrucciones-publicar.md
└── logs/
```

## Probar sin publicar

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\automatizacion\run-dia.ps1 -ProjectRoot . -DryRun
```

## Programar la tarea diaria (Windows)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\automatizacion\setup-windows.ps1 -ProjectRoot .
```

Ver próxima ejecución:

```powershell
Get-ScheduledTaskInfo -TaskName "Content Series - Diario"
```

Eliminar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\automatizacion\setup-windows.ps1 -ProjectRoot . -Remove
```

## macOS / Linux

Los scripts son de PowerShell. Instala PowerShell 7 y usa `cron` o `systemd`:

```bash
# Ejemplo de cron: todos los días a las 09:00
0 9 * * * pwsh -NoProfile -File /ruta/al/proyecto/automatizacion/run-dia.ps1 -ProjectRoot /ruta/al/proyecto
```

## Problemas comunes

| Problema | Solución |
|---|---|
| `/serie` no aparece | Verifica el JSON; la URL debe terminar en `/` |
| No encuentra `opencode` | Agrega el CLI al PATH o usa la ruta del escritorio |
| No genera | Revisa `automatizacion/logs/` |
| No publica | Revisa Composio (`opencode mcp list`) y el log |
| La tarea no corre | La PC debe estar encendida y con sesión iniciada |
