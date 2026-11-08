# Composio (publicación automática)

La publicación automática usa Composio como puente con LinkedIn. **Solo es necesaria si eliges `publish.mode: "auto"`.**

## 1. Crear cuenta

1. Entra a [composio.dev](https://composio.dev).
2. Crea una cuenta.
3. En el dashboard, busca **LinkedIn**.
4. Conecta tu cuenta y autoriza los permisos de publicación (`w_member_social`).

## 2. Agregar el MCP a OpenCode

```bash
opencode mcp add composio --global --url https://connect.composio.dev/mcp
```

Verifica:

```bash
opencode mcp list
```

Debe decir `composio connected`.

Si queda en `pending`, espera unos segundos. Si falla con DNS:

```bash
opencode reload
```

y vuelve a comprobar.

## 3. Autenticar

En OpenCode, abre `/mcps`, selecciona Composio y completa el login.

## 4. Obtener tu URN

Pide en el chat:

```text
Obtén mi URN de LinkedIn
```

El agente usará `LINKEDIN_GET_MY_INFO` y te dará algo como:

```
urn:li:person:TU_ID
```

Guárdalo en `contenido/config.json`:

```json
"linkedin": {
  "authorUrn": "urn:li:person:TU_ID",
  "account": "default"
}
```

`account` es el alias de la cuenta en Composio. Si solo tienes una, usa `default`.

## 5. Activar el modo automático

```json
"publish": {
  "mode": "auto",
  "offsetHours": 3
}
```

## Cómo funciona

```
09:00  run-dia.ps1     → genera el .md (no publica)
+3 h   publicar-dia.ps1 → publica vía LINKEDIN_CREATE_LINKED_IN_POST
```

La tarea de publicación se crea en el momento de generar y se elimina al ejecutarse.

## Buenas prácticas

- Prueba primero en modo `manual` para revisar el tono.
- No publiques varias veces el mismo día.
- Revisa `automatizacion/logs/` si algo falla.
- Si Composio falla, el `.md` queda como `programado`; puedes publicarlo luego.

## Limitaciones

- LinkedIn no permite programar posts de forma nativa; por eso se usa una tarea de Windows.
- Los límites y permisos de la API pueden cambiar.
- La cuenta de Composio y el consumo del modelo corren por tu cuenta.
