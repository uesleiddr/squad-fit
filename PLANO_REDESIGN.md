# Plano de Implementação - Squad Fit Redesign

## ⚠️ PRINCÍPIOS DE SEGURANÇA

### NÃO QUEBRAR FUNCIONALIDADES
1. **Separar visual de lógica** - Apenas refatorar UI, NUNCA mexer em services/providers
2. **Mudanças incrementais** - Uma tela por vez, testar antes de avançar
3. **Manter estrutura de dados** - Não alterar models, apenas como são exibidos
4. **Preservar navegação** - Drawer funciona, não mudar para bottom nav ainda
5. **Testar após cada mudança** - Rodar o app e verificar se funciona

### FOCO NO QUE JÁ EXISTE
O Claude Design criou features que **NÃO EXISTEM** no app. Algumas serão implementadas, outras não:

#### ✅ IMPLEMENTAR (features novas úteis):
- ✅ **Tela de Squads** → É a tela de Desafio/Competition melhorada
- ✅ **Streak/sequência de dias** → Tracking de dias consecutivos com registro
- ✅ **Badges/Conquistas** → Sistema de gamificação

#### ❌ NÃO IMPLEMENTAR (fora do escopo):
- ❌ Tela de Treino Ativo (não tem treinos)
- ❌ Sistema de XP/Níveis (complexo demais por agora)
- ❌ Water tracker
- ❌ Próximo treino agendado
- ❌ Passos

---

## O QUE REALMENTE EXISTE NO APP

### Telas Atuais (10 telas):
| Tela | Arquivo | Funcionalidade |
|------|---------|----------------|
| Login | `auth/screens/login_screen.dart` | Email/senha, Google, cadastro |
| Auth Wrapper | `auth/screens/auth_wrapper.dart` | Fluxo de autenticação |
| Profile Setup | `profile/screens/profile_setup_screen.dart` | Dados iniciais do usuário |
| Home | `home/screens/home_screen.dart` | Stats + ranking da competição |
| Weight | `weight/screens/weight_screen.dart` | Registro + histórico de peso |
| Add Weight | `weight/screens/add_weight_screen.dart` | Modal adicionar peso |
| Weight History | `weight/screens/weight_history_screen.dart` | Lista de pesagens |
| Nutrition (Diário) | `nutrition/screens/nutrition_screen.dart` | Diário alimentar |
| Competition | `competition/screens/competition_screen.dart` | Desafios + ranking |

### Navegação Atual:
- **Drawer** (menu lateral) com: Início, Peso, Desafio, Diário, Sair
- Deep links para convites de desafio

### Services (NÃO MEXER):
- AuthService, UserService, WeightService, CompetitionService
- NutritionService, GeminiNutritionService, FatSecretService

---

## Resumo do Redesign (FILTRADO)

Usar do Claude Design **APENAS** o que se aplica às telas existentes:
- ✅ **Design System**: Cores, tipografia, espaçamentos, sombras
- ✅ **Componentes**: Botões, inputs, cards, chips, avatars
- ✅ **Login Screen**: Novo visual
- ✅ **Home Screen**: Novo visual (adaptar para dados reais)
- ✅ **Diário/Nutrition**: Novo visual (já existe)
- ✅ **Competition/Ranking**: Usar visual do Ranking Screen
- ✅ **Modais existentes**: Melhorar visual dos modais atuais
- ✅ **Empty States**: Para quando não tem dados
- ✅ **Loading States**: Skeletons
- ✅ **Toasts**: Feedback visual

---

## Fase 1: Design System Base (Fundação)

### 1.1 Cores (`lib/core/theme/app_colors.dart`)
```
Cores principais:
- Orange (Primary): #FA8038, Light: #FFAB6B, Dark: #E06820
- Blue (Secondary): #256AD2, Light: #5A8FE0, Dark: #1A4FA0

Cores premium ("Squad Electric"):
- Lime (Victory/PR): #D6FF3B
- Magenta (Social): #FF3B8B
- Deep (Background): #0B0D12

Semânticas:
- Success: #22C55E
- Error: #EF4444
- Warning: #F59E0B
- Info: #256AD2

Surfaces (dark mode):
- Background: #0B0D12
- Surface: #1A1C22
- Surface2: #22252D
- Surface3: #2D3039
- Border: #2A2D35

Texto:
- fg: #FFFFFF
- fg1: #F5F6F8
- fg2: #9CA3AF
- fg3: #6B7280
- fg4: #4B5563

Feature colors:
- Breakfast: #F59E0B
- Lunch: #22C55E
- Dinner: #6366F1
- Snack: #EC4899
- Protein: #EF4444
- Carbs: #3B82F6
- Fat: #F59E0B
```

### 1.2 Gradientes (`lib/core/theme/app_gradients.dart`)
```
- gradPrimary: 135deg #FA8038 → #E06820
- gradHype: 135deg #FF3B8B → #FA8038 → #D6FF3B
- gradSquad: 135deg #256AD2 → #1A4FA0
- gradVictory: 135deg #D6FF3B → #22C55E
```

### 1.3 Tipografia (`lib/core/theme/app_typography.dart`)
```
Fontes:
- Display: Space Grotesk (bold, black)
- Body: Inter (regular, medium, semibold, bold)
- Mono: JetBrains Mono (para números)

Tamanhos:
- xs: 12, sm: 14, md: 16, lg: 18, xl: 20
- 2xl: 24, 3xl: 30, 4xl: 36, 5xl: 48, 6xl: 60, 7xl: 84
```

### 1.4 Espaçamentos (`lib/core/theme/app_spacing.dart`)
```
Escala 4px:
- space1: 4, space2: 8, space3: 12, space4: 16
- space5: 20, space6: 24, space8: 32, space10: 40
- space12: 48, space16: 64
```

### 1.5 Border Radius (`lib/core/theme/app_radius.dart`)
```
- xs: 4, sm: 8, md: 12, lg: 16, xl: 20
- 2xl: 24, 3xl: 32, full: 9999
```

### 1.6 Sombras (`lib/core/theme/app_shadows.dart`)
```
- shadowSm, shadowMd, shadowLg, shadowXl
- glowOrange, glowLime, glowBlue, glowMagenta
- insetHighlight (1px branco 6% no topo)
```

---

## Fase 2: Componentes Base

### 2.1 Botões (`lib/core/widgets/sf_button.dart`)
```
Variantes: primary, secondary, outline, ghost, destructive, victory, dark
Tamanhos: sm (36h), md (48h), lg (56h)
Features:
- Gradiente no primary
- Glow effect
- Scale animation no press (0.96)
- Loading state
```

### 2.2 Input (`lib/core/widgets/sf_input.dart`)
```
- Ícone leading
- Trailing widget
- Focus ring com cor laranja
- Error state
- Label opcional
```

### 2.3 Avatar (`lib/core/widgets/sf_avatar.dart`)
```
- Iniciais
- Gradiente customizável
- Ring effect (border glow)
- Badge opcional
```

### 2.4 Chip (`lib/core/widgets/sf_chip.dart`)
```
- Ícone opcional
- Cores customizáveis
- Background, border, glow
```

### 2.5 Progress Ring (`lib/core/widgets/sf_progress_ring.dart`)
```
- SVG circular
- Gradiente
- Animação suave
- Label central
```

### 2.6 Stat Pill (`lib/core/widgets/sf_stat_pill.dart`)
```
- Card pequeno com ícone
- Valor grande + unidade
- Cor de destaque
```

### 2.7 Section Header (`lib/core/widgets/sf_section_header.dart`)
```
- Título bold
- Action link opcional
```

### 2.8 Ranking Row (`lib/core/widgets/sf_ranking_row.dart`)
```
- Posição com medalha (1-3)
- Avatar
- Nome + subtítulo
- Delta (peso/xp)
- Highlight "você"
```

### 2.9 Card Base (`lib/core/widgets/sf_card.dart`)
```
- Background surface
- Border
- Shadow + inset highlight
- Border radius lg
```

---

## Fase 3: Bottom Navigation

### 3.1 `lib/core/widgets/sf_bottom_nav.dart`
```
5 tabs: Início, Treino, Diário (FAB central), Ranking, Perfil
- FAB elevado com gradiente
- Indicador de aba ativa (linha no topo)
- Animação de scale
- Blur background
```

### 3.2 `lib/core/navigation/app_shell.dart`
```
- Scaffold com BottomNav
- PageView ou IndexedStack para telas
- Manter estado entre trocas
```

---

## Fase 4: Modais e Feedback

### 4.1 Modal Shell (`lib/core/widgets/modals/sf_modal_shell.dart`)
```
- Bottom sheet com handle
- Scrim com blur
- Border radius top
```

### 4.2 Centered Modal (`lib/core/widgets/modals/sf_centered_modal.dart`)
```
- Para alertas/confirmações
- Centralizado
```

### 4.3 Toast (`lib/core/widgets/feedback/sf_toast.dart`)
```
- Variantes: success, error, info
- Ícone, título, mensagem
- Action button
- Auto dismiss
```

### 4.4 Bottom Sheet Options (`lib/core/widgets/modals/sf_bottom_sheet_options.dart`)
```
- Lista de ações com ícones
- Destructive style
- Cancel button
```

---

## Fase 5: Estados

### 5.1 Empty State (`lib/core/widgets/states/sf_empty_state.dart`)
```
- Ilustração geométrica
- Kicker, título, descrição
- CTAs
```

### 5.2 Loading Skeleton (`lib/core/widgets/states/sf_skeleton.dart`)
```
- Shimmer animation
- Componentes: rect, circle, text
```

### 5.3 Loading Spinner (`lib/core/widgets/states/sf_loading_spinner.dart`)
```
- Ring animado
- Glow
- Mensagem opcional
```

---

## Fase 6: Telas - ADAPTADAS PARA O QUE EXISTE

### 6.1 Login (`lib/features/auth/screens/login_screen.dart`)
Usar design do Claude Design, mantendo:
- ✅ Lógica de `_signIn()`, `_signUp()`, `_signInWithGoogle()`
- ✅ Controllers de email/senha
- ✅ Validação de formulário
- ✅ Estados de loading/erro

### 6.2 Home (`lib/features/home/screens/home_screen.dart`)
Adaptar design, usando dados REAIS:
- ✅ Nome do usuário (UserModel)
- ✅ Peso atual vs meta (do UserModel + WeightService)
- ✅ Streak banner (após implementar Sprint 10)
- ✅ Calorias consumidas (do NutritionService - mostrar se tiver dados)
- ✅ Ranking preview (já existe)
- ❌ Próximo treino - NÃO TEM (não implementar)

### 6.3 Nutrition/Diário (`lib/features/nutrition/screens/nutrition_screen.dart`)
Melhorar visual, mantendo:
- ✅ DateSelector
- ✅ CircularCalorieProgress
- ✅ MealSection (4 refeições)
- ✅ FoodItemTile
- ✅ Lógica de add/delete
- ❌ Water tracker - NÃO IMPLEMENTAR

### 6.4 Competition/Squads (`lib/features/competition/screens/competition_screen.dart`)
A "Tela de Squads" do Claude Design = tela de Competition melhorada.
Usar visual do "Squads Screen" + "Ranking Screen":
- ✅ Lista de desafios que participa (como cards do Squads)
- ✅ Hero do desafio ativo
- ✅ Pódio (top 3)
- ✅ Lista de ranking completa
- ✅ Criar/entrar/convidar
- ✅ Quick actions (criar squad, entrar com código)
- ❌ Tabs XP/Treinos - só tem peso (por enquanto)

### 6.5 Weight (`lib/features/weight/screens/weight_screen.dart`)
Melhorar visual:
- ✅ Registro de peso
- ✅ Histórico com gráfico
- ✅ Delete

### 6.6 Perfil - NOVA TELA (para badges)
Só existe ProfileSetupScreen (setup inicial).
Criar tela de perfil para exibir:
- ✅ Avatar + nome + username
- ✅ Stats (peso perdido, dias de streak, vitórias)
- ✅ Badges/Conquistas
- ✅ Gráfico de evolução de peso
- ✅ Botão editar perfil → vai para ProfileSetupScreen

### ❌ 6.7 Treino Ativo - NÃO EXISTE
Feature de treinos não existe. Não implementar.

### ❌ 6.8 Squads - NÃO EXISTE
Conceito de "squads" não existe. Só tem "Competição/Desafio".

---

## Fase 7: Modais - APENAS OS QUE EXISTEM

### ✅ 7.1 Modal Adicionar Alimento
Já existe fluxo. Melhorar visual.

### ✅ 7.2 Modal Criar Desafio (não "Squad")
Já existe em CompetitionScreen. Melhorar visual.

### ✅ 7.3 Modal Entrar com Código
Já existe em CompetitionScreen. Melhorar visual.

### ✅ 7.4 Modal Convidar (WhatsApp/Código)
Já existe em CompetitionScreen. Melhorar visual.

### ✅ 7.5 Modal Confirmação de Exclusão
Pode criar genérico para delete de peso, refeição, etc.

---

## Fase 8: Polish (SEGURO)

### 8.1 Micro-interações
- Button press scale (0.96)
- Page transitions suaves
- List item animations

### 8.2 Haptic Feedback
- Light impact em botões
- Success em ações completadas

### 8.3 Loading States
- Skeletons para carregamento
- Shimmer effect

---

## Ordem de Implementação (SEGURA)

### Sprint 1: Design System Base ✅ SEGURO
Apenas criar/atualizar arquivos de tema, não afeta funcionalidades.

1. [ ] Atualizar `app_colors.dart` com nova paleta
2. [ ] Criar `app_gradients.dart`
3. [ ] Atualizar `app_typography.dart` com Space Grotesk
4. [ ] Atualizar `app_spacing.dart`
5. [ ] Criar `app_shadows.dart`
6. [ ] Adicionar fontes ao `pubspec.yaml`
7. [ ] **TESTAR**: Rodar app, verificar se nada quebrou

### Sprint 2: Componentes Novos ✅ SEGURO
Criar componentes NOVOS em pasta separada, não substituir os existentes ainda.

1. [ ] Criar pasta `lib/core/widgets/redesign/`
2. [ ] `sf_button.dart` (novo, não substituir ElevatedButton existentes)
3. [ ] `sf_input.dart`
4. [ ] `sf_avatar.dart`
5. [ ] `sf_chip.dart`
6. [ ] `sf_card.dart`
7. [ ] `sf_progress_ring.dart`
8. [ ] `sf_stat_pill.dart`
9. [ ] `sf_section_header.dart`
10. [ ] **TESTAR**: Criar tela de preview dos componentes

### Sprint 3: Login Screen ⚠️ CUIDADO
Refatorar visual MANTENDO toda a lógica de auth.

1. [ ] Criar `login_screen_v2.dart` (cópia com novo visual)
2. [ ] Manter TODOS os controllers e callbacks
3. [ ] Apenas trocar widgets visuais
4. [ ] **TESTAR**: Login email, login Google, cadastro, erro
5. [ ] Se funcionar: substituir original

### Sprint 4: Home Screen ⚠️ CUIDADO
Refatorar visual MANTENDO streams e providers.

1. [ ] Criar `home_screen_v2.dart`
2. [ ] Adaptar design para dados REAIS (não os mockados do Figma)
3. [ ] Manter UserStatsCard e RankingList funcionais
4. [ ] **TESTAR**: Dados carregam? Ranking funciona? Drawer funciona?
5. [ ] Se funcionar: substituir original

### Sprint 5: Nutrition Screen ⚠️ CUIDADO
A tela já existe e funciona. Apenas melhorar visual.

1. [ ] Criar `nutrition_screen_v2.dart`
2. [ ] Manter DateSelector, MealSection, CircularCalorieProgress
3. [ ] Aplicar novo visual nos componentes
4. [ ] **TESTAR**: Trocar data, adicionar alimento, deletar
5. [ ] Se funcionar: substituir original

### Sprint 6: Competition Screen ⚠️ CUIDADO
Aplicar visual do "Ranking Screen" do Claude Design.

1. [ ] Criar `competition_screen_v2.dart`
2. [ ] Adaptar pódio e ranking para dados reais
3. [ ] Manter criar desafio, entrar código, convidar
4. [ ] **TESTAR**: Todas as funcionalidades de competição
5. [ ] Se funcionar: substituir original

### Sprint 7: Weight Screen ⚠️ CUIDADO
Melhorar visual do registro de peso.

1. [ ] Criar `weight_screen_v2.dart`
2. [ ] Aplicar novo visual
3. [ ] Manter add/delete peso funcionando
4. [ ] **TESTAR**: Adicionar peso, histórico, deletar
5. [ ] Se funcionar: substituir original

### Sprint 8: Feedback e Estados ✅ SEGURO
Componentes novos que melhoram UX sem quebrar nada.

1. [ ] `sf_toast.dart` - Feedback de ações
2. [ ] `sf_empty_state.dart` - Estados vazios
3. [ ] `sf_skeleton.dart` - Loading states
4. [ ] `sf_bottom_sheet.dart` - Opções
5. [ ] Integrar nos lugares apropriados
6. [ ] **TESTAR**: Feedback aparece corretamente

### Sprint 9: Polish ✅ SEGURO
Melhorias incrementais.

1. [ ] Animações sutis
2. [ ] Haptic feedback em ações
3. [ ] Transições de página
4. [ ] Ajustes de espaçamento
5. [ ] **TESTAR**: App fluido e responsivo

### Sprint 10: Features Novas - Streak ⚠️ NOVA FEATURE
Implementar sistema de sequência de dias.

1. [ ] Criar model `StreakModel` (currentStreak, longestStreak, lastActiveDate)
2. [ ] Criar `StreakService` para calcular streak baseado em registros de peso/nutrição
3. [ ] Adicionar campo streak no `UserModel` ou tabela separada
4. [ ] Criar widget `StreakBanner` para exibir na Home
5. [ ] **TESTAR**: Streak incrementa ao registrar peso/refeição diariamente

### Sprint 11: Features Novas - Badges/Conquistas ⚠️ NOVA FEATURE
Implementar sistema de conquistas.

1. [ ] Definir lista de badges (Em chamas, Primeiro peso, 7 dias seguidos, etc.)
2. [ ] Criar model `BadgeModel` (id, name, icon, description, earnedAt)
3. [ ] Criar `BadgeService` para verificar e desbloquear badges
4. [ ] Criar tabela `user_badges` no Supabase
5. [ ] Criar widget `BadgeGrid` para exibir no Perfil
6. [ ] Criar tela de Perfil (não existe ainda) para mostrar badges
7. [ ] **TESTAR**: Badges desbloqueiam corretamente

### ❌ NÃO IMPLEMENTAR (fora do escopo)
- Bottom Navigation (manter Drawer por enquanto)
- Tela de Treino Ativo (não tem sistema de treinos)
- Sistema de XP/Níveis (complexo, deixar para depois)
- Water tracker
- Passos

---

## Arquivos do Design de Referência

- `squad-fit-redesign-completo/project/colors_and_type.css` - Design tokens
- `squad-fit-redesign-completo/project/Components.jsx` - Componentes base
- `squad-fit-redesign-completo/project/Logo.jsx` - Logo SVG
- `squad-fit-redesign-completo/project/Screens.jsx` - Telas 1-5
- `squad-fit-redesign-completo/project/Screens2.jsx` - Telas 6-7
- `squad-fit-redesign-completo/project/Modals.jsx` - Modais
- `squad-fit-redesign-completo/project/States.jsx` - Empty/Loading/Toast

---

## Decisões Técnicas

1. **Fontes**: Usar Google Fonts (Space Grotesk, Inter) via pubspec
2. **Ícones**: Material Symbols Rounded (já disponível no Flutter)
3. **Animações**: Usar `AnimatedContainer`, `Hero`, `PageRouteBuilder`
4. **Estado**: Manter Riverpod existente
5. **Navegação**: go_router com shell route para bottom nav

---

## Notas

- O design usa dark mode como padrão
- Gradientes são muito usados - criar extensões para BoxDecoration
- Glow effects são importantes pro visual premium
- Bordas arredondadas grandes (16-20px) em quase tudo
- Espaçamentos generosos (16px padrão)
