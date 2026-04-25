// States.jsx — Bloco 3: Empty states, loading, toasts, bottom sheets
// Globals: SF, Icon, SFButton, Avatar, Chip, insetHi, gradPrimary, gradSquad, gradVictory, glowOrange, glowLime, fontBody, fontDisp

// ═══════════════════════════════════════════════════════════════
// 1. EMPTY STATES — each is a full-screen component
// ═══════════════════════════════════════════════════════════════

// Shared empty illustration frame — geometric glyph built from shapes
function EmptyIllustration({icon, glowColor=SF.orange, accent=SF.orange}){
  return (
    <div style={{position:'relative', width:200, height:200, margin:'0 auto'}}>
      {/* Soft glow */}
      <div style={{
        position:'absolute', inset:0,
        background:`radial-gradient(closest-side, ${glowColor}30, transparent 70%)`,
      }}/>
      {/* Concentric rings */}
      <svg viewBox="0 0 200 200" width="200" height="200" style={{position:'absolute', inset:0}}>
        <circle cx="100" cy="100" r="86" fill="none" stroke={SF.border} strokeWidth="1" strokeDasharray="2 6"/>
        <circle cx="100" cy="100" r="64" fill="none" stroke={SF.border} strokeWidth="1"/>
      </svg>
      {/* Floating accent dots */}
      <div style={{position:'absolute', top:20, right:26, width:8, height:8, borderRadius:999, background:accent, boxShadow:`0 0 10px ${accent}`}}/>
      <div style={{position:'absolute', bottom:32, left:30, width:5, height:5, borderRadius:999, background:SF.lime, boxShadow:`0 0 8px ${SF.lime}`}}/>
      <div style={{position:'absolute', top:60, left:14, width:4, height:4, borderRadius:999, background:SF.blue, opacity:.7}}/>
      <div style={{position:'absolute', bottom:60, right:10, width:6, height:6, borderRadius:999, background:SF.magenta, boxShadow:`0 0 8px ${SF.magenta}`, opacity:.6}}/>
      {/* Center icon tile */}
      <div style={{
        position:'absolute', top:'50%', left:'50%', transform:'translate(-50%,-50%)',
        width:96, height:96, borderRadius:28,
        background:`linear-gradient(135deg, ${SF.surface2}, ${SF.surface})`,
        border:`1px solid ${SF.border}`,
        display:'flex', alignItems:'center', justifyContent:'center',
        boxShadow:`0 12px 30px rgba(0,0,0,.5), 0 0 40px ${glowColor}40, ${insetHi}`,
      }}>
        <Icon name={icon} size={44} fill={1} color={accent}/>
      </div>
    </div>
  );
}

function EmptyLayout({illustration, kicker, title, desc, primary, secondary}){
  return (
    <div style={{
      minHeight:'100%',
      display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
      padding:'40px 24px', textAlign:'center',
    }}>
      {illustration}
      <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.2em', textTransform:'uppercase', color:SF.fg3, marginTop:20}}>{kicker}</div>
      <div style={{font:`900 24px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:8, textWrap:'balance'}}>{title}</div>
      <div style={{font:`500 13px ${fontBody}`, color:SF.fg2, marginTop:10, lineHeight:1.5, maxWidth:260, textWrap:'pretty'}}>{desc}</div>
      <div style={{marginTop:22, width:'100%', display:'flex', flexDirection:'column', gap:8}}>
        {primary}
        {secondary}
      </div>
    </div>
  );
}

function EmptySemTreinos(){
  return (
    <EmptyLayout
      illustration={<EmptyIllustration icon="fitness_center" glowColor={SF.orange} accent={SF.orange}/>}
      kicker="Sem treinos ainda"
      title="Bora começar sua jornada"
      desc="Seu primeiro treino desbloqueia o streak e move você no ranking do squad."
      primary={<SFButton variant="primary" size="lg" full icon="play_arrow">Iniciar treino</SFButton>}
      secondary={<button style={{height:44, background:'transparent', border:`1px solid ${SF.border}`, borderRadius:12, color:SF.fg1, font:`700 13px ${fontBody}`, cursor:'pointer'}}>Ver programas</button>}
    />
  );
}

function EmptySemSquad(){
  return (
    <EmptyLayout
      illustration={<EmptyIllustration icon="group_add" glowColor={SF.magenta} accent={SF.magenta}/>}
      kicker="Sem squad"
      title="Treino é melhor em squad"
      desc="Crie ou entre num squad pra competir em desafios e se motivar com amigos."
      primary={<SFButton variant="primary" size="lg" full icon="add">Criar squad</SFButton>}
      secondary={<button style={{height:44, background:SF.surface, border:`1px solid ${SF.border}`, borderRadius:12, color:SF.fg1, font:`700 13px ${fontBody}`, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap:6, boxShadow:insetHi}}>
        <Icon name="vpn_key" size={16} fill={1}/>Entrar com código
      </button>}
    />
  );
}

function EmptyDiarioVazio(){
  return (
    <EmptyLayout
      illustration={<EmptyIllustration icon="restaurant_menu" glowColor={SF.success} accent={SF.success}/>}
      kicker="Diário de hoje"
      title="Nenhuma refeição registrada"
      desc="Adicione seu café da manhã pra acompanhar calorias e macros do dia."
      primary={<SFButton variant="primary" size="lg" full icon="add_circle">Adicionar refeição</SFButton>}
      secondary={<button style={{height:44, background:'transparent', border:'none', color:SF.fg2, font:`600 12px ${fontBody}`, cursor:'pointer'}}>Ou fotografar o prato →</button>}
    />
  );
}

function EmptyBuscaSemResultado(){
  // Inline empty state (smaller, fits in search context)
  return (
    <div style={{minHeight:'100%', background:SF.bg}}>
      {/* Mock search bar to give context */}
      <div style={{padding:'10px 16px 14px'}}>
        <div style={{display:'flex', alignItems:'center', gap:10, height:48, padding:'0 14px',
          background:SF.surface2, border:`1px solid ${SF.border}`, borderRadius:14, boxShadow:insetHi}}>
          <Icon name="search" size={20} color={SF.fg2}/>
          <span style={{flex:1, color:SF.fg1, font:`500 14px ${fontBody}`}}>tapioca com banana dourada</span>
          <Icon name="close" size={18} color={SF.fg3}/>
        </div>
      </div>
      <div style={{padding:'40px 24px', textAlign:'center'}}>
        <EmptyIllustration icon="search_off" glowColor={SF.fg3} accent={SF.fg2}/>
        <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.2em', textTransform:'uppercase', color:SF.fg3, marginTop:20}}>Sem resultados</div>
        <div style={{font:`900 22px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:8}}>Não achamos esse alimento</div>
        <div style={{font:`500 13px ${fontBody}`, color:SF.fg2, marginTop:10, lineHeight:1.5, maxWidth:280, margin:'10px auto 0', textWrap:'pretty'}}>
          Tenta um nome mais simples ou cadastra como <span style={{color:'#fff', fontWeight:700}}>alimento personalizado</span>.
        </div>

        {/* Suggestions */}
        <div style={{marginTop:22, display:'flex', gap:8, flexWrap:'wrap', justifyContent:'center'}}>
          {['tapioca','banana','chia','aveia'].map(s=>(
            <button key={s} style={{
              padding:'8px 14px', borderRadius:999,
              background:SF.surface, border:`1px solid ${SF.border}`, boxShadow:insetHi,
              color:SF.fg1, font:`600 12px ${fontBody}`, cursor:'pointer',
            }}>{s}</button>
          ))}
        </div>

        <div style={{marginTop:20}}>
          <SFButton variant="primary" size="md" icon="add_circle">Criar alimento</SFButton>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 2. LOADING STATES
// ═══════════════════════════════════════════════════════════════

// Shimmer block — pure CSS animation via inline keyframes injected once
(function injectShimmer(){
  if (document.getElementById('sf-shimmer-kf')) return;
  const style = document.createElement('style');
  style.id = 'sf-shimmer-kf';
  style.textContent = `
    @keyframes sf-shimmer { 0% { background-position: -200% 0; } 100% { background-position: 200% 0; } }
    @keyframes sf-pulse { 0%,100% { opacity:.65 } 50% { opacity:1 } }
    @keyframes sf-spin { to { transform: rotate(360deg); } }
    @keyframes sf-slide-in { from { transform: translateY(100%); opacity:0 } to { transform: translateY(0); opacity:1 } }
    .sf-shimmer {
      background: linear-gradient(90deg, rgba(255,255,255,.02) 0%, rgba(255,255,255,.08) 50%, rgba(255,255,255,.02) 100%);
      background-size: 200% 100%;
      animation: sf-shimmer 1.6s linear infinite;
    }
  `;
  document.head.appendChild(style);
})();

const Skel = ({w='100%', h=12, r=6, style={}}) => (
  <div className="sf-shimmer" style={{width:w, height:h, borderRadius:r, ...style}}/>
);

function LoadingHome(){
  return (
    <div style={{padding:'12px 16px 24px', display:'flex', flexDirection:'column', gap:16}}>
      {/* Greeting */}
      <div style={{display:'flex', alignItems:'center', gap:12, paddingTop:4}}>
        <div className="sf-shimmer" style={{width:48, height:48, borderRadius:999}}/>
        <div style={{flex:1}}>
          <Skel w="40%" h={10}/>
          <div style={{height:6}}/>
          <Skel w="70%" h={18}/>
        </div>
        <div className="sf-shimmer" style={{width:40, height:40, borderRadius:12}}/>
      </div>

      {/* Streak banner */}
      <div className="sf-shimmer" style={{width:'100%', height:70, borderRadius:16}}/>

      {/* Hero card */}
      <div style={{
        background:SF.surface, border:`1px solid ${SF.border}`, borderRadius:20, padding:20,
        display:'flex', alignItems:'center', gap:16, boxShadow:insetHi,
      }}>
        <div className="sf-shimmer" style={{width:130, height:130, borderRadius:999}}/>
        <div style={{flex:1, display:'flex', flexDirection:'column', gap:14}}>
          <div><Skel w="55%" h={10}/><div style={{height:6}}/><Skel w="75%" h={22}/></div>
          <div><Skel w="55%" h={10}/><div style={{height:6}}/><Skel w="65%" h={22}/></div>
        </div>
      </div>

      {/* Stats row */}
      <div style={{display:'flex', gap:10}}>
        {[1,2,3].map(i=>(
          <div key={i} style={{flex:1, padding:14, borderRadius:16, background:SF.surface, border:`1px solid ${SF.border}`, boxShadow:insetHi}}>
            <Skel w="60%" h={9}/>
            <div style={{height:8}}/>
            <Skel w="80%" h={22}/>
          </div>
        ))}
      </div>

      {/* Section header */}
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'center'}}>
        <Skel w="35%" h={16}/>
        <Skel w={60} h={10}/>
      </div>

      {/* Ranking rows */}
      {[1,2,3].map(i=>(
        <div key={i} style={{display:'flex', alignItems:'center', gap:12, padding:12, borderRadius:14, background:SF.surface, border:`1px solid ${SF.border}`, boxShadow:insetHi, animation:'sf-pulse 1.8s ease-in-out infinite', animationDelay:`${i*120}ms`}}>
          <div className="sf-shimmer" style={{width:32, height:32, borderRadius:10}}/>
          <div className="sf-shimmer" style={{width:40, height:40, borderRadius:999}}/>
          <div style={{flex:1}}>
            <Skel w="55%" h={12}/>
            <div style={{height:6}}/>
            <Skel w="35%" h={9}/>
          </div>
          <Skel w={50} h={18}/>
        </div>
      ))}
    </div>
  );
}

function LoadingPerfil(){
  return (
    <div style={{padding:'16px 16px 24px', display:'flex', flexDirection:'column', gap:16}}>
      {/* Avatar + name */}
      <div style={{display:'flex', flexDirection:'column', alignItems:'center', gap:10, paddingTop:8}}>
        <div className="sf-shimmer" style={{width:100, height:100, borderRadius:999}}/>
        <Skel w={140} h={22}/>
        <Skel w={90} h={10}/>
      </div>

      {/* Chips row */}
      <div style={{display:'flex', gap:6, justifyContent:'center'}}>
        {[1,2,3].map(i=>(
          <div key={i} className="sf-shimmer" style={{width:72, height:26, borderRadius:999}}/>
        ))}
      </div>

      {/* XP bar */}
      <div style={{padding:14, borderRadius:16, background:SF.surface, border:`1px solid ${SF.border}`, boxShadow:insetHi}}>
        <div style={{display:'flex', justifyContent:'space-between', marginBottom:10}}>
          <Skel w="40%" h={12}/>
          <Skel w={60} h={12}/>
        </div>
        <Skel w="100%" h={10} r={999}/>
      </div>

      {/* Stats grid 2x2 */}
      <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:10}}>
        {[1,2,3,4].map(i=>(
          <div key={i} style={{padding:14, borderRadius:16, background:SF.surface, border:`1px solid ${SF.border}`, boxShadow:insetHi, display:'flex', flexDirection:'column', gap:8}}>
            <Skel w="55%" h={10}/>
            <Skel w="70%" h={22}/>
          </div>
        ))}
      </div>

      {/* Chart placeholder */}
      <div style={{padding:16, borderRadius:16, background:SF.surface, border:`1px solid ${SF.border}`, boxShadow:insetHi}}>
        <Skel w="45%" h={14}/>
        <div style={{height:10}}/>
        <div style={{display:'flex', alignItems:'flex-end', gap:5, height:90}}>
          {[38,54,32,48,70,58,82,60,92,72,88,100].map((h,i)=>(
            <div key={i} className="sf-shimmer" style={{flex:1, height:`${h}%`, borderRadius:4}}/>
          ))}
        </div>
      </div>
    </div>
  );
}

// Centered spinner for button/action loading
function LoadingSpinner(){
  return (
    <div style={{
      minHeight:'100%',
      display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
      gap:20,
    }}>
      <div style={{position:'relative', width:80, height:80}}>
        {/* Glow halo */}
        <div style={{
          position:'absolute', inset:-20,
          background:`radial-gradient(closest-side, ${SF.orange}40, transparent 70%)`,
        }}/>
        {/* Ring */}
        <svg viewBox="0 0 80 80" width="80" height="80" style={{position:'absolute', inset:0, animation:'sf-spin 1s linear infinite'}}>
          <defs>
            <linearGradient id="spinGrad" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0" stopColor="#FA8038"/>
              <stop offset="1" stopColor="#FF3B8B"/>
            </linearGradient>
          </defs>
          <circle cx="40" cy="40" r="32" fill="none" stroke={SF.surface2} strokeWidth="5"/>
          <circle cx="40" cy="40" r="32" fill="none" stroke="url(#spinGrad)" strokeWidth="5" strokeLinecap="round" strokeDasharray="50 150"/>
        </svg>
        {/* Center dot */}
        <div style={{
          position:'absolute', top:'50%', left:'50%', transform:'translate(-50%,-50%)',
          width:28, height:28, borderRadius:999,
          background:gradPrimary,
          boxShadow:glowOrange,
          display:'flex', alignItems:'center', justifyContent:'center',
        }}>
          <Icon name="fitness_center" size={14} fill={1} color="#fff"/>
        </div>
      </div>
      <div style={{textAlign:'center'}}>
        <div style={{font:`900 20px ${fontDisp}`, color:'#fff', letterSpacing:'-0.02em'}}>Carregando…</div>
        <div style={{font:`500 12px ${fontBody}`, color:SF.fg2, marginTop:6}}>Sincronizando seu squad</div>
        {/* Dots animation */}
        <div style={{display:'flex', gap:6, justifyContent:'center', marginTop:16}}>
          {[0,1,2].map(i=>(
            <div key={i} style={{
              width:8, height:8, borderRadius:999, background:SF.orange,
              animation:`sf-pulse 1.2s ease-in-out infinite`,
              animationDelay:`${i*150}ms`,
            }}/>
          ))}
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 3. TOASTS (success, error, info)
// ═══════════════════════════════════════════════════════════════

function Toast({variant='success', icon, title, msg, action}){
  const map = {
    success: {c:'#22C55E', grad:'linear-gradient(90deg, rgba(34,197,94,.14), rgba(34,197,94,.04))', border:'rgba(34,197,94,.4)', defaultIcon:'check_circle', glow:'0 0 24px rgba(34,197,94,.3)'},
    error:   {c:'#EF4444', grad:'linear-gradient(90deg, rgba(239,68,68,.14), rgba(239,68,68,.04))', border:'rgba(239,68,68,.4)', defaultIcon:'error', glow:'0 0 24px rgba(239,68,68,.3)'},
    info:    {c:SF.blue, grad:'linear-gradient(90deg, rgba(37,106,210,.14), rgba(37,106,210,.04))', border:'rgba(37,106,210,.4)', defaultIcon:'info', glow:'0 0 24px rgba(37,106,210,.3)'},
  };
  const t = map[variant];
  return (
    <div style={{
      display:'flex', alignItems:'center', gap:12, padding:'12px 14px',
      background:`${SF.surface2}`, borderRadius:14,
      border:`1px solid ${t.border}`,
      boxShadow:`${t.glow}, 0 8px 24px rgba(0,0,0,.4), ${insetHi}`,
      position:'relative', overflow:'hidden',
    }}>
      {/* Left gradient accent */}
      <div style={{position:'absolute', left:0, top:0, bottom:0, width:4, background:t.c, boxShadow:`0 0 10px ${t.c}`}}/>
      <div style={{
        width:38, height:38, borderRadius:10,
        background:`${t.c}22`, border:`1px solid ${t.c}40`,
        display:'flex', alignItems:'center', justifyContent:'center',
        flexShrink:0, marginLeft:2,
      }}>
        <Icon name={icon || t.defaultIcon} size={20} fill={1} color={t.c}/>
      </div>
      <div style={{flex:1, minWidth:0}}>
        <div style={{font:`800 13px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>{title}</div>
        {msg && <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:2, lineHeight:1.4}}>{msg}</div>}
      </div>
      {action && <button style={{
        padding:'6px 10px', borderRadius:8, background:'transparent', border:'none',
        color:t.c, font:`800 11px ${fontBody}`, letterSpacing:'.08em', textTransform:'uppercase', cursor:'pointer',
      }}>{action}</button>}
      <button style={{
        width:28, height:28, borderRadius:8, background:'transparent', border:'none',
        color:SF.fg3, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center',
      }}>
        <Icon name="close" size={16}/>
      </button>
    </div>
  );
}

function ToastsDemo(){
  return (
    <div style={{minHeight:'100%', padding:'16px', display:'flex', flexDirection:'column', gap:12, position:'relative'}}>
      {/* Context header */}
      <div style={{padding:'4px 4px 10px'}}>
        <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.18em', textTransform:'uppercase', color:SF.fg3}}>Feedback</div>
        <div style={{font:`900 22px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:2}}>Toasts</div>
      </div>

      {/* Success */}
      <Toast variant="success" title="Alimento adicionado" msg="Frango grelhado, 150g · +248 kcal no almoço" action="Ver"/>

      {/* Success 2 */}
      <Toast variant="success" icon="fitness_center" title="Treino salvo" msg="45 min · 320 kcal queimadas · +80 XP"/>

      {/* Error */}
      <Toast variant="error" title="Falha ao salvar" msg="Não conseguimos registrar sua refeição. Tenta de novo?" action="Tentar"/>

      {/* Error 2 */}
      <Toast variant="error" icon="cloud_off" title="Sem conexão" msg="Seu progresso tá salvo localmente e sincroniza quando voltar."/>

      {/* Info */}
      <Toast variant="info" icon="emoji_events" title="Novo desafio começou" msg="Verão 2026 · 30 dias · perda total de peso" action="Ver"/>

      {/* Info 2 — Gamification hype */}
      <div style={{marginTop:4}}>
        <Toast variant="info" icon="auto_awesome" title="Você subiu pro #2!" msg="Só 0.8kg separam você do líder do squad."/>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 4. BOTTOM SHEET DE OPÇÕES
// ═══════════════════════════════════════════════════════════════

function BottomSheetOpcoes(){
  const actions = [
    {icon:'edit', label:'Editar refeição', desc:'Altere itens ou quantidade', color:SF.fg1},
    {icon:'content_copy', label:'Duplicar para amanhã', desc:'Copia pro mesmo horário', color:SF.fg1},
    {icon:'bookmark_add', label:'Salvar como favorito', desc:'Acesso rápido depois', color:SF.lime, isHighlight:true},
    {icon:'share', label:'Compartilhar no squad', desc:'Envia no feed do Família Fit', color:SF.blue},
    {icon:'delete_outline', label:'Excluir refeição', desc:'Essa ação não pode ser desfeita', color:SF.error, isDestructive:true},
  ];

  return (
    <div style={{position:'absolute', inset:0, zIndex:50, display:'flex', flexDirection:'column', justifyContent:'flex-end'}}>
      {/* Scrim */}
      <div style={{position:'absolute', inset:0, background:'rgba(0,0,0,.65)', backdropFilter:'blur(6px)', WebkitBackdropFilter:'blur(6px)'}}/>

      {/* Sheet */}
      <div style={{
        position:'relative', zIndex:2,
        background: SF.surface,
        borderRadius:'24px 24px 0 0',
        borderTop:`1px solid ${SF.border}`,
        boxShadow:'0 -20px 40px rgba(0,0,0,.4)',
        padding:'10px 0 16px',
      }}>
        {/* Handle */}
        <div style={{display:'flex', justifyContent:'center', padding:'6px 0 4px'}}>
          <div style={{width:40, height:4, borderRadius:999, background:SF.border}}/>
        </div>

        {/* Context header */}
        <div style={{padding:'10px 20px 14px', display:'flex', alignItems:'center', gap:12, borderBottom:`1px solid ${SF.border}`}}>
          <div style={{
            width:44, height:44, borderRadius:12,
            background:`${SF.success}22`, color:SF.success,
            display:'flex', alignItems:'center', justifyContent:'center',
          }}>
            <Icon name="rice_bowl" size={22} fill={1}/>
          </div>
          <div style={{flex:1, minWidth:0}}>
            <div style={{font:`800 14px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Almoço de hoje</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:2}}>3 itens · 520 kcal</div>
          </div>
        </div>

        {/* Actions */}
        <div style={{padding:'6px 10px'}}>
          {actions.map((a,i)=>(
            <button key={i} style={{
              width:'100%', display:'flex', alignItems:'center', gap:14, padding:'12px 12px',
              background:'transparent', border:'none', borderRadius:12, cursor:'pointer',
              textAlign:'left',
            }}>
              <div style={{
                width:40, height:40, borderRadius:12, flexShrink:0,
                background: a.isDestructive ? 'rgba(239,68,68,.1)' : a.isHighlight ? 'rgba(214,255,59,.12)' : SF.surface2,
                border: a.isDestructive ? '1px solid rgba(239,68,68,.25)' : a.isHighlight ? '1px solid rgba(214,255,59,.25)' : `1px solid ${SF.border}`,
                display:'flex', alignItems:'center', justifyContent:'center',
                color: a.color,
              }}>
                <Icon name={a.icon} size={20} fill={1}/>
              </div>
              <div style={{flex:1}}>
                <div style={{font:`700 14px ${fontBody}`, color: a.isDestructive ? SF.error : '#fff'}}>{a.label}</div>
                <div style={{font:`500 11px ${fontBody}`, color: SF.fg3, marginTop:2}}>{a.desc}</div>
              </div>
              <Icon name="chevron_right" size={20} color={SF.fg3}/>
            </button>
          ))}
        </div>

        {/* Cancel */}
        <div style={{padding:'8px 16px 4px'}}>
          <button style={{
            width:'100%', height:52, borderRadius:14,
            background: SF.surface2, border:`1px solid ${SF.border}`,
            color:SF.fg1, font:`700 14px ${fontBody}`, cursor:'pointer',
            boxShadow: insetHi,
          }}>Cancelar</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {
  EmptyIllustration, EmptyLayout,
  EmptySemTreinos, EmptySemSquad, EmptyDiarioVazio, EmptyBuscaSemResultado,
  LoadingHome, LoadingPerfil, LoadingSpinner,
  Toast, ToastsDemo,
  BottomSheetOpcoes,
});
