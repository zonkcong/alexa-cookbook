/* Reels • iOS Glass Prototype (static, web-based) */

const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));
const vibrate = (ms = 10) => navigator.vibrate?.(ms);

// Data for three reels
const reels = [
  {
    id: 'mia',
    video:
      'https://videos.pexels.com/video-files/854174/854174-uhd_2560_1440_25fps.mp4',
    // Portrait-friendly placeholder; object-fit covers regardless of aspect
    creatorHandle: '@movewithmia',
    creatorName: 'Move with Mia',
    avatar: 'https://i.pravatar.cc/96?img=68',
    caption: '5 min core blast to start your day. Focus on controlled movements and breathe. Try 3 rounds! #core #morningroutine',
    sound: 'Upbeat Pop - Mia',
    likes: 12400,
    comments: 985,
    following: false,
    muted: true,
  },
  {
    id: 'nate',
    video:
      'https://videos.pexels.com/video-files/3129952/3129952-uhd_2560_1440_25fps.mp4',
    creatorHandle: '@nomadnate',
    creatorName: 'Nomad Nate',
    avatar: 'https://i.pravatar.cc/96?img=12',
    caption: 'Hidden waterfall hike in Iceland. Slippery rocks but absolutely worth the trek. Would you go? 🌊🇮🇸',
    sound: 'Ambient Nordic - Nate',
    likes: 7821,
    comments: 2103,
    following: false,
    muted: true,
  },
  {
    id: 'plate',
    video:
      'https://videos.pexels.com/video-files/5598041/5598041-uhd_2560_1440_25fps.mp4',
    creatorHandle: '@plateandpalette',
    creatorName: 'Plate & Palette',
    avatar: 'https://i.pravatar.cc/96?img=25',
    caption: 'Silky carbonara tip you need: temper the eggs off heat and add a splash of pasta water for gloss ✨',
    sound: 'Classic Kitchen - P&P',
    likes: 16234,
    comments: 653,
    following: true,
    muted: true,
  },
];

const state = {
  activeIndex: 0,
  likeById: new Map(),
  followById: new Map(),
  muteById: new Map(),
  progressRAF: null,
  sheet: null,
};

function formatCount(n) {
  if (n >= 1_000_000) return (n / 1_000_000).toFixed(1).replace(/\.0$/, '') + 'M';
  if (n >= 1000) return Math.round(n / 100) / 10 + 'K';
  return String(n);
}

function icon(name) {
  const paths = {
    heart: '<path d="M12 21s-6.716-4.438-9.167-8.167C1.054 10.7 2.324 7 6 7c2.148 0 3.321 1.262 4 2 0.679-.738 1.852-2 4-2 3.676 0 4.946 3.7 3.167 5.833C18.716 16.562 12 21 12 21z"/>',
    bubble: '<path d="M4 4h16v12H7l-3 3V4z"/>',
    paperplane: '<path d="M3 11l18-8-6 18-4-7-8-3z"/>',
    music: '<path d="M12 3v12.55A4 4 0 1 1 10 16V7h8V3h-6z"/>',
    ellipsis: '<circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/>'
  };
  return `<svg viewBox="0 0 24 24" aria-hidden="true">${paths[name] || ''}</svg>`;
}

function buildFeed() {
  const feed = $('#feed');
  feed.innerHTML = '';
  reels.forEach((r, idx) => {
    const article = document.createElement('article');
    article.className = 'reel';
    article.setAttribute('role', 'listitem');
    article.dataset.id = r.id;

    // Video
    const video = document.createElement('video');
    video.src = r.video;
    video.playsInline = true; video.setAttribute('playsinline', '');
    video.muted = state.muteById.get(r.id) ?? r.muted;
    video.preload = 'metadata';
    video.setAttribute('webkit-playsinline', 'true');
    video.setAttribute('aria-label', `${r.creatorHandle} reel video`);

    // Overlays
    const fadeTop = div('fade-top');
    const fadeBottom = div('fade-bottom');

    // Action rail
    const rail = div('action-rail parallax');

    rail.append(
      railButton('heart', 'Like', () => toggleLike(r.id, rail)),
      railCount('like', r.likes),
      railButton('bubble', 'Open comments', () => openComments(r)),
      railCount('comments', r.comments),
      railButton('paperplane', 'Share', () => openShare(r)),
      railCount('share', ''),
      railButton('music', 'Open audio details', () => openAudio(r)),
      railButton('ellipsis', 'More', () => openMore(r))
    );

    // Caption block card
    const caption = div('caption');
    const card = div('glass glass-card');
    const avatar = div('avatar');
    avatar.innerHTML = `<img alt="${r.creatorName}" src="${r.avatar}"/>`;

    const meta = div('meta');
    const name = document.createElement('button');
    name.className = 'creator title';
    name.textContent = `${r.creatorName}`;
    name.setAttribute('aria-label', `Open profile for ${r.creatorName}`);
    name.addEventListener('click', () => openProfile(r));

    const handle = span('small', r.creatorHandle);
    const follow = document.createElement('button');
    follow.className = 'follow btn-follow';
    follow.textContent = state.followById.get(r.id) ?? r.following ? 'Following' : 'Follow';
    if (state.followById.get(r.id) ?? r.following) follow.classList.add('following');
    follow.setAttribute('aria-pressed', String(state.followById.get(r.id) ?? r.following));
    follow.addEventListener('click', () => toggleFollow(r.id, follow));

    meta.append(name, handle, follow);

    const text = div('text body');
    const fullText = r.caption;
    text.textContent = fullText;
    clampCaption(text);

    const sound = div('sound small');
    sound.textContent = r.sound;
    sound.addEventListener('click', () => openAudio(r));

    // Volume chip + button
    const volumeChip = div('volume-chip glass small');
    volumeChip.innerHTML = `<span>${video.muted ? 'Muted' : 'Volume On'}</span>`;
    const volumeBtn = document.createElement('button');
    volumeBtn.className = 'chip glass';
    volumeBtn.textContent = video.muted ? '🔇' : '🔊';
    volumeBtn.setAttribute('aria-label', video.muted ? 'Unmute' : 'Mute');
    volumeBtn.addEventListener('click', () => toggleVolume(r.id, video, volumeBtn, volumeChip));

    card.append(avatar, meta, volumeBtn, text, sound);
    caption.append(card);
    caption.append(volumeChip);

    // Center play/pause glyph
    const glyph = div('center-glyph glass');
    article.append(video, fadeTop, fadeBottom, rail, caption, glyph);

    // Interactions on reel surface
    attachReelInteractions(article, video, glyph, r);

    feed.appendChild(article);
  });
}

function div(cls) { const e = document.createElement('div'); e.className = cls; return e; }
function span(cls, text='') { const e = document.createElement('span'); if (cls) e.className = cls; e.textContent = text; return e; }

function railButton(kind, label, onClick) {
  const wrap = div('rail-item');
  const btn = document.createElement('button');
  btn.className = 'rail-btn glass';
  btn.innerHTML = icon(mapKind(kind));
  btn.setAttribute('aria-label', label);
  btn.addEventListener('click', (e) => { e.stopPropagation(); onClick?.(); });
  wrap.append(btn);
  wrap.dataset.kind = kind;
  return wrap;
}

function railCount(kind, value) {
  const el = div('count small');
  el.dataset.kind = kind;
  el.textContent = value !== '' ? formatCount(value) : '';
  return el;
}

function mapKind(k) {
  return (
    {
      heart: 'heart',
      bubble: 'bubble',
      paperplane: 'paperplane',
      music: 'music',
      ellipsis: 'ellipsis',
    }[k] || 'ellipsis'
  );
}

function clampCaption(el) {
  // Add more/less control if overflows
  requestAnimationFrame(() => {
    if (el.scrollHeight > el.clientHeight + 2) {
      const more = document.createElement('button');
      more.className = 'more';
      more.textContent = 'more';
      more.addEventListener('click', () => {
        const expanded = el.classList.toggle('expanded');
        if (expanded) {
          el.style.maxHeight = 'none';
          more.textContent = 'less';
        } else {
          el.style.maxHeight = '';
          more.textContent = 'more';
        }
      });
      el.after(more);
    }
  });
}

function attachReelInteractions(article, video, glyph, reel) {
  // Play/pause on tap (single), like on double tap
  let lastTap = 0; let longPressTimer = null; let pressed = false;

  const surfaceTap = (ev) => {
    const now = Date.now();
    const delta = now - lastTap;
    lastTap = now;
    if (delta < 280) {
      // double tap → like and heart burst
      toggleLike(reel.id, article.querySelector('.action-rail'));
      showHeartBurst(article, ev.clientX, ev.clientY);
      vibrate(20);
      return;
    }
    // single tap → play/pause
    togglePlay(video, glyph);
  };

  const onPointerDown = (ev) => {
    pressed = true;
    longPressTimer = setTimeout(() => {
      if (pressed) openMore(reel);
    }, 500);
  };
  const onPointerUp = () => {
    pressed = false; clearTimeout(longPressTimer);
  };

  article.addEventListener('click', surfaceTap);
  article.addEventListener('pointerdown', onPointerDown);
  article.addEventListener('pointerup', onPointerUp);

  // Video events
  video.addEventListener('error', () => showToast('Video failed to load.', () => video.load()))
  video.addEventListener('ended', () => goToReel(state.activeIndex + 1));
}

function togglePlay(video, glyph) {
  if (video.paused) {
    video.play().catch(() => {/* ignore */});
    showGlyph(glyph, 'play');
  } else {
    video.pause();
    showGlyph(glyph, 'pause');
  }
}

function showGlyph(glyph, kind) {
  glyph.classList.remove('play', 'pause', 'show');
  glyph.classList.add(kind, 'show', 'glass');
  setTimeout(() => glyph.classList.remove('show'), 500);
}

function showHeartBurst(root, x, y) {
  const hb = div('heart-burst');
  hb.style.left = x + 'px'; hb.style.top = y + 'px';
  root.appendChild(hb);
  requestAnimationFrame(() => hb.classList.add('show'));
  setTimeout(() => hb.remove(), 800);
}

function toggleLike(id, rail) {
  const current = !!state.likeById.get(id);
  state.likeById.set(id, !current);
  const btn = rail.querySelector('[data-kind="heart"] .rail-btn');
  btn.classList.toggle('liked', !current);
  // micro-interaction scale
  btn.animate([
    { transform: 'scale(0.9)' },
    { transform: 'scale(1.12)' },
    { transform: 'scale(1.0)' },
  ], { duration: 220, easing: 'ease-out' });
  const countEl = rail.querySelector('.count[data-kind="like"]');
  const r = reels.find(r => r.id === id);
  const next = r.likes + (!current ? 1 : -1);
  countEl.textContent = formatCount(next);
}

function toggleFollow(id, btn) {
  const current = !!state.followById.get(id);
  const next = !current;
  state.followById.set(id, next);
  btn.classList.toggle('following', next);
  btn.textContent = next ? 'Following' : 'Follow';
  btn.animate([
    { transform: 'scale(0.9)', background: 'rgba(255,255,255,0.08)' },
    { transform: 'scale(1.12)' },
    { transform: 'scale(1)', background: next ? 'rgba(10,132,255,0.25)' : 'rgba(255,255,255,0.08)' }
  ], { duration: 220, easing: 'ease-out' });
}

function toggleVolume(id, video, btn, chip) {
  const current = state.muteById.get(id) ?? video.muted;
  const next = !current;
  state.muteById.set(id, next);
  video.muted = next;
  btn.textContent = next ? '🔇' : '🔊';
  btn.setAttribute('aria-label', next ? 'Unmute' : 'Mute');
  chip.innerHTML = `<span>${next ? 'Muted' : 'Volume On'}</span>`;
  chip.classList.add('show'); setTimeout(() => chip.classList.remove('show'), 1200);
}

function showToast(text, onRetry) {
  const toast = $('#toast');
  toast.querySelector('span').textContent = text;
  toast.hidden = false;
  requestAnimationFrame(() => toast.classList.add('show'));
  $('#retryBtn').onclick = () => { onRetry?.(); hideToast(); };
  setTimeout(hideToast, 3500);
}
function hideToast() { const toast = $('#toast'); toast.classList.remove('show'); setTimeout(() => toast.hidden = true, 220); }

function openSheet({ title, body, height = '60vh' }) {
  const sheets = $('#sheets');
  sheets.innerHTML = '';
  sheets.classList.add('show');
  const scrim = div('scrim');
  const sheet = document.createElement('div');
  sheet.className = 'sheet glass'; sheet.style.height = height;
  sheet.innerHTML = `<div class="grabber"></div><div class="sheet-header"><div class="sheet-title">${title}</div><button aria-label="Close" class="chip glass">Close</button></div><div class="sheet-body"></div>`;
  sheet.querySelector('button').onclick = () => closeSheet();
  sheets.append(scrim, sheet);
  scrim.classList.add('show');
  requestAnimationFrame(() => { sheet.style.transform = 'translateY(0)'; });
  state.sheet = sheet;
  // drag handling
  initSheetDrag(sheet, scrim);
  return sheet.querySelector('.sheet-body');
}

function closeSheet() {
  const sheets = $('#sheets');
  const sheet = state.sheet; if (!sheet) return;
  sheet.style.transform = 'translateY(100%)';
  $('.scrim', sheets)?.classList.remove('show');
  setTimeout(() => { sheets.classList.remove('show'); sheets.innerHTML = ''; state.sheet = null; }, 360);
}

function initSheetDrag(sheet, scrim) {
  let startY = 0; let startTop = 0; let dragging = false;
  const onDown = (e) => { dragging = true; startY = e.clientY || e.touches?.[0]?.clientY; startTop = sheet.getBoundingClientRect().top; };
  const onMove = (e) => {
    if (!dragging) return; const y = e.clientY || e.touches?.[0]?.clientY; const dy = Math.max(0, y - startY); sheet.style.transform = `translateY(${dy}px)`; scrim.style.opacity = String(Math.max(0, 0.4 - dy / 800)); };
  const onUp = (e) => { if (!dragging) return; dragging = false; const y = e.clientY || e.changedTouches?.[0]?.clientY; const dy = Math.max(0, y - startY); if (dy > 160) { closeSheet(); } else { sheet.style.transform = 'translateY(0)'; scrim.style.opacity = '0.4'; } };
  sheet.addEventListener('mousedown', onDown); window.addEventListener('mousemove', onMove); window.addEventListener('mouseup', onUp);
  sheet.addEventListener('touchstart', onDown, { passive: true }); sheet.addEventListener('touchmove', onMove, { passive: true }); sheet.addEventListener('touchend', onUp);
}

function openComments(r) {
  vibrate(10);
  const body = openSheet({ title: 'Comments', height: '80vh' });
  body.innerHTML = `
    <div class="comments">
      ${Array.from({ length: 12 }).map((_, i) => `
        <div class="comment">
          <div class="avatar"><img alt="" src="https://i.pravatar.cc/64?img=${(i%30)+1}"></div>
          <div>
            <div class="name">user${i+1}</div>
            <div class="text">Great clip! ${i%3===0 ? '🔥🔥' : ''}</div>
          </div>
          <div class="like small">${icon('heart')} ${Math.floor(Math.random()*120)}</div>
        </div>`).join('')}
    </div>
    <div class="comment-input">
      <input id="commentText" placeholder="Add a comment..." aria-label="Add a comment" />
      <button id="sendBtn" disabled>Send</button>
    </div>
  `;
  const input = $('#commentText', body);
  const send = $('#sendBtn', body);
  input.addEventListener('input', () => { const has = input.value.trim().length>0; send.disabled = !has; send.classList.toggle('enabled', has); });
}

function openShare(r) {
  vibrate(10);
  const body = openSheet({ title: 'Share', height: '45vh' });
  body.innerHTML = `
    <div class="share-row" style="display:flex; gap:10px; overflow:auto; padding: 4px 2px 12px;">
      ${['Messages','Mail','Copy Link','Report','Save'].map(name => `<button class="chip glass">${name}</button>`).join('')}
    </div>
    <div class="small" style="opacity:.85">Tap a target to share this reel.</div>
  `;
}

function openAudio(r) {
  vibrate(10);
  const body = openSheet({ title: 'Audio', height: '60vh' });
  body.innerHTML = `
    <div style="display:grid; grid-template-columns:64px 1fr auto; gap:12px; align-items:center;">
      <div class="thumb glass" style="width:64px; height:64px; border-radius:14px; overflow:hidden;"><img alt="" src="https://picsum.photos/seed/${r.id}/128/128" style="width:100%; height:100%; object-fit:cover"></div>
      <div>
        <div class="title">${r.sound}</div>
        <div class="small" style="opacity:.85">${Math.floor(2000 + Math.random()*4000)} uses</div>
      </div>
      <button class="chip glass">Use Audio</button>
    </div>
    <div class="grid" style="margin-top:12px;">
      ${reels.map(x => `<div class="thumb"><video src="${x.video}" muted playsinline></video></div>`).join('')}
    </div>
  `;
}

function openMore(r) {
  vibrate(10);
  const body = openSheet({ title: 'Actions', height: '35vh' });
  body.innerHTML = `
    <div style="display:grid; gap:8px;">
      <button class="chip glass">Save</button>
      <button class="chip glass">Not Interested</button>
      <button class="chip glass">Report</button>
    </div>
  `;
}

function openProfile(r) {
  const view = $('#profileView');
  view.innerHTML = `
    <div class="profile-card glass">
      <div class="header">
        <div class="avatar"><img alt="" src="${r.avatar}"></div>
        <div>
          <div class="title">${r.creatorName}</div>
          <div class="small" style="opacity:.9">${r.creatorHandle}</div>
        </div>
        <button class="btn">Message</button>
      </div>
      <div class="grid">
        ${reels.map(x => `<div class="thumb"><video src="${x.video}" muted playsinline></video></div>`).join('')}
      </div>
      <button class="chip glass" style="position:absolute; top: calc(env(safe-area-inset-top) + 10px); right: 12px;">Close</button>
    </div>
  `;
  view.hidden = false; requestAnimationFrame(() => view.classList.add('show'));
  view.querySelector('button').addEventListener('click', () => { view.classList.remove('show'); setTimeout(() => view.hidden = true, 320); });
}

function setupIntersection() {
  const obs = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      const el = entry.target; const idx = $$('.reel').indexOf(el);
      const vid = $('video', el);
      if (!vid) return;
      if (entry.intersectionRatio >= 0.6) {
        state.activeIndex = idx;
        vid.play().catch(()=>{});
        startProgress(vid);
      } else {
        vid.pause();
      }
    });
  }, { threshold: [0, 0.6, 1] });
  $$('.reel').forEach((r) => obs.observe(r));
}

function startProgress(video) {
  cancelAnimationFrame(state.progressRAF);
  const bar = $('.progress .bar');
  const tick = () => {
    if (!video || !bar) return; const d = video.duration || 1; const t = video.currentTime || 0; const pct = Math.min(100, (t/d)*100); bar.style.width = pct + '%'; state.progressRAF = requestAnimationFrame(tick);
  };
  tick();
}

function goToReel(i) {
  const list = $$('.reel');
  const next = Math.max(0, Math.min(list.length - 1, i));
  list[next].scrollIntoView({ behavior: 'smooth' });
  vibrate(10);
}

function setupBottomNav() {
  $$('.nav-item').forEach(btn => {
    btn.addEventListener('click', () => {
      const tab = btn.dataset.tab;
      if (tab !== 'reels') alert(`${tab} is a placeholder in this prototype.`);
    });
  });
  $('#themeToggle').addEventListener('click', () => {
    const html = document.documentElement;
    const next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next); $('#themeToggle').textContent = next === 'dark' ? '🌙' : '🌞';
  });
  $('#typePlus').addEventListener('click', () => adjustType(0.1));
  $('#typeMinus').addEventListener('click', () => adjustType(-0.1));
}
function adjustType(delta) {
  const s = parseFloat(getComputedStyle(document.documentElement).getPropertyValue('--font-scale')) || 1;
  const next = Math.max(0.8, Math.min(1.6, s + delta));
  document.documentElement.style.setProperty('--font-scale', String(next));
}

function setupParallax() {
  const apply = () => {
    const active = $$('.reel')[state.activeIndex]; if (!active) return;
    const rail = $('.action-rail', active); const nav = $('.bottom-nav');
    const rect = active.getBoundingClientRect(); const center = window.innerHeight/2; const dy = (rect.top + rect.height/2) - center; const offset = Math.max(-8, Math.min(8, -dy/80));
    rail && (rail.style.transform = `translateY(calc(-50% + ${offset}px))`);
    nav && (nav.style.transform = `translateY(${offset/2}px)`);
  };
  $('#feed').addEventListener('scroll', () => { apply(); });
  window.addEventListener('resize', apply);
  setInterval(apply, 120); // keep subtle motion
}

function init() {
  buildFeed();
  setupIntersection();
  setupBottomNav();
  setupParallax();
}

window.addEventListener('DOMContentLoaded', init);
