// Data only: no remote scripts, HTML insertion, proxies or guide-source uploads.
export const TYPES = {quests: 'quest', items: 'item', npcs: 'npc', objects: 'object'};
export function referenceInput(value, type) {
  const text = value.trim();
  if (/^\d+$/.test(text)) {
    const id = Number(text);
    if (!Number.isSafeInteger(id) || id < 1 || id > 2147483647 || !TYPES[type]) throw new Error('Enter a valid positive ID.');
    return {type, id};
  }
  if (/^https?:\/\//i.test(text)) {
    const url = new URL(text), match = /^\/wotlk\/(quest|item|npc|object)=(\d+)(?:\/[^/]*)?\/?$/.exec(url.pathname);
    if (url.protocol !== 'https:' || !['www.wowhead.com', 'wowhead.com'].includes(url.hostname) || url.port || url.username || url.password || !match) {
      throw new Error('Use a Wowhead WotLK quest, item, NPC or object link.');
    }
    return referenceInput(match[2], Object.keys(TYPES).find(key => TYPES[key] === match[1]));
  }
  return null;
}
export const referenceURL = ({type, id}) => 'https://www.wowhead.com/wotlk/' + TYPES[type] + '=' + id;
export const searchURL = query => 'https://www.wowhead.com/wotlk/search?q=' + encodeURIComponent(query.trim());

// Keep tooltip content inert, including encoded markup. Never load its icons,
// links or coordinates, and never infer client objective order from the text.
export function tooltipText(html) {
  const entities = {amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: ' '};
  return String(html || '').slice(0, 100000)
    .replace(/<!--[\s\S]*?-->/g, '')
    .replace(/<(script|style)\b[^>]*>[\s\S]*?<\/\1\s*>/gi, '')
    .replace(/<br\s*\/?\s*>|<\/(?:tr|table|p|div|li)>/gi, '\n')
    .replace(/<[^>]*>/g, '')
    .replace(/&(#x[0-9a-f]+|#\d+|amp|lt|gt|quot|apos|nbsp);/gi, (original, entity) => {
      if (entity[0] !== '#') return entities[entity.toLowerCase()] ?? original;
      const number = entity[1].toLowerCase() === 'x' ? parseInt(entity.slice(2), 16) : Number(entity.slice(1));
      return number > 0 && number <= 0x10ffff && !(number >= 0xd800 && number <= 0xdfff) ? String.fromCodePoint(number) : original;
    }).replace(/[ \t]+/g, ' ').replace(/\n\s*\n+/g, '\n\n').trim();
}
export function createLookup(fetcher = (...args) => fetch(...args)) {
  const cache = new Map();
  return async (ref, signal) => {
    const key = TYPES[ref.type] + '/' + ref.id;
    if (cache.has(key)) return cache.get(key);
    const response = await fetcher('https://nether.wowhead.com/wotlk/tooltip/' + key,
      {signal, credentials: 'omit', referrerPolicy: 'no-referrer', redirect: 'error'});
    if (response.status === 404) throw new Error('No WotLK entry found for this ID.');
    if (!response.ok) throw new Error('Wowhead is unavailable. Try again or open its website.');
    const raw = await response.text();
    if (raw.length > 200000) throw new Error('Wowhead response is too large.');
    const data = JSON.parse(raw);
    if (typeof data.name !== 'string' || !data.name.trim() || data.name.length > 500) throw new Error('Wowhead returned no usable name.');
    const result = {...ref, name: tooltipText(data.name), text: tooltipText(data.tooltip)};
    if (signal?.aborted) throw new DOMException('Cancelled', 'AbortError');
    cache.set(key, result);
    if (cache.size > 32) cache.delete(cache.keys().next().value);
    return result;
  };
}
