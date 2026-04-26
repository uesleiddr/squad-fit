# Squad Fit Logo Assets

## Novo Design (v2)

O logo do Squad Fit v2 consiste em:
- **LogoMark**: Dois chevrons duplos `<<` com gradiente laranja
- **Wordmark**: "SQUAD" branco + "FIT" com gradiente laranja

## Arquivos

### Logo Antigo (deprecado)
- `SquadFit-logo-transparent.png` - Logo antigo (só texto cinza)
- `../splash/splash_logo.png` - Splash antigo (texto azul)

### Novo LogoMark (Ícone - Chevrons)
- `squadfit-logomark.svg` - Ícone SVG dos chevrons (fundo transparente)
- `squadfit-icon-adaptive.svg` - Ícone SVG para adaptive icon Android

## Como atualizar o ícone do app

### Passo 1: Gerar PNG do novo ícone

Opção A - Figma/Editor:
1. Abra `squadfit-icon-adaptive.svg` no Figma
2. Adicione um retângulo de fundo `#0B0D12` (512x512)
3. Exporte como PNG 1024x1024 pixels
4. Salve como `squadfit-icon.png`

Opção B - Conversor online:
1. Acesse https://svgtopng.com/ ou https://cloudconvert.com/svg-to-png
2. Upload do `squadfit-icon-adaptive.svg`
3. Escolha tamanho 1024x1024
4. Baixe e salve como `squadfit-icon.png`

Opção C - Inkscape (linha de comando):
```bash
inkscape squadfit-icon-adaptive.svg --export-type=png --export-filename=squadfit-icon.png -w 1024 -h 1024
```

### Passo 2: Atualizar pubspec.yaml

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/logo/squadfit-icon.png"
  adaptive_icon_background: "#0B0D12"
  adaptive_icon_foreground: "assets/logo/squadfit-icon.png"

flutter_native_splash:
  color: "#0B0D12"
  image: assets/logo/squadfit-icon.png
  android_12:
    color: "#0B0D12"
    icon_background_color: "#0B0D12"
```

### Passo 3: Regenerar ícones

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

## Cores do Design System

| Cor | Hex | Uso |
|-----|-----|-----|
| Deep (Background) | `#0B0D12` | Fundo do ícone |
| Primary Light | `#FFAB6B` | Gradiente chevron (início) |
| Primary | `#FA8038` | Gradiente chevron (fim) |

## Uso no código Flutter

```dart
// Logo completo (wordmark com chevrons)
SFLogo(width: 220)

// Só os chevrons (ícone)
SFLogo.mark(size: 48)

// Em fundo laranja
SFLogo(width: 220, onOrange: true)
SFLogo.mark(size: 48, onOrange: true)
```
