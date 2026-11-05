import {NEW_GUIDE, FORMS, MAX_BYTES, History, decodeFile, encodeFile, parseDocument, instruction,
  buildInstruction, editGuide, setHeader, moveStep, newline, validate, guideSource, applyTextarea, reparseEditedGuide,
  newArguments, waypointMode, instructionHint, DEFAULT_TRAVEL_RADIUS,
  DETAILS, PURPOSES, guideDetails, setDetail, contributionPath} from './model.js';
import {referenceInput, referenceURL, searchURL, createLookup} from './wowhead.js';
import {createWorkspace} from './workspace.js';

const $ = id => document.getElementById(id);
const state = {history: new History(NEW_GUIDE), filename: 'MyGuide.txt', guide: 0, step: 0, line: 0,
  catalogue: {}, document: null, reference: null, saved: NEW_GUIDE, drafting: false, formEditable: false};
let sourceTimer, saveTimer, queryTimer, checkTimer, searchSerial = 0, documentSerial = 0, draftDirty = false;
let liveGroup = 0, lastInput = null, lastInputTime = 0, liveQueued = false, liveAction = null;
let lookupController;
let terrainMap, terrainModule;
let parsedText = null, parsedFilename = null;
const lookup = createLookup();
const DRAFT_KEY = 'rxp-guide-editor-draft-v1';
const node = (tag, text) => { const result = document.createElement(tag); if (text !== undefined) result.textContent = text; return result; };
const option = (label, value) => { const result = node('option', label); result.value = value; return result; };
const guide = () => state.document?.guides[state.guide];
const step = () => guide()?.steps[state.step];
const currentLine = () => step()?.lines[state.line];
const workspace = createWorkspace({beforeView: flushSource});
function status(message, error = false) { $('status').textContent = message; $('status').className = 'status' + (error ? ' error' : ''); }
function safely(action) { return event => { event?.preventDefault(); try { action(event); } catch (error) { status(error.message, true); } }; }
function flushSource() {
  flushLive();
  if (sourceTimer) { clearTimeout(sourceTimer); sourceTimer = null; commit(applyTextarea(state.history.text, $('source').value), false); }
}
function commit(text, replaceSource = true) {
  if (encodeFile(text).length > MAX_BYTES) throw new Error('Document exceeds 12 MiB.');
  if (state.history.set(text)) documentSerial++;
  refresh(replaceSource); scheduleSave();
}
function saveDraft() {
  if (!draftDirty) return;
    try {
      localStorage.setItem(DRAFT_KEY, JSON.stringify({version: 1, filename: state.filename, text: state.history.text, guide: state.guide, step: state.step}));
      $('storage-status').textContent = 'Draft saved in this browser.';
      $('restore').disabled = false;
      draftDirty = false;
    } catch { $('storage-status').textContent = 'Draft could not be saved. Download a backup now.'; }
}
function scheduleSave() {
  draftDirty = true;
  clearTimeout(saveTimer);
  saveTimer = setTimeout(saveDraft, 600);
}
function readDraft() {
  try { const draft = JSON.parse(localStorage.getItem(DRAFT_KEY)); return draft?.version === 1 && typeof draft.text === 'string' && typeof draft.filename === 'string' && encodeFile(draft.text).length <= MAX_BYTES ? draft : null; }
  catch { return null; }
}
function updateMetadata() {
  const name = $('header-name').value;
  const matches = guide()?.headers.filter(line => new RegExp('^\\s*#' + name + '\\s+').test(line.text)) || [];
  $('header-value').value = matches[0]?.text.replace(new RegExp('^\\s*#' + name + '\\s+'), '') || '';
  const fields = guideDetails(guide());
  // Keep nonstandard source values visible without coercing them to a preset.
  $('detail-purpose').replaceChildren(option('Not specified', ''), ...PURPOSES.map(value => option(value, value)));
  if (fields.purpose.value && !PURPOSES.includes(fields.purpose.value)) $('detail-purpose').append(option(fields.purpose.value + ' (source)', fields.purpose.value));
  for (const [key, field] of Object.entries(fields)) {
    $('detail-' + key).value = field.value;
    $('detail-' + key).disabled = !guide() || field.repeated;
  }
  $('details-status').textContent = Object.values(fields).some(field => field.repeated) ? 'Repeated details: edit Source.' : '';
  updateContributionPath();
}
function updateContributionPath() {
  $('contribution-path').textContent = contributionPath(guide()) || 'Set server/realm, purpose, zone and a file-safe guide name.';
}
function populateForm() {
  const parsed = currentLine() && instruction(currentLine());
  const supported = parsed && Object.hasOwn(FORMS, parsed.tag) && parsed.args.length <= FORMS[parsed.tag].length;
  if (supported) { $('action').value = parsed.tag; renderArguments(parsed.args); $('display-text').value = parsed.display; $('condition').value = parsed.condition; }
  else { renderArguments([]); $('display-text').value = ''; $('condition').value = ''; }
  state.formEditable = Boolean(supported);
  $('line-hint').textContent = supported ? '' : 'Edit this line in Source, or add a new instruction.';
  $('append-line').hidden = true; $('cancel-line').hidden = true;
  $('instruction-advanced').open = Boolean($('condition').value);
}
function renderArguments(values = []) {
  $('arguments').replaceChildren();
  for (const [index, title] of FORMS[$('action').value].entries()) {
    const label = node('label', title), input = node('input');
    input.id = 'arg-' + index; input.value = values[index] || ''; input.autocomplete = 'off';
    if ($('action').value === 'goto' && index === 0) input.setAttribute('list', 'map-tokens');
    const error=node('small');error.id='arg-error-'+index;error.className='error';error.hidden=true;input.setAttribute('aria-describedby',error.id);
    label.append(input,error); $('arguments').append(label);
  }
  updateActionHint();
}
function updateActionHint() {
  const tag = $('action').value, args = FORMS[tag].map((_, i) => $('arg-' + i).value.trim());
  $('waypoint-kind-field').hidden = tag !== 'goto';
  if (tag === 'goto') $('waypoint-kind').value = waypointMode(args);
  $('action-hint').textContent = instructionHint({tag, args});
}
function renderSteps() {
  const query=$('step-search').value.trim().toLowerCase(),items=guide()?.steps||[];
  const matched=items.map((item,index)=>({item,index})).filter(({item,index})=>!query||String(index+1)===query||item.lines.some(line=>line.text.toLowerCase().includes(query)));
  const shown=matched.slice();
  if(items[state.step]&&!shown.some(({index})=>index===state.step))shown.push({item:items[state.step],index:state.step});
  shown.sort((a,b)=>a.index-b.index);
  $('steps').replaceChildren(...shown.map(({item,index})=>option((index+1)+'. '+(item.lines.find(line=>/^\s*(>>|\+|\.)/.test(line.text))?.text.trim()||item.text).slice(0,110),index)));
  $('steps').value=state.step;
  $('step-search-status').textContent=query?matched.length+' matching steps'+(shown.length>matched.length?' · selected step retained':''):'';
}
function selectionContext() {
  $('document-name').textContent=guide()?.names.join(' / ')||state.filename;
  workspace.context(step()?'Editing step '+(state.step+1)+(state.drafting?' · new instruction':' · instruction '+(state.line+1)):'Select or add a step.');
}
function openDiagnostic(item,snapshot) {
  flushSource();
  if(snapshot!==state.history.text){check();status('Source changed. Select the updated problem.');return;}
  const active=guide(),line=active?.lines[item.line-1];
  if(line){
    const at=active.steps.findIndex(s=>line.start>=s.start&&line.start<s.stop);
    if(at>=0){state.step=at;state.line=Math.max(0,active.steps[at].lines.findIndex(l=>l.start===line.start));refresh();}
  }
  workspace.show('source');
  const start=line?state.history.text.slice(0,active.start+line.start).replace(/\r\n?/g,'\n').length:0;
  $('source').focus();$('source').setSelectionRange(start,start+(line?.text.length||0));
  const preceding=$('source').value.slice(0,start).split('\n').length-1;
  $('source').scrollTop=Math.max(0,preceding*parseFloat(getComputedStyle($('source')).lineHeight)-60);
}
function check() {
  const diagnostics = [...(state.document?.errors || []).map(message => ({severity: 'error', message})), ...(guide() ? validate(guide(), state.catalogue) : [])];
  $('diagnostics').replaceChildren();
  const snapshot=state.history.text,currentNumber=guide()?.lines.findIndex(line=>line.start===currentLine()?.start)+1;
  $('instruction-errors').replaceChildren();
  for(const input of $('arguments').querySelectorAll('input')){input.removeAttribute('aria-invalid');const help=$(input.getAttribute('aria-describedby'));help.hidden=true;help.textContent='';}
  const fieldError=(index,message)=>{const input=$('arg-'+index),help=$('arg-error-'+index);if(input&&help){input.setAttribute('aria-invalid','true');help.textContent=message;help.hidden=false;}};
  for (const item of diagnostics) {
    const li=node('li'),button=node('button',(item.line?'Line '+item.line+': ':'')+item.message);
    li.className=item.severity;button.type='button';button.className='diagnostic-link';button.onclick=safely(()=>openDiagnostic(item,snapshot));li.append(button);$('diagnostics').append(li);
    if(item.line&&item.line===currentNumber){
      const local=node('li',item.message);local.className=item.severity;$('instruction-errors').append(local);
      if(item.severity==='error'&&state.formEditable&&!state.drafting){
        if(/integer ID|Item ID/.test(item.message))fieldError(0,item.message);
        else if(/client objective index|Quantity/.test(item.message))fieldError(1,item.message);
        else if(/Radius/.test(item.message))fieldError(3,item.message);
        else if(/Coordinates must/.test(item.message))for(const index of [1,2]){
          const value=$('arg-'+index)?.value,world=/^\d+\/\d+$/.test($('arg-0')?.value||'');
          if(!value||!Number.isFinite(Number(value))||!world&&(Number(value)<0||Number(value)>100))fieldError(index,item.message);
        }
      }
    }
  }
  const errors=diagnostics.filter(d=>d.severity==='error').length,warnings=diagnostics.length-errors;
  $('problems-summary').textContent='Problems · '+errors+' errors · '+warnings+' warnings';
  if (!diagnostics.length) $('diagnostics').append(node('li', 'No source issues found. Test in-game before use.'));
  return diagnostics;
}
function refresh(replaceSource = true) {
  clearTimeout(checkTimer); state.drafting = false; lastInput = null;
  if (parsedText !== state.history.text || parsedFilename !== state.filename) {
    state.document = parseDocument(state.history.text, state.filename);
    parsedText = state.history.text; parsedFilename = state.filename;
  }
  state.guide = Math.max(0, Math.min(state.guide, state.document.guides.length - 1));
  $('guides').replaceChildren(...state.document.guides.map((item, i) => option((i + 1) + '. ' + (item.names.join(' / ') || '(unnamed)'), i)));
  $('guides').value = state.guide;
  const active = guide();
  state.step = Math.max(0, Math.min(state.step, (active?.steps.length || 0) - 1));
  renderSteps();
  state.line = Math.max(0, Math.min(state.line, (step()?.lines.length || 0) - 1));
  $('instructions').replaceChildren(...(step()?.lines || []).map((item, i) => option(item.text.trim().slice(0, 150) || '(blank)', i)));
  $('instructions').value = state.line;
  renderPreview();
  if (replaceSource) $('source').value = state.history.text;
  $('undo').disabled = !state.history.undoStack.length; $('redo').disabled = !state.history.redoStack.length;
  for (const id of ['add-step', 'raw', 'clone']) $(id).disabled = !active;
  for (const id of ['duplicate-step', 'delete-step', 'append-line', 'new-line']) $(id).disabled = !step();
  $('delete-line').disabled = !currentLine(); $('up').disabled = !step() || state.step === 0;
  $('down').disabled = !step() || state.step === active.steps.length - 1;
  updateMetadata(); populateForm(); check(); updateExport(); terrainMap?.sync();
}
function renderPreview(draft) {
  selectionContext();
  $('preview').replaceChildren();
  for (const line of step()?.lines || []) {
    const parsed = instruction(line);
    if (!parsed) continue;
    const text = (parsed.display || '.' + parsed.tag + ' ' + parsed.args.join(','))
      + (parsed.tag === 'goto' ? ' [' + (waypointMode(parsed.args) === 'travel' ? 'arrive within ' + parsed.args[3] + ' yards' : waypointMode(parsed.args) === 'navigation' ? 'navigation only' : 'special waypoint') + ']' : '');
    $('preview').append(node('li', text + (parsed.condition ? ' [only if: ' + parsed.condition + ']' : '')));
  }
  if (draft) $('preview').append(node('li', 'New: ' + (instruction({text: draft})?.display || draft.trim())));
}
function queueLive(kind, target) {
  if (target !== lastInput || performance.now() - lastInputTime > 1000) liveGroup++;
  lastInput = target; lastInputTime = performance.now();
  liveAction = kind;
  if (!liveQueued) { liveQueued = true; queueMicrotask(flushLive); }
}
function flushLive() {
  if (!liveQueued) return;
  liveQueued = false;
  const kind = liveAction; liveAction = null;
  try {
    if (kind === 'instruction') updateActionHint();
    if (kind === 'instruction' && state.drafting) { renderPreview(formLine()); return; }
    if (!guide() || (kind === 'instruction' && !state.formEditable)) return;
    const before = state.history.text;
    const next = kind.startsWith('detail:') ? setDetail(before, guide(), kind.slice(7), $('detail-' + kind.slice(7)).value)
      : kind === 'header' ? setHeader(before, guide(), $('header-name').value, $('header-value').value)
      : editGuide(before, guide(), currentLine().start, currentLine().end, formLine());
    if (next === before) return;
    if (encodeFile(next).length > MAX_BYTES) throw new Error('Document exceeds 12 MiB.');
    state.document = reparseEditedGuide(state.document, before, next, state.guide, state.filename);
    parsedText = next; parsedFilename = state.filename;
    state.history.set(next, liveGroup); documentSerial++;
    if (!guide() || state.document.errors.length) { refresh(); scheduleSave(); return; }
    // Keep focused inputs, caret, list selection and scroll positions intact.
    $('source').value = next;
    if (kind === 'header') $('guides').options[state.guide].textContent = (state.guide + 1) + '. ' + (guide().names.join(' / ') || '(unnamed)');
    else if (kind === 'instruction') {
      $('instructions').options[state.line].textContent = currentLine().text.trim().slice(0, 150) || '(blank)';
      const selectedStep=[...$('steps').options].find(o=>Number(o.value)===state.step);
      if(selectedStep)selectedStep.textContent = (state.step + 1) + '. ' + (step().lines.find(line => /^\s*(>>|\+|\.)/.test(line.text))?.text.trim() || step().text).slice(0, 110);
      $('line-hint').textContent = '';
    }
    updateContributionPath();
    renderPreview(); $('undo').disabled = false; $('redo').disabled = true;
    clearTimeout(checkTimer); checkTimer = setTimeout(() => { check(); updateExport(); }, 250);
    scheduleSave(); terrainMap?.sync();
  } catch (error) { status('Edit not applied: ' + error.message, true); }
}
function updateExport() {
  try {
    guideSource(guide());
    $('raw').disabled = false;
    $('export-status').textContent = 'Paste the downloaded text into RXPGuides → Import → Website guide source.';
  } catch (error) { $('raw').disabled = true; $('export-status').textContent = error.message; }
}
function download(filename, text) {
  const url = URL.createObjectURL(new Blob([encodeFile(text)], {type: 'text/plain;charset=utf-8'}));
  const a = node('a'); a.href = url; a.download = filename.replace(/[\\/:*?"<>|]/g, '_'); document.body.append(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1500);
}
function replaceDocument(text, filename) {
  documentSerial++;
  clearTimeout(sourceTimer); sourceTimer = null; clearTimeout(saveTimer);
  state.history = new History(text); state.filename = filename; state.guide = 0; state.step = 0; state.line = 0;
  state.saved = text; $('step-search').value=''; refresh(); scheduleSave();
  status(filename + ': ' + state.document.guides.length + ' supported guide(s).');
}
function confirmReplace() { flushSource(); return state.history.text === state.saved || confirm('Replace the current document? Download it first if you need a separate backup.'); }

for (const tag of Object.keys(FORMS)) $('action').append(option(tag === 'note' ? 'Note — display only (>>)' : tag === 'objective' ? 'Manual objective (+)' : '.' + tag, tag));
$('action').addEventListener('change', event => { renderArguments(newArguments($('action').value)); queueLive('instruction', event.target); });
$('waypoint-kind').addEventListener('change', event => {
  if ($('action').value !== 'goto') return;
  const travel = event.target.value === 'travel';
  $('arg-3').value = travel ? DEFAULT_TRAVEL_RADIUS : ''; $('arg-4').value = '';
  queueLive('instruction', event.target);
});
$('instruction-form').addEventListener('input', event => {
  // Selects own their change transaction; do not read the old argument fields
  // between the browser's input event and its subsequent change event.
  if (!event.isComposing && !['action', 'waypoint-kind'].includes(event.target.id)) queueLive('instruction', event.target);
});
$('instruction-form').addEventListener('compositionend', event => queueLive('instruction', event.target));
$('header-value').addEventListener('input', event => { if (!event.isComposing) queueLive('header', event.target); });
$('header-value').addEventListener('compositionend', event => queueLive('header', event.target));
for (const key of Object.keys(DETAILS)) {
  const field = $('detail-' + key);
  field.addEventListener('input', event => { if (!event.isComposing) queueLive('detail:' + key, field); });
  field.addEventListener('compositionend', () => queueLive('detail:' + key, field));
}
$('guide-details').onsubmit = safely(() => flushLive());
$('source').addEventListener('input', () => { clearTimeout(sourceTimer); sourceTimer = setTimeout(safely(() => { sourceTimer = null; commit(applyTextarea(state.history.text, $('source').value), false); }), 300); });
$('source').addEventListener('blur', event => {
  if (!sourceTimer) return;
  // A click into a form must use the latest source, even within its debounce.
  // Refresh may replace an argument input; restore the intended focus by ID.
  const target = event.relatedTarget, id = target?.id;
  flushSource();
  if (id && target !== $(id)) queueMicrotask(() => $(id)?.focus());
});
$('new').onclick = safely(() => { if (confirmReplace()) replaceDocument(NEW_GUIDE, 'MyGuide.txt'); });
$('open').onchange = async () => {
  const file = $('open').files[0]; if (!file) return;
  try {
    if (!confirmReplace()) return;
    if (file.size > MAX_BYTES) throw new Error('File exceeds 12 MiB.');
    const serial = ++documentSerial, bytes = await file.arrayBuffer();
    if (serial !== documentSerial || sourceTimer) { status('Open cancelled: the document changed.'); return; }
    replaceDocument(decodeFile(bytes), file.name);
  }
  catch (error) { status(error.message, true); } finally { $('open').value = ''; }
};
$('save').onclick = safely(() => { flushSource(); download(state.filename, state.history.text); state.saved = state.history.text; status('Download requested.'); });
$('raw').onclick = safely(() => { flushSource(); download('guide-source.txt', guideSource(guide())); });
$('clone').onclick = safely(() => {
  flushSource(); const active = guide();
  if (active.external) throw new Error('This guide has external Lua dependencies. Edit/save the original container; isolated cloning is blocked.');
  const name = prompt('Name for the independent custom guide:', (active.names[0] || 'My Guide') + ' (Custom)'); if (!name) return;
  let text = (active.provenance || '').replace(/^\uFEFF/, '') + active.body, parsed = parseDocument(text).guides[0];
  text = setHeader(text, parsed, 'group', 'RXPGuides Custom Guides'); parsed = parseDocument(text).guides[0]; text = setHeader(text, parsed, 'name', name);
  if (confirmReplace()) replaceDocument(text, 'custom-guide.txt');
});
$('undo').onclick = safely(() => { flushSource(); state.history.undo(); refresh(); scheduleSave(); });
$('redo').onclick = safely(() => { flushSource(); state.history.redo(); refresh(); scheduleSave(); });
$('restore').onclick = safely(() => { clearTimeout(saveTimer); const draft = readDraft(); if (draft && confirm('Replace this document with the last browser draft?')) { replaceDocument(draft.text, draft.filename); state.guide = Number(draft.guide) || 0; state.step = Number(draft.step) || 0; refresh(); } });
$('guides').onchange = safely(event => { const selected = Number(event.target.value); flushSource(); state.guide = selected; state.step = 0; state.line = 0; $('step-search').value=''; refresh(); });
$('step-search').oninput = safely(()=>{flushSource();renderSteps();});
$('steps').onchange = safely(event => { const selected = Number(event.target.value); flushSource(); state.step = selected; state.line = 0; refresh(); });
$('instructions').onchange = safely(event => { const selected = Number(event.target.value); flushSource(); state.line = selected; state.drafting = false; lastInput = null; populateForm(); renderPreview(); check(); workspace.inspect('details'); $('delete-line').disabled = !currentLine(); terrainMap?.sync(); });
$('header-name').onchange = () => { flushSource(); lastInput = null; updateMetadata(); };
$('metadata').onsubmit = safely(() => { queueLive('header', $('header-value')); flushLive(); });
$('add-step').onclick = safely(() => { flushSource(); const active = guide(), eol = newline(active.body); const at = step()?.stop ?? active.body.length; state.step = step() ? state.step + 1 : 0; state.line = 0; commit(editGuide(state.history.text, active, at, at, (at && !/[\r\n]$/.test(active.body.slice(0, at)) ? eol : '') + 'step' + eol + '    >>New instruction' + eol)); });
$('duplicate-step').onclick = safely(() => { flushSource(); const active = guide(), selected = step(), text = active.body.slice(selected.start, selected.stop); state.step++; commit(editGuide(state.history.text, active, selected.stop, selected.stop, (/[\r\n]$/.test(text) ? '' : newline(text)) + text)); });
$('delete-step').onclick = safely(() => { flushSource(); if (confirm('Delete this step? You can Undo.')) commit(editGuide(state.history.text, guide(), step().start, step().stop, '')); });
for (const [id, delta] of [['up', -1], ['down', 1]]) $(id).onclick = safely(() => { flushSource(); const text = moveStep(state.history.text, guide(), state.step, delta); state.step += delta; commit(text); });
function formLine() { return buildInstruction($('action').value, FORMS[$('action').value].map((_, i) => $('arg-' + i).value.trim()), $('display-text').value, $('condition').value, currentLine()?.text.match(/^[ \t]*/)[0] ?? '    '); }
$('instruction-form').onsubmit = safely(() => { if (state.drafting) $('append-line').click(); else { queueLive('instruction', $('display-text')); flushLive(); } });
$('new-line').onclick = safely(() => {
  flushSource(); state.drafting = true; lastInput = null; $('action').value = 'note'; renderArguments();
  $('display-text').value = ''; $('condition').value = ''; $('append-line').hidden = false; $('cancel-line').hidden = false;
  $('delete-line').disabled = true; $('line-hint').textContent = ''; workspace.inspect('details'); selectionContext(); $('display-text').focus();
});
$('cancel-line').onclick = () => { liveQueued = false; state.drafting = false; populateForm(); renderPreview(); $('delete-line').disabled = !currentLine(); };
$('append-line').onclick = safely(() => { const replacement = formLine(); flushSource(); const active = guide(), at = step().stop, eol = newline(active.body); state.line = step().lines.length; commit(editGuide(state.history.text, active, at, at, (at && !/[\r\n]$/.test(active.body.slice(0, at)) ? eol : '') + replacement + eol)); });
$('delete-line').onclick = safely(() => { flushSource(); const line = currentLine(); if (line) commit(editGuide(state.history.text, guide(), line.start, line.next, '')); });
$('validate').onclick = safely(() => { flushSource(); check(); $('problems-panel').open=true; status('Source checked. Review Problems, then test in-game.'); });

async function json(path) { const response = await fetch(path); if (!response.ok) throw new Error('Reference file unavailable: ' + path); return response.json(); }
$('terrain-panel').addEventListener('toggle', async () => {
  if (!$('terrain-panel').open) { terrainMap?.show(false); return; }
  try {
    flushSource();
    terrainModule ||= Promise.all([import('./map-view.js'), import('./map-model.js')]);
    const [view, model] = await terrainModule;
    if (!$('terrain-panel').open) return;
    terrainMap ||= view.createMap({
      read: () => ({text: state.history.text, guide: guide(), step: state.step, line: state.line}),
      select(marker) {
        flushSource();
        const line = guide()?.steps[marker.step]?.lines[marker.line];
        if (!line || line.text !== marker.source.text) throw new Error('Waypoint changed; select it again.');
        state.step = marker.step; state.line = marker.line; refresh();
      },
      move(marker, x, y) { flushSource(); commit(model.moveWaypoint(state.history.text, guide(), marker, x, y)); },
      add(instruction) {
        flushSource(); if (!step()) throw new Error('Add a step first.');
        const active = guide(), at = step().stop, eol = newline(active.body);
        state.line = step().lines.length;
        commit(editGuide(state.history.text, active, at, at, (at && !/[\r\n]$/.test(active.body.slice(0, at)) ? eol : '') + instruction + eol));
      },
      lookup(kind, id) { workspace.inspect('lookup'); $('reference-type').value = kind; $('query').value = id; clearTimeout(queryTimer); search(); }
    });
    await terrainMap.show(true);
  } catch (error) { $('map-status').textContent = error.message; }
});
async function search() {
  const serial = ++searchSerial, query = $('query').value.trim();
  lookupController?.abort();
  state.reference = null; $('use-reference').disabled = true; $('results').replaceChildren(); $('reference-details').replaceChildren();
  $('search-wowhead').href = query ? searchURL(query) : 'https://www.wowhead.com/wotlk';
  if (!query) { $('reference-status').textContent = ''; return; }
  let timeout;
  try {
    const ref = referenceInput(query, $('reference-type').value);
    if (!ref) { $('reference-status').textContent = 'Press Enter to search Wowhead titles.'; return; }
    $('reference-type').value = ref.type;
    $('search-wowhead').href = referenceURL(ref);
    $('reference-status').textContent = 'Loading from Wowhead…';
    const controller = new AbortController(); lookupController = controller;
    timeout = setTimeout(() => controller.abort(), 12000);
    const result = await lookup(ref, controller.signal);
    if (serial !== searchSerial) return;
    state.reference = result; $('use-reference').disabled = ref.type === 'objects';
    const link = node('a', result.name + ' [' + result.id + ']');
    link.href = referenceURL(ref); link.target = '_blank'; link.rel = 'noopener noreferrer';
    $('reference-details').replaceChildren(link, node('pre', result.text));
    $('reference-status').textContent = ref.type === 'objects' ? 'Use this object ID in Source.' : '';
    if (ref.type === 'quests') $('reference-details').append(node('p', 'Verify .complete objective indices in the game.'));
  } catch (error) {
    if (serial === searchSerial) $('reference-status').textContent = (error.name === 'AbortError' ? 'Wowhead lookup timed out.' : error.message) + ' Manual editing is still available.';
  } finally { clearTimeout(timeout); }
}
$('query').oninput = () => {
  ++searchSerial; lookupController?.abort(); state.reference = null; $('use-reference').disabled = true;
  $('reference-details').replaceChildren(); $('reference-status').textContent = '';
  $('search-wowhead').href = searchURL($('query').value);
  clearTimeout(queryTimer); queryTimer = setTimeout(search, 400);
};
$('reference-type').onchange = () => { clearTimeout(queryTimer); search(); };
$('reference-form').onsubmit = event => {
  event.preventDefault(); clearTimeout(queryTimer);
  try {
    if ($('query').value.trim() && !referenceInput($('query').value, $('reference-type').value)) { $('search-wowhead').href = searchURL($('query').value); $('search-wowhead').click(); }
    else search();
  } catch (error) { $('reference-status').textContent = error.message; }
};
$('use-reference').onclick = safely(() => {
  flushSource();
  const result = state.reference; if (!result) return;
  if (!step()) throw new Error('Add a step before using a reference.');
  const {id, name} = result;
  const allowed = result.type === 'quests' ? ['accept', 'turnin', 'complete'] : result.type === 'items' ? ['collect', 'use'] : ['target', 'mob'];
  if (result.type === 'objects') return;
  if (!state.drafting && !state.formEditable) $('new-line').click();
  if (!allowed.includes($('action').value)) { $('action').value = allowed[0]; renderArguments(); }
  $('arg-0').value = result.type === 'npcs' ? name + '::' + id : id;
  if (result.type === 'items' && $('action').value === 'collect') $('arg-1').value ||= '1';
  const verb = {accept: 'Accept ', turnin: 'Turn in ', complete: 'Complete ', collect: 'Collect ', use: 'Use ', target: 'Talk to ', mob: 'Kill '}[$('action').value];
  $('display-text').value = verb + name;
  queueLive('instruction', $('use-reference')); flushLive();
  workspace.inspect('details');
  status(state.drafting ? 'Reference ready. Choose Add instruction.' : 'Instruction updated.');
});
window.addEventListener('beforeunload', event => { flushSource(); saveDraft(); if (state.history.text !== state.saved) { event.preventDefault(); event.returnValue = ''; } });
window.addEventListener('pagehide', () => { flushSource(); saveDraft(); });
const draft = readDraft(); $('restore').disabled = !draft;
$('storage-status').textContent = draft ? 'Previous draft available. Restore it before editing.' : 'Drafts save in this browser.';
refresh(); status('Ready.');
json('../data/catalogue.json').then(catalogue => {
  state.catalogue = catalogue;
  const list = node('datalist'); list.id = 'map-tokens'; for (const name of Object.keys(catalogue.maps)) list.append(option(name, name)); document.body.append(list);
  check(); updateExport();
}).catch(() => status('Directive/map reference unavailable. Editing still works; validation is incomplete.', true));
