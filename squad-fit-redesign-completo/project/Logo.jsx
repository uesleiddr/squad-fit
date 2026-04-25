// Logo.jsx — Squad Fit official wordmark (concept B · Bold/Energético)
// Double-chevron italic wordmark. Use <Logo variant="onOrange"/> for orange surfaces.

function Logo({variant='default', width=220, style={}}){
  const h = width * (88/300);
  const wordColor = variant === 'onOrange' ? '#fff' : '#F5F6F8';
  const chevFill = variant === 'onOrange' ? '#fff' : 'url(#sfLogoGrad)';
  const chevOpacity2 = variant === 'onOrange' ? 0.55 : 0.6;
  return (
    <svg width={width} height={h} viewBox="0 0 300 88" fill="none" style={{display:'block', ...style}}>
      {variant !== 'onOrange' && (
        <defs>
          <linearGradient id="sfLogoGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stopColor="#FFAB6B"/><stop offset="1" stopColor="#FA8038"/>
          </linearGradient>
        </defs>
      )}
      <g transform="translate(0,12) skewX(-14)">
        <path d="M6 32 L22 8 L32 8 L16 32 L32 56 L22 56 Z" fill={chevFill}/>
        <path d="M30 32 L46 8 L56 8 L40 32 L56 56 L46 56 Z" fill={chevFill} opacity={chevOpacity2}/>
      </g>
      {variant === 'onOrange' ? (
        <text x="86" y="58" fontFamily='"Space Grotesk","Inter",system-ui' fontWeight="900" fontSize="38" letterSpacing="-0.04em" fill="#fff" transform="skewX(-8)">SQUADFIT</text>
      ) : (
        <g fontFamily='"Space Grotesk","Inter",system-ui' fontWeight="900" fontSize="38" letterSpacing="-0.04em" transform="skewX(-8)">
          <text x="86" y="58" fill={wordColor}>SQUAD</text>
          <text x="196" y="58" fill="url(#sfLogoGrad)">FIT</text>
        </g>
      )}
    </svg>
  );
}

// LogoMark — isolated chevron symbol only
function LogoMark({size=48, variant='default', style={}}){
  const fill = variant === 'onOrange' ? '#fff' : 'url(#sfMarkGrad)';
  return (
    <svg width={size} height={size * (72/68)} viewBox="0 0 68 72" fill="none" style={{display:'block', ...style}}>
      {variant !== 'onOrange' && (
        <defs>
          <linearGradient id="sfMarkGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stopColor="#FFAB6B"/><stop offset="1" stopColor="#FA8038"/>
          </linearGradient>
        </defs>
      )}
      <g transform="translate(4,8)">
        <path d="M6 26 L20 4 L28 4 L14 26 L28 48 L20 48 Z" fill={fill}/>
        <path d="M26 26 L40 4 L48 4 L34 26 L48 48 L40 48 Z" fill={fill} opacity={variant==='onOrange'?0.55:0.6}/>
      </g>
    </svg>
  );
}

Object.assign(window, {Logo, LogoMark});
