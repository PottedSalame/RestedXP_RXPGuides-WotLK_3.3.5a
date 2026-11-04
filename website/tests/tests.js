import * as M from '../guide-editor/model.js';
import * as W from '../guide-editor/wowhead.js';
import {mapTests,mapUITests,fixture as mapFixture} from './map-tests.js';
import {waypoints,moveWaypoint} from '../guide-editor/map-model.js';

const output = document.getElementById('test-results');
const passed = [], failed = [];
function assert(value, message = 'Assertion failed') { if (!value) throw new Error(message); }
function equal(a, b, message = 'Values differ') { assert(JSON.stringify(a) === JSON.stringify(b), message + ': ' + JSON.stringify(a).slice(0, 200) + ' / ' + JSON.stringify(b).slice(0, 200)); }
function rejects(fn, pattern) { let error; try { fn(); } catch (e) { error = e; } assert(error && pattern.test(error.message), 'Expected failure matching ' + pattern); }
async function test(name, fn) { try { await fn(); passed.push(name); } catch (e) { failed.push(name + ': ' + e.message); } }
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const basic = '#wotlk\n#ac335\n#group RXPGuides Custom Guides\n#name Browser Fixture\nstep\n.goto Durotar,43.33,68.61\n.accept 4641 >>Accept Your Place In The World\n.target Kaltunk::10176\nstep << Warrior\n.complete 788,1 >>Kill boars\nstep\n.turnin 4641\n';
const parse = text => M.parseDocument(text).guides[0];
const catalogue = await fetch('../data/catalogue.json').then(r => r.json());
await mapTests(test,assert,equal,rejects,sleep);
let exported;

await test('UTF-8 BOM, Unicode and mixed endings round trip', () => {
  const original = '\uFEFF#group Custom\r\n#name Café\rstep\n>>你好\r\n';
  const bytes = M.encodeFile(original); equal([...M.encodeFile(M.decodeFile(bytes))], [...bytes]);
  equal(M.applyTextarea(original, original.replace(/\r\n?/g, '\n')), original);
  equal(M.applyTextarea(original, original.replace(/\r\n?/g, '\n').replace('Café', 'New')), original.replace('Café', 'New'));
});
await test('Invalid UTF-8 / binary / oversized inputs rejected', () => {
  rejects(() => M.decodeFile(new Uint8Array([255])), /./); rejects(() => M.decodeFile(new Uint8Array([0])), /Binary/);
  rejects(() => M.decodeFile(new Uint8Array(M.MAX_BYTES + 1)), /limit/);
});
await test('Raw source parsing and exact passthrough', () => { const parsed = M.parseDocument(basic); equal(parsed.guides.length, 1); equal(parsed.guides[0].body, basic); equal(parsed.guides[0].steps.length, 3); });
await test('Registration examples inside plain guide notes do not hijack import', () => {
  const text = '-- Recorded draft\n' + basic + '>>Example: RXPGuides.RegisterGuide([[example]])\n';
  for (const filename of ['guide.txt', 'guide.lua']) equal(M.parseDocument(text, filename).guides[0].body, text);
});
await test('Multiple Lua registrations and targeted edit', () => {
  const text = '-- attribution\r\nRXPGuides.RegisterGuide([=[' + basic + ']=])\r\nRXPGuides.RegisterGuide([[' + basic.replace('Browser Fixture', 'Second') + ']])\n';
  const parsed = M.parseDocument(text, 'file.lua'); equal(parsed.guides.length, 2); assert(!parsed.guides[0].external);
  const changed = M.setHeader(text, parsed.guides[0], 'name', 'Changed'); equal(changed, text.replace('Browser Fixture', 'Changed'));
});
await test('Commented and quoted fake calls ignored', () => {
  const text = '-- RXPGuides.RegisterGuide([[' + basic.replace(/\n/g, ' ') + ']])\n--[=[ RXPGuides.RegisterGuide([[' + basic + ']]) ]=]\nlocal text="RXPGuides.RegisterGuide([[fake]])"\nRXPGuides.RegisterGuide([[' + basic + ']])';
  const parsed = M.parseDocument(text, 'file.lua'); equal(parsed.guides.length, 1); assert(parsed.guides[0].external);
});
await test('Dynamic, concatenated, overloaded and malformed wrappers rejected', () => {
  for (const text of ['RXPGuides.RegisterGuide(source)', 'RXPGuides.RegisterGuide([[x]] .. y)', 'RXPGuides.RegisterGuide("group", [[x]])', 'RXPGuides.RegisterGuide([[unfinished']) assert(M.parseDocument(text, 'x.lua').errors.length);
});
await test('Encoded imports are explicitly unsupported', () => assert(M.parseDocument('1|123:YWJj|30300').errors[0].includes('account-bound')));
await test('External guards retained and isolated export blocked', () => {
  const text = 'if UnitFactionGroup("player") == "Alliance" then return end\nRXPGuides.RegisterGuide([[' + basic + ']])';
  const g = M.parseDocument(text, 'x.lua').guides[0]; assert(g.external); equal(M.editGuide(text, g, 0, 0, ''), text); rejects(() => M.companion(g, catalogue, 'Test'), /External/);
});
await test('Conditional duplicate headers preserved, forms refuse flattening', () => {
  const text = basic.replace('#name Browser Fixture', '#name Horde << Horde\n#name Alliance << Alliance');
  rejects(() => M.setHeader(text, parse(text), 'name', 'Bad'), /Conditional/); equal(parse(text).names, ['Horde', 'Alliance']);
});
await test('Form changes only selected instruction', () => {
  const text = basic.replace('.goto Durotar,43.33,68.61', '  .goto Durotar,43.33,68.61 >>Travel << Orc');
  const g = parse(text), line = g.steps[0].lines[0], old = M.instruction(line);
  const replacement = M.buildInstruction(old.tag, ['Durotar', '45', '68.61'], old.display, old.condition, old.leading);
  equal(M.editGuide(text, g, line.start, line.end, replacement), text.replace('43.33', '45'));
});
await test('Target and mob use production semicolon separators, not commas', () => {
  const line = '.target Smith, the Elder::123;Second NPC::124';
  equal(M.instruction({text: line}).args, ['Smith, the Elder::123', 'Second NPC::124']);
  equal(M.buildInstruction('target', ['Smith, the Elder::123'], '', '', ''), '.target Smith, the Elder::123');
});
await test('Production default arguments and special coordinates are preserved', () => {
  const guide = parse(basic + '.turnin 788,0\n.collect 6948\n.goto Durotar,40,60,-1\n.goto 1411/1,-400,1200\n');
  assert(!M.validate(guide, catalogue).some(item => item.severity === 'error'));
  assert(M.validate(guide, catalogue).some(item => item.message.includes('World-coordinate')));
});
await test('Positional gaps and multiline injection rejected', () => {
  rejects(() => M.buildInstruction('goto', ['Durotar', '1', '2', '', '1'], '', ''), /gaps/);
  rejects(() => M.buildInstruction('accept', ['1\n.turnin 2'], '', ''), /multiline/);
});
await test('Move step preserves whole blocks and conditions', () => {
  const g = parse(basic), moved = M.moveStep(basic, g, 1, -1), p = parse(moved);
  equal(p.steps[0].text, 'step << Warrior'); equal(p.steps[1].lines.map(l => l.text), g.steps[0].lines.map(l => l.text));
  equal(M.moveStep(moved, p, 0, 1), basic);
});
await test('Move final unterminated step adds necessary boundary', () => { const text = basic.trimEnd(), moved = M.moveStep(text, parse(text), 2, -1); equal(parse(moved).steps.length, 3); assert(moved.includes('.turnin 4641\nstep')); });
await test('Undo redo and no-op edits', () => { const h = new M.History(basic); h.set(basic); equal(h.undoStack.length, 0); h.set(basic + '\n'); h.undo(); equal(h.text, basic); h.redo(); equal(h.text, basic + '\n'); });
await test('Consecutive live edits undo as a group without crossing fields', () => {
  const h = new M.History('original'); h.set('a', 1); h.set('ab', 1); h.set('abc', 2);
  h.undo(); equal(h.text, 'ab'); h.undo(); equal(h.text, 'original'); h.redo(); equal(h.text, 'ab');
});
await test('Targeted live parse retains unrelated guides and exact container identity', () => {
  const text = '-- credit\r\n' + Array.from({length: 200}, (_, i) => 'RXPGuides.RegisterGuide([[' + basic.replace('Browser Fixture', 'Guide ' + i) + ']])\r\n').join('');
  const before = M.parseDocument(text, 'large.lua'), guide = before.guides[100];
  const next = M.setHeader(text, guide, 'name', 'Edited live');
  const updated = M.reparseEditedGuide(before, text, next, 100, 'large.lua');
  equal(updated, M.parseDocument(next, 'large.lua'));
  assert(updated.guides[0] === before.guides[0]);
  assert(updated.guides[199].steps === before.guides[199].steps, 'Unchanged guide reparsed');
  const broken = M.editGuide(text, guide, guide.steps[0].lines[0].start, guide.steps[0].lines[0].end, '>>]]');
  equal(M.reparseEditedGuide(before, text, broken, 100, 'large.lua'), M.parseDocument(broken, 'large.lua'));
});
await test('Wowhead references accept WotLK identities only', () => {
  equal(W.referenceInput('788', 'quests'), {type: 'quests', id: 788});
  equal(W.referenceInput('https://www.wowhead.com/wotlk/npc=10176/kaltunk', 'items'), {type: 'npcs', id: 10176});
  equal(W.referenceInput('Cutting Teeth', 'quests'), null);
  equal(W.searchURL('a & b'), 'https://www.wowhead.com/wotlk/search?q=a%20%26%20b');
  for (const url of ['https://www.wowhead.com/quest=788', 'https://evil.test/wotlk/quest=788', 'http://www.wowhead.com/wotlk/quest=788', 'https://wowhead.com@evil.test/wotlk/quest=788']) rejects(() => W.referenceInput(url, 'quests'), /WotLK/);
  rejects(() => W.referenceInput('0', 'quests'), /positive/);
});
await test('Wowhead tooltip markup becomes inert text only', () => {
  equal(W.tooltipText('<table><tr><td>Fish &amp; Chips<br>8 &lt; 9</td></tr></table><script>bad()</script><img src="https://invalid.test">'), 'Fish & Chips\n8 < 9');
  assert(W.tooltipText('&#x110000; &lt;img onerror=x&gt;').includes('<img onerror=x>'));
});
await test('Wowhead cache is bounded and rejects missing/malformed/oversized results', async () => {
  const requests = [], lookup = W.createLookup(async (url, options) => {
    requests.push(url); equal(options.credentials, 'omit'); equal(options.referrerPolicy, 'no-referrer'); equal(options.redirect, 'error');
    return new Response(JSON.stringify({name: 'Fixture', tooltip: '<b>Details</b>'}));
  });
  const ref = {type: 'quests', id: 1}; await lookup(ref); await lookup(ref); equal(requests.length, 1);
  for (let id = 2; id <= 33; id++) await lookup({type: 'quests', id});
  await lookup(ref); equal(requests.length, 34);
  for (const response of [new Response('', {status: 404}), new Response('{}'), new Response('x'.repeat(200001))]) {
    let error; try { await W.createLookup(async () => response)(ref); } catch (e) { error = e; } assert(error);
  }
});
await test('Validation distinguishes errors, unknown directives and labels', () => {
  const d = M.validate(parse(basic + 'step\n.goto Durotar,101,2\n.unknown 3\n#requires missing\n#label same\n#label same\n'), catalogue);
  assert(d.some(i => i.severity === 'error' && i.message.includes('Coordinates')));
  assert(d.some(i => i.severity === 'warning' && i.message.includes('.unknown')));
  assert(d.some(i => i.message.includes('missing'))); assert(d.some(i => i.message.includes('Repeated label')));
});
await test('Advanced instructions flagged, not executed', () => assert(M.validate(parse(basic + '.setquestdb arbitrary()\n.macro 1 >>/run example\n'), catalogue).filter(i => i.message.includes('security review')).length === 2));
await test('Companion format, custom identity and delimiter rejection', () => {
  const moved = moveWaypoint(basic,parse(basic),waypoints(parse(basic),mapFixture)[0],44,67);
  exported = M.companion(parse(moved), catalogue, 'BrowserTest');
  assert(exported.toc.includes('## Dependencies: RXPGuides')); assert(exported.toc.includes('30300'));
  equal(M.parseDocument(exported.lua, 'Guide.lua').guides[0].body.trim(), moved.trim());
  rejects(() => M.companion(parse(basic + '>>]]\n'), catalogue, 'Test'), /contains/);
  rejects(() => M.companion(parse(basic), catalogue, '../Test'), /ASCII/);
});
await test('Companion keeps outer attribution and removes only a payload BOM', () => {
  const source = '-- GPL attribution retained\nRXPGuides.RegisterGuide([[' + basic + ']])\n';
  const result = M.companion(M.parseDocument(source, 'x.lua').guides[0], catalogue, 'Test');
  assert(result.lua.includes('-- GPL attribution retained'));
  const bom = M.companion(parse('\uFEFF' + basic), catalogue, 'Test'); assert(!bom.lua.includes('\uFEFF'));
});
await test('Empty headers and invalid reward index cannot pass companion checks', () => {
  rejects(() => M.companion(parse(basic.replace('#name Browser Fixture', '#name ')), catalogue, 'Test'), /errors/);
  assert(M.validate(parse(basic.replace('.turnin 4641', '.turnin 4641,wrong')), catalogue).some(item => item.severity === 'error'));
});
await test('Large multi-guide source parses without losing content', () => {
  const text = Array.from({length: 200}, (_, i) => 'RXPGuides.RegisterGuide([[' + basic.replace('Browser Fixture', 'Fixture ' + i) + ']])\n').join('');
  const start = performance.now(), parsed = M.parseDocument(text, 'large.lua'); equal(parsed.guides.length, 200);
  equal(parsed.guides[199].body, basic.replace('Browser Fixture', 'Fixture 199')); assert(performance.now() - start < 5000, 'Large import exceeded 5 seconds');
});
await test('Snapshot lookup IDs and objective uncertainty', async () => {
  const [quests, npcs, facts] = await Promise.all(['quests.json', 'npcs.json', 'quests/4.json'].map(path => fetch('../data/' + path).then(r => r.json())));
  assert(quests.some(row => row[0] === 4641)); assert(npcs.some(row => row[1] === 'Kaltunk'));
  assert(facts['4641'].relations.creature_queststarter.length); assert(!Object.hasOwn(facts['4641'], 'clientObjectiveIndex'));
  assert(npcs.length > new Set(npcs.map(row => row[1])).size, 'Duplicate names must not be collapsed');
});

// Real production UI in an isolated frame. Restore any draft used by a person
// opening this test page manually; the automated runner uses a private profile.
const key = 'rxp-guide-editor-draft-v1', previousDraft = localStorage.getItem(key);
const frame = document.getElementById('app');
try {
  const loaded = new Promise(resolve => { frame.onload = resolve; }); frame.src = '../guide-editor/'; await loaded; await sleep(700);
  const w = frame.contentWindow, d = w.document, get = id => d.getElementById(id);
  if (new URLSearchParams(location.search).has('live')) await test('Opt-in live Wowhead WotLK CORS access in the editor origin', async () => {
    for (const [kind, id, name] of [['quest', 788, 'Cutting Teeth'], ['npc', 10176, 'Kaltunk'], ['item', 6948, 'Hearthstone'], ['object', 31, 'Old Lion Statue']]) {
      const response = await w.fetch('https://nether.wowhead.com/wotlk/tooltip/' + kind + '/' + id, {credentials: 'omit', referrerPolicy: 'no-referrer'});
      assert(response.ok); equal((await response.json()).name, name);
    }
  });
  // Offline deterministic responses; production calls still use the real lookup
  // module. No test sends requests to Wowhead or falls back to local entity data.
  const localFetch = w.fetch;
  let remoteCalls = 0;
  w.fetch = async (url, options) => {
    if (!String(url).startsWith('https://nether.wowhead.com/')) return localFetch(url, options);
    remoteCalls++;
    return String(url).endsWith('/4641') ? new w.Response(JSON.stringify({name: 'Your Place In The World', tooltip: '<b>Quest</b><br>Talk to Gornek.'})) : new w.Response('', {status: 404});
  };
  w.confirm = () => true; w.prompt = () => 'Cloned Test';
  const change = (id, value) => { get(id).value = value; get(id).dispatchEvent(new w.Event('change', {bubbles: true})); };
  const input = (id, value) => { get(id).value = value; get(id).dispatchEvent(new w.Event('input', {bubbles: true})); };
  await test('Production UI starts without errors', () => { assert(get('status').textContent.startsWith('Ready')); equal(get('steps').options.length, 1); assert(get('source').value.includes('#group RXPGuides Custom Guides')); });
  await test('Metadata is live without initialization writes or focus replacement', async () => {
    const old = get('source').value; change('header-name', 'name'); equal(get('source').value, old);
    const control = get('header-value'); control.focus(); input('header-value', 'Visual Test'); await sleep(0);
    assert(get('source').value.includes('#name Visual Test')); assert(get('guides').selectedOptions[0].textContent.includes('Visual Test'));
    assert(get('header-value') === control && d.activeElement === control);
  });
  await test('Source edits synchronize with forms', async () => {
    input('source', basic); await sleep(400); equal(get('steps').options.length, 3);
    equal(get('action').value, 'goto'); equal(get('arg-0').value, 'Durotar');
  });
  await test('Leaving source flushes pending edits before editing a form', async () => {
    get('source').focus(); input('source', basic.replace('43.33', '42'));
    get('arg-1').focus(); await sleep(0); equal(get('arg-1').value, '42'); assert(d.activeElement === get('arg-1'));
    input('arg-1', '41'); await sleep(0); assert(get('source').value.includes('Durotar,41,68.61'));
    input('source', basic); await sleep(400);
  });
  await test('Visual form edit, undo and redo', async () => {
    const control = get('arg-1'); control.focus(); input('arg-1', '4'); await sleep(0); input('arg-1', '44'); await sleep(0);
    assert(get('source').value.includes('Durotar,44,68.61'));
    assert(get('instructions').selectedOptions[0].textContent.includes('Durotar,44,68.61'));
    assert(get('arg-1') === control && d.activeElement === control);
    get('undo').click(); equal(get('source').value, basic); get('redo').click(); assert(get('source').value.includes('Durotar,44,68.61'));
  });
  await test('Text, conditions and preview update immediately; composing text waits', async () => {
    const control = get('display-text'); control.focus(); input('display-text', 'Walk to the den'); await sleep(0);
    assert(get('instructions').selectedOptions[0].textContent.includes('Walk to the den'));
    assert(get('preview').textContent.includes('Walk to the den'));
    control.setSelectionRange(4, 4); input('condition', 'Orc'); await sleep(0);
    equal(control.selectionStart, 4); assert(get('preview').textContent.includes('only if: Orc'));
    const before = get('source').value;
    control.value = 'Composing'; control.dispatchEvent(new w.InputEvent('input', {bubbles: true, isComposing: true})); await sleep(0); equal(get('source').value, before);
    control.dispatchEvent(new w.Event('compositionend', {bubbles: true})); await sleep(0); assert(get('source').value.includes('Composing'));
  });
  await test('New instruction previews without changing source until Add; Cancel discards draft', async () => {
    const before = get('source').value; get('new-line').click(); input('display-text', 'New draft'); await sleep(0);
    equal(get('source').value, before); assert(get('preview').textContent.includes('New draft'));
    get('cancel-line').click(); equal(get('source').value, before); assert(!get('preview').textContent.includes('New draft'));
    get('new-line').click(); input('display-text', 'Added note'); get('append-line').click();
    assert(get('source').value.includes('>>Added note')); assert(get('append-line').hidden); get('undo').click(); equal(get('source').value, before);
  });
  await test('Step controls and selection do not drop instructions', () => {
    get('duplicate-step').click(); equal(get('steps').options.length, 4); get('up').click(); get('down').click(); get('delete-step').click(); equal(get('steps').options.length, 3);
    get('add-step').click(); equal(get('steps').options.length, 4); get('undo').click(); equal(get('steps').options.length, 3);
  });
  await test('Unsafe markup stays inert', async () => {
    input('source', basic + 'step\n>><img src=x onerror="window.untrustedExecuted=true">\n'); await sleep(400); change('steps', '3');
    assert(!get('preview').querySelector('img')); assert(!w.untrustedExecuted); assert(get('preview').textContent.includes('<img'));
  });
  await test('Name search stays external and does not send a request while typing', async () => {
    const before = remoteCalls; input('query', 'Cutting Teeth'); await sleep(500); equal(remoteCalls, before);
    assert(get('search-wowhead').href.endsWith('/wotlk/search?q=Cutting%20Teeth')); equal(get('search-wowhead').target, '_blank'); assert(get('use-reference').disabled);
  });
  await test('Partial titles open WotLK search through either Search or Enter', async () => {
    const originalClick = w.HTMLAnchorElement.prototype.click, opened = [], before = remoteCalls;
    w.HTMLAnchorElement.prototype.click = function() { opened.push(this.href); };
    try {
      input('query', 'cutting'); get('lookup').click();
      input('query', '  sarkoth  '); get('reference-form').dispatchEvent(new w.Event('submit', {cancelable: true}));
      equal(opened, ['https://www.wowhead.com/wotlk/search?q=cutting', 'https://www.wowhead.com/wotlk/search?q=sarkoth']);
      await sleep(500); equal(remoteCalls, before); assert(get('use-reference').disabled);
    } finally { w.HTMLAnchorElement.prototype.click = originalClick; }
  });
  await test('Icy blue section accents remain distinct with readable text contrast', () => {
    const panels = [...d.querySelectorAll('.editor-grid > section')];
    const accents = panels.map(panel => w.getComputedStyle(panel).borderTopColor);
    assert(new Set(accents).size >= 3);
    const rgb = color => color.match(/[\d.]+/g).slice(0, 3).map(Number);
    const luminance = color => rgb(color).map(n => n / 255).map(n => n <= .04045 ? n / 12.92 : ((n + .055) / 1.055) ** 2.4)
      .reduce((sum, n, i) => sum + n * [.2126, .7152, .0722][i], 0);
    const contrast = (foreground, background) => {
      const a = luminance(foreground), b = luminance(background);
      return (Math.max(a, b) + .05) / (Math.min(a, b) + .05);
    };
    for (const accent of accents) { const [r, g, b] = rgb(accent); assert(b > g && g > r, 'Expected analogous blue accent'); }
    for (const band of d.querySelectorAll('header, footer')) {
      const style = w.getComputedStyle(band);
      assert(contrast(style.color, style.backgroundColor) >= 4.5);
      for (const link of band.querySelectorAll('a')) assert(contrast(w.getComputedStyle(link).color, style.backgroundColor) >= 4.5);
    }
    for (const panel of panels) {
      const title = panel.querySelector('h2'), style = w.getComputedStyle(title);
      const background = style.backgroundColor === 'rgba(0, 0, 0, 0)' ? w.getComputedStyle(title.parentElement).backgroundColor : style.backgroundColor;
      assert(contrast(style.color, background) >= 4.5, 'Heading contrast below 4.5:1');
    }
    const panel = d.querySelector('.reference-panel');
    for (const element of [get('search-wowhead'), panel.querySelector('.hint')]) assert(contrast(w.getComputedStyle(element).color, w.getComputedStyle(panel).backgroundColor) >= 4.5);
  });
  await test('Wowhead WotLK link loads details and explicitly updates the instruction', async () => {
    const old = get('source').value;
    input('query', 'https://www.wowhead.com/wotlk/quest=4641/your-place-in-the-world'); await sleep(700);
    equal(get('source').value, old); assert(!get('use-reference').disabled);
    get('use-reference').click(); assert(get('source').value !== old); equal(get('arg-0').value, '4641');
    assert(get('preview').textContent.includes('Your Place In The World')); assert(get('reference-details').textContent.includes('Verify .complete'));
  });
  await test('Missing reference facts do not prevent editing', async () => { input('query', '999999999'); await sleep(500); assert(get('reference-status').textContent.includes('No WotLK entry')); assert(!get('source').disabled); });
  await test('Unavailable Wowhead leaves authoring usable', async () => {
    const fetch = w.fetch;
    w.fetch = async path => String(path).startsWith('https:') ? new w.Response('', {status: 503}) : fetch(path);
    try { get('query').value = '6948'; change('reference-type', 'items'); await sleep(300); assert(get('reference-status').textContent.includes('Manual editing')); assert(!get('source').disabled); }
    finally { w.fetch = fetch; }
  });
  await test('Stale remote responses cannot replace newer results', async () => {
    const fetch = w.fetch; let resolve;
    w.fetch = async (url, options) => String(url).endsWith('/12345') ? new Promise(done => { resolve = done; }) : fetch(url, options);
    try {
      get('query').value = '12345'; change('reference-type', 'quests'); await sleep(10);
      input('query', '4641'); await sleep(500);
      resolve(new w.Response(JSON.stringify({name: 'Stale', tooltip: 'Old'}))); await sleep(10);
      assert(get('reference-details').textContent.includes('Your Place In The World')); assert(!get('reference-details').textContent.includes('Stale'));
    } finally { w.fetch = fetch; }
  });
  await test('Actual File import and byte-preserving download', async () => {
    const text = '\uFEFF' + basic.replace(/\n/g, '\r\n');
    const file = new w.File([M.encodeFile(text)], 'roundtrip.txt', {type: 'text/plain'}), transfer = new w.DataTransfer(); transfer.items.add(file); get('open').files = transfer.files; await get('open').onchange();
    let blob; const originalURL = w.URL.createObjectURL, originalClick = w.HTMLAnchorElement.prototype.click;
    w.URL.createObjectURL = value => { blob = value; return 'blob:test'; }; w.HTMLAnchorElement.prototype.click = () => {};
    try { get('save').click(); equal([...new Uint8Array(await blob.arrayBuffer())], [...M.encodeFile(text)]); }
    finally { w.URL.createObjectURL = originalURL; w.HTMLAnchorElement.prototype.click = originalClick; }
  });
  await test('Production companion downloads match filenames and content', async () => {
    const blobs = [], names = []; const originalURL = w.URL.createObjectURL, originalClick = w.HTMLAnchorElement.prototype.click;
    w.URL.createObjectURL = value => { blobs.push(value); return 'blob:test'; }; w.HTMLAnchorElement.prototype.click = function() { names.push(this.download); };
    try { get('toc').click(); get('lua').click(); equal(names, ['RXPGuides_Custom_MyGuide.toc', 'Guide.lua']); assert((await blobs[0].text()).includes('30300')); assert((await blobs[1].text()).includes('RegisterGuide')); }
    finally { w.URL.createObjectURL = originalURL; w.HTMLAnchorElement.prototype.click = originalClick; }
  });
  await test('Stale file read cannot overwrite a newer document', async () => {
    const file = new w.File([basic], 'late.txt'), transfer = new w.DataTransfer();
    let complete; file.arrayBuffer = () => new Promise(resolve => { complete = resolve; });
    transfer.items.add(file); get('open').files = transfer.files;
    // DataTransfer can return a new File wrapper, so override that exact object.
    get('open').files[0].arrayBuffer = file.arrayBuffer;
    const pending = get('open').onchange(); get('new').click(); complete(M.encodeFile(basic).buffer); await pending;
    assert(get('source').value.includes('#name My Guide')); assert(get('status').textContent.includes('cancelled'));
    input('source', basic); await sleep(400);
  });
  await test('Local draft is recoverable', async () => { await sleep(800); const draft = JSON.parse(localStorage.getItem(key)); assert(draft.text.includes('Browser Fixture')); assert(!get('restore').disabled); get('restore').click(); assert(get('source').value.includes('Browser Fixture')); });
  await test('Storage failure is visible, source remains editable', async () => {
    const original = w.Storage.prototype.setItem; w.Storage.prototype.setItem = () => { throw new Error('Quota'); };
    try { input('source', basic + '\n'); await sleep(1100); assert(get('storage-status').textContent.includes('could not be saved')); assert(get('source').value.includes('Browser Fixture')); }
    finally { w.Storage.prototype.setItem = original; }
  });
  await test('Narrow production layout has no horizontal page overflow', async () => {
    frame.width = '375'; await sleep(100);
    const overflowing = [...d.querySelectorAll('body *')].filter(e => e.getBoundingClientRect().right > d.documentElement.clientWidth + 2 || (e.scrollWidth > e.clientWidth + 2 && w.getComputedStyle(e).overflowX === 'visible')).slice(0, 8).map(e => (e.id || e.tagName) + ':' + e.scrollWidth + '/' + e.clientWidth);
    assert(d.documentElement.scrollWidth <= d.documentElement.clientWidth + 2, 'Horizontal overflow: ' + d.documentElement.scrollWidth + '/' + d.documentElement.clientWidth + ' ' + overflowing.join(', '));
    assert(d.querySelector('label[for="source"]')); assert(get('up').textContent === 'Move up');
  });
  await mapUITests(test,assert,equal,sleep,w,d,input,basic);
  w.onbeforeunload = null;
} catch (error) { failed.push('Production UI harness: ' + error.message); }
finally {
  // Removing the frame synchronously flushes its pagehide handler before the
  // caller's original browser draft is restored.
  frame.remove();
  if (previousDraft === null) localStorage.removeItem(key); else localStorage.setItem(key, previousDraft);
}

// Automated runner can serve real repo files as explicit read-only test fixtures.
if (new URLSearchParams(location.search).has('corpus')) await test('Actual repository corpus imports losslessly', async () => {
  const corpus = await fetch('./corpus.json').then(r => r.json());
  for (const file of corpus) {
    const parsed = M.parseDocument(file.text, file.name); assert(!parsed.errors.length, file.name + ': ' + parsed.errors.join(';')); assert(parsed.guides.length > 0, file.name);
    for (const guide of parsed.guides) equal(file.text.slice(guide.start, guide.end), guide.body, 'Corpus span');
    equal([...M.encodeFile(M.decodeFile(M.encodeFile(file.text)))], [...M.encodeFile(file.text)], 'Corpus bytes');
  }
});
output.dataset.status = failed.length ? 'failed' : 'passed';
output.textContent = JSON.stringify({passed, failed, companion: exported}, null, 2);
