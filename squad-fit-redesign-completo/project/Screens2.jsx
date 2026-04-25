// Screens2.jsx — Bloco 1: Diário + Squads
// Uses globals from Components.jsx: SF, Icon, SFButton, SFAppBar, Avatar, Chip, SectionHeader, ProgressRing, insetHi, gradPrimary, gradSquad, gradVictory, glowOrange, glowLime, fontBody, fontDisp

// ═══════════════════════════════════════════════════════════════
// 06 — DIÁRIO (Nutrição)
// ═══════════════════════════════════════════════════════════════
function DiarioScreen(){
  const [dateIdx, setDateIdx] = React.useState(2); // 2 = Hoje
  const dates = [
    {d:'14', w:'Dom'},
    {d:'15', w:'Seg'},
    {d:'16', w:'Hoje', today:true},
    {d:'17', w:'Qua'},
    {d:'18', w:'Qui'},
    {d:'19', w:'Sex'},
    {d:'20', w:'Sáb'},
  ];

  const meals = [
    {id:'cafe', type:'Café da manhã', icon:'free_breakfast', color:SF.warning, kcal:320, items:[
      {n:'Omelete de 2 ovos', q:'120g', kcal:180},
      {n:'Pão integral', q:'1 fatia', kcal:80},
      {n:'Café com leite', q:'200ml', kcal:60},
    ]},
    {id:'almoco', type:'Almoço', icon:'rice_bowl', color:SF.success, kcal:520, items:[
      {n:'Frango grelhado', q:'150g', kcal:240},
      {n:'Arroz integral', q:'100g', kcal:180},
      {n:'Salada verde', q:'80g', kcal:100},
    ]},
    {id:'lanche', type:'Lanche', icon:'local_cafe', color:SF.magenta, kcal:204, items:[
      {n:'Whey protein', q:'30g', kcal:120},
      {n:'Banana', q:'1 un', kcal:84},
    ]},
    {id:'jantar', type:'Jantar', icon:'dinner_dining', color:'#6366F1', kcal:0, items:[]},
  ];

  return (
    <div>
      {/* Custom app bar with title + settings icon */}
      <div style={{padding:'10px 16px 4px', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <div>
          <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.fg3}}>Terça, 16 nov</div>
          <div style={{font:`900 28px ${fontDisp}`, color:'#fff', letterSpacing:'-0.035em', marginTop:2}}>Diário</div>
        </div>
        <button style={{width:40,height:40, borderRadius:12, background:SF.surface, border:`1px solid ${SF.border}`, color:SF.fg1, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:insetHi}}>
          <Icon name="tune" size={20}/>
        </button>
      </div>

      {/* Date strip */}
      <div style={{padding:'14px 16px 0', display:'flex', gap:6, overflowX:'auto', scrollbarWidth:'none'}}>
        {dates.map((d,i)=>{
          const on = i===dateIdx;
          return (
            <button key={i} onClick={()=>setDateIdx(i)} style={{
              minWidth:52, padding:'10px 6px', borderRadius:14, cursor:'pointer',
              background: on ? gradPrimary : SF.surface,
              border: on ? 'none' : `1px solid ${SF.border}`,
              boxShadow: on ? `${glowOrange}, ${insetHi}` : insetHi,
              display:'flex', flexDirection:'column', alignItems:'center', gap:2,
              transition:'all 180ms',
            }}>
              <span style={{font:`600 9px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', color: on ? 'rgba(255,255,255,.85)' : SF.fg3}}>{d.w}</span>
              <span style={{font:`800 17px ${fontDisp}`, color:on?'#fff':SF.fg1, letterSpacing:'-0.02em', fontVariantNumeric:'tabular-nums'}}>{d.d}</span>
              {d.today && !on && <span style={{width:4, height:4, borderRadius:999, background:SF.orange}}/>}
            </button>
          );
        })}
      </div>

      <div style={{padding:'16px 16px 24px', display:'flex', flexDirection:'column', gap:16}}>

        {/* Hero: calorie ring + restante / queimado */}
        <div style={{
          background:`linear-gradient(160deg, ${SF.surface2} 0%, ${SF.surface} 100%)`,
          border:`1px solid ${SF.border}`, borderRadius:20, padding:'20px 16px',
          boxShadow:`0 4px 12px rgba(0,0,0,.5), ${insetHi}`,
          position:'relative', overflow:'hidden',
        }}>
          <div style={{position:'absolute', right:-50,top:-50, width:200,height:200,
            background:'radial-gradient(closest-side,rgba(250,128,56,.22),transparent 70%)', pointerEvents:'none'}}/>
          <div style={{display:'flex', alignItems:'center', gap:18, position:'relative'}}>
            <ProgressRing value={58} size={130} label="de 1800" bigLabel="1044" stroke={10}/>
            <div style={{flex:1, display:'flex', flexDirection:'column', gap:12}}>
              <div>
                <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2}}>Restante</div>
                <div style={{display:'flex', alignItems:'baseline', gap:4, marginTop:2}}>
                  <span style={{font:`900 26px ${fontDisp}`, color:SF.lime, letterSpacing:'-0.035em', fontVariantNumeric:'tabular-nums'}}>756</span>
                  <span style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>kcal</span>
                </div>
              </div>
              <div>
                <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2, display:'flex', alignItems:'center', gap:4}}>
                  <Icon name="local_fire_department" size={11} fill={1} color={SF.orange}/> Queimado
                </div>
                <div style={{display:'flex', alignItems:'baseline', gap:4, marginTop:2}}>
                  <span style={{font:`900 26px ${fontDisp}`, color:'#fff', letterSpacing:'-0.035em', fontVariantNumeric:'tabular-nums'}}>412</span>
                  <span style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>kcal</span>
                </div>
              </div>
            </div>
          </div>

          {/* Macros row */}
          <div style={{display:'flex', gap:8, marginTop:16, position:'relative'}}>
            {[
              {n:78, l:'Proteína', c:'#EF4444', g:120},
              {n:112, l:'Carbs', c:'#3B82F6', g:180},
              {n:42, l:'Gordura', c:'#F59E0B', g:60},
            ].map(m=>(
              <div key={m.l} style={{flex:1, padding:'10px 12px', background:'rgba(255,255,255,.03)', borderRadius:10, border:`1px solid ${SF.border}`}}>
                <div style={{display:'flex', alignItems:'center', gap:5, marginBottom:4}}>
                  <span style={{width:6,height:6,borderRadius:999, background:m.c}}/>
                  <span style={{font:`600 9px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', color:SF.fg2}}>{m.l}</span>
                </div>
                <div style={{display:'flex', alignItems:'baseline', gap:3}}>
                  <span style={{font:`800 16px ${fontDisp}`, color:'#fff', fontVariantNumeric:'tabular-nums'}}>{m.n}</span>
                  <span style={{font:`500 10px ${fontBody}`, color:SF.fg3}}>/{m.g}g</span>
                </div>
                <div style={{height:3, background:SF.surface3, borderRadius:999, marginTop:5, overflow:'hidden'}}>
                  <div style={{width:`${Math.min(100,(m.n/m.g)*100)}%`, height:'100%', background:m.c, borderRadius:999}}/>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Meal sections */}
        {meals.map((meal)=>(
          <div key={meal.id} style={{
            background:SF.surface, border:`1px solid ${SF.border}`, borderRadius:16,
            overflow:'hidden', boxShadow:insetHi,
          }}>
            {/* Meal header */}
            <div style={{display:'flex', alignItems:'center', gap:12, padding:'14px'}}>
              <div style={{
                width:44, height:44, borderRadius:12,
                background:`${meal.color}22`, color:meal.color,
                display:'flex',alignItems:'center',justifyContent:'center',
              }}>
                <Icon name={meal.icon} size={22} fill={1}/>
              </div>
              <div style={{flex:1}}>
                <div style={{font:`700 15px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>{meal.type}</div>
                <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:2}}>
                  {meal.items.length ? `${meal.items.length} ${meal.items.length===1?'item':'itens'}` : 'Nenhum registro'}
                </div>
              </div>
              <div style={{textAlign:'right'}}>
                <div style={{font:`800 18px ${fontDisp}`, color: meal.kcal ? '#fff' : SF.fg3, fontVariantNumeric:'tabular-nums', letterSpacing:'-0.02em'}}>{meal.kcal||'—'}</div>
                <div style={{font:`600 9px ${fontBody}`, color:SF.fg3, letterSpacing:'.12em', textTransform:'uppercase'}}>kcal</div>
              </div>
            </div>

            {/* Meal items */}
            {meal.items.length > 0 && (
              <div style={{borderTop:`1px solid ${SF.border}`}}>
                {meal.items.map((item,i)=>(
                  <div key={i} style={{
                    display:'flex', alignItems:'center', gap:12, padding:'10px 14px',
                    borderTop: i>0 ? `1px solid ${SF.border}` : 'none',
                  }}>
                    <div style={{width:6,height:6,borderRadius:999, background:meal.color, flexShrink:0}}/>
                    <div style={{flex:1, minWidth:0}}>
                      <div style={{font:`500 13px ${fontBody}`, color:SF.fg1}}>{item.n}</div>
                      <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:1}}>{item.q}</div>
                    </div>
                    <div style={{font:`700 13px ${fontDisp}`, color:SF.fg2, fontVariantNumeric:'tabular-nums'}}>{item.kcal}<span style={{font:`500 10px ${fontBody}`, color:SF.fg3}}> kcal</span></div>
                  </div>
                ))}
              </div>
            )}

            {/* Add button */}
            <button style={{
              width:'100%', padding:'12px', background:'transparent', border:'none',
              borderTop:`1px solid ${SF.border}`,
              display:'flex', alignItems:'center', justifyContent:'center', gap:6,
              color:SF.orange, font:`700 12px ${fontBody}`, letterSpacing:'.06em', textTransform:'uppercase',
              cursor:'pointer',
            }}>
              <Icon name="add_circle" size={16} fill={1}/>
              Adicionar alimento
            </button>
          </div>
        ))}

        {/* Water tracker */}
        <div style={{
          background: 'linear-gradient(90deg, rgba(37,106,210,.15), rgba(37,106,210,.04))',
          border:`1px solid rgba(37,106,210,.3)`, borderRadius:14,
          padding:'14px', display:'flex', alignItems:'center', gap:12,
        }}>
          <div style={{width:40,height:40, borderRadius:12, background:gradSquad, display:'flex',alignItems:'center',justifyContent:'center'}}>
            <Icon name="water_drop" size={22} fill={1} color="#fff"/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`800 14px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Água · 1.8 / 2.5 L</div>
            <div style={{display:'flex', gap:3, marginTop:6}}>
              {[1,1,1,1,1,1,1,.5,0,0].map((f,i)=>(
                <div key={i} style={{flex:1, height:6, borderRadius:3, background: f>=1 ? SF.blue : f>0 ? SF.blueDark : SF.surface2}}/>
              ))}
            </div>
          </div>
          <button style={{width:36,height:36, borderRadius:10, background:'rgba(37,106,210,.2)', border:`1px solid rgba(37,106,210,.3)`, color:'#fff', cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center'}}>
            <Icon name="add" size={20} fill={1}/>
          </button>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 07 — SQUADS (Lista de squads)
// ═══════════════════════════════════════════════════════════════
function SquadsScreen(){
  const squads = [
    {
      id:1,
      name:'Família Fit',
      tag:'@familia-fit',
      members:8,
      grad:'linear-gradient(135deg,#FA8038,#FF3B8B)',
      challenge:{name:'Verão 2026', progress:62, daysLeft:18, leader:'Ueslei D.', myPos:2, of:8},
      initials:'FF',
      streak:12,
      avatars:['UD','JP','MA','CS','+4'],
      active:true,
    },
    {
      id:2,
      name:'Pernas de Aço',
      tag:'@pernas-aco',
      members:5,
      grad:'linear-gradient(135deg,#6366F1,#256AD2)',
      challenge:{name:'Leg day challenge', progress:34, daysLeft:41, leader:'Mariana A.', myPos:1, of:5},
      initials:'PA',
      streak:6,
      avatars:['MA','PH','CS','RL','+1'],
      active:true,
    },
    {
      id:3,
      name:'Corrida do parque',
      tag:'@corrida-parque',
      members:12,
      grad:'linear-gradient(135deg,#22C55E,#D6FF3B)',
      challenge:null,
      initials:'CP',
      streak:0,
      avatars:['TK','LB','GR','SE','+8'],
      active:false,
    },
  ];

  const SquadCard = ({s}) => (
    <div style={{
      background: s.active
        ? `linear-gradient(180deg, ${SF.surface2} 0%, ${SF.surface} 100%)`
        : SF.surface,
      border: s.active ? `1px solid rgba(255,255,255,.1)` : `1px solid ${SF.border}`,
      borderRadius:18,
      overflow:'hidden',
      boxShadow:`0 4px 12px rgba(0,0,0,.3), ${insetHi}`,
      cursor:'pointer',
      position:'relative',
    }}>
      {/* Header strip */}
      <div style={{
        height:72, background:s.grad, position:'relative', overflow:'hidden',
      }}>
        <div style={{position:'absolute', right:-30,top:-40, width:160,height:160, borderRadius:'50%', background:'rgba(255,255,255,.12)'}}/>
        <div style={{position:'absolute', left:-20,bottom:-30, width:100,height:100, borderRadius:'50%', background:'rgba(0,0,0,.15)'}}/>

        {/* Streak badge */}
        {s.streak > 0 && (
          <div style={{
            position:'absolute', top:12, right:12, display:'flex', alignItems:'center', gap:4,
            padding:'4px 10px', background:'rgba(0,0,0,.35)', backdropFilter:'blur(8px)',
            borderRadius:999, border:`1px solid rgba(255,255,255,.2)`,
          }}>
            <Icon name="local_fire_department" size={12} fill={1} color={SF.warning}/>
            <span style={{font:`800 11px ${fontDisp}`, color:'#fff', fontVariantNumeric:'tabular-nums'}}>{s.streak}</span>
          </div>
        )}
      </div>

      {/* Avatar overlap */}
      <div style={{padding:'0 14px', marginTop:-28, position:'relative'}}>
        <Avatar initials={s.initials} size={56} grad={s.grad} ring={s.active}/>
      </div>

      <div style={{padding:'10px 14px 14px'}}>
        <div style={{display:'flex', alignItems:'baseline', gap:8}}>
          <span style={{font:`900 20px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em'}}>{s.name}</span>
          {!s.active && <Chip color={SF.fg3} bg='rgba(255,255,255,.04)'>Pausado</Chip>}
        </div>
        <div style={{font:`500 12px ${fontBody}`, color:SF.fg3, marginTop:2}}>{s.tag} · {s.members} membros</div>

        {/* Member avatars stack */}
        <div style={{display:'flex', alignItems:'center', marginTop:12}}>
          {s.avatars.map((a,i)=>(
            <div key={i} style={{
              marginLeft: i===0 ? 0 : -8,
              zIndex: 10-i,
              borderRadius:999,
              border:`2px solid ${s.active ? SF.surface2 : SF.surface}`,
            }}>
              {a.startsWith('+') ? (
                <div style={{
                  width:28,height:28, borderRadius:999,
                  background:SF.surface3,
                  display:'flex',alignItems:'center',justifyContent:'center',
                  font:`800 10px ${fontDisp}`, color:SF.fg2,
                }}>{a}</div>
              ) : (
                <Avatar initials={a} size={28} grad={['linear-gradient(135deg,#FA8038,#FF3B8B)','linear-gradient(135deg,#6366F1,#256AD2)','linear-gradient(135deg,#22C55E,#D6FF3B)','linear-gradient(135deg,#F59E0B,#EF4444)'][i%4]}/>
              )}
            </div>
          ))}
        </div>

        {/* Active challenge block */}
        {s.challenge ? (
          <div style={{
            marginTop:14, padding:'12px 14px', borderRadius:14,
            background:'rgba(250,128,56,.08)',
            border:`1px solid rgba(250,128,56,.25)`,
          }}>
            <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:8}}>
              <div style={{display:'flex', alignItems:'center', gap:6}}>
                <Icon name="emoji_events" size={14} fill={1} color={SF.orange}/>
                <span style={{font:`700 12px ${fontBody}`, color:'#fff'}}>{s.challenge.name}</span>
              </div>
              <span style={{font:`600 10px ${fontBody}`, letterSpacing:'.1em', textTransform:'uppercase', color:SF.fg2}}>{s.challenge.daysLeft}d restantes</span>
            </div>

            {/* Progress bar */}
            <div style={{height:5, background:SF.surface3, borderRadius:999, overflow:'hidden'}}>
              <div style={{width:`${s.challenge.progress}%`, height:'100%', background:gradPrimary, borderRadius:999, boxShadow:glowOrange}}/>
            </div>

            <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginTop:8}}>
              <span style={{font:`500 11px ${fontBody}`, color:SF.fg2}}>
                Você: <span style={{font:`800 12px ${fontDisp}`, color: s.challenge.myPos===1 ? SF.lime : '#fff', fontVariantNumeric:'tabular-nums'}}>#{s.challenge.myPos}</span> de {s.challenge.of}
              </span>
              <span style={{font:`600 11px ${fontBody}`, color:SF.fg3}}>Líder: {s.challenge.leader}</span>
            </div>
          </div>
        ) : (
          <div style={{
            marginTop:14, padding:'10px 14px', borderRadius:12,
            border:`1px dashed ${SF.border}`, background:'rgba(255,255,255,.02)',
            display:'flex', alignItems:'center', justifyContent:'center', gap:6,
          }}>
            <Icon name="add_circle_outline" size={14} color={SF.fg2}/>
            <span style={{font:`600 12px ${fontBody}`, color:SF.fg2}}>Nenhum desafio ativo</span>
          </div>
        )}
      </div>
    </div>
  );

  return (
    <div>
      {/* Header */}
      <div style={{padding:'10px 16px 4px', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <div>
          <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.fg3}}>3 squads ativos</div>
          <div style={{font:`900 28px ${fontDisp}`, color:'#fff', letterSpacing:'-0.035em', marginTop:2}}>Seus squads</div>
        </div>
        <button style={{width:40,height:40, borderRadius:12, background:SF.surface, border:`1px solid ${SF.border}`, color:SF.fg1, cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', boxShadow:insetHi}}>
          <Icon name="search" size={20}/>
        </button>
      </div>

      <div style={{padding:'16px 16px 24px', display:'flex', flexDirection:'column', gap:14}}>

        {/* Quick actions */}
        <div style={{display:'flex', gap:10}}>
          <button style={{
            flex:1, padding:'14px 12px', borderRadius:16, cursor:'pointer',
            background: gradPrimary, border:'none',
            boxShadow:`${glowOrange}, ${insetHi}`,
            display:'flex', alignItems:'center', gap:10, textAlign:'left',
          }}>
            <div style={{width:40, height:40, borderRadius:12, background:'rgba(255,255,255,.18)', display:'flex', alignItems:'center', justifyContent:'center'}}>
              <Icon name="add" size={22} fill={1} weight={700} color="#fff"/>
            </div>
            <div style={{flex:1}}>
              <div style={{font:`800 13px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Criar squad</div>
              <div style={{font:`500 11px ${fontBody}`, color:'rgba(255,255,255,.8)', marginTop:1}}>Comece um novo</div>
            </div>
          </button>
          <button style={{
            flex:1, padding:'14px 12px', borderRadius:16, cursor:'pointer',
            background: SF.surface, border:`1px solid ${SF.border}`,
            boxShadow: insetHi,
            display:'flex', alignItems:'center', gap:10, textAlign:'left',
          }}>
            <div style={{width:40, height:40, borderRadius:12, background:'rgba(214,255,59,.12)', display:'flex', alignItems:'center', justifyContent:'center'}}>
              <Icon name="qr_code_2" size={22} fill={1} color={SF.lime}/>
            </div>
            <div style={{flex:1}}>
              <div style={{font:`800 13px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Entrar</div>
              <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:1}}>Com código</div>
            </div>
          </button>
        </div>

        {/* Suggested squad (highlight card) */}
        <div style={{
          padding:'12px 14px', borderRadius:14,
          background: 'linear-gradient(90deg, rgba(214,255,59,.1), rgba(34,197,94,.05))',
          border: `1px solid rgba(214,255,59,.25)`,
          display:'flex', alignItems:'center', gap:12,
        }}>
          <div style={{width:40, height:40, borderRadius:12, background:'rgba(214,255,59,.18)', display:'flex', alignItems:'center', justifyContent:'center'}}>
            <Icon name="auto_awesome" size={20} fill={1} color={SF.lime}/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`700 13px ${fontBody}`, color:'#fff'}}>Convite pendente</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:1}}>Ueslei D. te convidou pro "Cardio Crew"</div>
          </div>
          <button style={{padding:'6px 12px', borderRadius:999, background:SF.lime, border:'none', color:'#0B0D12', font:`800 11px ${fontBody}`, cursor:'pointer', letterSpacing:'.04em'}}>Aceitar</button>
        </div>

        <SectionHeader title="Meus squads"/>

        {/* Squad cards */}
        <div style={{display:'flex', flexDirection:'column', gap:14}}>
          {squads.map(s=><SquadCard key={s.id} s={s}/>)}
        </div>

        {/* Discover footer */}
        <div style={{
          marginTop:4, padding:'16px', borderRadius:14,
          background: SF.surface, border: `1px dashed ${SF.border}`,
          display:'flex', alignItems:'center', gap:12,
        }}>
          <div style={{width:40,height:40, borderRadius:12, background:SF.surface2, display:'flex',alignItems:'center',justifyContent:'center'}}>
            <Icon name="explore" size={22} color={SF.fg2}/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`700 13px ${fontBody}`, color:'#fff'}}>Descobrir squads</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:1}}>Encontre pessoas com objetivos parecidos</div>
          </div>
          <Icon name="chevron_right" size={22} color={SF.fg2}/>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {DiarioScreen, SquadsScreen});
