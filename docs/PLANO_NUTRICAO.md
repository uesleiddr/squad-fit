# Plano de Implementação - Nutricionista Inteligente

## Visão Geral

Feature que permite ao usuário registrar refeições de forma natural via chat. A IA (Gemini) interpreta o texto e estrutura em JSON, depois a API FatSecret fornece os dados nutricionais reais.

### Fluxo Principal
1. Usuário digita: "Comi 2 ovos fritos e 1 fatia de pão integral"
2. Gemini transforma em JSON estruturado: `[{item: "ovo frito", qty: 2}, {item: "pão integral", qty: 1}]`
3. Backend consulta FatSecret para cada item
4. Exibe na tela: calorias por item + total

---

## Etapa 1: Banco de Dados (Supabase)

### 1.1 Adicionar campo na tabela `users`

```sql
ALTER TABLE users
ADD COLUMN calorie_goal INTEGER DEFAULT 2000;
```

### 1.2 Criar tabela `meal_entries`

```sql
CREATE TABLE meal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  description TEXT NOT NULL, -- texto original do usuário
  total_calories INTEGER NOT NULL DEFAULT 0,
  total_protein DECIMAL(8,2) DEFAULT 0,
  total_carbs DECIMAL(8,2) DEFAULT 0,
  total_fat DECIMAL(8,2) DEFAULT 0,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE meal_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own meals" ON meal_entries
  FOR ALL USING (auth.uid() = user_id);

-- Index para consultas por data
CREATE INDEX idx_meal_entries_user_date ON meal_entries(user_id, recorded_at);
```

### 1.3 Criar tabela `meal_items`

```sql
CREATE TABLE meal_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_entry_id UUID NOT NULL REFERENCES meal_entries(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity DECIMAL(8,2) NOT NULL DEFAULT 1,
  unit TEXT DEFAULT 'porção',
  calories INTEGER NOT NULL DEFAULT 0,
  protein DECIMAL(8,2) DEFAULT 0,
  carbs DECIMAL(8,2) DEFAULT 0,
  fat DECIMAL(8,2) DEFAULT 0,
  fatsecret_food_id TEXT, -- ID do alimento na FatSecret (para referência)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS
ALTER TABLE meal_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meal items" ON meal_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own meal items" ON meal_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own meal items" ON meal_items
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM meal_entries
      WHERE meal_entries.id = meal_items.meal_entry_id
      AND meal_entries.user_id = auth.uid()
    )
  );
```

### 1.4 Atualizar UserModel no Flutter

Adicionar campo `calorieGoal` no `UserModel`.

---

## Etapa 2: Serviços de API

### 2.1 FatSecret Service

Arquivo: `lib/features/nutrition/services/fatsecret_service.dart`

Responsabilidades:
- Autenticação OAuth 2.0 (Client Credentials)
- Buscar alimentos por nome (`foods.search`)
- Obter detalhes nutricionais (`food.get.v4`)
- Cache de token de acesso

```dart
class FatSecretService {
  // OAuth 2.0 - obter access token
  Future<String> _getAccessToken();

  // Buscar alimentos por termo
  Future<List<FoodSearchResult>> searchFoods(String query);

  // Obter dados nutricionais completos
  Future<FoodNutrition> getFoodNutrition(String foodId);
}
```

### 2.2 Gemini Service

Arquivo: `lib/features/nutrition/services/gemini_nutrition_service.dart`

Responsabilidades:
- Receber texto natural do usuário
- Retornar JSON estruturado com itens e quantidades

```dart
class GeminiNutritionService {
  // Transforma texto em lista estruturada
  Future<List<ParsedFoodItem>> parseNaturalText(String userInput);
}

class ParsedFoodItem {
  final String name;      // "ovo frito"
  final double quantity;  // 2
  final String? unit;     // "unidade"
}
```

Prompt do Gemini:
```
Você é um parser de alimentos. Extraia os alimentos e quantidades do texto.
Retorne APENAS um JSON array, sem explicações.

Formato: [{"name": "nome do alimento", "quantity": numero, "unit": "unidade"}]

Texto: "{input}"
```

### 2.3 Nutrition Service (Orquestrador)

Arquivo: `lib/features/nutrition/services/nutrition_service.dart`

Responsabilidades:
- Orquestrar fluxo completo
- Coordenar Gemini + FatSecret
- Salvar no Supabase

```dart
class NutritionService {
  // Fluxo completo: texto -> parse -> busca -> salva
  Future<MealEntry> processMealInput({
    required String userInput,
    required MealType mealType,
  });

  // Buscar refeições do dia
  Future<List<MealEntry>> getMealsForDate(DateTime date);

  // Resumo diário (total calorias, macros)
  Future<DailySummary> getDailySummary(DateTime date);

  // Atualizar meta de calorias do usuário
  Future<void> updateCalorieGoal(int calories);
}
```

---

## Etapa 3: Models

### 3.1 MealEntry

```dart
class MealEntry extends Equatable {
  final String id;
  final String usrId;
  final MealType mealType;
  final String description;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealItem> items;
  final DateTime recordedAt;
  final DateTime createdAt;
}

enum MealType { breakfast, lunch, dinner, snack }
```

### 3.2 MealItem

```dart
class MealItem extends Equatable {
  final String id;
  final String mealEntryId;
  final String name;
  final double quantity;
  final String unit;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? fatsecretFoodId;
}
```

### 3.3 DailySummary

```dart
class DailySummary extends Equatable {
  final DateTime date;
  final int totalCalories;
  final int calorieGoal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<MealEntry> meals;

  double get calorieProgress => totalCalories / calorieGoal;
  int get remainingCalories => calorieGoal - totalCalories;
}
```

---

## Etapa 4: Interface (Telas)

### 4.1 NutritionScreen (Tela Principal)

Arquivo: `lib/features/nutrition/screens/nutrition_screen.dart`

Layout:
```
┌─────────────────────────────────────┐
│  < Hoje, 28 Mar >                   │  ← Seletor de data
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐    │
│  │   1.250 / 2.000 kcal        │    │  ← Progresso circular
│  │      [===----]              │    │
│  │    750 kcal restantes       │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│  Macros                             │
│  ┌───────────────────────────┐      │
│  │  🥧 Pie Chart              │     │  ← fl_chart
│  │  P: 45g  C: 120g  G: 35g  │      │
│  └───────────────────────────┘      │
├─────────────────────────────────────┤
│  Refeições                          │
│  ┌─────────────────────────────┐    │
│  │ ☀️ Café da Manhã    450kcal │    │
│  │   2x Ovo frito       180    │    │
│  │   1x Pão integral    120    │    │
│  │   1x Café c/ leite   150    │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ 🌞 Almoço           800kcal │    │
│  │   ...                       │    │
│  └─────────────────────────────┘    │
├─────────────────────────────────────┤
│         [+ Adicionar Refeição]      │  ← FAB ou botão
└─────────────────────────────────────┘
```

### 4.2 AddMealScreen (Chat de Entrada)

Arquivo: `lib/features/nutrition/screens/add_meal_screen.dart`

Layout:
```
┌─────────────────────────────────────┐
│  ← Adicionar Refeição               │
├─────────────────────────────────────┤
│  Tipo de Refeição                   │
│  [Café] [Almoço] [Jantar] [Lanche]  │  ← Chips selecionáveis
├─────────────────────────────────────┤
│                                     │
│  "Descreva o que você comeu..."     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ Comi 2 ovos fritos com      │    │
│  │ pão integral e um copo de   │    │  ← TextField multiline
│  │ suco de laranja             │    │
│  └─────────────────────────────┘    │
│                                     │
│         [Analisar Refeição]         │  ← Botão principal
├─────────────────────────────────────┤
│  (Após análise - preview)           │
│  ┌─────────────────────────────┐    │
│  │ ✓ 2x Ovo frito       180cal │    │
│  │ ✓ 1x Pão integral    120cal │    │
│  │ ✓ 1x Suco laranja    110cal │    │
│  ├─────────────────────────────┤    │
│  │ Total:               410cal │    │
│  └─────────────────────────────┘    │
│                                     │
│  [Cancelar]      [Confirmar]        │
└─────────────────────────────────────┘
```

### 4.3 CalorieGoalScreen (Configuração)

Arquivo: `lib/features/nutrition/screens/calorie_goal_screen.dart`

Tela simples para definir meta diária de calorias.
- Slider ou input numérico
- Sugestões baseadas em peso/altura (opcional)

---

## Etapa 5: Widgets Reutilizáveis

### 5.1 CalorieProgressWidget
- Círculo de progresso com calorias consumidas/meta
- Cor muda conforme progresso (verde -> amarelo -> vermelho)

### 5.2 MacrosPieChart
- Gráfico de pizza com Proteína, Carboidratos, Gordura
- Usa `fl_chart` (já instalado)
- Legenda com gramas de cada macro

### 5.3 MealCard
- Card expansível por tipo de refeição
- Lista itens com calorias individuais
- Ícone por tipo (café, almoço, jantar, lanche)

### 5.4 FoodItemTile
- Item individual com nome, quantidade e calorias
- Opção de remover (swipe ou botão)

---

## Etapa 6: Integração e Navegação

### 6.1 Adicionar rota para NutritionScreen
- Adicionar no drawer/menu principal
- Ícone: `Icons.restaurant_menu`

### 6.2 Service Locator
- Registrar todos os services no `get_it`
- FatSecretService, GeminiNutritionService, NutritionService

---

## Ordem de Implementação

### Etapa 1: Banco de Dados ✅
- [x] Configurar Supabase CLI e migrations
- [x] Criar tabelas `meal_entries` e `meal_items`
- [x] Adicionar campo `calorie_goal` na tabela `users`
- [x] Configurar RLS (Row Level Security)
- [x] Atualizar `UserModel` no Flutter

### Etapa 2: Models
- [ ] Criar `MealEntry` model
- [ ] Criar `MealItem` model
- [ ] Criar `DailySummary` model
- [ ] Criar enum `MealType`

### Etapa 3: Telas (com dados mockados)
- [ ] `NutritionScreen` - Tela principal com resumo diário
- [ ] `AddMealScreen` - Tela de adicionar refeição
- [ ] Widgets: `CalorieProgressWidget`, `MacrosPieChart`, `MealCard`
- [ ] Adicionar navegação no drawer

### Etapa 4: Services (Backend)
- [ ] `FatSecretService` - Autenticação OAuth e busca de alimentos
- [ ] `GeminiNutritionService` - Parser de texto natural para JSON
- [ ] `NutritionService` - Orquestrador (Gemini + FatSecret + Supabase)

### Etapa 5: Integração
- [ ] Conectar telas aos services reais
- [ ] Remover dados mockados
- [ ] Testes e ajustes finais

---

## Variáveis de Ambiente Necessárias

```env
# Já existentes
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
GEMINI_API_KEY=...

# Novas
FATSECRET_CLIENT_ID=...
FATSECRET_CLIENT_SECRET=...
```

---

## Considerações

- **Offline**: Por enquanto, feature requer conexão (IA + API externa)
- **Rate Limits**: FatSecret tem limites, considerar cache local futuro
- **Precisão**: Gemini pode errar no parse; usuário pode ajustar antes de confirmar
- **Idioma**: Buscar no FatSecret em português quando possível
