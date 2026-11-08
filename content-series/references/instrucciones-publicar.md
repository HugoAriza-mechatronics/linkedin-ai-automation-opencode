# Instrucciones — publicación en LinkedIn

Esta tarea se ejecuta después de generar un post, o cuando el usuario lo pide explícitamente.

## 0. Regla de autorización

- Si es una publicación **ad-hoc** (no viene de la tarea programada), pregunta antes: **"¿Deseas publicar?"**.
- Si viene de la tarea programada y `publish.mode = "auto"`, el usuario ya aprobó el flujo en el onboarding.
- Si hay duda, no publiques.

## 1. Leer el pendiente

Lee `contenido/pendiente.json`. Contiene:

- `dia`: número de día.
- `archivo`: ruta absoluta del `.md`.
- `publicar_en`: fecha/hora prevista.

Si no existe y el usuario pidió publicar un día concreto, busca `contenido/posts/dia-NN-*.md`.

## 2. Verificar estado

En el `.md`, revisa **Estado**:

- `publicado` → detente, no publiques, limpia el pendiente.
- `programado` → continúa.

## 3. Extraer el texto

Toma exactamente el contenido entre `## Texto` y `## Recursos`.
No incluyas encabezados, tabla de recursos ni notas.
Conserva emojis, saltos de línea y enlaces.

Verifica que tenga entre 1 y 3.000 caracteres. Si supera 3.000, recórtalo.

## 4. Publicar con Composio

Lee `contenido/config.json`:

- `linkedin.authorUrn` → autor.
- `linkedin.account` → alias de la cuenta (si existe).

Usa `COMPOSIO_MULTI_EXECUTE_TOOL` con `LINKEDIN_CREATE_LINKED_IN_POST`:

```json
{
  "author": "<authorUrn>",
  "commentary": "<texto extraído>",
  "visibility": "PUBLIC",
  "lifecycleState": "PUBLISHED"
}
```

- No agregues imágenes.
- No cambies el texto salvo el recorte por longitud.

## 5. Confirmar y registrar

Si la respuesta es exitosa:

1. Lee el identificador (`data.results[0].response.data.x_restli_id`, forma `urn:li:share:...`).
2. Edita el `.md`:
   - Estado → `publicado`.
   - URL → `https://www.linkedin.com/feed/update/<URN>/`.
   - Agrega en Notas: `- Publicado automáticamente el YYYY-MM-DD HH:mm.`
3. Elimina `contenido/pendiente.json`.

## 6. Si falla

- Reintenta **una sola vez**.
- Si vuelve a fallar: no publiques nada más, deja el `.md` como `programado`, registra el error y termina.
- Nunca intentes publicar dos veces el mismo día.
- Nunca borres posts ya publicados.

## Salida final

Resume en 4 líneas: día, resultado, URN o motivo del error, y si se limpió el pendiente.
