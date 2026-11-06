// Moneytoring — Prototype MVP (layar 01–11)
// Plugin development lokal untuk file "Moneytoring — App Design (MVP)".
// Mengubah 11 layar statis di halaman "Screens — MVP" menjadi prototype interaktif:
//   - flow starting point (Onboarding, Beranda)
//   - navigasi antar layar (tap → navigate / overlay / back)
//   - behavior komponen (interactive components, CHANGE_TO antar varian)
//   - scroll vertikal di Body (StatusBar, NavBar, Footer, FAB tetap di tempat)
// Aman dijalankan ulang: setiap reaction yang dipasang plugin ini dicatat di registry
// (pluginData dokumen), lalu dibersihkan dulu sebelum dipasang ulang. Reaction buatan
// tangan dengan trigger lain tidak disentuh. Tampilan visual layar tidak diubah.

const CONFIG = {
  // FAB membuka bottom sheet "Tambah Transaksi" sebagai overlay yang naik dari bawah
  // (memakai frame bantu "Proto · 06 Sheet Overlay" di bawah layar 06).
  // false = FAB pindah ke layar 06 biasa (navigate + animasi dari bawah).
  sheetOverlay: true,
  // Pintasan keyboard saat Present: B di layar 04 → 05 (Berisiko), A di layar 05 → 04 (Aman).
  keyboardShortcuts: true,
  // NavBar sebagai interactive component: tiap tab di main component berpindah varian (CHANGE_TO).
  // Di layar, tab yang sama di-override menjadi navigate ke layar tujuan.
  navBarVariants: true,
  // Toggle Pengeluaran/Pemasukan (06) dan tombol 👍/👎 (09, 11) dijadikan interactive component.
  // Frame aslinya diganti instance yang tampilannya identik.
  toggleComponents: true,
};

const SCREENS_PAGE_ID = '4:3';
const COMPONENTS_PAGE_ID = '4:2';
const TAG = 'Moneytoring prototype: ';
const REG_KEY = 'moneytoring-prototype-registry';
const OVERLAY_NAME = 'Proto · 06 Sheet Overlay';
const SECTION_NAME = 'Prototype Components';
const TOGGLE_SET = 'Proto/TypeToggle';
const FEEDBACK_SET = 'Proto/FeedbackButton';

// ID komponen di halaman Components (sama dengan figma-screens-plugin)
const CID = {
  Button: '6:15', Chip: '6:64', FAB: '6:65', Obl: '7:115', Alert: '7:141', Nav: '8:187', Card: '8:262',
};
// Nama default instance (nama component / component set)
const INST_NAME = {
  Button: 'Button', Chip: 'Chip', FAB: 'FAB', Obl: 'ListItem/Obligation', Alert: 'AlertBanner',
  Nav: 'NavBar', Card: 'SafeToSpendCard',
};
// Nama frame yang diketahui. Kalau berbeda, layar dicari dari prefiks nomor ("01 ", "02 ", ...).
const KNOWN = {
  '01': '01 Onboarding — Siklus Gajian',
  '02': '02 Onboarding — Kewajiban Rutin',
  '03': '03 Onboarding — Aha Moment',
  '04': '04 Beranda — Aman',
  '05': '05 Beranda — Berisiko',
  '06': '06 Tambah Transaksi (Bottom Sheet)',
  '07': '07 Transaksi',
  '08': '08 Kewajiban',
  '09': '09 Insight',
  '10': '10 Simulasi What-If',
  '11': '11 Detail Peringatan (A1)',
};
const KEYS = Object.keys(KNOWN).sort();
const TAB = { Beranda: '04', Transaksi: '07', Kewajiban: '08', Insight: '09' };
const KEY_A = 65, KEY_B = 66;

// ---------- state ----------
let page = null;
let compPage = null;
let protoSection = null;
let V = {};
let S = {};
let reg = {};
let regNodes = {};
const plan = new Map();
const okList = [];
const failList = [];
const mainCache = new Map();
let scrollCount = 0;
let flowCount = 0;

// ---------- util ----------
function msg(e) { return e && e.message ? e.message : String(e); }
function note(text) { console.log(TAG + text); }
function fail(label, reason) {
  failList.push(label + ' — ' + reason);
  console.warn(TAG + 'gagal · ' + label + ' — ' + reason);
}
async function step(label, fn) {
  try { return await fn(); } catch (e) { fail(label, msg(e)); return null; }
}
function P(name) {
  const v = V[name];
  if (!v) throw new Error('Variabel tidak ditemukan: ' + name);
  return figma.variables.setBoundVariableForPaint({ type: 'SOLID', color: { r: 0, g: 0, b: 0 } }, 'color', v);
}
function alive(n) { return !!n && !n.removed; }
function insideInstance(n) {
  let p = n ? n.parent : null;
  while (p) { if (p.type === 'INSTANCE') return true; p = p.parent; }
  return false;
}
function isDescendant(n, ancestor) {
  let p = n ? n.parent : null;
  while (p) { if (p === ancestor) return true; p = p.parent; }
  return false;
}
function byName(root, name, type) {
  if (!root || !('findOne' in root)) return null;
  return root.findOne(n => n.name === name && (!type || n.type === type));
}
function prop(inst, name) {
  try {
    const cp = inst.componentProperties;
    for (const k of Object.keys(cp)) if (k.split('#')[0] === name) return cp[k].value;
  } catch (e) { /* bukan instance dengan properti */ }
  return undefined;
}
function variant(set, props) {
  if (!set || !('children' in set)) return null;
  return set.children.find(c => {
    const vp = c.variantProperties || {};
    return Object.keys(props).every(k => vp[k] === props[k]);
  }) || null;
}
function recolor(node, color) {
  for (const n of node.findAll(x => 'strokes' in x && Array.isArray(x.strokes) && x.strokes.length > 0)) n.strokes = [P(color)];
}
async function mainKey(inst) {
  if (mainCache.has(inst.id)) return mainCache.get(inst.id);
  let id = null;
  try {
    const m = await inst.getMainComponentAsync();
    if (m) id = m.parent && m.parent.type === 'COMPONENT_SET' ? m.parent.id : m.id;
  } catch (e) { id = null; }
  mainCache.set(inst.id, id);
  return id;
}
// Semua instance komponen `key` di dalam root (cocok lewat nama, atau lewat main component).
async function instancesOf(root, key) {
  if (!root || !('findAll' in root)) return [];
  const out = [];
  for (const n of root.findAll(x => x.type === 'INSTANCE')) {
    if (n.name === INST_NAME[key] || (await mainKey(n)) === CID[key]) out.push(n);
  }
  return out;
}
async function firstInstance(root, key) { return (await instancesOf(root, key))[0] || null; }
async function button(screen, label, fallbackParent) {
  const list = await instancesOf(screen, 'Button');
  const hit = list.find(b => prop(b, 'Label') === label);
  if (hit) return hit;
  if (fallbackParent) {
    const p = byName(screen, fallbackParent);
    const alt = p ? list.find(b => isDescendant(b, p) && prop(b, 'Style') === 'Primary') : null;
    if (alt) {
      note('tombol "' + label + '" tidak ditemukan di "' + screen.name + '", dipakai tombol Primary di ' + fallbackParent);
      return alt;
    }
  }
  return null;
}
function stepperBack(screen) {
  const st = byName(screen, 'Stepper');
  return st && 'children' in st ? (st.children.find(n => n.type === 'INSTANCE') || null) : null;
}
function appBarBack(screen) {
  const bar = byName(screen, 'AppBar');
  return bar ? byName(bar, 'IconButton/chevron-left') : null;
}
function sectionLink(screen, title) {
  const sec = byName(screen, 'Section/' + title);
  return sec ? byName(sec, 'Link') : null;
}

// ---------- reaction builders ----------
const ON_CLICK = { type: 'ON_CLICK' };
const ON_DRAG = { type: 'ON_DRAG' };
function onKey(code) { return { type: 'ON_KEY_DOWN', device: 'KEYBOARD', keyCodes: [code] }; }
// Durasi transisi dalam detik.
const TR = {
  smart: d => ({ type: 'SMART_ANIMATE', easing: { type: 'EASE_IN_AND_OUT' }, duration: d || 0.3 }),
  dissolve: d => ({ type: 'DISSOLVE', easing: { type: 'EASE_OUT' }, duration: d || 0.2 }),
  push: dir => ({ type: 'PUSH', direction: dir, matchLayers: false, easing: { type: 'EASE_IN_AND_OUT' }, duration: 0.3 }),
  moveIn: dir => ({ type: 'MOVE_IN', direction: dir, matchLayers: false, easing: { type: 'EASE_OUT' }, duration: 0.3 }),
};
function nodeAction(dest, navigation, transition) {
  if (!alive(dest)) return null;
  return { type: 'NODE', destinationId: dest.id, navigation: navigation, transition: transition || null };
}
function go(dest, t) { return nodeAction(dest, 'NAVIGATE', t); }
function openOverlay(dest, t) { return nodeAction(dest, 'OVERLAY', t); }
function changeTo(v, t) { return nodeAction(v, 'CHANGE_TO', t); }
const BACK = { type: 'BACK' };
const CLOSE = { type: 'CLOSE' };

function want(label, node, trigger, action) {
  if (!alive(node)) return fail(label, 'node sumber tidak ditemukan');
  if (!action) return fail(label, 'tujuan tidak ditemukan');
  let e = plan.get(node.id);
  if (!e) { e = { node: node, items: [] }; plan.set(node.id, e); }
  e.items.push({ label: label, reaction: { trigger: trigger, actions: [action] } });
}

// ---------- registry (idempotent) ----------
function actionsOf(r) { return r.actions && r.actions.length ? r.actions : (r.action ? [r.action] : []); }
function trigKey(t) { return t ? t.type + (t.keyCodes ? ':' + t.keyCodes.join(',') : '') : 'none'; }
function sig(r) {
  return trigKey(r.trigger) + '|' + actionsOf(r).map(a => a.type + ':' + (a.navigation || '') + ':' + (a.destinationId || '')).join(',');
}
function loadReg() {
  try { return JSON.parse(figma.root.getPluginData(REG_KEY) || '{}') || {}; } catch (e) { return {}; }
}
function saveReg() {
  try {
    reg.version = 1;
    reg.nodes = regNodes;
    reg.updatedAt = new Date().toISOString();
    figma.root.setPluginData(REG_KEY, JSON.stringify(reg));
  } catch (e) { note('registry tidak tersimpan: ' + msg(e)); }
}
async function regNode(key) {
  const id = regNodes[key];
  if (!id) return null;
  try { const n = await figma.getNodeByIdAsync(id); return alive(n) ? n : null; } catch (e) { return null; }
}

// Pasang semua reaction yang direncanakan + bersihkan reaction lama milik plugin ini.
async function applyPlan() {
  const prev = reg.reactions || {};
  const ids = Object.keys(prev);
  plan.forEach((e, id) => { if (ids.indexOf(id) === -1) ids.push(id); });
  const next = {};
  let cleaned = 0;
  for (const id of ids) {
    const e = plan.get(id);
    let node = e ? e.node : null;
    if (!node) { try { node = await figma.getNodeByIdAsync(id); } catch (err) { node = null; } }
    if (!alive(node) || typeof node.setReactionsAsync !== 'function') {
      if (e) for (const it of e.items) fail(it.label, 'node tidak mendukung prototyping');
      continue;
    }
    const oldSigs = prev[id] || [];
    const mine = e ? e.items : [];
    const mineTrig = mine.map(it => trigKey(it.reaction.trigger));
    const current = (node.reactions || []).map(r => ({ trigger: r.trigger, actions: actionsOf(r) }));
    // buang reaction lama milik plugin ini + reaction lain dengan trigger yang sama (diganti punya kita)
    const keep = current.filter(r => r.trigger && r.actions.length &&
      oldSigs.indexOf(sig(r)) === -1 && mineTrig.indexOf(trigKey(r.trigger)) === -1);
    const dropped = current.length - keep.length;
    let acc = keep;
    const sigs = [];
    for (const it of mine) {
      try {
        await node.setReactionsAsync(acc.concat([it.reaction]));
        acc = acc.concat([it.reaction]);
        sigs.push(sig(it.reaction));
        okList.push(it.label);
      } catch (err) {
        fail(it.label, msg(err));
      }
    }
    if (!sigs.length && dropped > 0) {
      try { await node.setReactionsAsync(keep); } catch (err) { note('gagal membersihkan reaction lama di "' + node.name + '": ' + msg(err)); }
    }
    cleaned += dropped;
    if (sigs.length) next[id] = sigs;
  }
  reg.reactions = next;
  if (cleaned) note(cleaned + ' reaction lama diganti/dibersihkan');
}

// ---------- discovery ----------
function topFrames(p) {
  const out = [];
  for (const n of p.children) {
    if (n.type === 'FRAME' || n.type === 'COMPONENT') out.push(n);
    else if (n.type === 'SECTION') for (const c of n.children) if (c.type === 'FRAME' || c.type === 'COMPONENT') out.push(c);
  }
  return out;
}
function discoverScreens() {
  const frames = topFrames(page);
  note('frame di halaman "' + page.name + '" (' + frames.length + '): ' + frames.map(f => '"' + f.name + '"').join(', '));
  S = {};
  for (const k of KEYS) {
    const re = new RegExp('^' + k + '(?!\\d)');
    const exact = frames.filter(f => f.name === KNOWN[k]);
    const cands = exact.length ? exact : frames.filter(f => re.test(f.name.trim()));
    if (!cands.length) { S[k] = null; continue; }
    if (cands.length > 1) note('layar ' + k + ': ' + cands.length + ' frame cocok, dipakai "' + cands[0].name + '" (' + cands[0].id + ')');
    S[k] = cands[0];
  }
  note('pemetaan layar: ' + KEYS.map(k => k + ' = ' + (S[k] ? '"' + S[k].name + '" (' + S[k].id + ')' : 'TIDAK DITEMUKAN')).join(' | '));
}

// ---------- komponen di halaman Components ----------
async function loadComponentsPage() {
  if (compPage) return compPage;
  let p = null;
  try { p = await figma.getNodeByIdAsync(COMPONENTS_PAGE_ID); } catch (e) { p = null; }
  if (!p || p.type !== 'PAGE') p = figma.root.children.find(x => x.name === 'Components') || null;
  if (!p) throw new Error('halaman "Components" tidak ditemukan');
  await p.loadAsync();
  compPage = p;
  return p;
}
async function ensureSection() {
  if (alive(protoSection)) return protoSection;
  const cp = await loadComponentsPage();
  let sec = await regNode('section');
  if (!sec || sec.type !== 'SECTION') sec = cp.children.find(n => n.type === 'SECTION' && n.name === SECTION_NAME) || null;
  if (!sec) {
    const right = cp.children.reduce((m, c) => Math.max(m, c.x + c.width), 0);
    sec = figma.createSection();
    sec.name = SECTION_NAME;
    cp.appendChild(sec);
    sec.x = Math.round(right + 160); sec.y = 0;
    sec.resizeWithoutConstraints(600, 400);
  }
  protoSection = sec;
  regNodes.section = sec.id;
  return sec;
}
function styleSet(set, cols, description) {
  const pad = 24, gap = 16;
  const kids = set.children.slice();
  const cw = Math.max.apply(null, kids.map(c => c.width));
  const ch = Math.max.apply(null, kids.map(c => c.height));
  kids.forEach((c, i) => { c.x = pad + (i % cols) * (cw + gap); c.y = pad + Math.floor(i / cols) * (ch + gap); });
  const rows = Math.ceil(kids.length / cols);
  set.resizeWithoutConstraints(2 * pad + cols * cw + (cols - 1) * gap, 2 * pad + rows * ch + (rows - 1) * gap);
  try { set.fills = [P('bg/surface')]; } catch (e) { /* biarkan default */ }
  set.strokes = [{ type: 'SOLID', color: { r: 0.6, g: 0.4, b: 0.95 } }];
  set.dashPattern = [6, 4]; set.strokeWeight = 1; set.cornerRadius = 16;
  set.description = description;
}
function fitSection(sec) {
  let y = 80, w = 0;
  for (const c of sec.children) { c.x = 40; c.y = y; y += c.height + 40; w = Math.max(w, c.width); }
  sec.resizeWithoutConstraints(Math.max(480, w + 80), Math.max(240, y + 40));
}
async function findSet(regKey, name) {
  let set = await regNode(regKey);
  if (!set || set.type !== 'COMPONENT_SET') {
    const cp = await loadComponentsPage();
    set = cp.findOne(n => n.type === 'COMPONENT_SET' && n.name === name);
  }
  if (set) regNodes[regKey] = set.id;
  return set || null;
}
// Ganti frame di layar dengan instance komponen yang tampilannya sama.
function swapForInstance(frame, comp) {
  const fillW = frame.layoutSizingHorizontal === 'FILL';
  if (Math.abs(frame.height - comp.height) > 0.5 || (!fillW && Math.abs(frame.width - comp.width) > 0.5)) {
    throw new Error('ukuran "' + frame.name + '" berbeda dari komponen, dilewati agar tampilan tidak berubah');
  }
  const parent = frame.parent;
  const idx = parent.children.indexOf(frame);
  const inst = comp.createInstance();
  parent.insertChild(idx, inst);
  inst.name = frame.name;
  const auto = 'layoutMode' in parent && parent.layoutMode !== 'NONE';
  if (auto && frame.layoutPositioning !== 'ABSOLUTE') {
    inst.layoutSizingHorizontal = frame.layoutSizingHorizontal;
    inst.layoutSizingVertical = frame.layoutSizingVertical;
  } else {
    if (auto) inst.layoutPositioning = 'ABSOLUTE';
    inst.x = frame.x; inst.y = frame.y;
  }
  frame.remove();
  return inst;
}
function swapAll(screens, frameName, comp, label) {
  let n = 0;
  for (const s of screens) {
    if (!s) continue;
    const frames = s.findAll(x => x.type === 'FRAME' && x.name === frameName && !insideInstance(x));
    for (const f of frames) {
      try { swapForInstance(f, comp); n++; } catch (e) { fail(label + ' di "' + s.name + '"', msg(e)); }
    }
  }
  return n;
}
async function applyEffect(node, styleId, effects) {
  if (styleId) { await node.setEffectStyleIdAsync(styleId); return; }
  if (node.effectStyleId) await node.setEffectStyleIdAsync('');
  node.effects = effects;
}

// Chip: Default ↔ Selected
async function chipBehavior() {
  await loadComponentsPage();
  const set = await figma.getNodeByIdAsync(CID.Chip);
  if (!set || set.type !== 'COMPONENT_SET') throw new Error('component set Chip (' + CID.Chip + ') tidak ditemukan');
  const d = variant(set, { State: 'Default' }), s = variant(set, { State: 'Selected' });
  want('Chip: Default → Selected', d, ON_CLICK, changeTo(s, TR.smart(0.15)));
  want('Chip: Selected → Default', s, ON_CLICK, changeTo(d, TR.smart(0.15)));
}

// NavBar: tiap tab berpindah ke varian Active=<tab>
async function navBehavior() {
  await loadComponentsPage();
  const set = await figma.getNodeByIdAsync(CID.Nav);
  if (!set || set.type !== 'COMPONENT_SET') throw new Error('component set NavBar (' + CID.Nav + ') tidak ditemukan');
  const tabs = Object.keys(TAB);
  for (const a of tabs) {
    const v = variant(set, { Active: a });
    for (const b of tabs) {
      if (b === a) continue;
      want('NavBar[' + a + ']: tab ' + b + ' → Active=' + b, v ? byName(v, 'Item/' + b) : null, ON_CLICK, changeTo(variant(set, { Active: b }), TR.smart(0.2)));
    }
  }
}

// Toggle Pengeluaran/Pemasukan di 06
async function typeToggleBehavior() {
  let set = await findSet('toggleSet', TOGGLE_SET);
  if (!set) {
    const src = S['06'] ? S['06'].findOne(n => n.type === 'FRAME' && n.name === 'TypeToggle' && !insideInstance(n)) : null;
    if (!src) throw new Error('frame TypeToggle di layar 06 tidak ditemukan');
    const sec = await ensureSection();
    const a = src.clone(); sec.appendChild(a);
    const b = src.clone(); sec.appendChild(b);
    const segOut = byName(b, 'Segment/Pengeluaran'), segIn = byName(b, 'Segment/Pemasukan');
    if (!segOut || !segIn) { a.remove(); b.remove(); throw new Error('Segment/Pengeluaran atau Segment/Pemasukan tidak ditemukan'); }
    // varian Pemasukan: tukar gaya segmen aktif ↔ tidak aktif
    const fOut = segOut.fills, fIn = segIn.fills;
    segOut.fills = fIn; segIn.fills = fOut;
    const eOut = segOut.effectStyleId, eIn = segIn.effectStyleId;
    const xOut = segOut.effects, xIn = segIn.effects;
    await applyEffect(segOut, typeof eIn === 'string' ? eIn : '', xIn);
    await applyEffect(segIn, typeof eOut === 'string' ? eOut : '', xOut);
    const tOut = byName(segOut, 'Label', 'TEXT') || segOut.findOne(n => n.type === 'TEXT');
    const tIn = byName(segIn, 'Label', 'TEXT') || segIn.findOne(n => n.type === 'TEXT');
    if (tOut && tIn) { const pOut = tOut.fills, pIn = tIn.fills; tOut.fills = pIn; tIn.fills = pOut; }
    const ca = figma.createComponentFromNode(a); ca.name = 'Type=Pengeluaran';
    const cb = figma.createComponentFromNode(b); cb.name = 'Type=Pemasukan';
    set = figma.combineAsVariants([ca, cb], sec);
    set.name = TOGGLE_SET;
    styleSet(set, 1, 'Prototype-only, dibuat oleh tools/figma-prototype-plugin. Toggle jenis transaksi di layar 06 (interactive component). Flutter: SegmentedButton.');
    fitSection(sec);
    regNodes.toggleSet = set.id;
    note('komponen ' + TOGGLE_SET + ' dibuat di halaman Components');
  }
  const vOut = variant(set, { Type: 'Pengeluaran' }), vIn = variant(set, { Type: 'Pemasukan' });
  if (vOut) {
    const n = swapAll([S['06']], 'TypeToggle', vOut, 'Toggle 06');
    if (n) note('TypeToggle di 06 diganti instance ' + TOGGLE_SET + ' (tampilan sama)');
  }
  want('06 Toggle: Pengeluaran → Pemasukan', vOut ? byName(vOut, 'Segment/Pemasukan') : null, ON_CLICK, changeTo(vIn, TR.smart(0.2)));
  want('06 Toggle: Pemasukan → Pengeluaran', vIn ? byName(vIn, 'Segment/Pengeluaran') : null, ON_CLICK, changeTo(vOut, TR.smart(0.2)));
}

// Tombol 👍/👎 di 09 dan 11: Off ↔ On
async function feedbackBehavior() {
  let set = await findSet('feedbackSet', FEEDBACK_SET);
  if (!set) {
    const find = name => {
      for (const s of [S['11'], S['09']]) {
        if (!s) continue;
        const f = s.findOne(n => n.type === 'FRAME' && n.name === name && !insideInstance(n));
        if (f) return f;
      }
      return null;
    };
    const up = find('IconButton/thumbs-up'), down = find('IconButton/thumbs-down');
    if (!up || !down) throw new Error('IconButton/thumbs-up atau thumbs-down tidak ditemukan di layar 09/11');
    const sec = await ensureSection();
    const specs = [[up, 'Up', 'Off'], [up, 'Up', 'On'], [down, 'Down', 'Off'], [down, 'Down', 'On']];
    const clones = [];
    try {
      for (const sp of specs) {
        const f = sp[0].clone(); sec.appendChild(f); clones.push(f);
        if (sp[2] === 'On' && sp[1] === 'Up') {
          f.fills = [P('bg/brand-subtle')]; f.strokes = [P('border/focus')]; recolor(f, 'tone/brand/fg');
        } else if (sp[2] === 'On') {
          // 👎 sengaja netral, bukan merah: merah hanya untuk risiko nyata (DESIGN.md §1.3)
          f.fills = [P('bg/surface-muted')]; f.strokes = [P('border/strong')]; recolor(f, 'icon/primary');
        }
      }
    } catch (e) {
      for (const f of clones) f.remove();
      throw e;
    }
    const comps = clones.map((f, i) => {
      const c = figma.createComponentFromNode(f);
      c.name = 'Vote=' + specs[i][1] + ', State=' + specs[i][2];
      return c;
    });
    set = figma.combineAsVariants(comps, sec);
    set.name = FEEDBACK_SET;
    styleSet(set, 2, 'Prototype-only, dibuat oleh tools/figma-prototype-plugin. Tombol feedback alert 👍/👎 (interactive component). Flutter: IconButton dengan isSelected.');
    fitSection(sec);
    regNodes.feedbackSet = set.id;
    note('komponen ' + FEEDBACK_SET + ' dibuat di halaman Components');
  }
  const pairs = [['Up', '👍', 'IconButton/thumbs-up'], ['Down', '👎', 'IconButton/thumbs-down']];
  for (const p of pairs) {
    const off = variant(set, { Vote: p[0], State: 'Off' }), on = variant(set, { Vote: p[0], State: 'On' });
    if (off) {
      const n = swapAll([S['09'], S['11']], p[2], off, 'Feedback ' + p[1]);
      if (n) note(n + '× ' + p[2] + ' di 09/11 diganti instance ' + FEEDBACK_SET + ' (tampilan sama)');
    }
    want('Feedback ' + p[1] + ': Off → On', off, ON_CLICK, changeTo(on, TR.smart(0.15)));
    want('Feedback ' + p[1] + ': On → Off', on, ON_CLICK, changeTo(off, TR.smart(0.15)));
  }
}

// ---------- overlay bottom sheet ----------
async function buildOverlay() {
  const old = await regNode('overlay');
  if (old) old.remove();
  for (const f of topFrames(page).filter(x => x.name === OVERLAY_NAME)) f.remove();
  delete regNodes.overlay;
  if (!CONFIG.sheetOverlay) return null;
  const s06 = S['06'];
  if (!s06) throw new Error('layar 06 tidak ditemukan');
  const sheet = s06.children.find(n => n.name === 'Sheet');
  if (!sheet) throw new Error('frame "Sheet" di layar 06 tidak ditemukan');
  const f = figma.createFrame();
  f.name = OVERLAY_NAME;
  f.resize(s06.width, s06.height);
  f.fills = [];
  f.clipsContent = true;
  s06.parent.appendChild(f);
  f.x = s06.x; f.y = s06.y + s06.height + 160;
  const tap = figma.createFrame();
  tap.name = 'TapOutside'; tap.fills = [];
  f.appendChild(tap);
  tap.resize(f.width, Math.max(1, Math.round(sheet.y))); tap.x = 0; tap.y = 0;
  const sh = sheet.clone();
  f.appendChild(sh);
  sh.x = sheet.x; sh.y = sheet.y;
  regNodes.overlay = f.id;
  note('frame bantu "' + OVERLAY_NAME + '" dibuat di bawah layar 06 (salinan Sheet untuk overlay)');
  return f;
}

// ---------- navigasi antar layar ----------
async function planScreens(overlay) {
  const s = S;
  const SA = TR.smart, DIS = TR.dissolve;

  await step('Onboarding', async () => {
    want('01 "Lanjut" → 02', await button(s['01'], 'Lanjut', 'Footer'), ON_CLICK, go(s['02'], SA(0.35)));
    want('02 "Lanjut" → 03', await button(s['02'], 'Lanjut', 'Footer'), ON_CLICK, go(s['03'], SA(0.35)));
    want('02 ‹ Kembali → BACK', stepperBack(s['02']), ON_CLICK, BACK);
    want('03 "Mulai pakai Moneytoring" → 04', await button(s['03'], 'Mulai pakai Moneytoring', 'Footer'), ON_CLICK, go(s['04'], SA(0.5)));
    want('03 ‹ Kembali → BACK', stepperBack(s['03']), ON_CLICK, BACK);
  });

  // FAB → Tambah Transaksi
  await step('FAB', async () => {
    for (const k of ['04', '05', '07']) {
      const fab = await firstInstance(s[k], 'FAB');
      if (overlay) want(k + ' FAB → Tambah Transaksi (overlay dari bawah)', fab, ON_CLICK, openOverlay(overlay, TR.moveIn('TOP')));
      else want(k + ' FAB → 06 Tambah Transaksi', fab, ON_CLICK, go(s['06'], TR.moveIn('TOP')));
    }
  });

  // NavBar di tiap layar utama
  await step('NavBar', async () => {
    for (const k of ['04', '05', '07', '08', '09']) {
      const nav = await firstInstance(s[k], 'Nav');
      for (const tab of Object.keys(TAB)) {
        const dest = TAB[tab];
        if (dest === k || (k === '05' && tab === 'Beranda')) continue;
        want(k + ' NavBar ' + tab + ' → ' + dest, nav ? byName(nav, 'Item/' + tab) : null, ON_CLICK, go(s[dest], DIS(0.2)));
      }
    }
  });

  // Beranda Aman (04) & Berisiko (05)
  await step('Beranda', async () => {
    want('04 "Lihat semua" kewajiban → 08', sectionLink(s['04'], 'Kewajiban terdekat'), ON_CLICK, go(s['08'], DIS(0.2)));
    want('04 "Lihat semua" transaksi → 07', sectionLink(s['04'], 'Transaksi terakhir'), ON_CLICK, go(s['07'], DIS(0.2)));
    want('04 Kartu Safe-to-Spend → 10 What-If', await firstInstance(s['04'], 'Card'), ON_CLICK, go(s['10'], TR.push('LEFT')));
    want('04 Lonceng → 09 Insight', byName(s['04'], 'IconButton/bell'), ON_CLICK, go(s['09'], DIS(0.2)));

    want('05 "Lihat semua" kewajiban → 08', sectionLink(s['05'], 'Kewajiban terdekat'), ON_CLICK, go(s['08'], DIS(0.2)));
    want('05 AlertBanner A1 → 11', await firstInstance(s['05'], 'Alert'), ON_CLICK, go(s['11'], TR.push('LEFT')));
    want('05 Lonceng → 11', byName(s['05'], 'IconButton/bell'), ON_CLICK, go(s['11'], TR.push('LEFT')));
    const obl = (await instancesOf(s['05'], 'Obl')).find(o => prop(o, 'Name') === 'Cicilan motor') || null;
    want('05 Cicilan motor (berisiko) → 11', obl, ON_CLICK, go(s['11'], TR.push('LEFT')));
    want('05 Kartu Safe-to-Spend → 10 What-If', await firstInstance(s['05'], 'Card'), ON_CLICK, go(s['10'], TR.push('LEFT')));

    if (CONFIG.keyboardShortcuts) {
      want('04 tombol B → 05 (transaksi besar, Aman → Berisiko)', s['04'], onKey(KEY_B), go(s['05'], SA(0.5)));
      want('05 tombol A → 04 (kembali Aman)', s['05'], onKey(KEY_A), go(s['04'], SA(0.5)));
    }
  });

  // 06 statis + overlay
  await step('Tambah Transaksi', async () => {
    want('06 "Simpan" → 04 Beranda', await button(s['06'], 'Simpan'), ON_CLICK, go(s['04'], DIS(0.25)));
    want('06 Scrim (tap di luar sheet) → BACK', s['06'] ? s['06'].children.find(n => n.name === 'Scrim') : null, ON_CLICK, BACK);
    want('06 Sheet digeser → BACK', s['06'] ? s['06'].children.find(n => n.name === 'Sheet') : null, ON_DRAG, BACK);
    if (overlay) {
      want('Overlay "Simpan" → tutup (kembali ke Beranda)', await button(overlay, 'Simpan'), ON_CLICK, CLOSE);
      want('Overlay tap di luar sheet → tutup', overlay.children.find(n => n.name === 'TapOutside'), ON_CLICK, CLOSE);
      want('Overlay Sheet digeser → tutup', overlay.children.find(n => n.name === 'Sheet'), ON_DRAG, CLOSE);
    }
  });

  // Insight, What-If, Detail Peringatan
  await step('Insight / What-If / Peringatan', async () => {
    want('09 "Coba Premium" → 10 What-If', await button(s['09'], 'Coba Premium'), ON_CLICK, go(s['10'], TR.push('LEFT')));

    want('10 ‹ Kembali → BACK', appBarBack(s['10']), ON_CLICK, BACK);
    want('10 "Tunda & ingatkan saya" → BACK', await button(s['10'], 'Tunda & ingatkan saya'), ON_CLICK, BACK);
    want('10 "Tetap beli & catat" → 05 (Aman → Berisiko)', await button(s['10'], 'Tetap beli & catat'), ON_CLICK, go(s['05'], DIS(0.4)));

    want('11 ‹ Kembali → BACK', appBarBack(s['11']), ON_CLICK, BACK);
    const actions = s['11'] ? s['11'].findAll(n => n.type === 'FRAME' && n.name.indexOf('Action/') === 0) : [];
    if (!actions.length) fail('11 Cara mengamankan → 04', 'baris Action/* tidak ditemukan');
    for (const a of actions) want('11 "' + a.name.slice(7) + '" → 04 (kembali Aman)', a, ON_CLICK, go(s['04'], DIS(0.3)));
  });
}

// ---------- scroll ----------
function setupScroll(overlay) {
  for (const k of KEYS) {
    const s = S[k];
    if (!s || k === '06') continue;
    const body = s.children.find(n => n.name === 'Body' && 'overflowDirection' in n);
    if (!body) { fail('Scroll ' + k, 'frame Body tidak ditemukan'); continue; }
    if (!body.clipsContent) note('Scroll ' + k + ': Body tidak memakai "Clip content", jadi scroll mungkin tidak aktif. Clip sengaja tidak diubah supaya tampilan tetap.');
    try { body.overflowDirection = 'VERTICAL'; scrollCount++; } catch (e) { fail('Scroll ' + k, msg(e)); }
  }
  const rows = [[S['07'], '07', 'Filters'], [S['06'], '06', 'Categories'], [S['06'], '06', 'Meta']];
  if (overlay) rows.push([overlay, 'overlay', 'Categories'], [overlay, 'overlay', 'Meta']);
  for (const r of rows) {
    if (!r[0]) continue;
    const n = r[0].findOne(x => x.name === r[2] && 'overflowDirection' in x && !insideInstance(x));
    if (!n) { fail('Scroll horizontal ' + r[1] + ' ' + r[2], 'frame tidak ditemukan'); continue; }
    try { n.overflowDirection = 'HORIZONTAL'; scrollCount++; } catch (e) { fail('Scroll horizontal ' + r[1] + ' ' + r[2], msg(e)); }
  }
}

// ---------- flow starting points ----------
function setupFlows() {
  const wanted = [];
  if (S['01']) wanted.push({ nodeId: S['01'].id, name: 'Onboarding' }); else fail('Flow "Onboarding"', 'layar 01 tidak ditemukan');
  if (S['04']) wanted.push({ nodeId: S['04'].id, name: 'Beranda' }); else fail('Flow "Beranda"', 'layar 04 tidak ditemukan');
  const names = wanted.map(f => f.name), ids = wanted.map(f => f.nodeId);
  const others = (page.flowStartingPoints || []).filter(f => names.indexOf(f.name) === -1 && ids.indexOf(f.nodeId) === -1);
  page.flowStartingPoints = wanted.concat(others);
  flowCount = wanted.length;
}

// ---------- main ----------
async function main() {
  let p = null;
  try { p = await figma.getNodeByIdAsync(SCREENS_PAGE_ID); } catch (e) { p = null; }
  if (!p || p.type !== 'PAGE') p = figma.root.children.find(x => x.name.indexOf('Screens') === 0) || null;
  if (!p) throw new Error('Halaman "Screens — MVP" tidak ditemukan. Jalankan plugin di file Moneytoring — App Design (MVP).');
  page = p;
  await figma.setCurrentPageAsync(page);

  const vars = await figma.variables.getLocalVariablesAsync();
  V = {}; for (const v of vars) V[v.name] = v;
  for (const st of ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    try { await figma.loadFontAsync({ family: 'Plus Jakarta Sans', style: st }); } catch (e) { /* tidak wajib */ }
  }

  reg = loadReg();
  regNodes = Object.assign({}, reg.nodes || {});
  note('config ' + JSON.stringify(CONFIG));
  discoverScreens();

  // 1. behavior komponen (interactive components)
  await step('Chip Default ↔ Selected', chipBehavior);
  if (CONFIG.navBarVariants) await step('NavBar Active per tab', navBehavior);
  if (CONFIG.toggleComponents) {
    await step('Toggle Pengeluaran/Pemasukan (06)', typeToggleBehavior);
    await step('Feedback 👍/👎 (09, 11)', feedbackBehavior);
  }
  // 2. overlay bottom sheet (setelah toggle di 06 diganti instance, supaya salinannya ikut interaktif)
  const overlay = await step('Overlay bottom sheet 06', buildOverlay);
  // 3. navigasi antar layar
  await planScreens(overlay);
  // 4. pasang semua reaction + bersihkan yang lama
  await applyPlan();
  saveReg();
  // 5. scroll & flow
  await step('Scroll', async () => setupScroll(overlay));
  await step('Flow starting points', async () => setupFlows());
  saveReg();

  if (okList.length) console.log(TAG + okList.length + ' koneksi terpasang:\n  ' + okList.join('\n  '));
  if (failList.length) console.warn(TAG + failList.length + ' gagal:\n  ' + failList.join('\n  '));
  const screens = KEYS.map(k => S[k]).filter(Boolean);
  if (screens.length) figma.viewport.scrollAndZoomIntoView(screens);
  figma.closePlugin(TAG + okList.length + ' koneksi terpasang · ' + failList.length + ' gagal' +
    (failList.length ? ' (lihat console)' : '') + ' · scroll ' + scrollCount + ' frame · ' + flowCount + ' flow');
}

main().catch(e => {
  console.error(e);
  try { saveReg(); } catch (err) { /* abaikan */ }
  figma.closePlugin(TAG + 'gagal — ' + msg(e));
});
