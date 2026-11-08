# Personalización

## Cambiar el temario

Edita `contenido/temario.md`. El script busca la fila del día:

```markdown
| Día | Tema | Enfoque |
|-----|------|---------|
| 1 | Tu tema | Tu enfoque |
```

No cambies el formato de la tabla ni el número de la primera columna.

## Cambiar el tono

En `contenido/config.json`:

```json
"creator": {
  "tone": "directo y con humor"
}
```

Funciona mejor con 3–5 palabras concretas que con "profesional".

## Cambiar idioma

```json
"series": { "language": "en" }
```

Afecta el texto del post. Para los videos:

```json
"content": { "resourcesLanguage": "en" }
```

## Cambiar longitud y emojis

```json
"content": {
  "minChars": 900,
  "maxChars": 1800,
  "emojisMin": 5,
  "emojisMax": 8
}
```

LinkedIn permite hasta 3.000 caracteres; el límite absoluto del script es 3.000.

## Cambiar hashtags

```json
"hashtags": {
  "base": ["#TuTema", "#TuIndustria", "#TuNicho"]
}
```

El agente añade 2–4 específicos por día.

## Varias series a la vez

Crea una carpeta por serie:

```
proyectos/
├── serie-derecho/
│   └── contenido/
└── serie-datos/
    └── contenido/
```

Y ejecuta con `-ProjectRoot` apuntando a cada una.

## Cambiar la hora

```json
"schedule": { "generateAt": "07:30" }
```

Vuelve a registrar la tarea:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\automatizacion\setup-windows.ps1 -ProjectRoot . -Remove
powershell -NoProfile -ExecutionPolicy Bypass -File .\automatizacion\setup-windows.ps1 -ProjectRoot .
```

## Regenerar un día

Borra el `.md` de ese día y ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\automatizacion\run-dia.ps1 -ProjectRoot . -Dia 5
```

## Preguntas frecuentes

**¿Puedo usar otra red social?**
Hoy solo LinkedIn. El motor se puede adaptar, pero requiere otro publicador.

**¿Funciona sin Composio?**
Sí, en modo `manual`. Genera el texto y lo copias.

**¿Puedo publicar dos posts el mismo día?**
El script lo evita por fecha. Si lo necesitas, usa `-Dia` explícito y publica a mano.

**¿Dónde están mis posts?**
En `contenido/posts/`, un `.md` por día.
