// Moneytoring — Build MVP Screens (04–11)
// Plugin development lokal untuk file "Moneytoring — App Design (MVP)".
// Membangun 8 layar di halaman "Screens — MVP" memakai komponen & variabel yang sudah ada.
// Aman dijalankan ulang: frame dengan nama yang sama dihapus dulu sebelum dibangun ulang.

const SCREENS_PAGE_ID = '4:3';

const IC = {
  home: '5:6', receipt: '5:11', 'calendar-check': '5:18', 'chart-pie': '5:22', plus: '5:26', bell: '5:30',
  utensils: '5:35', car: '5:41', 'shopping-bag': '5:46', zap: '5:49', wifi: '5:55', bike: '5:61', bed: '5:67',
  tv: '5:71', smartphone: '5:75', 'alert-triangle': '5:80', 'chevron-right': '5:83', 'chevron-left': '5:86',
  check: '5:92', 'check-circle': '5:96', sparkles: '5:99', wallet: '5:103', 'arrow-down-left': '5:107',
  'arrow-up-right': '5:111', calculator: '5:123', 'thumbs-up': '5:127', 'thumbs-down': '5:131', delete: '5:136',
  search: '5:140', 'trending-up': '5:144', clock: '5:152', 'piggy-bank': '5:157', 'heart-handshake': '5:164',
  'shield-check': '5:168',
};
const CID = {
  Button: '6:15', Tile: '6:46', Badge: '6:57', Chip: '6:64', FAB: '6:65', Trx: '7:46', Obl: '7:115',
  Alert: '7:141', SB: '8:62', Nav: '8:187', Card: '8:262',
};
const NAMES = {
  s04: '04 Beranda — Aman',
  s05: '05 Beranda — Berisiko',
  s06: '06 Tambah Transaksi (Bottom Sheet)',
  s07: '07 Transaksi',
  s08: '08 Kewajiban',
  s09: '09 Insight',
  s10: '10 Simulasi What-If',
  s11: '11 Detail Peringatan (A1)',
};

let V = {}, T = {}, E = {}, C = {};

// ---------- helpers ----------
function P(name) {
  const v = V[name];
  if (!v) throw new Error('Variabel tidak ditemukan: ' + name);
  return figma.variables.setBoundVariableForPaint({ type: 'SOLID', color: { r: 0, g: 0, b: 0 } }, 'color', v);
}
async function tx(chars, style, color, name) {
  const t = figma.createText();
  await t.setTextStyleIdAsync(T[style].id);
  t.characters = chars;
  t.fills = [P(color)];
  if (name) t.name = name;
  return t;
}
function SP(f, key, n) { f.setBoundVariable(key, V['spacing/' + n]); }
function pad(f, h, v) { SP(f, 'paddingLeft', h); SP(f, 'paddingRight', h); SP(f, 'paddingTop', v); SP(f, 'paddingBottom', v); }
function R(f, r) {
  for (const k of ['topLeftRadius', 'topRightRadius', 'bottomLeftRadius', 'bottomRightRadius']) f.setBoundVariable(k, V['radius/' + r]);
}
function al(dir, name, o) {
  o = o || {};
  const f = figma.createFrame();
  f.name = name || 'Frame';
  f.layoutMode = dir;
  f.primaryAxisSizingMode = 'AUTO';
  f.counterAxisSizingMode = 'AUTO';
  f.clipsContent = false;
  f.fills = o.fill ? [P(o.fill)] : [];
  if (o.gap !== undefined) SP(f, 'itemSpacing', o.gap);
  if (o.pad) pad(f, o.pad[0], o.pad[1]);
  if (o.rad) R(f, o.rad);
  if (o.stroke) { f.strokes = [P(o.stroke)]; f.strokeWeight = 1; }
  if (o.center) f.counterAxisAlignItems = 'CENTER';
  if (o.between) f.primaryAxisAlignItems = 'SPACE_BETWEEN';
  return f;
}
function add(parent, node, fill) {
  parent.appendChild(node);
  if (fill !== false) {
    node.layoutSizingHorizontal = 'FILL';
    if (node.type === 'TEXT') node.textAutoResize = 'HEIGHT';
  }
  return node;
}
function recolor(node, color) {
  const nodes = node.findAll(n => 'strokes' in n && Array.isArray(n.strokes) && n.strokes.length > 0);
  for (const n of nodes) n.strokes = [P(color)];
}
async function ico(name, color, size) {
  const comp = await figma.getNodeByIdAsync(IC[name]);
  const i = comp.createInstance();
  recolor(i, color);
  if (size && size !== 24) i.rescale(size / 24);
  return i;
}
function props(inst, map) {
  const keys = Object.keys(inst.componentProperties);
  const out = {};
  for (const p of Object.keys(map)) {
    const k = keys.find(k => k.split('#')[0] === p);
    if (k) out[k] = map[p];
  }
  inst.setProperties(out);
  return inst;
}
function mk(key, map) {
  const c = C[key];
  const base = c.type === 'COMPONENT_SET' ? c.defaultVariant : c;
  const i = base.createInstance();
  if (map) props(i, map);
  return i;
}
function tone(tile, t, icon) {
  props(tile, { Tone: t, Icon: IC[icon] });
  const ic = tile.findOne(n => n.type === 'INSTANCE');
  if (ic) recolor(ic, 'tone/' + t.toLowerCase() + '/fg');
}
function nestedTile(i) { return i.findOne(n => n.type === 'INSTANCE' && n.name === 'CategoryTile'); }
function trx(parent, d) {
  const i = mk('Trx', { Type: d[5] || 'Expense', Title: d[0], Subtitle: d[1], Amount: d[2] });
  add(parent, i);
  const tl = nestedTile(i); if (tl) tone(tl, d[3], d[4]);
  return i;
}
function obl(parent, d) {
  const i = mk('Obl', { Status: d[3], Name: d[0], Due: d[1], Amount: d[2] });
  add(parent, i);
  const tl = nestedTile(i); if (tl) tone(tl, d[4], d[5]);
  return i;
}
function screen(name, x, o) {
  o = o || {};
  const s = figma.createFrame();
  s.name = name; s.resize(360, 800); s.x = x; s.y = 0;
  s.layoutMode = 'VERTICAL'; s.primaryAxisSizingMode = 'FIXED'; s.counterAxisSizingMode = 'FIXED';
  s.fills = [P('bg/canvas')]; s.clipsContent = true;
  figma.currentPage.appendChild(s);
  add(s, mk('SB'));
  const b = al('VERTICAL', 'Body', { gap: o.gap !== undefined ? o.gap : 20, pad: [16, 8] });
  add(s, b); b.layoutSizingVertical = 'FILL'; b.clipsContent = true;
  if (o.nav) add(s, mk('Nav', { Active: o.nav }));
  if (o.fab) {
    const f = mk('FAB'); s.appendChild(f);
    f.layoutPositioning = 'ABSOLUTE'; f.x = 360 - 16 - 56; f.y = 800 - 80 - 16 - 56;
  }
  return { s: s, b: b };
}
function card(parent, name, o) {
  o = o || {};
  const c = al('VERTICAL', name, { fill: 'bg/surface', rad: 'lg', stroke: 'border/default', pad: o.pad || [0, 4], gap: o.gap !== undefined ? o.gap : 0 });
  add(parent, c);
  return c;
}
async function sec(parent, title, link) {
  const r = al('HORIZONTAL', 'Section/' + title, { center: true, between: true }); add(parent, r);
  r.appendChild(await tx(title, 'Title/Medium', 'text/primary', 'Title'));
  if (link) r.appendChild(await tx(link, 'Label/Large', 'text/brand', 'Link'));
  return r;
}
async function iconBtn(name, o) {
  o = o || {};
  const size = o.size || 40;
  const f = al('HORIZONTAL', 'IconButton/' + name, { fill: o.plain ? null : 'bg/surface', rad: 'full' });
  if (!o.plain) { f.strokes = [P('border/default')]; f.strokeWeight = 1; }
  f.resize(size, size); f.primaryAxisSizingMode = 'FIXED'; f.counterAxisSizingMode = 'FIXED';
  f.primaryAxisAlignItems = 'CENTER'; f.counterAxisAlignItems = 'CENTER';
  f.appendChild(await ico(name, o.color || 'icon/primary', o.iconSize || 20));
  if (o.dot) {
    const d = figma.createEllipse(); d.name = 'Dot'; d.resize(8, 8); d.fills = [P('status/danger')];
    f.appendChild(d); d.layoutPositioning = 'ABSOLUTE'; d.x = size - 15; d.y = 8;
  }
  return f;
}
async function homeHeader(b, dot) {
  const h = al('HORIZONTAL', 'Header', { center: true, gap: 12 }); add(b, h);
  const col = al('VERTICAL', 'Greeting'); add(h, col);
  add(col, await tx('Selamat pagi,', 'Body/Small', 'text/tertiary', 'Hello'));
  add(col, await tx('Raka', 'Headline/Small', 'text/primary', 'Name'));
  h.appendChild(await iconBtn('bell', { dot: dot }));
}
async function titleHeader(b, title, iconName) {
  const h = al('HORIZONTAL', 'Header', { center: true, gap: 8 }); add(b, h);
  add(h, await tx(title, 'Headline/Small', 'text/primary', 'Title'));
  if (iconName) h.appendChild(await iconBtn(iconName));
}
async function appBar(b, title, trailing) {
  const h = al('HORIZONTAL', 'AppBar', { center: true, gap: 4 }); add(b, h);
  h.appendChild(await iconBtn('chevron-left', { plain: true, iconSize: 24 }));
  add(h, await tx(title, 'Title/Medium', 'text/primary', 'Title'));
  if (trailing) h.appendChild(trailing);
}
async function dayHeader(b, label, total) {
  const r = al('HORIZONTAL', 'Group/' + label, { center: true, between: true }); add(b, r);
  r.appendChild(await tx(label, 'Overline', 'text/tertiary', 'Label'));
  if (total) r.appendChild(await tx(total, 'Label/Medium', 'text/tertiary', 'Total'));
}
async function kv(parent, label, value, o) {
  o = o || {};
  const r = al('HORIZONTAL', 'Row/' + label, { center: true, between: true, gap: 12 }); add(parent, r);
  r.appendChild(await tx(label, o.labelStyle || 'Body/Medium', o.labelColor || 'text/secondary', 'Label'));
  r.appendChild(await tx(value, o.valueStyle || 'Title/Small', o.valueColor || 'text/primary', 'Value'));
  return r;
}
function rect(name, w, h, fill, radius) {
  const r = figma.createRectangle(); r.name = name; r.resize(w, h); r.fills = [P(fill)];
  if (radius) r.cornerRadius = radius;
  return r;
}
function divider(parent) { const d = rect('Divider', 10, 1, 'bg/surface-muted'); add(parent, d); return d; }
// polyline / polygon inside a non-auto-layout frame (coords in frame space)
function poly(parent, pts, o) {
  const xs = pts.map(p => p[0]), ys = pts.map(p => p[1]);
  const minX = Math.min.apply(null, xs), minY = Math.min.apply(null, ys);
  const d = pts.map((p, i) => (i ? 'L ' : 'M ') + (p[0] - minX).toFixed(1) + ' ' + (p[1] - minY).toFixed(1)).join(' ') + (o.close ? ' Z' : '');
  const v = figma.createVector();
  v.vectorPaths = [{ windingRule: o.close ? 'NONZERO' : 'NONE', data: d }];
  parent.appendChild(v);
  v.x = minX; v.y = minY;
  if (o.fill) { v.fills = [P(o.fill)]; v.strokes = []; }
  else {
    v.fills = []; v.strokes = [P(o.stroke)]; v.strokeWeight = o.w || 2;
    v.strokeCap = 'ROUND'; v.strokeJoin = 'ROUND';
    if (o.dash) v.dashPattern = o.dash;
  }
  v.name = o.name || 'Line';
  return v;
}
function chartFrame(parent, w, h) {
  const f = figma.createFrame(); f.name = 'Chart'; f.resize(w, h); f.fills = []; f.clipsContent = false;
  parent.appendChild(f);
  for (let i = 0; i <= 3; i++) {
    const g = rect('Grid', w, 1, 'bg/surface-muted'); f.appendChild(g); g.x = 0; g.y = Math.round(i * (h - 1) / 3);
  }
  return f;
}
async function legend(parent, items) {
  const r = al('HORIZONTAL', 'Legend', { gap: 12, center: true }); add(parent, r);
  for (const it of items) {
    const g = al('HORIZONTAL', 'Legend/' + it[0], { gap: 6, center: true });
    g.appendChild(rect('Swatch', 12, it[2] || 3, it[1], 2));
    g.appendChild(await tx(it[0], 'Label/Small', 'text/secondary', 'Label'));
    r.appendChild(g);
  }
}
async function compareRow(parent, label, before, after, color) {
  const r = al('HORIZONTAL', 'Compare/' + label, { center: true, between: true, gap: 8 }); add(parent, r);
  r.appendChild(await tx(label, 'Body/Medium', 'text/secondary', 'Label'));
  const right = al('HORIZONTAL', 'Values', { gap: 6, center: true }); r.appendChild(right);
  const b = await tx(before, 'Body/Medium', 'text/tertiary', 'Before'); b.textDecoration = 'STRIKETHROUGH'; right.appendChild(b);
  right.appendChild(await tx('→', 'Body/Medium', 'text/tertiary', 'Arrow'));
  right.appendChild(await tx(after, 'Title/Small', color, 'After'));
}
async function actionRow(parent, title, sub, t, icon) {
  const r = al('HORIZONTAL', 'Action/' + title, { center: true, gap: 12, pad: [16, 12] }); add(parent, r);
  const tile = mk('Tile'); tone(tile, t, icon); r.appendChild(tile);
  const col = al('VERTICAL', 'Text', { gap: 2 }); add(r, col);
  add(col, await tx(title, 'Title/Small', 'text/primary', 'Title'));
  add(col, await tx(sub, 'Body/Small', 'text/tertiary', 'Subtitle'));
  r.appendChild(await ico('chevron-right', 'icon/secondary', 20));
}
function footer(s) {
  const f = al('VERTICAL', 'Footer', { gap: 8, pad: [16, 16], fill: 'bg/canvas' });
  add(s, f);
  return f;
}

// ---------- screens ----------
async function build04() {
  const r = screen(NAMES.s04, 1200, { nav: 'Beranda', fab: true }); const b = r.b;
  await homeHeader(b, false);
  add(b, mk('Card', { Risk: 'Safe', Amount: 'Rp 760.000', Daily: '≈ Rp 54.300/hari · 14 hari lagi gajian', Protected: 'Rp 2,2 jt diamankan · 3 kewajiban' }));
  await sec(b, 'Kewajiban terdekat', 'Lihat semua');
  const c1 = card(b, 'UpcomingObligations');
  obl(c1, ['Listrik', '20 Nov · 9 hari lagi', '±Rp 350.000', 'Pending', 'Amber', 'zap']);
  obl(c1, ['Cicilan motor', '25 Nov · 14 hari lagi', 'Rp 850.000', 'Pending', 'Blue', 'bike']);
  await sec(b, 'Transaksi terakhir', 'Lihat semua');
  const c2 = card(b, 'RecentTransactions');
  trx(c2, ['Makan siang', 'Makan & Minum · GoPay', '−Rp 25.000', 'Amber', 'utensils']);
  trx(c2, ['Ojek ke kantor', 'Transport · GoPay', '−Rp 18.000', 'Blue', 'car']);
  trx(c2, ['Belanja bulanan', 'Belanja · BCA', '−Rp 312.000', 'Violet', 'shopping-bag']);
  return r.s;
}

async function build05() {
  const r = screen(NAMES.s05, 1600, { nav: 'Beranda', fab: true, gap: 16 }); const b = r.b;
  await homeHeader(b, true);
  add(b, mk('Card', { Risk: 'Danger', Amount: '−Rp 160.000', Daily: 'Sudah kurang Rp 160.000 dari kewajiban', Protected: 'Rp 2,2 jt dibutuhkan · 3 kewajiban' }));
  add(b, mk('Alert', { Tone: 'Danger', Title: 'Cicilan motor berisiko tidak tertutup', Body: 'Dengan pola belanja sekarang, uangmu kurang Rp 350.000 untuk 25 Nov.', Action: 'Lihat cara amankan' }));
  await sec(b, 'Kewajiban terdekat', 'Lihat semua');
  const c1 = card(b, 'UpcomingObligations');
  obl(c1, ['Cicilan motor', '25 Nov · dana kurang', 'Rp 850.000', 'AtRisk', 'Blue', 'bike']);
  obl(c1, ['Listrik', '20 Nov · 9 hari lagi', '±Rp 350.000', 'Pending', 'Amber', 'zap']);
  return r.s;
}

async function build06(home04) {
  const s = figma.createFrame(); s.name = NAMES.s06; s.resize(360, 800); s.x = 2000; s.y = 0;
  s.clipsContent = true; s.fills = [P('bg/canvas')];
  figma.currentPage.appendChild(s);
  if (home04) { const bg = home04.clone(); s.appendChild(bg); bg.x = 0; bg.y = 0; bg.name = 'Background (Beranda)'; }
  const scrim = rect('Scrim', 360, 800, 'bg/scrim'); s.appendChild(scrim);
  const sh = al('VERTICAL', 'Sheet', { fill: 'bg/surface-raised', gap: 16, pad: [16, 12] });
  sh.setBoundVariable('topLeftRadius', V['radius/2xl']); sh.setBoundVariable('topRightRadius', V['radius/2xl']);
  SP(sh, 'paddingBottom', 24);
  await sh.setEffectStyleIdAsync(E['Elevation/2'].id);
  sh.counterAxisAlignItems = 'CENTER';
  s.appendChild(sh); sh.resize(360, 100); sh.counterAxisSizingMode = 'FIXED'; sh.primaryAxisSizingMode = 'AUTO';
  sh.appendChild(rect('Handle', 36, 4, 'bg/surface-muted', 2));
  const seg = al('HORIZONTAL', 'TypeToggle', { fill: 'bg/surface-muted', rad: 'full', gap: 4, pad: [4, 4] }); add(sh, seg);
  for (const it of [['Pengeluaran', true], ['Pemasukan', false]]) {
    const g = al('HORIZONTAL', 'Segment/' + it[0], { fill: it[1] ? 'bg/surface' : null, rad: 'full', pad: [12, 8], center: true });
    g.primaryAxisAlignItems = 'CENTER';
    if (it[1]) await g.setEffectStyleIdAsync(E['Elevation/1'].id);
    g.appendChild(await tx(it[0], 'Label/Large', it[1] ? 'text/primary' : 'text/secondary', 'Label'));
    add(seg, g);
  }
  const amt = al('VERTICAL', 'Amount', { gap: 4, center: true }); add(sh, amt);
  amt.appendChild(await tx('Rp 25.000', 'Display/Amount', 'text/primary', 'Value'));
  const pill = al('HORIZONTAL', 'SafeAfter', { fill: 'bg/brand-subtle', rad: 'full', pad: [10, 4], gap: 6, center: true });
  pill.appendChild(await ico('shield-check', 'tone/brand/fg', 14));
  pill.appendChild(await tx('Sisa aman setelah ini Rp 735.000', 'Label/Medium', 'text/brand', 'Label'));
  amt.appendChild(pill);
  const cats = al('HORIZONTAL', 'Categories', { gap: 8 }); add(sh, cats); cats.clipsContent = true;
  const catList = [['Makan', 'Amber', 'utensils', true], ['Transport', 'Blue', 'car', false], ['Belanja', 'Violet', 'shopping-bag', false], ['Tagihan', 'Brand', 'zap', false], ['Hiburan', 'Red', 'tv', false], ['Pulsa', 'Neutral', 'smartphone', false]];
  for (const c of catList) {
    const col = al('VERTICAL', 'Cat/' + c[0], { gap: 6, center: true });
    const ring = al('HORIZONTAL', 'Ring', { rad: 'lg', pad: [2, 2] });
    if (c[3]) { ring.strokes = [P('border/focus')]; ring.strokeWeight = 2; }
    const tile = mk('Tile'); tone(tile, c[1], c[2]); ring.appendChild(tile); col.appendChild(ring);
    col.appendChild(await tx(c[0], c[3] ? 'Label/Medium' : 'Label/Small', c[3] ? 'text/primary' : 'text/secondary', 'Label'));
    cats.appendChild(col); col.resize(56, col.height); col.counterAxisSizingMode = 'FIXED';
  }
  const meta = al('HORIZONTAL', 'Meta', { gap: 8 }); add(sh, meta); meta.clipsContent = true;
  for (const l of ['GoPay', 'Hari ini, 11 Nov', '+ Catatan']) meta.appendChild(mk('Chip', { State: 'Default', Label: l }));
  const kp = al('VERTICAL', 'Keypad', { gap: 8 }); add(sh, kp);
  for (const row of [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9'], ['000', '0', 'del']]) {
    const r = al('HORIZONTAL', 'Row', { gap: 8 }); add(kp, r);
    for (const k of row) {
      const key = al('HORIZONTAL', 'Key/' + k, { fill: 'bg/canvas', rad: 'md', center: true });
      key.primaryAxisAlignItems = 'CENTER';
      key.appendChild(k === 'del' ? await ico('delete', 'icon/primary', 24) : await tx(k, 'Keypad', 'text/primary', 'Label'));
      r.appendChild(key); key.resize(80, 52); key.layoutSizingHorizontal = 'FILL';
    }
  }
  add(sh, mk('Button', { Style: 'Primary', Size: 'Large', Label: 'Simpan' }));
  sh.x = 0; sh.y = 800 - sh.height;
  return s;
}

async function build07() {
  const r = screen(NAMES.s07, 2400, { nav: 'Transaksi', fab: true, gap: 16 }); const b = r.b;
  await titleHeader(b, 'Transaksi', 'search');
  const sc = card(b, 'CycleSummary', { pad: [16, 16], gap: 12 });
  add(sc, await tx('Siklus 25 Okt – 24 Nov', 'Label/Medium', 'text/tertiary', 'Cycle'));
  const row = al('HORIZONTAL', 'InOut', { gap: 16, center: true }); add(sc, row);
  const cols = [['Masuk', '+Rp 6.000.000', 'text/income', 'arrow-down-left', 'tone/brand/fg'], ['Keluar', 'Rp 2.840.000', 'text/primary', 'arrow-up-right', 'tone/neutral/fg']];
  for (const c of cols) {
    const col = al('VERTICAL', c[0], { gap: 4 }); add(row, col);
    const lr = al('HORIZONTAL', 'Label', { gap: 4, center: true });
    lr.appendChild(await ico(c[3], c[4], 16)); lr.appendChild(await tx(c[0], 'Body/Small', 'text/secondary', 'Text'));
    col.appendChild(lr);
    col.appendChild(await tx(c[1], 'Title/Medium', c[2], 'Value'));
    if (c[0] === 'Masuk') row.appendChild(rect('Divider', 1, 40, 'bg/surface-muted'));
  }
  const chips = al('HORIZONTAL', 'Filters', { gap: 8 }); add(b, chips); chips.clipsContent = true;
  for (const c of [['Semua', true], ['Pengeluaran', false], ['Pemasukan', false], ['BCA', false], ['GoPay', false]]) {
    chips.appendChild(mk('Chip', { State: c[1] ? 'Selected' : 'Default', Label: c[0] }));
  }
  await dayHeader(b, 'Hari ini · Rab, 11 Nov', '−Rp 43.000');
  const g1 = card(b, 'Group/Today');
  trx(g1, ['Makan siang', 'Makan & Minum · GoPay', '−Rp 25.000', 'Amber', 'utensils']);
  trx(g1, ['Ojek ke kantor', 'Transport · GoPay', '−Rp 18.000', 'Blue', 'car']);
  await dayHeader(b, 'Kemarin · Sel, 10 Nov', '−Rp 1.012.000');
  const g2 = card(b, 'Group/Yesterday');
  trx(g2, ['Kos November', 'Kewajiban · BCA · ✓ lunas otomatis', '−Rp 1.000.000', 'Violet', 'bed']);
  trx(g2, ['Kopi susu', 'Makan & Minum · Tunai', '−Rp 12.000', 'Amber', 'utensils']);
  return r.s;
}

async function build08() {
  const r = screen(NAMES.s08, 2800, { nav: 'Kewajiban', gap: 16 }); const b = r.b;
  await titleHeader(b, 'Kewajiban', 'plus');
  const sc = card(b, 'CycleProgress', { pad: [16, 16], gap: 12 });
  add(sc, await tx('Siklus 25 Okt – 24 Nov', 'Label/Medium', 'text/tertiary', 'Cycle'));
  const top = al('HORIZONTAL', 'Count', { center: true, between: true }); add(sc, top);
  top.appendChild(await tx('2 dari 6 lunas', 'Title/Medium', 'text/primary', 'Title'));
  top.appendChild(await tx('Rp 2.704.000 / siklus', 'Label/Medium', 'text/tertiary', 'Total'));
  const track = figma.createFrame(); track.name = 'Progress'; track.resize(296, 8); track.fills = [P('bg/surface-muted')];
  track.cornerRadius = 4; track.clipsContent = true; sc.appendChild(track);
  const fill = rect('Paid', Math.round(296 * 2 / 6), 8, 'bg/brand', 4); track.appendChild(fill); fill.x = 0; fill.y = 0;
  await kv(sc, 'Sudah dibayar', 'Rp 204.000', { valueColor: 'text/income' });
  await kv(sc, 'Sisa sampai gajian', 'Rp 2.500.000');
  add(b, mk('Alert', { Tone: 'Warning', Title: 'Internet sudah dibayar?', Body: 'Lewat 2 hari dari jatuh tempo dan belum ada transaksi yang cocok.', Action: 'Tandai lunas' }));
  await dayHeader(b, 'Terlambat', '1');
  const g0 = card(b, 'Group/Late');
  obl(g0, ['Internet', 'Jatuh tempo 9 Nov · lewat 2 hari', 'Rp 300.000', 'Late', 'Blue', 'wifi']);
  await dayHeader(b, 'Akan datang', '3');
  const g1 = card(b, 'Group/Upcoming');
  obl(g1, ['Listrik', '20 Nov · estimasi', '±Rp 350.000', 'Pending', 'Amber', 'zap']);
  obl(g1, ['Cicilan motor', '25 Nov', 'Rp 850.000', 'Pending', 'Blue', 'bike']);
  obl(g1, ['Kos', '25 Nov', 'Rp 1.000.000', 'Pending', 'Violet', 'bed']);
  await dayHeader(b, 'Lunas', '2');
  const g2 = card(b, 'Group/Paid');
  obl(g2, ['BPJS Kesehatan', 'Dibayar 3 Nov · BCA', 'Rp 150.000', 'Paid', 'Red', 'heart-handshake']);
  obl(g2, ['Streaming', 'Dibayar 1 Nov · GoPay', 'Rp 54.000', 'Paid', 'Red', 'tv']);
  return r.s;
}

async function build09() {
  const r = screen(NAMES.s09, 3200, { nav: 'Insight', gap: 16 }); const b = r.b;
  await titleHeader(b, 'Insight', null);
  add(b, await tx('Siklus 25 Okt – 24 Nov · hari ke-18 dari 31', 'Body/Small', 'text/tertiary', 'Cycle'));
  // forecast card
  const fc = card(b, 'Forecast', { pad: [16, 16], gap: 12 });
  const head = al('HORIZONTAL', 'Head', { center: true, between: true }); add(fc, head);
  head.appendChild(await tx('Proyeksi belanja akhir siklus', 'Label/Medium', 'text/secondary', 'Label'));
  head.appendChild(mk('Badge', { Tone: 'Success', Label: 'Aman' }));
  add(fc, await tx('Rp 1.500.000', 'Headline/Small', 'text/primary', 'Value'));
  add(fc, await tx('Di bawah batas aman Rp 1.800.000 · peluang melewati batas 15%', 'Body/Small', 'text/tertiary', 'Caption'));
  const ch = chartFrame(fc, 296, 140);
  const X = d => d / 31 * 296, Y = v => 140 - v / 2200 * 140;
  poly(ch, [[X(18), Y(780)], [X(31), Y(1850)], [X(31), Y(1250)]], { fill: 'tone/brand/bg', close: true, name: 'P10–P90 band' });
  poly(ch, [[0, Y(1800)], [296, Y(1800)]], { stroke: 'status/danger', w: 1.5, dash: [4, 4], name: 'Batas aman' });
  poly(ch, [[X(0), Y(0)], [X(3), Y(90)], [X(6), Y(200)], [X(9), Y(330)], [X(12), Y(480)], [X(15), Y(640)], [X(18), Y(780)]], { stroke: 'status/safe', w: 2.5, name: 'Aktual' });
  poly(ch, [[X(18), Y(780)], [X(31), Y(1500)]], { stroke: 'tone/brand/fg', w: 2, dash: [5, 4], name: 'Proyeksi P50' });
  const dot = figma.createEllipse(); dot.name = 'Today'; dot.resize(8, 8); dot.fills = [P('status/safe')];
  ch.appendChild(dot); dot.x = X(18) - 4; dot.y = Y(780) - 4;
  await legend(fc, [['Aktual', 'status/safe'], ['Rentang proyeksi', 'tone/brand/bg', 8], ['Batas aman', 'status/danger']]);
  // categories
  const cc = card(b, 'Categories', { pad: [16, 16], gap: 12 });
  add(cc, await tx('Pengeluaran per kategori', 'Title/Small', 'text/primary', 'Title'));
  const cats = [['Makan & Minum', 'Rp 296.000', '38%', 0.38, 'tone/amber/fg'], ['Belanja', 'Rp 187.000', '24%', 0.24, 'tone/violet/fg'], ['Tagihan', 'Rp 140.000', '18%', 0.18, 'tone/brand/fg'], ['Transport', 'Rp 109.000', '14%', 0.14, 'tone/blue/fg'], ['Lainnya', 'Rp 48.000', '6%', 0.06, 'tone/neutral/fg']];
  const bar = al('HORIZONTAL', 'StackedBar', { gap: 2 }); add(cc, bar); bar.clipsContent = true; bar.cornerRadius = 5;
  for (const c of cats) bar.appendChild(rect(c[0], Math.max(4, Math.round(c[3] * 286)), 10, c[4]));
  for (const c of cats) {
    const row = al('HORIZONTAL', 'Cat/' + c[0], { center: true, gap: 8 }); add(cc, row);
    const d = figma.createEllipse(); d.name = 'Dot'; d.resize(8, 8); d.fills = [P(c[4])]; row.appendChild(d);
    add(row, await tx(c[0], 'Body/Medium', 'text/primary', 'Name'));
    row.appendChild(await tx(c[1], 'Title/Small', 'text/primary', 'Amount'));
    const pct = await tx(c[2], 'Label/Small', 'text/tertiary', 'Pct'); row.appendChild(pct);
    pct.textAlignHorizontal = 'RIGHT'; pct.textAutoResize = 'HEIGHT'; pct.resize(32, pct.height);
  }
  // alert feedback
  const ac = card(b, 'AlertFeedback', { pad: [16, 16], gap: 12 });
  add(ac, await tx('Peringatan terakhir', 'Title/Small', 'text/primary', 'Title'));
  const ar = al('HORIZONTAL', 'Alert', { center: true, gap: 12 }); add(ac, ar);
  const tile = mk('Tile'); tone(tile, 'Amber', 'alert-triangle'); ar.appendChild(tile);
  const col = al('VERTICAL', 'Text', { gap: 2 }); add(ar, col);
  add(col, await tx('Belanja lebih cepat dari biasanya', 'Title/Small', 'text/primary', 'Title'));
  add(col, await tx('Pace · 3 Nov', 'Body/Small', 'text/tertiary', 'Meta'));
  ar.appendChild(await iconBtn('thumbs-up', { size: 36, iconSize: 18 }));
  ar.appendChild(await iconBtn('thumbs-down', { size: 36, iconSize: 18 }));
  add(ac, await tx('Feedback-mu membantu Moneytoring menyesuaikan kapan peringatan muncul.', 'Body/Small', 'text/tertiary', 'Caption'));
  // premium teaser
  const pc = al('VERTICAL', 'PremiumTeaser', { fill: 'bg/brand-subtle', rad: 'lg', pad: [16, 16], gap: 8 }); add(b, pc);
  const ph = al('HORIZONTAL', 'Head', { center: true, gap: 6 }); add(pc, ph);
  ph.appendChild(await ico('sparkles', 'tone/brand/fg', 18));
  ph.appendChild(await tx('Premium', 'Label/Medium', 'text/brand', 'Label'));
  add(pc, await tx('Laporan multi-siklus', 'Title/Medium', 'text/primary', 'Title'));
  add(pc, await tx('Bandingkan pola belanja 6–12 siklus terakhir dan lihat tren tiap kategori.', 'Body/Medium', 'text/secondary', 'Body'));
  pc.appendChild(mk('Button', { Style: 'Primary', Size: 'Medium', Label: 'Coba Premium' }));
  return r.s;
}

async function build10() {
  const r = screen(NAMES.s10, 3600, { gap: 16 }); const b = r.b; const s = r.s;
  await appBar(b, 'Simulasi pembelian', mk('Badge', { Tone: 'Neutral', Label: '2 dari 3 gratis' }));
  add(b, await tx('Kalau aku beli…', 'Headline/Small', 'text/primary', 'Title'));
  const ic = card(b, 'Input', { pad: [16, 16], gap: 8 });
  add(ic, await tx('Nominal', 'Label/Medium', 'text/tertiary', 'Label'));
  const vr = al('HORIZONTAL', 'Value', { gap: 6, center: true }); add(ic, vr);
  vr.appendChild(await tx('Rp', 'Title/Medium', 'text/tertiary', 'Prefix'));
  vr.appendChild(await tx('800.000', 'Headline/Large', 'text/primary', 'Amount'));
  divider(ic);
  add(ic, await tx('Untuk apa?', 'Label/Medium', 'text/tertiary', 'Label'));
  add(ic, await tx('Sepatu lari', 'Body/Large', 'text/primary', 'Note'));
  add(b, await tx('Kapan?', 'Label/Medium', 'text/secondary', 'WhenLabel'));
  const when = al('HORIZONTAL', 'When', { gap: 8 }); add(b, when);
  when.appendChild(mk('Chip', { State: 'Selected', Label: 'Hari ini' }));
  when.appendChild(mk('Chip', { State: 'Default', Label: 'Setelah gajian · 25 Nov' }));
  const rc = card(b, 'Result', { pad: [16, 16], gap: 12 });
  const rh = al('HORIZONTAL', 'Head', { center: true, gap: 12 }); add(rc, rh);
  const tile = mk('Tile'); tone(tile, 'Red', 'alert-triangle'); rh.appendChild(tile);
  const col = al('VERTICAL', 'Text', { gap: 2 }); add(rh, col);
  add(col, await tx('Kewajiban jadi berisiko', 'Title/Small', 'text/danger', 'Title'));
  add(col, await tx('Listrik (20 Nov) tidak tertutup', 'Body/Small', 'text/tertiary', 'Subtitle'));
  divider(rc);
  await compareRow(rc, 'Aman dibelanjakan', 'Rp 760.000', '−Rp 40.000', 'text/danger');
  await compareRow(rc, 'Jatah harian', 'Rp 54.300', 'Rp 0', 'text/danger');
  const sug = al('HORIZONTAL', 'Suggestion', { fill: 'bg/brand-subtle', rad: 'md', pad: [12, 12], gap: 8 }); add(rc, sug);
  sug.appendChild(await ico('sparkles', 'tone/brand/fg', 18));
  add(sug, await tx('Saran: tunda 8 hari sampai gajian. Setelah 25 Nov pembelian ini aman dan jatah harianmu tetap Rp 48.000.', 'Body/Small', 'text/primary', 'Text'));
  const f = footer(s);
  add(f, mk('Button', { Style: 'Primary', Size: 'Large', Label: 'Tunda & ingatkan saya' }));
  add(f, mk('Button', { Style: 'Ghost', Size: 'Large', Label: 'Tetap beli & catat' }));
  return s;
}

async function build11() {
  const r = screen(NAMES.s11, 4000, { gap: 16 }); const b = r.b;
  await appBar(b, 'Detail peringatan', null);
  const hero = al('VERTICAL', 'Hero', { gap: 8 }); add(b, hero);
  const hr = al('HORIZONTAL', 'Tags', { gap: 8, center: true }); add(hero, hr);
  const tile = mk('Tile'); tone(tile, 'Red', 'alert-triangle'); hr.appendChild(tile);
  hr.appendChild(mk('Badge', { Tone: 'Danger', Label: 'Berisiko' }));
  add(hero, await tx('Cicilan motor 25 Nov berisiko tidak tertutup', 'Headline/Small', 'text/primary', 'Title'));
  add(hero, await tx('Kalau pola belanja 7 hari terakhir berlanjut, uangmu diperkirakan kurang Rp 350.000 saat jatuh tempo.', 'Body/Medium', 'text/secondary', 'Body'));
  const cc = card(b, 'Projection', { pad: [16, 16], gap: 12 });
  add(cc, await tx('Proyeksi saldo sampai 25 Nov', 'Title/Small', 'text/primary', 'Title'));
  const ch = chartFrame(cc, 296, 120);
  const X = d => d / 14 * 296, Y = v => 120 - v / 1400 * 120;
  poly(ch, [[X(0), Y(1210)], [X(14), Y(650)], [X(14), Y(350)]], { fill: 'tone/red/bg', close: true, name: 'Rentang proyeksi' });
  poly(ch, [[0, Y(850)], [296, Y(850)]], { stroke: 'status/danger', w: 1.5, dash: [4, 4], name: 'Kebutuhan cicilan' });
  poly(ch, [[X(0), Y(1210)], [X(14), Y(500)]], { stroke: 'tone/red/fg', w: 2.5, dash: [6, 4], name: 'Proyeksi saldo' });
  const d0 = figma.createEllipse(); d0.name = 'Today'; d0.resize(8, 8); d0.fills = [P('status/danger')]; ch.appendChild(d0); d0.x = -4; d0.y = Y(1210) - 4;
  const axis = al('HORIZONTAL', 'Axis', { between: true }); add(cc, axis);
  axis.appendChild(await tx('Hari ini · 11 Nov', 'Label/Small', 'text/tertiary', 'Start'));
  axis.appendChild(await tx('25 Nov', 'Label/Small', 'text/tertiary', 'End'));
  divider(cc);
  await kv(cc, 'Butuh untuk cicilan', 'Rp 850.000');
  await kv(cc, 'Proyeksi saldo 25 Nov', '≈ Rp 500.000');
  await kv(cc, 'Kekurangan', '−Rp 350.000', { valueColor: 'text/danger' });
  await sec(b, 'Cara mengamankan', null);
  const ac = card(b, 'Actions');
  await actionRow(ac, 'Turunkan jatah harian ke Rp 60.000', 'Hemat Rp 25.000/hari dari biasanya', 'Brand', 'trending-up');
  await actionRow(ac, 'Pindahkan dana dari akun lain', 'Tabungan BCA: Rp 1.200.000', 'Blue', 'wallet');
  await actionRow(ac, 'Geser target tabungan siklus ini', 'Kurangi Rp 350.000, kembalikan siklus depan', 'Violet', 'piggy-bank');
  const fb = card(b, 'Feedback', { pad: [16, 12], gap: 0 });
  fb.layoutMode = 'HORIZONTAL'; fb.counterAxisAlignItems = 'CENTER'; SP(fb, 'itemSpacing', 8);
  fb.layoutSizingHorizontal = 'FILL';
  add(fb, await tx('Peringatan ini berguna?', 'Body/Medium', 'text/secondary', 'Label'));
  fb.appendChild(await iconBtn('thumbs-up', { size: 36, iconSize: 18 }));
  fb.appendChild(await iconBtn('thumbs-down', { size: 36, iconSize: 18 }));
  return r.s;
}

// ---------- main ----------
async function main() {
  const page = await figma.getNodeByIdAsync(SCREENS_PAGE_ID);
  if (!page || page.type !== 'PAGE') throw new Error('Halaman "Screens — MVP" (4:3) tidak ditemukan. Pastikan plugin dijalankan di file Moneytoring — App Design (MVP).');
  await figma.setCurrentPageAsync(page);

  const vars = await figma.variables.getLocalVariablesAsync();
  V = {}; for (const v of vars) V[v.name] = v;
  const ts = await figma.getLocalTextStylesAsync();
  T = {}; for (const s of ts) T[s.name] = s;
  const es = await figma.getLocalEffectStylesAsync();
  E = {}; for (const s of es) E[s.name] = s;
  for (const st of ['Regular', 'Medium', 'SemiBold', 'Bold']) await figma.loadFontAsync({ family: 'Plus Jakarta Sans', style: st });
  await figma.loadFontAsync({ family: 'Inter', style: 'Regular' });
  C = {};
  for (const k of Object.keys(CID)) {
    const n = await figma.getNodeByIdAsync(CID[k]);
    if (!n) throw new Error('Komponen ' + k + ' (' + CID[k] + ') tidak ditemukan.');
    C[k] = n;
  }

  // idempotent: hapus frame lama dengan nama yang sama
  const names = Object.keys(NAMES).map(k => NAMES[k]);
  for (const n of page.children.filter(c => names.indexOf(c.name) !== -1)) n.remove();

  const built = [], errors = [];
  let home04 = null;
  const steps = [
    ['04', async () => { home04 = await build04(); return home04; }],
    ['05', build05],
    ['06', async () => build06(home04)],
    ['07', build07],
    ['08', build08],
    ['09', build09],
    ['10', build10],
    ['11', build11],
  ];
  for (const st of steps) {
    try {
      const node = await st[1]();
      if (node) built.push(node);
    } catch (e) {
      errors.push(st[0] + ': ' + (e && e.message ? e.message : String(e)));
    }
  }
  if (built.length) figma.viewport.scrollAndZoomIntoView(built);
  const msg = 'Moneytoring: ' + built.length + '/8 layar dibuat' + (errors.length ? ' · ' + errors.length + ' error (lihat console)' : '');
  if (errors.length) console.error('Moneytoring build errors:\n' + errors.join('\n'));
  figma.closePlugin(msg);
}

main().catch(e => {
  console.error(e);
  figma.closePlugin('Moneytoring gagal: ' + (e && e.message ? e.message : String(e)));
});
