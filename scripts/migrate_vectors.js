/**
 * Script para migrar embeddings do food_vectors.json para Supabase pgvector
 *
 * Execução:
 *   cd scripts
 *   npm install
 *   npm run migrate-vectors
 *
 * Pré-requisitos:
 *   1. Rodar a migration: supabase db push
 *   2. Ter o food_vectors.json gerado: dart run scripts/generate_embeddings.dart
 *
 * O script:
 * 1. Lê o arquivo food_vectors.json
 * 2. Adiciona categoria e tags como metadados
 * 3. Envia em batches para a tabela food_vectors no Supabase
 * 4. Cria o índice IVFFlat após inserir os dados
 */

import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'
import { readFileSync } from 'fs'

const __dirname = dirname(fileURLToPath(import.meta.url))

// Carrega .env da raiz do projeto
config({ path: resolve(__dirname, '..', '.env') })

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_ANON_KEY

const BATCH_SIZE = 500
const VECTORS_FILE = resolve(__dirname, '..', 'assets', 'data', 'food_vectors.json')

// ============================================================================
// HELPERS
// ============================================================================

/**
 * Extrai categoria do nome do alimento
 */
function extractCategory(name) {
  const n = name.toLowerCase()

  if (n.startsWith('ovo') || n.includes('ovo,') || n.includes('ovo de')) {
    return 'ovo'
  }
  if (n.startsWith('frango') || n.includes('frango,') || n.includes('galinha')) {
    return 'frango'
  }
  if (n.startsWith('carne') || n.includes('boi') || n.includes('bovina') || n.includes('patinho') || n.includes('alcatra') || n.includes('picanha')) {
    return 'carne_bovina'
  }
  if (n.includes('porco') || n.includes('suíno') || n.includes('bacon') || n.includes('presunto')) {
    return 'carne_suina'
  }
  if (n.startsWith('peixe') || n.includes('salmão') || n.includes('atum') || n.includes('tilápia') || n.includes('bacalhau')) {
    return 'peixe'
  }
  if (n.startsWith('arroz')) {
    return 'arroz'
  }
  if (n.startsWith('feijão') || n.startsWith('feijao')) {
    return 'feijao'
  }
  if (n.startsWith('macarrão') || n.startsWith('massa') || n.includes('espaguete') || n.includes('lasanha')) {
    return 'massa'
  }
  if (n.startsWith('pão') || n.startsWith('pao')) {
    return 'pao'
  }
  if (n.startsWith('leite') || n.includes('iogurte') || n.includes('queijo') || n.includes('requeijão')) {
    return 'laticinio'
  }
  if (n.startsWith('salada') || n.includes('alface') || n.includes('rúcula') || n.includes('agrião')) {
    return 'salada'
  }
  if (n.includes('legume') || n.includes('cenoura') || n.includes('batata') || n.includes('abobrinha') || n.includes('brócolis')) {
    return 'legume'
  }
  if (n.includes('fruta') || n.includes('banana') || n.includes('maçã') || n.includes('laranja') || n.includes('morango')) {
    return 'fruta'
  }
  if (n.includes('suco') || n.includes('café') || n.includes('chá') || n.includes('refrigerante') || n.includes('bebida')) {
    return 'bebida'
  }
  if (n.includes('sanduíche') || n.includes('hambúrguer') || n.includes('pizza') || n.includes('lanche')) {
    return 'lanche'
  }
  if (n.includes('doce') || n.includes('bolo') || n.includes('chocolate') || n.includes('sorvete') || n.includes('biscoito')) {
    return 'doce'
  }

  return 'outro'
}

/**
 * Extrai método de preparação
 */
function extractPreparation(name) {
  const n = name.toLowerCase()

  if (n.includes('grelh')) return 'grelhado'
  if (n.includes('frit')) return 'frito'
  if (n.includes('cozid')) return 'cozido'
  if (n.includes('assad')) return 'assado'
  if (n.includes('cru')) return 'cru'
  if (n.includes('refog')) return 'refogado'
  if (n.includes('mexid')) return 'mexido'
  if (n.includes('empan')) return 'empanado'

  return null
}

/**
 * Extrai tags adicionais
 */
function extractTags(name) {
  const tags = []
  const n = name.toLowerCase()

  if (n.includes('integral')) tags.push('integral')
  if (n.includes('light')) tags.push('light')
  if (n.includes('diet')) tags.push('diet')
  if (n.includes('zero')) tags.push('zero')
  if (n.includes('sem glúten') || n.includes('s/ glúten')) tags.push('sem_gluten')
  if (n.includes('sem lactose') || n.includes('s/ lactose')) tags.push('sem_lactose')
  if (n.includes('orgânico')) tags.push('organico')
  if (n.includes('peito')) tags.push('peito')
  if (n.includes('coxa')) tags.push('coxa')
  if (n.includes('sobrecoxa')) tags.push('sobrecoxa')
  if (n.includes('filé') || n.includes('file')) tags.push('file')

  return tags
}

/**
 * Formata embedding para pgvector
 * pgvector espera formato: [0.1, 0.2, 0.3, ...]
 */
function formatEmbedding(embedding) {
  return `[${embedding.join(',')}]`
}

// ============================================================================
// MAIN
// ============================================================================

async function main() {
  console.log('='.repeat(60))
  console.log('MIGRAÇÃO DE EMBEDDINGS PARA SUPABASE PGVECTOR')
  console.log('='.repeat(60))
  console.log()

  // Validação
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    console.error('❌ ERRO: SUPABASE_URL e SUPABASE_SERVICE_KEY são obrigatórios')
    console.error('   Adicione ao arquivo .env:')
    console.error('   SUPABASE_SERVICE_KEY=sua_service_role_key')
    process.exit(1)
  }

  // 1. Carrega o arquivo de vetores
  console.log('📂 Carregando food_vectors.json...')
  console.log(`   Arquivo: ${VECTORS_FILE}`)

  let vectors
  try {
    const content = readFileSync(VECTORS_FILE, 'utf-8')
    vectors = JSON.parse(content)
    console.log(`   ✅ ${vectors.length} vetores carregados`)
  } catch (error) {
    console.error(`   ❌ Erro ao carregar arquivo: ${error.message}`)
    console.error('   Execute primeiro: dart run scripts/generate_embeddings.dart')
    process.exit(1)
  }

  // 2. Conecta ao Supabase
  console.log()
  console.log('📡 Conectando ao Supabase...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

  // Verifica se a tabela existe
  const { error: checkError } = await supabase
    .from('food_vectors')
    .select('id')
    .limit(1)

  if (checkError) {
    console.error(`   ❌ Erro ao acessar tabela: ${checkError.message}`)
    console.error('   Execute primeiro: supabase db push')
    process.exit(1)
  }

  console.log('   ✅ Conectado!')

  // 3. Limpa dados existentes (se houver)
  console.log()
  console.log('🗑️  Limpando dados existentes...')

  const { error: deleteError } = await supabase
    .from('food_vectors')
    .delete()
    .neq('id', '')  // Deleta todos

  if (deleteError) {
    console.error(`   ⚠️  Aviso ao limpar: ${deleteError.message}`)
  } else {
    console.log('   ✅ Tabela limpa')
  }

  // 4. Prepara os vetores com metadados
  console.log()
  console.log('🏷️  Processando metadados...')

  const processedVectors = vectors.map((v) => {
    const category = extractCategory(v.name)
    const preparation = extractPreparation(v.name)
    const tags = extractTags(v.name)

    return {
      id: v.id,
      name: v.name,
      calories: v.calories || 0,
      protein: v.protein || 0,
      carbs: v.carbs || 0,
      fat: v.fat || 0,
      source: v.source || '',
      category,
      preparation,
      tags: tags.join(','),
      embedding: formatEmbedding(v.embedding),
    }
  })

  // Estatísticas de categorias
  const categoryCount = {}
  processedVectors.forEach((v) => {
    categoryCount[v.category] = (categoryCount[v.category] || 0) + 1
  })

  console.log('   Distribuição por categoria:')
  Object.entries(categoryCount)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .forEach(([cat, count]) => {
      console.log(`     ${cat}: ${count}`)
    })

  // 5. Envia em batches
  console.log()
  console.log('📤 Enviando vetores para o Supabase...')
  console.log(`   Total: ${processedVectors.length} vetores`)
  console.log(`   Batches de: ${BATCH_SIZE}`)

  const totalBatches = Math.ceil(processedVectors.length / BATCH_SIZE)
  let uploaded = 0
  let errors = 0

  for (let i = 0; i < processedVectors.length; i += BATCH_SIZE) {
    const batchNum = Math.floor(i / BATCH_SIZE) + 1
    const batch = processedVectors.slice(i, i + BATCH_SIZE)

    process.stdout.write(`\r   Batch ${batchNum}/${totalBatches} (${uploaded}/${processedVectors.length})...`)

    try {
      const { error } = await supabase
        .from('food_vectors')
        .insert(batch)

      if (error) {
        throw error
      }

      uploaded += batch.length
    } catch (error) {
      errors++
      console.error(`\n   ❌ Erro no batch ${batchNum}: ${error.message}`)

      // Tenta inserir um por um para identificar o problemático
      if (error.message.includes('duplicate') || error.message.includes('unique')) {
        console.log('      Tentando inserir individualmente...')
        for (const item of batch) {
          try {
            const { error: singleError } = await supabase
              .from('food_vectors')
              .upsert(item, { onConflict: 'id' })

            if (!singleError) uploaded++
          } catch (e) {
            // ignora
          }
        }
      }
    }
  }

  console.log(`\n   ✅ ${uploaded} vetores enviados com sucesso!`)

  if (errors > 0) {
    console.log(`   ⚠️  ${errors} batches com erro`)
  }

  // 6. Cria índice IVFFlat (requer dados na tabela)
  console.log()
  console.log('📊 Criando índice IVFFlat para busca vetorial...')

  try {
    // Verifica se o índice já existe
    const { data: indexExists } = await supabase.rpc('to_regclass', {
      relation: 'food_vectors_embedding_idx'
    })

    if (!indexExists) {
      const { error: indexError } = await supabase.rpc('exec_sql', {
        sql: `
          CREATE INDEX IF NOT EXISTS food_vectors_embedding_idx
          ON food_vectors
          USING ivfflat (embedding vector_cosine_ops)
          WITH (lists = 100);
        `
      })

      if (indexError) {
        console.log(`   ⚠️  Índice precisa ser criado manualmente:`)
        console.log(`      CREATE INDEX food_vectors_embedding_idx ON food_vectors`)
        console.log(`      USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);`)
      } else {
        console.log('   ✅ Índice criado!')
      }
    } else {
      console.log('   ℹ️  Índice já existe')
    }
  } catch (e) {
    console.log(`   ⚠️  Crie o índice manualmente no SQL Editor:`)
    console.log(`      CREATE INDEX food_vectors_embedding_idx ON food_vectors`)
    console.log(`      USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);`)
  }

  // 7. Resumo
  console.log()
  console.log('='.repeat(60))
  console.log('✅ MIGRAÇÃO CONCLUÍDA!')
  console.log('='.repeat(60))
  console.log()
  console.log(`Tabela: food_vectors`)
  console.log(`Vetores: ${uploaded}`)
  console.log(`Dimensão: 768 (Gemini embedding-001)`)
  console.log()
  console.log('Próximo passo: atualizar o FoodVectorStore no Flutter')
  console.log()
}

main().catch(console.error)
