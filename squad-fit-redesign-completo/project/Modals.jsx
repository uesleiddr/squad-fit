// Modals.jsx — Bloco 2: Modais essenciais
// Globals used: SF, Icon, SFButton, Avatar, Chip, insetHi, gradPrimary, gradSquad, gradVictory, glowOrange, glowLime, fontBody, fontDisp

// ─── Shared modal shell ─────────────────────────────
function ModalShell({children, height='auto', maxHeight='85%', backdropBlur=true}){
  return (
    <div style={{position:'absolute', inset:0, zIndex:50, display:'flex', flexDirection:'column', justifyContent:'flex-end'}}>
      {/* Scrim */}
      <div style={{
        position:'absolute', inset:0,
        background:'rgba(0,0,0,.65)',
        backdropFilter: backdropBlur ? 'blur(6px)' : 'none',
        WebkitBackdropFilter: backdropBlur ? 'blur(6px)' : 'none',
      }}/>
      {/* Sheet */}
      <div style={{
        position:'relative', zIndex:2,
        background: SF.surface,
        borderRadius:'24px 24px 0 0',
        borderTop: `1px solid ${SF.border}`,
        boxShadow:'0 -20px 40px rgba(0,0,0,.4)',
        height, maxHeight,
        display:'flex', flexDirection:'column',
        overflow:'hidden',
      }}>
        {/* Handle */}
        <div style={{display:'flex', justifyContent:'center', padding:'10px 0 6px'}}>
          <div style={{width:40, height:4, borderRadius:999, background:SF.border}}/>
        </div>
        {children}
      </div>
    </div>
  );
}

// ─── Centered (alert) modal shell ─────────────────────────────
function CenteredModalShell({children}){
  return (
    <div style={{position:'absolute', inset:0, zIndex:50, display:'flex', alignItems:'center', justifyContent:'center', padding:'0 24px'}}>
      <div style={{position:'absolute', inset:0, background:'rgba(0,0,0,.7)', backdropFilter:'blur(8px)', WebkitBackdropFilter:'blur(8px)'}}/>
      <div style={{
        position:'relative', zIndex:2, width:'100%',
        background: SF.surface2,
        border: `1px solid ${SF.border}`,
        borderRadius:20,
        boxShadow:'0 24px 60px rgba(0,0,0,.55)',
        overflow:'hidden',
      }}>
        {children}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 01 — MODAL ADICIONAR ALIMENTO
// ═══════════════════════════════════════════════════════════════
function ModalAdicionarAlimento(){
  const [selected, setSelected] = React.useState('frango');
  const [qty, setQty] = React.useState(150);
  const [unit, setUnit] = React.useState('g');

  const results = [
    {id:'frango', n:'Frango grelhado, peito', per:'165 kcal/100g', cat:'Proteína', c:'#EF4444', icon:'restaurant'},
    {id:'arroz', n:'Arroz integral cozido', per:'124 kcal/100g', cat:'Carboidrato', c:'#3B82F6', icon:'rice_bowl'},
    {id:'brocolis', n:'Brócolis cozido', per:'35 kcal/100g', cat:'Vegetal', c:'#22C55E', icon:'eco'},
    {id:'batata', n:'Batata doce cozida', per:'86 kcal/100g', cat:'Carboidrato', c:'#3B82F6', icon:'local_dining'},
  ];

  const food = results.find(r=>r.id===selected) || results[0];
  const totalKcal = Math.round(165 * qty / 100);
  const prot = (31 * qty / 100).toFixed(1);
  const carbs = (0);
  const fat = (3.6 * qty / 100).toFixed(1);

  return (
    <ModalShell maxHeight="94%">
      {/* Header */}
      <div style={{padding:'6px 20px 10px', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <button style={{width:36,height:36, borderRadius:10, background:SF.surface2, border:`1px solid ${SF.border}`, color:SF.fg1, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
          <Icon name="close" size={20}/>
        </button>
        <span style={{font:`800 16px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Adicionar ao almoço</span>
        <button style={{width:36, height:36, borderRadius:10, background:'rgba(214,255,59,.12)', border:`1px solid rgba(214,255,59,.25)`, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
          <Icon name="auto_awesome" size={18} fill={1} color={SF.lime}/>
        </button>
      </div>

      <div style={{flex:1, overflow:'auto', padding:'4px 20px 0'}}>
        {/* Search bar */}
        <div style={{
          display:'flex', alignItems:'center', gap:10, height:48, padding:'0 14px',
          background:SF.surface2, border:`1.5px solid ${SF.orange}`, borderRadius:14,
          boxShadow:`0 0 0 3px rgba(250,128,56,.15), ${insetHi}`,
        }}>
          <Icon name="search" size={20} color={SF.orange}/>
          <input defaultValue="frango grelhado" style={{flex:1, background:'transparent', border:'none', outline:'none', color:SF.fg, font:`500 14px ${fontBody}`}}/>
          <Icon name="close" size={18} color={SF.fg3}/>
        </div>
        <div style={{display:'flex', alignItems:'center', gap:6, marginTop:8, font:`500 11px ${fontBody}`, color:SF.fg3}}>
          <Icon name="auto_awesome" size={12} color={SF.lime}/>
          Busca inteligente · RAG + base TACO
        </div>

        {/* Results */}
        <div style={{font:`600 10px ${fontBody}`, color:SF.fg3, letterSpacing:'.14em', textTransform:'uppercase', margin:'16px 0 8px'}}>4 resultados</div>
        <div style={{display:'flex', flexDirection:'column', gap:8}}>
          {results.map(r=>{
            const on = r.id===selected;
            return (
              <div key={r.id} onClick={()=>setSelected(r.id)} style={{
                display:'flex', alignItems:'center', gap:12, padding:'10px 12px',
                background: on ? 'rgba(250,128,56,.08)' : SF.surface2,
                border: on ? `1.5px solid ${SF.orange}` : `1px solid ${SF.border}`,
                borderRadius:12, boxShadow:insetHi, cursor:'pointer',
              }}>
                <div style={{width:6, alignSelf:'stretch', borderRadius:3, background:r.c}}/>
                <div style={{flex:1, minWidth:0}}>
                  <div style={{font:`600 13px ${fontBody}`, color:SF.fg1}}>{r.n}</div>
                  <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:2, display:'flex', alignItems:'center', gap:6}}>
                    <span style={{padding:'1px 5px', borderRadius:4, background:`${r.c}22`, color:r.c, font:`700 8px ${fontBody}`, letterSpacing:'.08em', textTransform:'uppercase'}}>{r.cat}</span>
                    <span>{r.per}</span>
                  </div>
                </div>
                <Icon name={on?'check_circle':'add_circle'} size={22} fill={on?1:0} color={on?SF.orange:SF.fg3}/>
              </div>
            );
          })}
        </div>
      </div>

      {/* Selected food quantity footer (when something is picked) */}
      <div style={{
        borderTop:`1px solid ${SF.border}`, padding:'14px 20px 20px',
        background:'linear-gradient(180deg, rgba(26,28,34,0) 0%, rgba(26,28,34,1) 40%)',
      }}>
        <div style={{display:'flex', alignItems:'center', gap:10, marginBottom:12}}>
          <div style={{width:8, height:8, borderRadius:999, background:food.c, boxShadow:`0 0 10px ${food.c}`}}/>
          <span style={{font:`700 13px ${fontBody}`, color:'#fff'}}>{food.n}</span>
        </div>

        {/* Qty + unit */}
        <div style={{display:'flex', alignItems:'center', gap:8}}>
          <button onClick={()=>setQty(Math.max(10, qty-10))} style={{width:44,height:52, borderRadius:12, background:SF.surface2, border:`1px solid ${SF.border}`, color:SF.fg, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
            <Icon name="remove" size={20} weight={700}/>
          </button>
          <div style={{flex:1, height:52, borderRadius:12, background:SF.surface2, border:`1px solid ${SF.border}`, display:'flex', alignItems:'center', justifyContent:'center', gap:6, boxShadow:insetHi}}>
            <span style={{font:`900 26px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', fontVariantNumeric:'tabular-nums'}}>{qty}</span>
            <span style={{font:`500 13px ${fontBody}`, color:SF.fg2}}>{unit}</span>
          </div>
          <button onClick={()=>setQty(qty+10)} style={{width:44,height:52, borderRadius:12, background:SF.surface2, border:`1px solid ${SF.border}`, color:SF.fg, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
            <Icon name="add" size={20} weight={700}/>
          </button>
        </div>

        {/* Unit chips */}
        <div style={{display:'flex', gap:6, marginTop:10, overflowX:'auto', scrollbarWidth:'none'}}>
          {[{v:'g',g:null},{v:'porção',g:100},{v:'fatia',g:25},{v:'colher',g:15}].map(u=>(
            <button key={u.v} onClick={()=>{setUnit(u.v); if(u.g) setQty(u.g);}} style={{
              padding:'6px 12px', borderRadius:999,
              border: unit===u.v ? `1px solid ${SF.orange}` : `1px solid ${SF.border}`,
              background: unit===u.v ? 'rgba(250,128,56,.14)' : 'transparent',
              color: unit===u.v ? SF.orange : SF.fg2,
              font:`600 11px ${fontBody}`, whiteSpace:'nowrap', cursor:'pointer',
            }}>{u.v}{u.g?` (${u.g}g)`:''}</button>
          ))}
        </div>

        {/* Preview */}
        <div style={{
          margin:'14px 0', padding:'12px 14px', borderRadius:12,
          background:'linear-gradient(135deg, rgba(250,128,56,.12), rgba(255,59,139,.04))',
          border:'1px solid rgba(250,128,56,.2)',
          display:'flex', alignItems:'center', gap:14,
        }}>
          <div>
            <div style={{font:`500 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2}}>Total</div>
            <div style={{display:'flex', alignItems:'baseline', gap:4}}>
              <span style={{font:`900 26px ${fontDisp}`, color:SF.orange, letterSpacing:'-0.03em', fontVariantNumeric:'tabular-nums'}}>{totalKcal}</span>
              <span style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>kcal</span>
            </div>
          </div>
          <div style={{flex:1, display:'flex', gap:10, justifyContent:'flex-end'}}>
            {[{l:'Prot',v:prot,c:'#EF4444'},{l:'Carb',v:carbs,c:'#3B82F6'},{l:'Gord',v:fat,c:'#F59E0B'}].map(m=>(
              <div key={m.l} style={{textAlign:'center'}}>
                <div style={{font:`800 14px ${fontDisp}`, color:'#fff', fontVariantNumeric:'tabular-nums'}}>{m.v}<span style={{font:`500 9px ${fontBody}`, color:SF.fg3}}>g</span></div>
                <div style={{display:'flex', alignItems:'center', justifyContent:'center', gap:3, marginTop:2}}>
                  <span style={{width:4,height:4,borderRadius:999, background:m.c}}/>
                  <span style={{font:`600 8px ${fontBody}`, color:SF.fg3, letterSpacing:'.1em', textTransform:'uppercase'}}>{m.l}</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <SFButton variant="primary" size="lg" full icon="check">Adicionar refeição</SFButton>
      </div>
    </ModalShell>
  );
}

// ═══════════════════════════════════════════════════════════════
// 02 — MODAL CRIAR SQUAD
// ═══════════════════════════════════════════════════════════════
function ModalCriarSquad(){
  const [name, setName] = React.useState('Família Fit');
  const [grad, setGrad] = React.useState(0);
  const gradients = [
    'linear-gradient(135deg,#FA8038,#FF3B8B)',
    'linear-gradient(135deg,#6366F1,#256AD2)',
    'linear-gradient(135deg,#22C55E,#D6FF3B)',
    'linear-gradient(135deg,#F59E0B,#EF4444)',
    'linear-gradient(135deg,#8B5CF6,#FF3B8B)',
    'linear-gradient(135deg,#0EA5E9,#6366F1)',
  ];

  const initials = (name||'??').split(' ').slice(0,2).map(w=>w[0]).join('').toUpperCase();

  return (
    <ModalShell>
      <div style={{padding:'8px 20px 24px'}}>
        <div style={{textAlign:'center', padding:'4px 0 16px'}}>
          <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.orange}}>Novo squad</div>
          <div style={{font:`900 24px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:4}}>Bora criar uma galera</div>
          <div style={{font:`500 12px ${fontBody}`, color:SF.fg2, marginTop:4}}>Você vira líder e pode convidar até 19 amigos</div>
        </div>

        {/* Avatar picker */}
        <div style={{display:'flex', justifyContent:'center', marginBottom:16}}>
          <div style={{position:'relative'}}>
            <div style={{
              width:96, height:96, borderRadius:28, background:gradients[grad],
              display:'flex', alignItems:'center', justifyContent:'center',
              font:`900 38px ${fontDisp}`, color:'#fff', letterSpacing:'-0.02em',
              boxShadow:`0 8px 24px rgba(250,128,56,.3), inset 0 1px 0 rgba(255,255,255,.15)`,
            }}>{initials}</div>
            <button style={{
              position:'absolute', bottom:-4, right:-4, width:36, height:36, borderRadius:12,
              background:SF.surface2, border:`2px solid ${SF.surface}`, color:'#fff', cursor:'pointer',
              display:'flex', alignItems:'center', justifyContent:'center',
              boxShadow:'0 4px 12px rgba(0,0,0,.4)',
            }}>
              <Icon name="photo_camera" size={18} fill={1}/>
            </button>
          </div>
        </div>

        {/* Gradient swatches */}
        <div style={{display:'flex', justifyContent:'center', gap:8, marginBottom:20}}>
          {gradients.map((g,i)=>(
            <button key={i} onClick={()=>setGrad(i)} style={{
              width:28, height:28, borderRadius:999, background:g,
              border: i===grad ? `2px solid #fff` : '2px solid transparent',
              cursor:'pointer', padding:0,
              boxShadow: i===grad ? '0 0 0 2px rgba(255,255,255,.2)' : 'inset 0 1px 0 rgba(255,255,255,.15)',
            }}/>
          ))}
        </div>

        {/* Name input */}
        <div style={{marginBottom:14}}>
          <label style={{font:`600 11px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', color:SF.fg2, marginBottom:8, display:'block'}}>Nome do squad</label>
          <div style={{
            display:'flex', alignItems:'center', gap:10, height:52, padding:'0 14px',
            background:SF.surface2, border:`1.5px solid ${SF.orange}`, borderRadius:14,
            boxShadow:`0 0 0 3px rgba(250,128,56,.12), ${insetHi}`,
          }}>
            <Icon name="group" size={20} color={SF.orange}/>
            <input value={name} onChange={e=>setName(e.target.value)} style={{flex:1, background:'transparent', border:'none', outline:'none', color:'#fff', font:`600 15px ${fontBody}`}}/>
            <span style={{font:`600 11px ${fontBody}`, color:SF.fg3, fontVariantNumeric:'tabular-nums'}}>{name.length}/30</span>
          </div>
          <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:6}}>Tag automática: <span style={{color:SF.fg2, fontFamily:fontBody, fontWeight:600}}>@{name.toLowerCase().replace(/\s+/g,'-').replace(/[^a-z0-9-]/g,'')}</span></div>
        </div>

        {/* Tip */}
        <div style={{
          padding:'12px 14px', borderRadius:12, marginBottom:16,
          background: 'linear-gradient(90deg, rgba(214,255,59,.08), rgba(34,197,94,.03))',
          border:`1px solid rgba(214,255,59,.2)`,
          display:'flex', alignItems:'flex-start', gap:10,
        }}>
          <div style={{width:28,height:28, borderRadius:8, background:'rgba(214,255,59,.15)', display:'flex',alignItems:'center',justifyContent:'center', flexShrink:0}}>
            <Icon name="lightbulb" size={16} fill={1} color={SF.lime}/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`700 12px ${fontBody}`, color:'#fff'}}>Dica</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:2, lineHeight:1.45}}>Depois de criar, você pode iniciar um desafio e convidar o squad pra competir.</div>
          </div>
        </div>

        <SFButton variant="primary" size="lg" full iconRight="arrow_forward">Criar squad</SFButton>
        <div style={{textAlign:'center', marginTop:10}}>
          <span style={{font:`600 13px ${fontBody}`, color:SF.fg2, cursor:'pointer'}}>Cancelar</span>
        </div>
      </div>
    </ModalShell>
  );
}

// ═══════════════════════════════════════════════════════════════
// 03 — MODAL ENTRAR COM CÓDIGO
// ═══════════════════════════════════════════════════════════════
function ModalEntrarCodigo(){
  const code = ['S','Q','F','7'];
  return (
    <ModalShell>
      <div style={{padding:'8px 20px 24px'}}>
        <div style={{textAlign:'center', padding:'4px 0 20px'}}>
          <div style={{
            width:72, height:72, margin:'0 auto 14px', borderRadius:20,
            background: gradSquad,
            display:'flex', alignItems:'center', justifyContent:'center',
            boxShadow:'0 8px 24px rgba(37,106,210,.4), inset 0 1px 0 rgba(255,255,255,.2)',
          }}>
            <Icon name="vpn_key" size={34} fill={1} color="#fff"/>
          </div>
          <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.blue}}>Entrar no squad</div>
          <div style={{font:`900 24px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:6}}>Digite o código</div>
          <div style={{font:`500 13px ${fontBody}`, color:SF.fg2, marginTop:6, lineHeight:1.45, padding:'0 12px'}}>Pede pra quem criou o squad o código de 4 dígitos</div>
        </div>

        {/* Code input */}
        <div style={{display:'flex', justifyContent:'center', gap:10, marginBottom:18}}>
          {code.map((c,i)=>(
            <div key={i} style={{
              width:56, height:68, borderRadius:14,
              background: c ? `linear-gradient(180deg, ${SF.surface2}, ${SF.surface})` : SF.surface,
              border: c ? `1.5px solid ${SF.orange}` : `1.5px solid ${SF.border}`,
              boxShadow: c ? `0 0 0 3px rgba(250,128,56,.12), ${insetHi}` : insetHi,
              display:'flex', alignItems:'center', justifyContent:'center',
            }}>
              <span style={{font:`900 32px ${fontDisp}`, color:c?'#fff':SF.fg3, letterSpacing:'-0.02em'}}>{c || '·'}</span>
            </div>
          ))}
        </div>

        {/* Or divider */}
        <div style={{display:'flex', alignItems:'center', gap:10, margin:'18px 0'}}>
          <div style={{flex:1, height:1, background:SF.border}}/>
          <span style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.fg3}}>Ou</span>
          <div style={{flex:1, height:1, background:SF.border}}/>
        </div>

        {/* QR scan option */}
        <button style={{
          width:'100%', padding:'14px', borderRadius:14,
          background:SF.surface2, border:`1px solid ${SF.border}`,
          display:'flex', alignItems:'center', gap:12, cursor:'pointer', boxShadow:insetHi,
        }}>
          <div style={{width:40,height:40, borderRadius:12, background:'rgba(214,255,59,.12)', display:'flex',alignItems:'center',justifyContent:'center'}}>
            <Icon name="qr_code_scanner" size={22} fill={1} color={SF.lime}/>
          </div>
          <div style={{flex:1, textAlign:'left'}}>
            <div style={{font:`700 13px ${fontBody}`, color:'#fff'}}>Escanear QR code</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:1}}>Abre a câmera pra ler um convite</div>
          </div>
          <Icon name="chevron_right" size={20} color={SF.fg2}/>
        </button>

        <div style={{height:20}}/>
        <SFButton variant="primary" size="lg" full icon="login">Entrar no squad</SFButton>
      </div>
    </ModalShell>
  );
}

// ═══════════════════════════════════════════════════════════════
// 04 — MODAL CONVIDAR AMIGOS
// ═══════════════════════════════════════════════════════════════
function ModalConvidarAmigos(){
  // Small SVG-based QR placeholder (pattern of squares) — stylized, not a real code
  const QR = () => {
    const cells = [];
    // Pseudo-random but deterministic pattern
    const seed = 'SQF7';
    for (let y=0; y<21; y++){
      for (let x=0; x<21; x++){
        const v = (x*7 + y*13 + y*x) ^ seed.charCodeAt((x+y)%4);
        if (v % 3 === 0) cells.push(<rect key={`${x}-${y}`} x={x*5} y={y*5} width={5} height={5} fill="#0B0D12"/>);
      }
    }
    // Corner markers
    const corner = (cx, cy)=>(
      <g key={`c-${cx}-${cy}`}>
        <rect x={cx} y={cy} width={35} height={35} fill="#0B0D12"/>
        <rect x={cx+5} y={cy+5} width={25} height={25} fill="#fff"/>
        <rect x={cx+10} y={cy+10} width={15} height={15} fill="#0B0D12"/>
      </g>
    );
    return (
      <svg viewBox="0 0 105 105" width="100%" height="100%" style={{display:'block'}}>
        <rect width="105" height="105" fill="#fff"/>
        {cells}
        {corner(0,0)}
        {corner(70,0)}
        {corner(0,70)}
        {/* Center logo overlay */}
        <rect x={42} y={42} width={21} height={21} fill="#fff"/>
        <rect x={44} y={44} width={17} height={17} rx={4} fill="#FA8038"/>
        <text x={52.5} y={57} fontSize="11" fontWeight="900" fill="#fff" textAnchor="middle" fontFamily="Space Grotesk">SF</text>
      </svg>
    );
  };

  return (
    <ModalShell>
      <div style={{padding:'8px 20px 24px'}}>
        <div style={{textAlign:'center', padding:'4px 0 14px'}}>
          <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.orange}}>Convidar amigos</div>
          <div style={{font:`900 24px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:4}}>Família Fit</div>
          <div style={{display:'flex', alignItems:'center', justifyContent:'center', gap:5, marginTop:6, font:`500 12px ${fontBody}`, color:SF.fg2}}>
            <Icon name="group" size={14}/>
            8 membros · 12 vagas restantes
          </div>
        </div>

        {/* QR code */}
        <div style={{
          padding:16, borderRadius:20, background:'#fff',
          width:200, height:200, margin:'0 auto 16px',
          boxShadow:'0 10px 30px rgba(0,0,0,.4), 0 0 0 1px rgba(255,255,255,.1)',
        }}>
          <QR/>
        </div>

        {/* Code copy row */}
        <div style={{
          display:'flex', alignItems:'center', gap:8, padding:'6px 8px 6px 16px',
          background:SF.surface2, border:`1px solid ${SF.border}`, borderRadius:14, boxShadow:insetHi,
          marginBottom:14,
        }}>
          <div style={{flex:1}}>
            <div style={{font:`600 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg3}}>Código do squad</div>
            <div style={{font:`900 22px ${fontDisp}`, color:'#fff', letterSpacing:'0.12em', fontVariantNumeric:'tabular-nums', marginTop:2}}>SQF7</div>
          </div>
          <button style={{
            padding:'10px 14px', borderRadius:10, background:gradPrimary, border:'none',
            color:'#fff', font:`800 11px ${fontBody}`, letterSpacing:'.06em', textTransform:'uppercase',
            cursor:'pointer', display:'flex', alignItems:'center', gap:6,
            boxShadow:`${glowOrange}, ${insetHi}`,
          }}>
            <Icon name="content_copy" size={14} fill={1}/>Copiar
          </button>
        </div>

        {/* Share options */}
        <div style={{font:`600 11px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', color:SF.fg2, marginBottom:10}}>Compartilhar via</div>
        <div style={{display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:10}}>
          {[
            {n:'WhatsApp', i:'chat', c:'#22C55E'},
            {n:'Instagram', i:'photo_camera', c:'#FF3B8B'},
            {n:'Link', i:'link', c:SF.blue},
            {n:'Mais', i:'more_horiz', c:SF.fg2},
          ].map(s=>(
            <button key={s.n} style={{
              padding:'12px 6px', borderRadius:14, background:SF.surface2, border:`1px solid ${SF.border}`,
              display:'flex', flexDirection:'column', alignItems:'center', gap:6, cursor:'pointer', boxShadow:insetHi,
            }}>
              <div style={{
                width:40, height:40, borderRadius:12, background:`${s.c}22`,
                display:'flex', alignItems:'center', justifyContent:'center',
              }}>
                <Icon name={s.i} size={20} fill={1} color={s.c}/>
              </div>
              <span style={{font:`600 11px ${fontBody}`, color:SF.fg1}}>{s.n}</span>
            </button>
          ))}
        </div>

        <div style={{
          marginTop:16, textAlign:'center', padding:'10px',
          font:`500 11px ${fontBody}`, color:SF.fg3, lineHeight:1.5,
        }}>
          O código expira em <span style={{color:SF.fg1, fontWeight:700}}>24h</span>. Você pode gerar um novo a qualquer momento.
        </div>
      </div>
    </ModalShell>
  );
}

// ═══════════════════════════════════════════════════════════════
// 05 — MODAL CONFIRMAÇÃO DE EXCLUSÃO
// ═══════════════════════════════════════════════════════════════
function ModalConfirmarExclusao(){
  return (
    <CenteredModalShell>
      <div style={{
        padding:'24px 22px 22px',
        textAlign:'center',
        position:'relative',
      }}>
        {/* Decorative glow */}
        <div style={{
          position:'absolute', top:-30, left:'50%', transform:'translateX(-50%)',
          width:220, height:120,
          background:'radial-gradient(closest-side, rgba(239,68,68,.22), transparent 70%)',
          pointerEvents:'none',
        }}/>

        {/* Icon */}
        <div style={{
          width:64, height:64, margin:'0 auto 14px', borderRadius:20,
          background:'linear-gradient(135deg, rgba(239,68,68,.2), rgba(239,68,68,.08))',
          border:'1px solid rgba(239,68,68,.35)',
          display:'flex', alignItems:'center', justifyContent:'center',
          boxShadow:'0 8px 24px rgba(239,68,68,.25)',
          position:'relative',
        }}>
          <Icon name="delete_forever" size={34} fill={1} color="#EF4444"/>
        </div>

        <div style={{font:`900 22px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', position:'relative'}}>Tem certeza?</div>
        <div style={{font:`500 13px ${fontBody}`, color:SF.fg2, marginTop:8, lineHeight:1.5, padding:'0 8px', position:'relative'}}>
          Você vai sair do <span style={{color:'#fff', fontWeight:700}}>Família Fit</span> e perder seu histórico no desafio <span style={{color:'#fff', fontWeight:700}}>Verão 2026</span>.
        </div>

        {/* Info row (what will be lost) */}
        <div style={{
          marginTop:16, padding:'12px 14px', borderRadius:12,
          background:'rgba(239,68,68,.06)', border:'1px solid rgba(239,68,68,.2)',
          display:'flex', alignItems:'center', gap:10, textAlign:'left',
          position:'relative',
        }}>
          <Icon name="warning_amber" size={18} fill={1} color="#F59E0B"/>
          <div style={{flex:1, font:`500 12px ${fontBody}`, color:SF.fg1, lineHeight:1.4}}>
            <span style={{fontWeight:700}}>-2.3kg perdidos</span> · <span style={{fontWeight:700}}>9 treinos</span> · <span style={{fontWeight:700}}>posição #2</span>
          </div>
        </div>

        {/* Buttons */}
        <div style={{display:'flex', gap:10, marginTop:18, position:'relative'}}>
          <button style={{
            flex:1, height:48, borderRadius:12,
            background:'transparent', border:`1px solid ${SF.border}`,
            color:SF.fg1, font:`700 14px ${fontBody}`, cursor:'pointer',
          }}>Cancelar</button>
          <button style={{
            flex:1, height:48, borderRadius:12,
            background:'linear-gradient(180deg, #EF4444, #C53030)',
            border:'1px solid rgba(255,255,255,.08)',
            color:'#fff', font:`800 14px ${fontBody}`, cursor:'pointer', letterSpacing:'.01em',
            boxShadow:'0 4px 20px rgba(239,68,68,.35), inset 0 1px 0 rgba(255,255,255,.15)',
            display:'flex', alignItems:'center', justifyContent:'center', gap:6,
          }}>
            <Icon name="delete" size={18} fill={1}/>Sair do squad
          </button>
        </div>
      </div>
    </CenteredModalShell>
  );
}

Object.assign(window, {
  ModalShell, CenteredModalShell,
  ModalAdicionarAlimento, ModalCriarSquad, ModalEntrarCodigo,
  ModalConvidarAmigos, ModalConfirmarExclusao,
});
