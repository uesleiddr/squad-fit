// Screens.jsx — Squad Fit redesign screens

// ═══════════════════════════════════════════════════════════════
// 01 — LOGIN
// ═══════════════════════════════════════════════════════════════
function LoginScreen({onLogin}){
  const [mode, setMode] = React.useState('login');
  const [email, setEmail] = React.useState('mariana@squadfit.app');
  const [pw, setPw] = React.useState('••••••••••');
  return (
    <div style={{
      minHeight:'100%', position:'relative', overflow:'hidden',
      background: `
        radial-gradient(ellipse 500px 400px at 20% 0%, rgba(250,128,56,.22), transparent 60%),
        radial-gradient(ellipse 600px 500px at 100% 40%, rgba(255,59,139,.15), transparent 60%),
        radial-gradient(ellipse 500px 400px at 0% 100%, rgba(37,106,210,.18), transparent 60%),
        #0B0D12
      `,
    }}>
      {/* noise overlay */}
      <div style={{position:'absolute', inset:0, opacity:.04, pointerEvents:'none',
        backgroundImage:`url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='120' height='120'><filter id='n'><feTurbulence baseFrequency='.9' seed='3'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>")`}}/>

      <div style={{padding:'40px 24px 24px', display:'flex', flexDirection:'column', gap:16, minHeight:'100%', position:'relative'}}>
        <div style={{display:'flex', justifyContent:'center', marginTop:20}}>
          <Logo width={220}/>
        </div>

        <div style={{textAlign:'center', marginTop:8, marginBottom:8}}>
          <div style={{font:`900 28px/1.1 ${fontDisp}`, color:'#fff', letterSpacing:'-0.035em'}}>
            Treino é melhor<br/>em <span style={{background:gradHype,WebkitBackgroundClip:'text',backgroundClip:'text',color:'transparent'}}>squad</span>.
          </div>
          <div style={{font:`500 13px ${fontBody}`, color: SF.fg2, marginTop:10, maxWidth:280, margin:'10px auto 0'}}>
            Desafie amigos, perca peso junto, comemore cada PR.
          </div>
        </div>

        <div style={{display:'flex',flexDirection:'column',gap:12, marginTop:8}}>
          <SFInput icon="mail" placeholder="seu@email.com" value={email} onChange={setEmail}/>
          <SFInput icon="lock" type="password" placeholder="Senha" value={pw} onChange={setPw}
            trailing={<Icon name="visibility" size={20} color={SF.fg2}/>}/>
          {mode==='login' && <div style={{textAlign:'right', marginTop:-4}}>
            <span style={{font:`600 13px ${fontBody}`, color: SF.orange, cursor:'pointer'}}>Esqueceu a senha?</span>
          </div>}
        </div>

        <SFButton variant="primary" size="lg" full onClick={onLogin} iconRight="arrow_forward">
          {mode==='login' ? 'Entrar no squad' : 'Criar conta'}
        </SFButton>

        <div style={{display:'flex',alignItems:'center',gap:10, color:SF.fg3, font:`500 11px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', marginTop:4}}>
          <div style={{flex:1,height:1,background:SF.border}}/>ou<div style={{flex:1,height:1,background:SF.border}}/>
        </div>

        <SFButton variant="secondary" size="lg" full>
          <svg width="18" height="18" viewBox="0 0 48 48" style={{flexShrink:0}}>
            <path fill="#FFC107" d="M43.6 20.1H42V20H24v8h11.3c-1.6 4.7-6.1 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.6-.4-3.9z"/>
            <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.6 15.1 18.9 12 24 12c3.1 0 5.8 1.2 7.9 3.1l5.7-5.7C34 6.1 29.3 4 24 4 16.3 4 9.6 8.3 6.3 14.7z"/>
            <path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35 26.7 36 24 36c-5.2 0-9.6-3.3-11.3-7.9l-6.5 5C9.5 39.6 16.2 44 24 44z"/>
            <path fill="#1976D2" d="M43.6 20.1H42V20H24v8h11.3c-.8 2.3-2.3 4.3-4.1 5.6l6.2 5.2C41.9 35.6 44 30.2 44 24c0-1.3-.1-2.6-.4-3.9z"/>
          </svg>
          Continuar com Google
        </SFButton>

        <div style={{textAlign:'center', marginTop:'auto', paddingTop:16, font:`500 13px ${fontBody}`, color:SF.fg2}}>
          {mode==='login' ? 'Novo por aqui? ' : 'Já tem conta? '}
          <span onClick={()=>setMode(mode==='login'?'signup':'login')} style={{color:SF.orange, fontWeight:700, cursor:'pointer'}}>
            {mode==='login' ? 'Cadastre-se' : 'Entrar'}
          </span>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 02 — HOME
// ═══════════════════════════════════════════════════════════════
function HomeScreen(){
  return (
    <div>
      <div style={{padding:'8px 16px 0', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <div style={{display:'flex', alignItems:'center', gap:12}}>
          <Avatar initials="MA" size={40} grad="linear-gradient(135deg,#FA8038,#FF3B8B)"/>
          <div>
            <div style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>Boa noite,</div>
            <div style={{font:`800 17px ${fontDisp}`, color:'#fff', letterSpacing:'-0.02em', marginTop:-1}}>Mariana</div>
          </div>
        </div>
        <div style={{display:'flex', gap:4}}>
          <button style={{width:40,height:40,borderRadius:12, background:SF.surface, border:`1px solid ${SF.border}`, color:SF.fg1, display:'flex',alignItems:'center',justifyContent:'center', cursor:'pointer', boxShadow:insetHi, position:'relative'}}>
            <Icon name="notifications" size={20} fill={1}/>
            <div style={{position:'absolute', top:7, right:7, width:8,height:8, borderRadius:999, background:SF.magenta, boxShadow:`0 0 8px ${SF.magenta}`}}/>
          </button>
        </div>
      </div>

      <div style={{padding:'16px 16px 100px', display:'flex',flexDirection:'column',gap:14}}>

        {/* Streak banner */}
        <div style={{
          background: 'linear-gradient(135deg,rgba(250,128,56,.22),rgba(255,59,139,.12))',
          border:'1px solid rgba(250,128,56,.3)', borderRadius:16,
          padding:'12px 14px', display:'flex', alignItems:'center', gap:12,
          boxShadow:`0 0 24px rgba(250,128,56,.15), ${insetHi}`,
        }}>
          <div style={{width:40,height:40,borderRadius:12, background:gradPrimary, display:'flex',alignItems:'center',justifyContent:'center', boxShadow:glowOrange}}>
            <Icon name="local_fire_department" size={22} fill={1} color="#fff"/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`800 14px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>12 dias em chamas 🔥</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:1}}>Treine hoje pra não quebrar a sequência</div>
          </div>
          <div style={{font:`900 28px ${fontDisp}`, color:SF.orange, letterSpacing:'-0.04em', fontVariantNumeric:'tabular-nums', textShadow:`0 0 20px rgba(250,128,56,.5)`}}>12</div>
        </div>

        {/* Hero: dual rings */}
        <div style={{
          background: `linear-gradient(160deg, ${SF.surface2} 0%, ${SF.surface} 100%)`,
          border: `1px solid ${SF.border}`, borderRadius: 20, padding: 18,
          boxShadow: `0 4px 12px rgba(0,0,0,.5), ${insetHi}`,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{position:'absolute', right:-60, top:-60, width:220, height:220,
            background:'radial-gradient(closest-side,rgba(250,128,56,.28),transparent 70%)', pointerEvents:'none'}}/>

          <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:12, position:'relative'}}>
            <span style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2}}>Hoje · 18 nov</span>
            <Chip icon="bolt" color={SF.lime} bg="rgba(214,255,59,.12)" border="1px solid rgba(214,255,59,.3)">Ativo</Chip>
          </div>

          <div style={{display:'flex', alignItems:'center', gap:16, position:'relative'}}>
            <ProgressRing value={72} size={130} label="Meta diária" bigLabel="72" unit="%" stroke={9}/>
            <div style={{flex:1, display:'flex', flexDirection:'column', gap:10}}>
              <div>
                <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', color:SF.fg2, marginBottom:2}}>Calorias</div>
                <div style={{display:'flex', alignItems:'baseline', gap:4}}>
                  <span style={{font:`900 26px ${fontDisp}`, color:'#fff', fontVariantNumeric:'tabular-nums', letterSpacing:'-0.04em'}}>1044</span>
                  <span style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>/ 1800</span>
                </div>
              </div>
              <div>
                <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.12em', textTransform:'uppercase', color:SF.fg2, marginBottom:2}}>Queimado</div>
                <div style={{display:'flex', alignItems:'baseline', gap:4}}>
                  <span style={{font:`900 26px ${fontDisp}`, color:SF.lime, fontVariantNumeric:'tabular-nums', letterSpacing:'-0.04em'}}>412</span>
                  <span style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>kcal</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick stats row */}
        <div style={{display:'flex', gap:10}}>
          <StatPill label="Peso" value="-2.3" unit="kg" icon="monitor_weight" accent={SF.lime}/>
          <StatPill label="Passos" value="8.4k" icon="directions_walk" accent={SF.blue}/>
          <StatPill label="Água" value="1.8" unit="L" icon="water_drop" accent="#5A8FE0"/>
        </div>

        {/* Next workout CTA */}
        <div style={{
          background: gradPrimary, borderRadius:18, padding:'16px 16px',
          boxShadow: `${glowOrange}, ${insetHi}`, position:'relative', overflow:'hidden',
          display:'flex', alignItems:'center', gap:14, cursor:'pointer',
        }}>
          <div style={{position:'absolute', right:-30,top:-40, width:140,height:140, borderRadius:'50%', background:'rgba(255,255,255,.1)'}}/>
          <div style={{position:'absolute', right:20,bottom:-30, width:100,height:100, borderRadius:'50%', background:'rgba(255,255,255,.06)'}}/>
          <div style={{width:52, height:52, borderRadius:14, background:'rgba(0,0,0,.18)', backdropFilter:'blur(4px)', display:'flex',alignItems:'center',justifyContent:'center', position:'relative'}}>
            <Icon name="fitness_center" size={26} fill={1} color="#fff"/>
          </div>
          <div style={{flex:1, position:'relative'}}>
            <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:'rgba(255,255,255,.85)'}}>Próximo treino</div>
            <div style={{font:`800 18px ${fontDisp}`, color:'#fff', letterSpacing:'-0.02em', marginTop:2}}>Peito & Tríceps</div>
            <div style={{font:`500 12px ${fontBody}`, color:'rgba(255,255,255,.85)', marginTop:2}}>8 exercícios · ~45 min</div>
          </div>
          <div style={{width:40, height:40, borderRadius:999, background:'#fff', display:'flex',alignItems:'center',justifyContent:'center', position:'relative'}}>
            <Icon name="play_arrow" size={24} fill={1} color={SF.orange}/>
          </div>
        </div>

        {/* Ranking preview */}
        <SectionHeader title="Ranking do squad" action="Ver tudo"/>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          <RankingRow pos={1} name="Ueslei D." initials="UD" delta="-3.8kg" sub="Líder há 4 dias" avatarGrad="linear-gradient(135deg,#FFD166,#FA8038)"/>
          <RankingRow pos={2} name="Mariana A." initials="MA" delta="-2.3kg" sub="Subiu 1 posição" isMe/>
          <RankingRow pos={3} name="João P." initials="JP" delta="-1.9kg" sub="Último: 2h atrás" avatarGrad="linear-gradient(135deg,#6366F1,#1A4FA0)"/>
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 03 — TREINO ATIVO (Active Workout)
// ═══════════════════════════════════════════════════════════════
function TreinoAtivoScreen(){
  const [setsDone, setSetsDone] = React.useState(2);
  const totalSets = 4;
  const exercises = [
    {n:'Supino reto', sets:'4 × 10', status:'done'},
    {n:'Supino inclinado', sets:'3 × 12', status:'current', reps:'60kg × 10'},
    {n:'Crossover', sets:'3 × 15', status:'next'},
    {n:'Tríceps corda', sets:'4 × 12', status:'next'},
    {n:'Tríceps francês', sets:'3 × 12', status:'next'},
  ];
  return (
    <div style={{background:SF.bg, minHeight:'100%'}}>
      {/* Header with timer */}
      <div style={{
        padding:'8px 16px 16px',
        background: `linear-gradient(180deg, rgba(250,128,56,.18), rgba(250,128,56,0) 80%), ${SF.bg}`,
        position:'relative',
      }}>
        <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 0'}}>
          <button style={{width:40,height:40,borderRadius:12, background:'rgba(0,0,0,.3)', border:`1px solid ${SF.border}`, color:SF.fg, display:'flex',alignItems:'center',justifyContent:'center', backdropFilter:'blur(10px)', cursor:'pointer'}}>
            <Icon name="close" size={22}/>
          </button>
          <Chip icon="circle" color={SF.lime} bg="rgba(214,255,59,.15)" border="1px solid rgba(214,255,59,.35)" glow={glowLime}>Ao vivo</Chip>
          <button style={{width:40,height:40,borderRadius:12, background:'rgba(0,0,0,.3)', border:`1px solid ${SF.border}`, color:SF.fg, display:'flex',alignItems:'center',justifyContent:'center', cursor:'pointer'}}>
            <Icon name="more_horiz" size={22}/>
          </button>
        </div>

        <div style={{display:'flex', alignItems:'flex-end', justifyContent:'space-between', marginTop:18}}>
          <div>
            <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.16em', textTransform:'uppercase', color:SF.orange}}>Treino A · Peito & Tríceps</div>
            <div style={{font:`900 54px/0.95 ${fontDisp}`, color:'#fff', letterSpacing:'-0.045em', fontVariantNumeric:'tabular-nums', marginTop:6}}>
              24:38
            </div>
            <div style={{font:`500 13px ${fontBody}`, color:SF.fg2, marginTop:4}}>Exercício 2 de 5 · 48% completo</div>
          </div>
          <div style={{display:'flex', flexDirection:'column', alignItems:'flex-end', gap:6}}>
            <div style={{font:`800 20px ${fontDisp}`, color:SF.lime, letterSpacing:'-0.03em', fontVariantNumeric:'tabular-nums'}}>186</div>
            <div style={{font:`600 10px ${fontBody}`, color:SF.fg2, letterSpacing:'.12em', textTransform:'uppercase'}}>kcal</div>
          </div>
        </div>

        {/* Progress segments */}
        <div style={{display:'flex', gap:4, marginTop:16}}>
          {[1,1,0.5,0,0].map((f,i)=>(
            <div key={i} style={{flex:1, height:5, borderRadius:999, background:SF.surface2, overflow:'hidden'}}>
              <div style={{width:`${f*100}%`, height:'100%', background: i<2 ? gradPrimary : (i===2 ? SF.orange : 'transparent'), boxShadow: f>0 ? glowOrange : 'none', transition:'width 400ms'}}/>
            </div>
          ))}
        </div>
      </div>

      {/* Current exercise card — the hero */}
      <div style={{padding:'4px 16px 0'}}>
        <div style={{
          background: SF.surface2, border:`1px solid rgba(250,128,56,.3)`, borderRadius:20,
          padding:18, boxShadow:`0 8px 24px rgba(0,0,0,.4), 0 0 0 1px rgba(250,128,56,.15), ${insetHi}`,
          position:'relative', overflow:'hidden',
        }}>
          <div style={{position:'absolute',right:-40,top:-40, width:180,height:180, background:'radial-gradient(closest-side, rgba(250,128,56,.22), transparent)', pointerEvents:'none'}}/>
          <div style={{display:'flex', justifyContent:'space-between', alignItems:'flex-start', position:'relative'}}>
            <div>
              <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.orange}}>Agora</div>
              <div style={{font:`800 22px ${fontDisp}`, color:'#fff', letterSpacing:'-0.02em', marginTop:4}}>Supino inclinado</div>
              <div style={{font:`500 12px ${fontBody}`, color:SF.fg2, marginTop:2}}>60kg · tempo 2-0-2</div>
            </div>
            <button style={{width:44,height:44, borderRadius:14, background:SF.surface3, border:`1px solid ${SF.border}`, color:SF.fg, cursor:'pointer', display:'flex',alignItems:'center',justifyContent:'center'}}>
              <Icon name="info" size={20}/>
            </button>
          </div>

          {/* Sets grid */}
          <div style={{display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:8, marginTop:16, position:'relative'}}>
            {[0,1,2,3].map(i=>{
              const done = i<setsDone, cur = i===setsDone;
              return (
                <div key={i} style={{
                  aspectRatio:'1', borderRadius:14,
                  background: done ? gradPrimary : cur ? 'rgba(250,128,56,.1)' : SF.surface,
                  border: done ? 'none' : cur ? `1.5px solid ${SF.orange}` : `1px solid ${SF.border}`,
                  display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:2,
                  boxShadow: done ? glowOrange : insetHi,
                }}>
                  <div style={{font:`900 22px ${fontDisp}`, color: done ? '#fff' : cur ? SF.orange : SF.fg3, letterSpacing:'-0.03em', fontVariantNumeric:'tabular-nums'}}>
                    {done ? '10' : cur ? '10' : '—'}
                  </div>
                  <div style={{font:`700 9px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color: done ? 'rgba(255,255,255,.85)' : cur ? SF.orange : SF.fg3}}>
                    Set {i+1}
                  </div>
                </div>
              );
            })}
          </div>

          {/* Controls */}
          <div style={{display:'flex', gap:10, marginTop:16, position:'relative'}}>
            <SFButton variant="secondary" size="md" icon="remove" style={{width:52, padding:0}} glow={false}/>
            <SFButton variant="primary" size="md" full onClick={()=>setSetsDone(Math.min(totalSets, setsDone+1))} icon="check">
              Completar série
            </SFButton>
            <SFButton variant="secondary" size="md" icon="add" style={{width:52, padding:0}} glow={false}/>
          </div>
        </div>
      </div>

      {/* Rest timer / next up */}
      <div style={{padding:'14px 16px 0'}}>
        <div style={{
          background: 'linear-gradient(90deg, rgba(37,106,210,.18), rgba(37,106,210,.05))',
          border:`1px solid rgba(37,106,210,.3)`, borderRadius:14,
          padding:'12px 14px', display:'flex', alignItems:'center', gap:12,
        }}>
          <div style={{width:40,height:40, borderRadius:12, background:gradSquad, display:'flex',alignItems:'center',justifyContent:'center', boxShadow:'0 0 18px rgba(37,106,210,.4)'}}>
            <Icon name="timer" size={22} fill={1} color="#fff"/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`800 14px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Descanso · 1:30</div>
            <div style={{font:`500 12px ${fontBody}`, color:SF.fg2, marginTop:1}}>Prepare o próximo set</div>
          </div>
          <button style={{padding:'8px 14px', borderRadius:10, background:'rgba(255,255,255,.08)', border:`1px solid ${SF.border}`, color:SF.fg, font:`700 12px ${fontBody}`, letterSpacing:'.06em', textTransform:'uppercase', cursor:'pointer'}}>Pular</button>
        </div>
      </div>

      {/* Upcoming list */}
      <div style={{padding:'18px 16px 120px'}}>
        <SectionHeader title="A seguir"/>
        <div style={{display:'flex', flexDirection:'column', gap:8, marginTop:14}}>
          {exercises.map((ex,i)=>{
            const done = ex.status==='done', cur = ex.status==='current';
            return (
              <div key={i} style={{
                display:'flex', alignItems:'center', gap:12, padding:'12px 14px',
                background: cur ? 'rgba(250,128,56,.08)' : SF.surface,
                border: `1px solid ${cur ? 'rgba(250,128,56,.35)' : SF.border}`,
                borderRadius:14, boxShadow: insetHi, opacity: done ? 0.5 : 1,
              }}>
                <div style={{
                  width:32,height:32, borderRadius:10, flexShrink:0,
                  background: done ? SF.success : cur ? gradPrimary : SF.surface2,
                  border: done || cur ? 'none' : `1px solid ${SF.border}`,
                  display:'flex',alignItems:'center',justifyContent:'center',
                  boxShadow: cur ? glowOrange : 'none',
                }}>
                  {done ? <Icon name="check" size={18} fill={1} color="#fff" weight={700}/>
                    : cur ? <Icon name="fitness_center" size={16} fill={1} color="#fff"/>
                    : <span style={{font:`800 13px ${fontDisp}`, color:SF.fg3, fontVariantNumeric:'tabular-nums'}}>{i+1}</span>}
                </div>
                <div style={{flex:1}}>
                  <div style={{font:`600 14px ${fontBody}`, color: done ? SF.fg2 : SF.fg1, textDecoration: done ? 'line-through' : 'none'}}>{ex.n}</div>
                  <div style={{font:`500 11px ${fontBody}`, color:SF.fg3, marginTop:2}}>{ex.sets}</div>
                </div>
                {cur && <Chip color={SF.orange} bg="rgba(250,128,56,.12)" border="1px solid rgba(250,128,56,.3)">Agora</Chip>}
                {!cur && !done && <Icon name="chevron_right" size={18} color={SF.fg3}/>}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 04 — PERFIL
// ═══════════════════════════════════════════════════════════════
function PerfilScreen(){
  const badges = [
    {icon:'local_fire_department', label:'Em chamas', color:SF.orange, earned:true},
    {icon:'bolt', label:'PR master', color:SF.lime, earned:true},
    {icon:'groups', label:'Squad pro', color:SF.magenta, earned:true},
    {icon:'workspace_premium', label:'Campeão', color:'#FFD166', earned:false},
    {icon:'diamond', label:'Elite', color:'#7BA6E8', earned:false},
    {icon:'rocket_launch', label:'Foguete', color:SF.orange, earned:false},
  ];
  return (
    <div>
      {/* Hero / cover */}
      <div style={{
        padding:'8px 16px 0', position:'relative',
        background: `
          radial-gradient(ellipse 400px 300px at 50% 0%, rgba(250,128,56,.3), transparent 70%),
          linear-gradient(180deg, rgba(255,59,139,.08), transparent 60%)
        `,
      }}>
        <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 0'}}>
          <Icon name="arrow_back" size={24} color={SF.fg}/>
          <div style={{font:`700 16px ${fontDisp}`, color:'#fff'}}>Perfil</div>
          <Icon name="settings" size={22} color={SF.fg1}/>
        </div>

        <div style={{display:'flex', flexDirection:'column', alignItems:'center', padding:'18px 0 8px'}}>
          <Avatar initials="MA" size={96} grad="linear-gradient(135deg,#FA8038,#FF3B8B)" ring/>
          <div style={{font:`900 26px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:16}}>Mariana Alves</div>
          <div style={{font:`500 13px ${fontBody}`, color:SF.fg2, marginTop:2}}>@mari.alves · desde mar/2025</div>
          <div style={{display:'flex', gap:8, marginTop:14, flexWrap:'wrap', justifyContent:'center'}}>
            <Chip icon="local_fire_department" color={SF.orange} bg="rgba(250,128,56,.12)" border="1px solid rgba(250,128,56,.3)">12 dias</Chip>
            <Chip icon="military_tech" color={SF.lime} bg="rgba(214,255,59,.1)" border="1px solid rgba(214,255,59,.3)">Nível 7</Chip>
            <Chip icon="groups" color="#7BA6E8" bg="rgba(37,106,210,.12)" border="1px solid rgba(37,106,210,.3)">3 squads</Chip>
          </div>
        </div>
      </div>

      <div style={{padding:'16px 16px 100px', display:'flex', flexDirection:'column', gap:16}}>
        {/* XP bar */}
        <div style={{
          background:SF.surface, border:`1px solid ${SF.border}`, borderRadius:16, padding:14, boxShadow:insetHi,
        }}>
          <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom:10}}>
            <div>
              <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2}}>Nível 7 · Intermediária</div>
              <div style={{font:`800 16px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em', marginTop:2}}>2.840 <span style={{color:SF.fg2, fontWeight:500}}>/ 3.500 XP</span></div>
            </div>
            <div style={{font:`800 14px ${fontDisp}`, color:SF.orange, fontVariantNumeric:'tabular-nums'}}>660 XP p/ nível 8</div>
          </div>
          <div style={{height:8, background:SF.surface2, borderRadius:999, overflow:'hidden'}}>
            <div style={{width:'81%', height:'100%', background:gradHype, borderRadius:999, boxShadow:glowOrange}}/>
          </div>
        </div>

        {/* Stats grid */}
        <div style={{
          display:'grid', gridTemplateColumns:'1fr 1fr', gap:10,
        }}>
          <StatPill label="Peso perdido" value="-4.8" unit="kg" icon="trending_down" accent={SF.lime}/>
          <StatPill label="Treinos" value="87" icon="fitness_center" accent={SF.orange}/>
          <StatPill label="Sequência" value="12" unit="dias" icon="local_fire_department" accent={SF.magenta}/>
          <StatPill label="Vitórias" value="3" icon="emoji_events" accent="#FFD166"/>
        </div>

        {/* Weight chart */}
        <div style={{
          background:SF.surface, border:`1px solid ${SF.border}`, borderRadius:16, padding:16, boxShadow:insetHi,
        }}>
          <div style={{display:'flex', justifyContent:'space-between', alignItems:'baseline', marginBottom:14}}>
            <div>
              <div style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2}}>Evolução · 30 dias</div>
              <div style={{display:'flex', alignItems:'baseline', gap:6, marginTop:4}}>
                <span style={{font:`900 28px ${fontDisp}`, color:'#fff', letterSpacing:'-0.035em', fontVariantNumeric:'tabular-nums'}}>62.4</span>
                <span style={{font:`500 13px ${fontBody}`, color:SF.fg2}}>kg</span>
                <Chip color={SF.lime} bg="rgba(214,255,59,.1)" border="1px solid rgba(214,255,59,.25)">-2.3</Chip>
              </div>
            </div>
          </div>
          {/* Mini chart */}
          <svg viewBox="0 0 300 90" style={{width:'100%', height:90, display:'block'}}>
            <defs>
              <linearGradient id="wChart" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stopColor="#FA8038" stopOpacity=".35"/>
                <stop offset="1" stopColor="#FA8038" stopOpacity="0"/>
              </linearGradient>
            </defs>
            <path d="M0,30 C30,25 50,40 80,50 C110,58 140,55 170,65 C200,72 230,75 260,78 L300,80 L300,90 L0,90 Z" fill="url(#wChart)"/>
            <path d="M0,30 C30,25 50,40 80,50 C110,58 140,55 170,65 C200,72 230,75 260,78 L300,80" stroke="#FA8038" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
            <circle cx="300" cy="80" r="5" fill="#FA8038"/>
            <circle cx="300" cy="80" r="10" fill="#FA8038" opacity=".25"/>
          </svg>
          <div style={{display:'flex', justifyContent:'space-between', marginTop:6, font:`500 10px ${fontBody}`, color:SF.fg3, letterSpacing:'.08em'}}>
            <span>out 19</span><span>nov 3</span><span>nov 18</span>
          </div>
        </div>

        {/* Badges */}
        <SectionHeader title="Conquistas" action="3 de 12"/>
        <div style={{display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap:10}}>
          {badges.map((b,i)=>(
            <div key={i} style={{
              background: b.earned ? SF.surface : 'transparent',
              border: `1px solid ${b.earned ? SF.border : SF.border}`,
              borderRadius:14, padding:'14px 10px',
              display:'flex', flexDirection:'column', alignItems:'center', gap:8,
              opacity: b.earned ? 1 : 0.4, boxShadow: b.earned ? insetHi : 'none',
              borderStyle: b.earned ? 'solid' : 'dashed',
            }}>
              <div style={{
                width:44, height:44, borderRadius:12,
                background: b.earned ? `linear-gradient(135deg, ${b.color}, ${b.color}88)` : SF.surface2,
                display:'flex',alignItems:'center',justifyContent:'center',
                boxShadow: b.earned ? `0 0 20px ${b.color}44` : 'none',
              }}>
                <Icon name={b.earned ? b.icon : 'lock'} size={22} fill={1} color={b.earned ? (b.color===SF.lime ? '#0B0D12' : '#fff') : SF.fg3}/>
              </div>
              <div style={{font:`700 11px ${fontBody}`, color: b.earned ? SF.fg1 : SF.fg3, textAlign:'center', letterSpacing:'.02em'}}>{b.label}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// 05 — RANKING DO SQUAD
// ═══════════════════════════════════════════════════════════════
function RankingScreen(){
  const [tab, setTab] = React.useState('peso');
  const others = [
    {pos:4, name:'Carol S.', initials:'CS', delta:'-1.2kg', sub:'Treinou há 1h', grad:'linear-gradient(135deg,#FF3B8B,#E06820)'},
    {pos:5, name:'Pedro H.', initials:'PH', delta:'-0.6kg', sub:'Treinou há 3h', grad:'linear-gradient(135deg,#22C55E,#1A4FA0)'},
    {pos:6, name:'Lucas F.', initials:'LF', delta:'-0.3kg', sub:'Treinou ontem', grad:'linear-gradient(135deg,#6366F1,#FF3B8B)'},
    {pos:7, name:'Bia R.', initials:'BR', delta:'+0.1kg', sub:'3 dias sem log', grad:'linear-gradient(135deg,#9CA3AF,#4B5563)'},
  ];
  return (
    <div>
      {/* Header with desafio */}
      <div style={{
        padding:'8px 16px 18px', position:'relative',
        background: `
          radial-gradient(ellipse 500px 300px at 50% 0%, rgba(255,59,139,.18), transparent 70%),
          ${SF.bg}
        `,
      }}>
        <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', padding:'4px 0 12px'}}>
          <Icon name="arrow_back" size={24} color={SF.fg}/>
          <Chip icon="share" color={SF.fg1} bg="rgba(255,255,255,.06)">Convidar</Chip>
        </div>

        {/* Desafio hero */}
        <div style={{
          background: gradPrimary, borderRadius:20, padding:'18px 16px',
          boxShadow: `${glowOrange}, ${insetHi}`, position:'relative', overflow:'hidden',
        }}>
          <div style={{position:'absolute', right:-40,top:-40, width:180,height:180, borderRadius:'50%',background:'rgba(255,255,255,.1)'}}/>
          <div style={{position:'absolute', left:-20,bottom:-40, width:120,height:120, borderRadius:'50%',background:'rgba(255,255,255,.06)'}}/>

          <div style={{display:'flex', justifyContent:'space-between', alignItems:'flex-start', position:'relative'}}>
            <div>
              <Chip icon="circle" color="#fff" bg="rgba(0,0,0,.25)" border="1px solid rgba(255,255,255,.2)" glow={glowLime}>Ao vivo</Chip>
              <div style={{font:`900 26px ${fontDisp}`, color:'#fff', letterSpacing:'-0.03em', marginTop:10}}>Verão 2026</div>
              <div style={{font:`500 12px ${fontBody}`, color:'rgba(255,255,255,.85)', marginTop:2}}>7 participantes · faltam 23 dias</div>
            </div>
            <div style={{textAlign:'right'}}>
              <div style={{font:`900 36px ${fontDisp}`, color:'#fff', letterSpacing:'-0.04em', fontVariantNumeric:'tabular-nums'}}>#2</div>
              <div style={{font:`700 10px ${fontBody}`, color:'rgba(255,255,255,.85)', letterSpacing:'.14em', textTransform:'uppercase'}}>sua posição</div>
            </div>
          </div>
        </div>
      </div>

      {/* Podium */}
      <div style={{padding:'0 16px', marginTop:-8}}>
        <div style={{
          display:'flex', alignItems:'flex-end', justifyContent:'center', gap:10,
          padding:'20px 8px 20px', background:SF.surface, borderRadius:20,
          border:`1px solid ${SF.border}`, boxShadow:insetHi, position:'relative', overflow:'hidden',
        }}>
          <div style={{position:'absolute', inset:0, background:'radial-gradient(ellipse at top, rgba(255,209,102,.12), transparent 60%)', pointerEvents:'none'}}/>

          {/* 2nd */}
          <div style={{display:'flex', flexDirection:'column', alignItems:'center', gap:8, flex:1, position:'relative'}}>
            <Avatar initials="MA" size={58} grad="linear-gradient(135deg,#FA8038,#FF3B8B)" ring/>
            <div style={{font:`700 13px ${fontBody}`, color:SF.fg1}}>Mariana</div>
            <div style={{font:`800 16px ${fontDisp}`, color:SF.lime, letterSpacing:'-0.02em', fontVariantNumeric:'tabular-nums'}}>-2.3kg</div>
            <div style={{
              height:52, width:'100%', borderRadius:'12px 12px 0 0', marginTop:4,
              background:`linear-gradient(180deg, #D9D9E0, #9CA3AF)`,
              display:'flex',alignItems:'center',justifyContent:'center',
              font:`900 26px ${fontDisp}`, color:'#0B0D12', letterSpacing:'-0.03em',
              boxShadow: insetHi,
            }}>2</div>
          </div>
          {/* 1st */}
          <div style={{display:'flex', flexDirection:'column', alignItems:'center', gap:8, flex:1, position:'relative'}}>
            <Icon name="workspace_premium" size={24} fill={1} color="#FFD166" style={{marginBottom:-2, filter:'drop-shadow(0 0 8px #FFD16688)'}}/>
            <Avatar initials="UD" size={68} grad="linear-gradient(135deg,#FFD166,#FA8038)" ring/>
            <div style={{font:`800 14px ${fontBody}`, color:'#fff'}}>Ueslei</div>
            <div style={{font:`800 18px ${fontDisp}`, color:SF.lime, letterSpacing:'-0.02em', fontVariantNumeric:'tabular-nums'}}>-3.8kg</div>
            <div style={{
              height:74, width:'100%', borderRadius:'14px 14px 0 0', marginTop:4,
              background: `linear-gradient(180deg, #FFD166, #FA8038)`,
              display:'flex',alignItems:'center',justifyContent:'center',
              font:`900 34px ${fontDisp}`, color:'#0B0D12', letterSpacing:'-0.03em',
              boxShadow: `0 -4px 20px rgba(255,209,102,.4), ${insetHi}`,
            }}>1</div>
          </div>
          {/* 3rd */}
          <div style={{display:'flex', flexDirection:'column', alignItems:'center', gap:8, flex:1, position:'relative'}}>
            <Avatar initials="JP" size={54} grad="linear-gradient(135deg,#6366F1,#1A4FA0)"/>
            <div style={{font:`700 13px ${fontBody}`, color:SF.fg1}}>João</div>
            <div style={{font:`800 16px ${fontDisp}`, color:SF.lime, letterSpacing:'-0.02em', fontVariantNumeric:'tabular-nums'}}>-1.9kg</div>
            <div style={{
              height:40, width:'100%', borderRadius:'12px 12px 0 0', marginTop:4,
              background:`linear-gradient(180deg, #E09460, #A4603F)`,
              display:'flex',alignItems:'center',justifyContent:'center',
              font:`900 22px ${fontDisp}`, color:'#0B0D12', letterSpacing:'-0.03em',
              boxShadow: insetHi,
            }}>3</div>
          </div>
        </div>
      </div>

      <div style={{padding:'16px 16px 100px', display:'flex', flexDirection:'column', gap:12}}>
        {/* Tabs */}
        <div style={{
          display:'flex', gap:4, padding:4, background:SF.surface, borderRadius:12,
          border:`1px solid ${SF.border}`, boxShadow:insetHi,
        }}>
          {[{id:'peso',l:'Peso'},{id:'xp',l:'XP'},{id:'treinos',l:'Treinos'}].map(t=>{
            const on = tab===t.id;
            return (
              <button key={t.id} onClick={()=>setTab(t.id)} style={{
                flex:1, height:38, border:'none', borderRadius:9,
                background: on ? gradPrimary : 'transparent',
                color: on ? '#fff' : SF.fg2,
                font:`700 13px ${fontBody}`, cursor:'pointer', letterSpacing:'.01em',
                boxShadow: on ? `${glowOrange}, ${insetHi}` : 'none',
                transition:'all 180ms',
              }}>{t.l}</button>
            );
          })}
        </div>

        {/* Full ranking list */}
        <SectionHeader title="Classificação"/>
        <div style={{display:'flex', flexDirection:'column', gap:8}}>
          <RankingRow pos={1} name="Ueslei D." initials="UD" delta="-3.8kg" sub="Líder há 4 dias · 12 treinos" avatarGrad="linear-gradient(135deg,#FFD166,#FA8038)" trend={null}/>
          <RankingRow pos={2} name="Mariana A." initials="MA" delta="-2.3kg" sub="Subiu 1 posição · 9 treinos" isMe trend={null}/>
          <RankingRow pos={3} name="João P." initials="JP" delta="-1.9kg" sub="Últ. treino: 2h · 11 treinos" avatarGrad="linear-gradient(135deg,#6366F1,#1A4FA0)" trend={null}/>
          {others.map(o=>(
            <RankingRow key={o.pos} pos={o.pos} name={o.name} initials={o.initials} delta={o.delta} sub={o.sub} avatarGrad={o.grad} trend={null}/>
          ))}
        </div>

        {/* Motivational footer */}
        <div style={{
          marginTop:4, padding:'14px 16px', borderRadius:14,
          background:'linear-gradient(90deg, rgba(214,255,59,.1), rgba(34,197,94,.05))',
          border:'1px solid rgba(214,255,59,.25)',
          display:'flex', alignItems:'center', gap:12,
        }}>
          <div style={{width:40,height:40, borderRadius:12, background:gradVictory, display:'flex',alignItems:'center',justifyContent:'center', boxShadow:glowLime}}>
            <Icon name="flag" size={22} fill={1} color="#0B0D12"/>
          </div>
          <div style={{flex:1}}>
            <div style={{font:`800 13px ${fontDisp}`, color:'#fff', letterSpacing:'-0.01em'}}>Faltam 1.5kg pro #1</div>
            <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:1}}>Você consegue até o fim do desafio</div>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {LoginScreen, HomeScreen, TreinoAtivoScreen, PerfilScreen, RankingScreen});
