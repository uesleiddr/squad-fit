// Components.jsx — Squad Fit premium primitives (redesign)

const SF = {
  bg: '#0B0D12', bgElev: '#111214',
  surface: '#1A1C22', surface2: '#22252D', surface3: '#2D3039',
  border: '#2A2D35', borderStrong: '#4B5563',
  fg: '#fff', fg1: '#F5F6F8', fg2: '#9CA3AF', fg3: '#6B7280',
  orange: '#FA8038', orangeDark: '#E06820', orangeLight: '#FFAB6B',
  blue: '#256AD2', blueDark: '#1A4FA0',
  lime: '#D6FF3B', magenta: '#FF3B8B',
  success: '#22C55E', error: '#EF4444', warning: '#F59E0B',
};
const gradPrimary = 'linear-gradient(135deg,#FA8038 0%,#E06820 100%)';
const gradHype = 'linear-gradient(135deg,#FF3B8B 0%,#FA8038 60%,#D6FF3B 100%)';
const gradVictory = 'linear-gradient(135deg,#D6FF3B 0%,#22C55E 100%)';
const gradSquad = 'linear-gradient(135deg,#256AD2 0%,#1A4FA0 100%)';
const glowOrange = '0 0 24px rgba(250,128,56,.45), 0 0 1px rgba(250,128,56,.9)';
const glowLime = '0 0 24px rgba(214,255,59,.45)';
const glowMagenta = '0 0 24px rgba(255,59,139,.4)';
const insetHi = 'inset 0 1px 0 rgba(255,255,255,.06)';

const fontBody = '"Inter", system-ui, sans-serif';
const fontDisp = '"Space Grotesk", "Inter", system-ui, sans-serif';
const fontMono = '"JetBrains Mono", ui-monospace, monospace';

// ─── Icon ─────────────────────────────
function Icon({name, size=22, fill=0, color, weight=500, style={}}){
  return <span className="material-symbols-rounded" style={{
    fontSize: size, color: color || 'inherit',
    fontVariationSettings: `"FILL" ${fill}, "wght" ${weight}, "GRAD" 0, "opsz" 24`,
    lineHeight: 1, userSelect:'none', ...style,
  }}>{name}</span>;
}

// ─── Button ─────────────────────────────
function SFButton({variant='primary', size='md', icon, iconRight, children, onClick, style={}, full=false, glow=true}){
  const [pressed, setPressed] = React.useState(false);
  const sizes = {
    sm: {h: 36, px: 14, fs: 13, r: 10},
    md: {h: 48, px: 20, fs: 15, r: 12},
    lg: {h: 56, px: 24, fs: 16, r: 14},
  }[size];
  const variants = {
    primary: {background: gradPrimary, color: '#fff', boxShadow: glow ? `${glowOrange}, ${insetHi}` : insetHi, border: 'none'},
    secondary: {background: SF.surface2, color: SF.fg, border: `1px solid ${SF.border}`, boxShadow: insetHi},
    outline: {background: 'transparent', color: SF.orange, border: `1.5px solid ${SF.orange}`},
    ghost: {background: 'transparent', color: SF.fg1, border: 'none'},
    destructive: {background: 'rgba(239,68,68,.12)', color: SF.error, border: '1px solid rgba(239,68,68,.3)'},
    victory: {background: gradVictory, color: '#0B0D12', boxShadow: `${glowLime}, ${insetHi}`, border: 'none'},
    dark: {background: '#000', color: '#fff', border: `1px solid ${SF.border}`, boxShadow: insetHi},
  }[variant];
  return (
    <button onMouseDown={()=>setPressed(true)} onMouseUp={()=>setPressed(false)}
      onMouseLeave={()=>setPressed(false)} onClick={onClick}
      style={{
        height: sizes.h, padding: `0 ${sizes.px}px`, borderRadius: sizes.r,
        font: `600 ${sizes.fs}px ${fontBody}`, letterSpacing: '.01em',
        display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
        cursor: 'pointer', width: full ? '100%' : 'auto',
        transition: 'transform 120ms cubic-bezier(.2,.8,.2,1)',
        transform: pressed ? 'scale(.96)' : 'scale(1)',
        ...variants, ...style,
      }}>
      {icon && <Icon name={icon} size={sizes.fs + 5} fill={1}/>}
      {children}
      {iconRight && <Icon name={iconRight} size={sizes.fs + 5} fill={1}/>}
    </button>
  );
}

// ─── Top app bar ─────────────────────────────
function SFAppBar({title, leading='menu', trailing, onLeading, showLogo=false, transparent=false, subtitle}){
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 8, padding: '4px 8px',
      background: transparent ? 'transparent' : SF.bg, position: 'relative', zIndex: 2,
    }}>
      <button onClick={onLeading} style={{
        width: 44, height: 44, borderRadius: 12, border: 'none', background: 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center', color: SF.fg, cursor: 'pointer',
      }}><Icon name={leading} size={24}/></button>
      <div style={{flex:1, textAlign:'center', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center'}}>
        {showLogo ? <Logo width={110}/> : <>
          <div style={{font:`700 17px ${fontDisp}`, color: SF.fg, letterSpacing:'-0.01em'}}>{title}</div>
          {subtitle && <div style={{font:`500 11px ${fontBody}`, color:SF.fg2, marginTop:1}}>{subtitle}</div>}
        </>}
      </div>
      <div style={{width: 44, height: 44, display:'flex',alignItems:'center',justifyContent:'center',color:SF.fg1}}>{trailing}</div>
    </div>
  );
}

// ─── Text field ─────────────────────────────
function SFInput({icon, placeholder, type='text', value, onChange, error, trailing, label}){
  const [focus,setFocus] = React.useState(false);
  return (
    <div>
      {label && <div style={{font:`600 11px ${fontBody}`, color:SF.fg2, letterSpacing:'.12em', textTransform:'uppercase', marginBottom:8}}>{label}</div>}
      <div style={{
        display:'flex',alignItems:'center',gap:10, height:54, padding:'0 16px',
        background: SF.surface,
        border: `1px solid ${error ? SF.error : focus ? SF.orange : SF.border}`,
        borderRadius:14,
        boxShadow: focus ? (error ? '0 0 0 3px rgba(239,68,68,.18)' : '0 0 0 3px rgba(250,128,56,.18)') : insetHi,
        transition:'all 160ms cubic-bezier(.2,.8,.2,1)',
      }}>
        {icon && <Icon name={icon} size={20} color={focus ? SF.orange : SF.fg2}/>}
        <input type={type} value={value||''} placeholder={placeholder}
          onChange={e=>onChange?.(e.target.value)}
          onFocus={()=>setFocus(true)} onBlur={()=>setFocus(false)}
          style={{flex:1, background:'transparent', border:'none',outline:'none', color: SF.fg, font:`500 15px ${fontBody}`, minWidth:0}}/>
        {trailing}
      </div>
      {error && <div style={{font:`500 12px ${fontBody}`, color:SF.error, marginTop:6, display:'flex',alignItems:'center',gap:6}}>
        <Icon name="error" size={14}/>{error}
      </div>}
    </div>
  );
}

// ─── Bottom tab bar ─────────────────────────────
function BottomTabBar({active='home', onSelect}){
  const tabs = [
    {id:'home', icon:'home', label:'Início'},
    {id:'treino', icon:'fitness_center', label:'Treino'},
    {id:'diario', icon:'restaurant_menu', label:'Diário', fab:true},
    {id:'ranking', icon:'leaderboard', label:'Ranking'},
    {id:'perfil', icon:'person', label:'Perfil'},
  ];
  return (
    <div style={{
      display:'flex', alignItems:'flex-end', padding:'6px 6px 14px',
      background:'rgba(11,13,18,.88)',
      backdropFilter:'blur(20px)', WebkitBackdropFilter:'blur(20px)',
      borderTop: `1px solid ${SF.border}`,
    }}>
      {tabs.map(t=>{
        const on = active===t.id;
        if (t.fab) {
          return (
            <button key={t.id} onClick={()=>onSelect?.(t.id)} style={{
              flex:1, background:'transparent', border:'none', padding:'0',
              display:'flex', flexDirection:'column', alignItems:'center', gap:4,
              cursor:'pointer',
            }}>
              <div style={{
                width:50, height:50, borderRadius:16, marginTop:-18,
                background: on ? gradPrimary : `linear-gradient(135deg, ${SF.surface2}, ${SF.surface})`,
                border: on ? 'none' : `1px solid ${SF.border}`,
                boxShadow: on ? `${glowOrange}, ${insetHi}` : insetHi,
                display:'flex', alignItems:'center', justifyContent:'center',
                color:'#fff',
                transition:'transform 200ms cubic-bezier(.34,1.56,.64,1)',
                transform: on ? 'scale(1.05)' : 'scale(1)',
              }}>
                <Icon name={t.icon} size={26} fill={1} weight={600}/>
              </div>
              <span style={{
                font:`${on?800:600} 9px ${fontBody}`, letterSpacing:'.04em',
                color: on ? SF.orange : SF.fg2,
              }}>{t.label}</span>
            </button>
          );
        }
        return (
          <button key={t.id} onClick={()=>onSelect?.(t.id)} style={{
            flex:1, background:'transparent',border:'none', padding:'8px 2px',
            display:'flex',flexDirection:'column',alignItems:'center',gap:5,
            color: on ? SF.orange : SF.fg2, cursor:'pointer',
            transition:'transform 120ms cubic-bezier(.34,1.56,.64,1)',
            transform: on ? 'scale(1.05)' : 'scale(1)', position:'relative',
          }}>
            {on && <div style={{position:'absolute',top:-6, width:22,height:3,borderRadius:999, background:SF.orange, boxShadow:glowOrange}}/>}
            <Icon name={t.icon} size={22} fill={on?1:0} weight={on?700:500}/>
            <span style={{font:`${on?700:500} 9px ${fontBody}`, letterSpacing:'.04em'}}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ─── Progress ring ─────────────────────────────
function ProgressRing({value=75, size=140, label='meta', bigLabel, unit, stroke=10, gradient=['#FA8038','#FF3B8B']}){
  const r = size/2 - stroke;
  const circ = 2 * Math.PI * r;
  const off = circ * (1 - Math.min(1,value/100));
  const id = React.useId ? React.useId() : `pg${size}`;
  return (
    <div style={{position:'relative',width:size,height:size}}>
      <svg width={size} height={size} style={{transform:'rotate(-90deg)'}}>
        <defs><linearGradient id={`ring${id}`} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor={gradient[0]}/><stop offset="1" stopColor={gradient[1]}/>
        </linearGradient></defs>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={SF.surface2} strokeWidth={stroke}/>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={`url(#ring${id})`} strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={circ} strokeDashoffset={off}
          style={{transition:'stroke-dashoffset 800ms cubic-bezier(.2,.8,.2,1)'}}/>
      </svg>
      <div style={{position:'absolute',inset:0,display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center'}}>
        <div style={{font:`900 ${size*0.26}px/1 ${fontDisp}`, color:'#fff', letterSpacing:'-0.035em', fontVariantNumeric:'tabular-nums'}}>{bigLabel ?? `${value}`}{unit && <span style={{font:`500 ${size*0.12}px ${fontBody}`, color:SF.fg2, marginLeft:3}}>{unit}</span>}</div>
        <div style={{font:`600 10px ${fontBody}`, color: SF.fg2, marginTop: 6, letterSpacing:'.14em', textTransform:'uppercase'}}>{label}</div>
      </div>
    </div>
  );
}

// ─── Chip ─────────────────────────────
function Chip({icon, children, color=SF.fg2, bg='rgba(255,255,255,.06)', border='1px solid rgba(255,255,255,.08)', glow}){
  return (
    <div style={{
      display:'inline-flex', alignItems:'center', gap:6,
      padding:'6px 12px', borderRadius:999,
      background: bg, border, color,
      font:`700 11px ${fontBody}`, letterSpacing:'.08em', textTransform:'uppercase',
      boxShadow: glow,
    }}>{icon && <Icon name={icon} size={13} fill={1}/>}{children}</div>
  );
}

// ─── Avatar ─────────────────────────────
function Avatar({initials='MA', size=40, grad=gradSquad, ring=false, badge}){
  return (
    <div style={{position:'relative', width:size, height:size, flexShrink:0}}>
      <div style={{
        width:size, height:size, borderRadius:999, background:grad,
        display:'flex',alignItems:'center',justifyContent:'center',
        font:`700 ${size*0.38}px ${fontDisp}`, color:'#fff',
        boxShadow: ring ? `0 0 0 3px ${SF.bg}, 0 0 0 5px ${SF.orange}, ${glowOrange}` : insetHi,
        letterSpacing:'-0.02em',
      }}>{initials}</div>
      {badge && <div style={{
        position:'absolute', bottom:-2, right:-2, width:size*0.45, height:size*0.45,
        borderRadius:999, background:SF.lime, border:`2px solid ${SF.bg}`,
        display:'flex',alignItems:'center',justifyContent:'center',
      }}><Icon name={badge} size={size*0.28} fill={1} color="#0B0D12"/></div>}
    </div>
  );
}

// ─── Ranking row ─────────────────────────────
function RankingRow({pos, name, initials, delta, sub, isMe=false, isPodium=false, avatarGrad, trend='down'}){
  const medal = pos===1 ? '#FFD166' : pos===2 ? '#D9D9E0' : pos===3 ? '#E09460' : null;
  return (
    <div style={{
      display:'flex',alignItems:'center',gap:12,padding:'12px 14px',borderRadius:16,
      border: isMe ? '1px solid rgba(250,128,56,.45)' : `1px solid ${SF.border}`,
      background: isMe ? 'linear-gradient(90deg,rgba(250,128,56,.18),rgba(250,128,56,.02))' : SF.surface,
      boxShadow: isMe ? `0 0 0 1px rgba(250,128,56,.25), ${insetHi}` : insetHi,
    }}>
      <div style={{
        width:32, height:32, borderRadius:10, flexShrink:0,
        display:'flex',alignItems:'center',justifyContent:'center',
        background: medal ? `linear-gradient(135deg, ${medal}, ${medal}88)` : SF.surface2,
        border: medal ? 'none' : `1px solid ${SF.border}`,
        font:`900 14px ${fontDisp}`, color: medal ? '#0B0D12' : SF.fg2,
        fontVariantNumeric:'tabular-nums',
        boxShadow: medal ? `0 0 16px ${medal}66` : 'none',
      }}>{pos}</div>
      <Avatar initials={initials} size={40} grad={avatarGrad || gradSquad}/>
      <div style={{flex:1, minWidth:0}}>
        <div style={{font:`600 15px ${fontBody}`, color: SF.fg1, display:'flex', alignItems:'center', gap:6}}>
          {name}{isMe && <span style={{font:`800 9px ${fontBody}`,letterSpacing:'.14em',textTransform:'uppercase',color:SF.orange, padding:'2px 6px', borderRadius:4, background:'rgba(250,128,56,.15)'}}>você</span>}
        </div>
        {sub && <div style={{font:`500 12px ${fontBody}`, color:SF.fg3, marginTop:2}}>{sub}</div>}
      </div>
      <div style={{textAlign:'right'}}>
        <div style={{font:`800 16px ${fontDisp}`, color: isMe ? SF.lime : (pos<=3 ? SF.lime : SF.fg1), fontVariantNumeric:'tabular-nums', letterSpacing:'-0.02em'}}>{delta}</div>
        {trend && <div style={{font:`500 10px ${fontBody}`, color:SF.fg3, letterSpacing:'.08em'}}>
          <Icon name={trend==='down'?'arrow_downward':'arrow_upward'} size={11}/> vs ontem
        </div>}
      </div>
    </div>
  );
}

// ─── Stat pill (small metric) ─────────────────────────────
function StatPill({label, value, unit, icon, accent=SF.orange}){
  return (
    <div style={{
      flex:1, padding:'14px 14px', borderRadius:16,
      background: SF.surface, border:`1px solid ${SF.border}`, boxShadow: insetHi,
      display:'flex', flexDirection:'column', gap:6,
    }}>
      <div style={{display:'flex', alignItems:'center', gap:6, color:accent}}>
        {icon && <Icon name={icon} size={16} fill={1}/>}
        <span style={{font:`700 10px ${fontBody}`, letterSpacing:'.14em', textTransform:'uppercase', color:SF.fg2}}>{label}</span>
      </div>
      <div style={{display:'flex', alignItems:'baseline', gap:4}}>
        <span style={{font:`800 24px ${fontDisp}`, color:'#fff', fontVariantNumeric:'tabular-nums', letterSpacing:'-0.03em'}}>{value}</span>
        {unit && <span style={{font:`500 12px ${fontBody}`, color:SF.fg2}}>{unit}</span>}
      </div>
    </div>
  );
}

// ─── Section header ─────────────────────────────
function SectionHeader({title, action, actionIcon='chevron_right'}){
  return (
    <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginTop:4}}>
      <span style={{font:`800 18px ${fontDisp}`, color:'#fff', letterSpacing:'-0.02em'}}>{title}</span>
      {action && <span style={{font:`600 13px ${fontBody}`, color:SF.orange, cursor:'pointer', display:'inline-flex', alignItems:'center', gap:2}}>
        {action}<Icon name={actionIcon} size={16}/>
      </span>}
    </div>
  );
}

Object.assign(window, {
  SF, gradPrimary, gradVictory, gradSquad, gradHype,
  glowOrange, glowLime, glowMagenta, insetHi,
  fontBody, fontDisp, fontMono,
  Icon, SFButton, SFAppBar, SFInput, BottomTabBar, ProgressRing,
  Chip, Avatar, RankingRow, StatPill, SectionHeader,
});
