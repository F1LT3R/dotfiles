#!/usr/bin/env node

/*
  Paper resolution and open-access discovery.

  Uses free, public APIs (no API keys required for basic usage):
    - Semantic Scholar  — paper search, metadata, OA PDF links
    - Unpaywall         — legal open-access PDF discovery via DOI
    - CrossRef          — DOI metadata validation

  Usage:
    node scripts/resolve-papers.js --query "attention transformers" --year 2020-2024 --limit 5
    node scripts/resolve-papers.js --doi "10.1145/3292500.3330919"
*/

const https = require('https');
const url = require('url');

// ---------------------------------------------------------------------------
// HTTP helper (Node built-in only, no deps)
// ---------------------------------------------------------------------------

function httpGet(reqUrl, headers = {}) {
  return new Promise((resolve, reject) => {
    const parsed = new url.URL(reqUrl);
    const opts = {
      hostname: parsed.hostname,
      path: parsed.pathname + parsed.search,
      headers: { 'User-Agent': 'academic-researcher-skill/1.1 (mailto:academic-researcher@example.com)', ...headers },
    };
    https.get(opts, (res) => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        return httpGet(res.headers.location, headers).then(resolve, reject);
      }
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(data);
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data.slice(0, 200)}`));
        }
      });
    }).on('error', reject);
  });
}

async function jsonGet(reqUrl) {
  const raw = await httpGet(reqUrl);
  return JSON.parse(raw);
}

// ---------------------------------------------------------------------------
// Semantic Scholar
// ---------------------------------------------------------------------------

async function searchPapers(query, { year, limit = 10 } = {}) {
  let q = encodeURIComponent(query);
  let apiUrl = `https://api.semanticscholar.org/graph/v1/paper/search?query=${q}&limit=${limit}&fields=title,authors,year,venue,externalIds,citationCount,abstract,isOpenAccess,openAccessPdf`;
  if (year) apiUrl += `&year=${year}`;
  const data = await jsonGet(apiUrl);
  if (!data.data || data.data.length === 0) return [];
  return data.data.map(normalizeSS);
}

async function resolveByDOI_SS(doi) {
  const apiUrl = `https://api.semanticscholar.org/graph/v1/paper/DOI:${encodeURIComponent(doi)}?fields=title,authors,year,venue,externalIds,citationCount,abstract,isOpenAccess,openAccessPdf`;
  try {
    const data = await jsonGet(apiUrl);
    return normalizeSS(data);
  } catch {
    return null;
  }
}

function normalizeSS(p) {
  const doi = p.externalIds && p.externalIds.DOI ? p.externalIds.DOI : null;
  const arxiv = p.externalIds && p.externalIds.ArXiv ? p.externalIds.ArXiv : null;
  return {
    title: p.title || '',
    authors: (p.authors || []).map((a) => a.name),
    year: p.year,
    venue: p.venue || '',
    doi,
    arxiv,
    citationCount: p.citationCount || 0,
    abstract: p.abstract || '',
    oaUrl: p.openAccessPdf ? p.openAccessPdf.url : null,
    source: 'semantic-scholar',
  };
}

// ---------------------------------------------------------------------------
// Unpaywall
// ---------------------------------------------------------------------------

async function resolveUnpaywall(doi) {
  const email = 'academic-researcher@example.com';
  const apiUrl = `https://api.unpaywall.org/v2/${encodeURIComponent(doi)}?email=${email}`;
  try {
    const data = await jsonGet(apiUrl);
    return {
      title: data.title || '',
      authors: (data.z_authors || []).map((a) => [a.given, a.family].filter(Boolean).join(' ')),
      year: data.year,
      venue: data.journal_name || '',
      doi: data.doi,
      oaUrl: data.best_oa_location ? data.best_oa_location.url_for_pdf || data.best_oa_location.url : null,
      source: 'unpaywall',
    };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// CrossRef
// ---------------------------------------------------------------------------

async function resolveCrossRef(doi) {
  const apiUrl = `https://api.crossref.org/works/${encodeURIComponent(doi)}`;
  try {
    const data = await jsonGet(apiUrl);
    const item = data.message;
    return {
      title: Array.isArray(item.title) ? item.title[0] : item.title || '',
      authors: (item.author || []).map((a) => [a.given, a.family].filter(Boolean).join(' ')),
      year: item.published && item.published['date-parts'] ? item.published['date-parts'][0][0] : null,
      venue: Array.isArray(item['container-title']) ? item['container-title'][0] : item['container-title'] || '',
      doi: item.DOI,
      type: item.type,
      source: 'crossref',
    };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// BibTeX generation
// ---------------------------------------------------------------------------

function makeCiteKey(meta) {
  const firstAuthor = (meta.authors[0] || 'unknown').split(/\s+/).pop().toLowerCase().replace(/[^a-z]/g, '');
  return `${firstAuthor}${meta.year || 'XXXX'}`;
}

function toBibtex(meta) {
  const key = makeCiteKey(meta);
  const authors = meta.authors.join(' and ');
  const lines = [`@article{${key},`];
  lines.push(`  author  = {${authors}},`);
  lines.push(`  title   = {${meta.title}},`);
  if (meta.venue) lines.push(`  journal = {${meta.venue}},`);
  if (meta.year) lines.push(`  year    = {${meta.year}},`);
  if (meta.doi) lines.push(`  doi     = {${meta.doi}},`);
  lines.push('}');
  return lines.join('\n');
}

// ---------------------------------------------------------------------------
// Resolve DOI (fallback chain)
// ---------------------------------------------------------------------------

async function resolveDOI(doi) {
  // Try Semantic Scholar first
  let result = await resolveByDOI_SS(doi);
  if (result) {
    // Enrich with Unpaywall OA link if Semantic Scholar didn't have one
    if (!result.oaUrl) {
      const uw = await resolveUnpaywall(doi);
      if (uw && uw.oaUrl) result.oaUrl = uw.oaUrl;
    }
    result.bibtex = toBibtex(result);
    return result;
  }

  // Fallback to Unpaywall
  result = await resolveUnpaywall(doi);
  if (result) {
    result.bibtex = toBibtex(result);
    return result;
  }

  // Fallback to CrossRef
  result = await resolveCrossRef(doi);
  if (result) {
    result.bibtex = toBibtex(result);
    return result;
  }

  return null;
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function printResult(r) {
  console.log(`\n  Title:      ${r.title}`);
  console.log(`  Authors:    ${r.authors.join(', ')}`);
  console.log(`  Year:       ${r.year || 'N/A'}`);
  console.log(`  Venue:      ${r.venue || 'N/A'}`);
  console.log(`  DOI:        ${r.doi || 'N/A'}`);
  if (r.arxiv) console.log(`  arXiv:      ${r.arxiv}`);
  console.log(`  Citations:  ${r.citationCount != null ? r.citationCount : 'N/A'}`);
  console.log(`  OA PDF:     ${r.oaUrl || 'not found'}`);
  if (r.bibtex) console.log(`  BibTeX:\n${r.bibtex.replace(/^/gm, '    ')}`);
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args.includes('--help')) {
    console.log('Usage:');
    console.log('  node scripts/resolve-papers.js --query "search terms" [--year 2020-2024] [--limit 10]');
    console.log('  node scripts/resolve-papers.js --doi "10.xxxx/yyyy"');
    process.exit(0);
  }

  const flagIdx = (f) => args.indexOf(f);

  // --doi mode
  const doiIdx = flagIdx('--doi');
  if (doiIdx !== -1) {
    const doi = args[doiIdx + 1];
    if (!doi) { console.error('Error: --doi requires a value'); process.exit(1); }
    console.log(`Resolving DOI: ${doi}`);
    const result = await resolveDOI(doi);
    if (result) {
      printResult(result);
    } else {
      console.log('Could not resolve DOI via any API. Ask the user to provide the paper.');
    }
    return;
  }

  // --query mode
  const queryIdx = flagIdx('--query');
  if (queryIdx !== -1) {
    const query = args[queryIdx + 1];
    if (!query) { console.error('Error: --query requires a value'); process.exit(1); }

    const limitIdx = flagIdx('--limit');
    const limit = limitIdx !== -1 ? parseInt(args[limitIdx + 1], 10) : 10;

    const yearIdx = flagIdx('--year');
    const year = yearIdx !== -1 ? args[yearIdx + 1] : undefined;

    console.log(`Searching: "${query}"${year ? ` (year: ${year})` : ''} [limit: ${limit}]`);
    const results = await searchPapers(query, { year, limit });
    if (results.length === 0) {
      console.log('No results found.');
      return;
    }
    console.log(`Found ${results.length} result(s):`);
    for (const r of results) {
      r.bibtex = toBibtex(r);
      printResult(r);
    }
    return;
  }

  console.error('Error: specify --query or --doi. Use --help for usage.');
  process.exit(1);
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
