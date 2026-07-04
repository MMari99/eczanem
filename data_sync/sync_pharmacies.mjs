import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

const root = path.resolve(new URL('..', import.meta.url).pathname);
const sourcesPath = path.join(root, 'data_sync', 'free_sources.json');
const seedPath = path.join(root, 'public', 'data', 'normal_pharmacies_seed.json');
const outPath = path.join(root, 'public', 'data', 'pharmacies_latest.json');
const requestDelayMs = Number(process.env.REQUEST_DELAY_MS || 900);
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

function decodeEntities(value) {
  return String(value || '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&#(\d+);/g, (_, code) => String.fromCharCode(Number(code)));
}

function clean(value) {
  return decodeEntities(value).replace(/\s+/g, ' ').trim();
}

function htmlToLines(html) {
  return html
    .replace(/<script[\s\S]*?<\/script>/gi, '')
    .replace(/<style[\s\S]*?<\/style>/gi, '')
    .replace(/<(br|li|p|div|h[1-6]|tr|section|article|a)\b[^>]*>/gi, '\n')
    .replace(/<\/(li|p|div|h[1-6]|tr|section|article|a)>/gi, '\n')
    .replace(/<[^>]+>/g, ' ')
    .split(/\n+/)
    .map(clean)
    .filter(Boolean);
}

function districtFromAddress(address, city) {
  const parts = address.split(' ').filter(Boolean);
  const lowered = parts.map((p) => p.toLocaleLowerCase('tr-TR'));
  const cityIndex = lowered.lastIndexOf(city.toLocaleLowerCase('tr-TR'));
  if (cityIndex > 0) return parts[cityIndex - 1];
  return '';
}

function normalizeName(line, city) {
  return line.replace(new RegExp('^' + city + '\\s+', 'i'), '').replace(/\s+/g, ' ').trim();
}

function parseCityPage(html, source) {
  const lines = htmlToLines(html);
  const items = [];
  const seen = new Set();

  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i];
    const lowerLine = line.toLocaleLowerCase('tr-TR');
    if (!lowerLine.includes('eczane')) continue;
    if (lowerLine.includes('nöbetçi eczane') || lowerLine.includes('eczaneleri') || lowerLine.includes('verisi doğru mu')) continue;

    const address = lines.slice(i + 1, i + 5).find((candidate) => {
      const lower = candidate.toLocaleLowerCase('tr-TR');
      return candidate.length > 18 && lower.includes(source.city.toLocaleLowerCase('tr-TR')) && !lower.includes('eczane verisi');
    });
    if (!address) continue;

    const name = normalizeName(line, source.city);
    const key = (source.city + '|' + name + '|' + address).toLocaleLowerCase('tr-TR');
    if (seen.has(key)) continue;
    seen.add(key);

    items.push({
      id: 'free-' + source.slug + '-' + (items.length + 1),
      name,
      address,
      phone: '',
      city: source.city,
      district: districtFromAddress(address, source.city),
      latitude: source.lat,
      longitude: source.lon,
      isOnDuty: true,
      workingHours: 'Nöbetçi',
      source: 'free_public_page',
      sourceUrl: source.sourceUrl,
      coordinateQuality: 'city_center_fallback'
    });
  }

  return items;
}

function browserHeaders(source) {
  return {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36',
    Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'tr-TR,tr;q=0.9,en-US;q=0.7,en;q=0.6',
    'Cache-Control': 'no-cache',
    Pragma: 'no-cache',
    Referer: 'https://eczaneleri.net/',
    'Upgrade-Insecure-Requests': '1'
  };
}

function readerUrl(url) {
  return 'https://r.jina.ai/http://r.jina.ai/http://' + url;
}

async function fetchText(url, source) {
  const response = await fetch(url, { headers: browserHeaders(source) });
  if (!response.ok) throw new Error('HTTP ' + response.status);
  return response.text();
}

async function fetchCity(source) {
  const attempts = [
    source.sourceUrl,
    source.sourceUrl.replace('https://', 'http://'),
    readerUrl(source.sourceUrl),
    readerUrl(source.sourceUrl.replace('https://', 'http://'))
  ];
  const errors = [];

  for (const url of attempts) {
    try {
      const html = await fetchText(url, source);
      const items = parseCityPage(html, source);
      if (items.length > 0) return { source, items, usedUrl: url };
      errors.push(url + ' -> No pharmacies parsed');
    } catch (error) {
      errors.push(url + ' -> ' + error.message);
    }
  }

  return { source, items: [], error: errors.join(' | ') };
}

async function main() {
  const generatedAt = new Date();
  const expiresAt = new Date(generatedAt.getTime() + 26 * 60 * 60 * 1000);
  const sources = JSON.parse(await readFile(sourcesPath, 'utf8'));
  const seed = JSON.parse(await readFile(seedPath, 'utf8')).pharmacies || [];
  const duty = [];
  const errors = [];

  for (const source of sources) {
    const result = await fetchCity(source);
    duty.push(...result.items);
    if (result.error || result.items.length === 0) {
      errors.push({ city: source.city, sourceUrl: source.sourceUrl, error: result.error || 'No pharmacies parsed' });
    }
    await sleep(requestDelayMs);
  }

  const normal = seed.map((item) => ({ ...item, isOnDuty: false, source: item.source || 'normal_seed' }));
  const pharmacies = [...duty, ...normal];
  const payload = {
    generatedAt: generatedAt.toISOString(),
    expiresAt: expiresAt.toISOString(),
    source: {
      duty: 'free_public_city_pages_daily_scrape',
      normal: 'public/data/normal_pharmacies_seed.json'
    },
    notice: 'Nöbetçi eczane verisi kamuya açık il sayfalarından günde bir kez derlenir. Koordinat bulunmayan kayıtlar il merkezi koordinatı ile işaretlenir.',
    totals: { duty: duty.length, normal: normal.length, all: pharmacies.length, cities: sources.length, cityErrors: errors.length },
    errors,
    pharmacies
  };

  await mkdir(path.dirname(outPath), { recursive: true });
  await writeFile(outPath, JSON.stringify(payload, null, 2) + '\n', 'utf8');
  console.log('Wrote ' + pharmacies.length + ' pharmacies from ' + sources.length + ' cities. City errors: ' + errors.length + '.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
