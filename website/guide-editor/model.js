// RXPGuides source editor. No Lua evaluation, formatting pass, or game simulation.
export const MAX_BYTES = 12 * 1024 * 1024;
export const NEW_GUIDE = '#wotlk\n#ac335\n#version 1\n#group RXPGuides Custom Guides\n#name My Guide\n\nstep\n    >>Write your first instruction here.\n';
export const FORMS = {
  goto: ['Zone / map token', 'X (0–100)', 'Y (0–100)', 'Arrival radius (yards; blank = navigation only)', 'Optional marker (presence enables; usually 0)'],
  accept: ['Quest ID'], turnin: ['Quest ID', 'Reward choice (optional)'],
  complete: ['Quest ID', 'Client objective index', 'Partial amount (optional)'],
  collect: ['Item ID', 'Quantity (defaults to 1)'], use: ['Item ID'],
  target: ['NPC name or ID'], mob: ['Creature name or ID'],
  note: [], objective: [],
};
export const DEFAULT_TRAVEL_RADIUS = '15';
// Defaults apply only to newly chosen actions, never to imported source.
export function newArguments(tag) { return tag === 'goto' ? ['', '', '', DEFAULT_TRAVEL_RADIUS] : []; }
export function waypointMode(args) {
  if (args.length <= 3 || !args[3] && !args[4]) return 'navigation';
  return Number(args[3]) > 0 && !args[4] ? 'travel' : 'advanced';
}
export function newWaypoint(zone, x, y, mode = 'travel') {
  if (!['travel', 'navigation'].includes(mode)) throw new Error('Select a waypoint type.');
  return buildInstruction('goto', [zone, x.toFixed(2), y.toFixed(2), ...(mode === 'travel' ? [DEFAULT_TRAVEL_RADIUS] : [])], '', '');
}
export function instructionHint(parsed) {
  if (!parsed) return '';
  if (parsed.tag === 'goto') return {
    travel: 'Travel objective: completes inside the arrival radius.',
    navigation: 'Navigation marker only: pair with a quest or manual objective in this step.',
    advanced: 'Special waypoint behavior: radius and optional fields are preserved; review in Source.',
  }[waypointMode(parsed.args)];
  return {
    note: 'Display only. Use Manual objective for a checkable instruction.',
    objective: 'Manually checked by the player.',
    target: 'Target helper only; does not detect talking to the NPC.',
    mob: 'Target helper only; use a quest objective or collection to track kills.',
    use: 'Item-button helper only; does not track successful use. Pair with an objective.',
    complete: 'Uses the client quest-log objective index, not a database slot.',
  }[parsed.tag] || '';
}

export function decodeFile(bytes) {
  if (bytes.byteLength > MAX_BYTES) throw new Error('File exceeds the 12 MiB editor limit. Split the source file first.');
  const text = new TextDecoder('utf-8', {fatal: true, ignoreBOM: true}).decode(bytes);
  if (text.includes('\0')) throw new Error('Binary/NUL-containing files are not guide source.');
  return text;
}
export function encodeFile(text) { return new TextEncoder().encode(text); }
export function newline(text) { return text.match(/\r\n|\n|\r/)?.[0] || '\n'; }
// Textareas normalize line endings. Translate only the actual changed span
// back into the source so untouched CRLF/mixed endings and BOM survive.
export function applyTextarea(original, value) {
  const normalized = original.replace(/\r\n?/g, '\n');
  if (normalized === value) return original;
  let first = 0, endOld = normalized.length, endNew = value.length;
  while (first < endOld && first < endNew && normalized[first] === value[first]) first++;
  while (endOld > first && endNew > first && normalized[endOld - 1] === value[endNew - 1]) { endOld--; endNew--; }
  function offset(wanted) {
    let raw = 0, index = 0;
    while (index < wanted) { if (original[raw] === '\r' && original[raw + 1] === '\n') raw++; raw++; index++; }
    return raw;
  }
  return replaceSpan(original, offset(first), offset(endOld), value.slice(first, endNew).replace(/\n/g, newline(original)));
}
export function lines(text) {
  const result = [];
  const re = /([^\r\n]*)(\r\n|\n|\r|$)/g;
  let m;
  while ((m = re.exec(text)) && m[0].length) {
    result.push({start: m.index, end: m.index + m[1].length, next: re.lastIndex, text: m[1], eol: m[2]});
  }
  return result;
}

// Only lex the Lua container. Long strings/comments and escaped quotes cannot
// inject a fake registration. Payload spans keep their original literal bytes.
export function lexLua(text) {
  const tokens = [];
  let i = 0;
  function longAt(at) { return /^\[(=*)\[/.exec(text.slice(at)); }
  while (i < text.length) {
    if (/\s|\uFEFF/.test(text[i])) { i++; continue; }
    const start = i;
    const comment = text.startsWith('--', i);
    if (comment) i += 2;
    const long = longAt(i);
    if (long) {
      const contentStart = i + long[0].length;
      const close = ']' + long[1] + ']';
      const end = text.indexOf(close, contentStart);
      if (end < 0) throw new Error('Unclosed Lua long string/comment at character ' + start + '.');
      i = end + close.length;
      if (!comment) tokens.push({kind: 'long', start, end: i, contentStart, contentEnd: end});
      continue;
    }
    if (comment) {
      while (i < text.length && !/[\r\n]/.test(text[i])) i++;
      continue;
    }
    if (text[i] === '"' || text[i] === "'") {
      const quote = text[i++];
      let closed = false;
      while (i < text.length) {
        if (text[i] === '\\') { i += 2; continue; }
        if (text[i++] === quote) { closed = true; break; }
      }
      if (!closed) throw new Error('Unclosed quoted Lua string.');
      tokens.push({kind: 'quoted', start, end: i});
      continue;
    }
    const word = /^[A-Za-z_][A-Za-z_0-9]*/.exec(text.slice(i));
    i += word ? word[0].length : 1;
    tokens.push({kind: word ? 'word' : 'symbol', value: text.slice(start, i), start, end: i});
  }
  return tokens;
}

export function parseGuide(body) {
  const all = lines(body);
  const starts = all.filter(line => /^\s*step(?:\s|$)/.test(line.text));
  const headerEnd = starts[0]?.start ?? body.length;
  const headers = all.filter(line => line.start < headerEnd);
  const values = name => headers.filter(line => new RegExp('^\\s*#' + name + '\\s+').test(line.text))
    .map(line => line.text.replace(new RegExp('^\\s*#' + name + '\\s+'), '').split(/\s*<</)[0].trim());
  const steps = starts.map((line, index) => ({...line, stop: starts[index + 1]?.start ?? body.length, lines: []}));
  let current = -1;
  for (const line of all) {
    if (line.start === steps[current + 1]?.start) current++;
    else if (current >= 0) steps[current].lines.push(line);
  }
  return {body, lines: all, headers, headerEnd, names: values('name'), groups: values('group'), subgroups: values('subgroup'), steps};
}

export function parseDocument(text, filename = 'guide.txt') {
  if (/^\uFEFF?\s*\d+\|/.test(text)) return {guides: [], errors: ['Encoded account-bound imports are unsupported. Open plain guide text or a static Lua guide file.']};
  // A guide header following ordinary comment lines establishes plain source;
  // registration examples in its notes must not turn it into a Lua container.
  let cursor = 0;
  while (cursor < text.length) {
    const space = /^[\s\uFEFF]+/.exec(text.slice(cursor));
    if (space) { cursor += space[0].length; continue; }
    if (!text.startsWith('--', cursor)) break;
    const long = /^--\[(=*)\[/.exec(text.slice(cursor));
    if (long) {
      const close = ']' + long[1] + ']', end = text.indexOf(close, cursor + long[0].length);
      if (end < 0) break; // The container lexer will report the malformed comment.
      cursor = end + close.length;
    } else {
      const end = text.slice(cursor).search(/[\r\n]/);
      cursor = end < 0 ? text.length : cursor + end;
    }
  }
  const plainStart = /^(?:#|<<|step(?:\s|$))/.test(text.slice(cursor));
  if (plainStart) {
    return {guides: [{start: 0, end: text.length, external: false, ...parseGuide(text)}], errors: [], lua: false};
  }
  let tokens;
  try { tokens = lexLua(text); } catch (error) { return {guides: [], errors: [error.message]}; }
  const guides = [], used = new Set(), errors = [], containers = [];
  for (let i = 0; i < tokens.length; i++) {
    if (tokens[i].value !== 'RXPGuides' || tokens[i + 1]?.value !== '.' || tokens[i + 2]?.value !== 'RegisterGuide') continue;
    const payload = tokens[i + 4];
    if (tokens[i + 3]?.value !== '(' || payload?.kind !== 'long' || tokens[i + 5]?.value !== ')') {
      errors.push('Only a single literal long-string RegisterGuide argument is supported. Dynamic calls and overloads stay source-only.');
      continue;
    }
    for (let k = i; k <= i + 5; k++) used.add(k);
    containers.push([tokens[i].start, tokens[i + 5].end]);
    guides.push({start: payload.contentStart, end: payload.contentEnd,
      ...parseGuide(text.slice(payload.contentStart, payload.contentEnd))});
    i += 5;
  }
  const external = tokens.some((token, index) => !used.has(index) && token.value !== ';');
  let provenance = '';
  cursor = 0;
  if (!external) {
    for (const [start, end] of containers) { provenance += text.slice(cursor, start); cursor = end; }
    provenance += text.slice(cursor);
  }
  for (const guide of guides) { guide.external = external; guide.provenance = provenance; }
  if (!guides.length && !errors.length) errors.push('No supported guide found. Use plain headers/steps or a literal RXPGuides.RegisterGuide([[...]]) call.');
  return {guides, errors, lua: true};
}

export function replaceSpan(text, start, end, replacement) { return text.slice(0, start) + replacement + text.slice(end); }
// Form edits stay inside one guide. Reparse that body, not every chapter in a
// large container. Fall back to the container scanner if its delimiter changes.
export function reparseEditedGuide(document, original, text, index, filename) {
  const active = document.guides[index], delta = text.length - original.length;
  if (!active || document.errors.length || text.slice(0, active.start) !== original.slice(0, active.start)
    || text.slice(active.end + delta) !== original.slice(active.end)) return parseDocument(text, filename);
  const body = text.slice(active.start, active.end + delta);
  const close = document.lua && /^\]=*\]/.exec(original.slice(active.end))?.[0];
  if (document.lua && (!close || body.includes(close))) return parseDocument(text, filename);
  return {...document, guides: document.guides.map((item, i) => i === index
    ? {...item, ...parseGuide(body), end: item.end + delta}
    : i > index ? {...item, start: item.start + delta, end: item.end + delta} : item)};
}
export function editGuide(text, guide, start, end, replacement) {
  return replaceSpan(text, guide.start + start, guide.start + end, replacement);
}
export function setHeader(text, guide, name, value) {
  if (!/^(name|group|subgroup|version)$/.test(name) || /[\r\n\0]/.test(value)) throw new Error('Invalid header value.');
  const matching = guide.headers.filter(line => new RegExp('^\\s*#' + name + '(?:\\s|$)').test(line.text));
  if (matching.length > 1 || matching.some(line => line.text.includes('<<') || /^\s*#\S+\s*=/.test(line.text))) {
    throw new Error('Conditional, repeated or computed headers must be edited in Source.');
  }
  if (!matching.length) return editGuide(text, guide, guide.headerEnd, guide.headerEnd, '#' + name + ' ' + value + newline(guide.body));
  const line = matching[0];
  const prefix = line.text.match(/^\s*#\S+\s*/)[0];
  const trailing = line.text.match(/[ \t]*$/)[0];
  return editGuide(text, guide, line.start, line.end, prefix + value + trailing);
}

export function instruction(line) {
  const leading = line.text.match(/^[ \t]*/)[0];
  let text = line.text.slice(leading.length), condition = '';
  const conditionAt = text.indexOf('<<');
  if (conditionAt >= 0) { condition = text.slice(conditionAt + 2).trim(); text = text.slice(0, conditionAt).trimEnd(); }
  if (text.startsWith('>>') || text.startsWith('+')) return {tag: text.startsWith('+') ? 'objective' : 'note', args: [], display: text.replace(/^(>>|\+)\s*/, ''), condition, leading};
  const match = /^\.([A-Za-z][A-Za-z0-9]*)\s*(.*)$/.exec(text);
  if (!match) return null;
  const split = match[2].indexOf('>>');
  const argsText = (split < 0 ? match[2] : match[2].slice(0, split)).trim();
  const separator = ['target', 'mob'].includes(match[1]) ? ';' : ',';
  return {tag: match[1], args: argsText ? argsText.split(separator).map(s => s.trim()) : [],
    display: split < 0 ? '' : match[2].slice(split + 2).trim(), condition, leading};
}
export function buildInstruction(tag, args, display, condition, leading = '    ') {
  if (!Object.hasOwn(FORMS, tag)) throw new Error('Unsupported form.');
  if ([...args, display, condition].some(value => /[\r\n\0]/.test(value))) throw new Error('Use Source for multiline instructions.');
  const separator = ['target', 'mob'].includes(tag) ? ';' : ',';
  if (args.some(value => value.includes(separator) || />>|<</.test(value))) throw new Error('Arguments cannot contain directive separators. Use Source for advanced syntax.');
  if (display.includes('<<') || condition.includes('<<')) throw new Error('Use the condition field for << conditions.');
  const parts = args.slice();
  while (parts.length && !parts.at(-1)) parts.pop();
  if (parts.some(value => !value)) throw new Error('Do not leave gaps between positional arguments.');
  let text = tag === 'note' ? '>>' + display : tag === 'objective' ? '+' + display : '.' + tag + (parts.length ? ' ' + parts.join(separator) : '') + (display ? ' >>' + display : '');
  return leading + text + (condition ? ' << ' + condition : '');
}

export function moveStep(text, guide, index, direction) {
  const other = index + direction;
  if (other < 0 || other >= guide.steps.length) return text;
  const a = guide.steps[Math.min(index, other)], b = guide.steps[Math.max(index, other)];
  const first = guide.body.slice(a.start, a.stop), second = guide.body.slice(b.start, b.stop);
  const separator = /[\r\n]$/.test(second) ? '' : newline(guide.body);
  return editGuide(text, guide, a.start, b.stop, second + separator + first);
}

export function validate(guide, catalogue = {}) {
  const found = [], labels = new Map(), refs = [];
  const add = (severity, message, line = 0) => found.push({severity, message, line});
  if (!guide.groups.length || guide.groups.some(value => !value)) add('error', 'Missing or empty #group header.');
  if (!guide.names.length || guide.names.some(value => !value)) add('error', 'Missing or empty #name header.');
  if (!guide.steps.length) add('error', 'No steps.');
  if (!/^\s*#(?:wotlk|ac335)(?:\s|$)/m.test(guide.body)) add('warning', 'No WotLK/3.3.5 header. Verify game eligibility.');
  if (guide.external) add('warning', 'Surrounding Lua may contain guards or dependencies. Companion export is blocked; edited-original export preserves the container.');
  if (guide.groups.some(group => /^(RestedXP|Original Guides|RXP Speedrun)/.test(group))) add('warning', 'This looks like a bundled guide group. Use Save as new guide to avoid replacing existing routes.');
  let stepCondition = '';
  for (const [index, line] of guide.lines.entries()) {
    const number = index + 1;
    if (/^\s*step(?:\s|$)/.test(line.text)) stepCondition = line.text.split('<<')[1]?.trim() || '';
    const label = /^\s*#label\s+(\S+)/.exec(line.text);
    if (label) {
      if (labels.has(label[1])) add('warning', 'Repeated label ' + label[1] + '; verify branch exclusivity in the addon.', number);
      labels.set(label[1], stepCondition);
    }
    const ref = /^\s*#(?:requires|completewith)\s+(\S+)/.exec(line.text);
    if (ref && !['next', 'sticky', 'current'].includes(ref[1])) refs.push([ref[1], number]);
    const parsed = instruction(line);
    if (!parsed) { if (/^\s*\./.test(line.text)) add('error', 'Malformed directive.', number); continue; }
    const {tag, args} = parsed;
    if (['note', 'objective'].includes(tag)) continue;
    if (catalogue.directives && !catalogue.directives.includes(tag)) add('warning', 'Unrecognized directive .' + tag + '; preserved, not verified.', number);
    if (['macro', 'setquestdb', 'addtoquestdb', 'link'].includes(tag)) add('warning', '.' + tag + ' needs manual source/security review; the preview never executes it.', number);
    if (['goto', 'groundgoto', 'flygoto', 'waypoint'].includes(tag)) {
      const worldCoordinates = /^\d+\/\d+$/.test(args[0]);
      if (args.length < 3 || args.length > 5 || !args[0]) add('error', 'Waypoint requires zone, X, Y and at most radius/optional fields.', number);
      for (const value of args.slice(1, 3)) if (!value || !Number.isFinite(Number(value)) || (!worldCoordinates && (Number(value) < 0 || Number(value) > 100))) add('error', 'Coordinates must be finite numbers; zone percentages must be between 0 and 100.', number);
      if (worldCoordinates) add('warning', 'World-coordinate tuple preserved; verify map compatibility manually. No conversion is performed.', number);
      if (args[3] && !Number.isFinite(Number(args[3]))) add('error', 'Radius must be numeric.', number);
      if (Number(args[3]) < 0) add('warning', 'Negative radius uses special runtime behavior; review in Source.', number);
      if (args[4] && !['0', '1'].includes(args[4])) add('warning', 'Advanced waypoint marker/callback requires source review.', number);
      if (!worldCoordinates && catalogue.maps && !Object.hasOwn(catalogue.maps, args[0]) && !Object.values(catalogue.maps).includes(Number(args[0]))) add('warning', 'Map token not in the bundled alias snapshot.', number);
    }
    if (['accept', 'turnin', 'complete', 'collect', 'use'].includes(tag) && (!/^-?\d+$/.test(args[0] || '') || Number(args[0]) === 0)) add('error', 'A nonzero integer ID is required.', number);
    if (['collect', 'use'].includes(tag) && !/^[1-9]\d*$/.test(args[0] || '')) add('error', 'Item ID must be a positive integer.', number);
    if (tag === 'complete' && (!/^\d+$/.test(args[1] || '') || Number(args[1]) < 1)) add('error', 'A positive client objective index is required.', number);
    if (tag === 'collect' && args[1] && !/^\d+$/.test(args[1])) add('error', 'Quantity must be a nonnegative integer when specified.', number);
    const optionalNumber = tag === 'turnin' ? args[1] : tag === 'complete' ? args[2] : undefined;
    if (optionalNumber && !/^\d+$/.test(optionalNumber)) add('error', 'Nonnegative integer optional argument required.', number);
  }
  for (const [label, number] of refs) if (!labels.has(label)) add('warning', 'Unresolved local label ' + label + '; check the intended branch/dependency.', number);
  // Diagnose only the simple forms we understand. Advanced directives and
  // step gates may supply their own progression rules; do not guess those.
  const lineNumbers = new Map(guide.lines.map((line, index) => [line, index + 1]));
  for (const step of guide.steps) {
    const content = step.lines.filter(line => line.text.trim() && !/^\s*--/.test(line.text));
    const parsed = content.map(instruction);
    const helper = item => item && (['note', 'target', 'mob', 'use'].includes(item.tag)
      || item.tag === 'goto' && waypointMode(item.args) === 'navigation');
    if (parsed.length && parsed.every(helper)) add('warning', 'This step has only notes/navigation/helpers, with no completion objective. For a stop, add a travel, quest or manual objective.', lineNumbers.get(content[0]));
  }
  return found;
}

export function companion(guide, catalogue, slug) {
  if (!/^[A-Za-z][A-Za-z0-9_]{0,47}$/.test(slug)) throw new Error('Use an ASCII folder name beginning with a letter (up to 48 characters).');
  if (guide.external) throw new Error('External Lua guards/dependencies prevent isolated companion export. Download the edited original file instead.');
  if (guide.body.includes(']]')) throw new Error('The source contains ]]. Save raw source; this wrapper format cannot contain that delimiter.');
  if (validate(guide, catalogue).some(item => item.severity === 'error')) throw new Error('Resolve the source errors before exporting a companion.');
  const folder = 'RXPGuides_Custom_' + slug;
  const body = guide.body.replace(/^\uFEFF/, '');
  const provenance = (guide.provenance || '').replace(/^\uFEFF/, '');
  return {folder, toc: '## Interface: 30300\n## Title: RXPGuides Custom - ' + slug + '\n## Dependencies: RXPGuides\n## Notes: Locally authored guide; gameplay verification required.\nGuide.lua\n',
    lua: '-- Custom guide source. Review and test before use.\n' + provenance + '\nRXPGuides.RegisterGuide([[\n' + body + (/[\r\n]$/.test(body) ? '' : '\n') + ']])\n'};
}

export class History {
  constructor(text) { this.text = text; this.undoStack = []; this.redoStack = []; this.group = null; }
  set(text, group = null) {
    if (text === this.text) return false;
    if (group === null || group !== this.group) this.undoStack.push(this.text);
    this.group = group;
    while (this.undoStack.length > 30 || this.undoStack.reduce((n, s) => n + s.length, 0) > 24 * 1024 * 1024) this.undoStack.shift();
    this.text = text; this.redoStack = []; return true;
  }
  undo() { this.group = null; if (this.undoStack.length) { this.redoStack.push(this.text); this.text = this.undoStack.pop(); } return this.text; }
  redo() { this.group = null; if (this.redoStack.length) { this.undoStack.push(this.text); this.text = this.redoStack.pop(); } return this.text; }
}
