# Referencia de configuración

`contenido/config.json` es el único archivo que define tu serie. La skill lo escribe en el onboarding, pero puedes editarlo a mano.

## Ejemplo completo

```json
{
  "creator": {
    "name": "María Pérez",
    "headline": "Abogada especializada en derecho laboral",
    "audience": "profesionales de RR. HH. y reclutadores",
    "tone": "profesional y cercano"
  },
  "series": {
    "title": "30 días de legal tech",
    "totalDays": 30,
    "language": "es"
  },
  "content": {
    "minChars": 900,
    "maxChars": 1800,
    "emojisMin": 5,
    "emojisMax": 8,
    "resourcesMin": 2,
    "resourcesMax": 3,
    "resourcesLanguage": "es"
  },
  "hashtags": {
    "base": ["#LegalTech", "#Derecho", "#Abogacía"]
  },
  "publish": {
    "mode": "manual",
    "offsetHours": 3
  },
  "linkedin": {
    "authorUrn": "urn:li:person:TU_ID",
    "account": "default"
  },
  "schedule": {
    "generateAt": "09:00"
  }
}
```

## Campos

| Campo | Tipo | Descripción |
|---|---|---|
| `creator.name` | string | Nombre del autor |
| `creator.headline` | string | Titular profesional |
| `creator.audience` | string | A quién le habla |
| `creator.tone` | string | Tono de escritura |
| `series.title` | string | Título de la serie |
| `series.totalDays` | number | Días de la serie (por defecto 30) |
| `series.language` | string | `es`, `en`, etc. |
| `content.minChars` | number | Mínimo de caracteres |
| `content.maxChars` | number | Máximo de caracteres (≤ 3000) |
| `content.emojisMin` | number | Emojis mínimos |
| `content.emojisMax` | number | Emojis máximos |
| `content.resourcesMin` | number | Enlaces mínimos |
| `content.resourcesMax` | number | Enlaces máximos |
| `content.resourcesLanguage` | string | Idioma de los videos |
| `hashtags.base` | array | Hashtags obligatorios |
| `publish.mode` | string | `manual` o `auto` |
| `publish.offsetHours` | number | Horas entre generar y publicar |
| `linkedin.authorUrn` | string | URN del autor |
| `linkedin.account` | string | Alias de Composio |
| `schedule.generateAt` | string | Hora diaria (`HH:mm`) |

## Cómo obtener tu `authorUrn`

1. Conecta LinkedIn en Composio.
2. Pide en el chat: *"Obtén mi URN de LinkedIn"*.
3. Copia el valor `urn:li:person:...` en `linkedin.authorUrn`.

## Modos de publicación

| Modo | Comportamiento |
|---|---|
| `manual` | Solo genera el `.md`. Tú copias y pegas en LinkedIn. |
| `auto` | Genera y programa la publicación +3 h con Composio. |
