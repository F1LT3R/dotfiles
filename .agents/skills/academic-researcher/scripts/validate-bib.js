#!/usr/bin/env node

/*
  BibTeX validation: checks .bib entries against the CrossRef API.

  For each entry with a DOI, queries CrossRef and reports:
    - Title/author/year mismatches
    - Entries missing DOIs
    - Placeholder/fake DOIs

  Usage:
    node scripts/validate-bib.js path/to/references.bib
*/

const https = require('https');
const url = require('url');
const fs = require('fs');
const path = require('path');

// ---------------------------------------------------------------------------
// HTTP helper (same pattern as resolve-papers.js)
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
          reject(new Error(`HTTP ${res.statusCode}`));
        }
      });
    }).on('error', reject);
  });
}

// ---------------------------------------------------------------------------
// BibTeX parser (lightweight, extracts key fields)
// ---------------------------------------------------------------------------

function extractBibEntries(bibContent) {
  const entries = [];
  const re = /@(\w+)\s*\{\s*([^,\s]+)\s*,([\s\S]*?)(?=\n@|\n*$)/g;
  let m;
  while ((m = re.exec(bibContent)) !== null) {
    const type = m[1].toLowerCase();
    const key = m[2];
    const body = m[3];
    const fields = {};
    const fieldRe = /(\w+)\s*=\s*\{([^}]*)\}/g;
    let fm;
    while ((fm = fieldRe.exec(body)) !== null) {
      fields[fm[1].toLowerCase()] = fm[2].trim();
    }
    entries.push({ type, key, fields });
  }
  return entries;
}

// ---------------------------------------------------------------------------
// CrossRef lookup
// ---------------------------------------------------------------------------

async function queryCrossRef(doi) {
  const apiUrl = `https://api.crossref.org/works/${encodeURIComponent(doi)}`;
  try {
    const raw = await httpGet(apiUrl);
    const data = JSON.parse(raw);
    const item = data.message;
    return {
      title: Array.isArray(item.title) ? item.title[0] : item.title || '',
      authors: (item.author || []).map((a) => [a.given, a.family].filter(Boolean).join(' ')).join(', '),
      year: item.published && item.published['date-parts'] ? String(item.published['date-parts'][0][0]) : null,
    };
  } catch {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Comparison helpers
// ---------------------------------------------------------------------------

function normalizeStr(s) {
  return (s || '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
}

function titlesMatch(a, b) {
  return normalizeStr(a) === normalizeStr(b);
}

function yearsMatch(a, b) {
  return String(a).trim() === String(b).trim();
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const bibPath = process.argv[2];
  if (!bibPath) {
    console.log('Usage: node scripts/validate-bib.js path/to/references.bib');
    process.exit(0);
  }

  const fullPath = path.resolve(bibPath);
  if (!fs.existsSync(fullPath)) {
    console.error(`File not found: ${fullPath}`);
    process.exit(1);
  }

  const content = fs.readFileSync(fullPath, 'utf8');
  const entries = extractBibEntries(content);

  if (entries.length === 0) {
    console.log('No BibTeX entries found.');
    return;
  }

  let withDoi = 0;
  let noDoi = 0;
  let validated = 0;
  let mismatches = 0;
  let unreachable = 0;
  const issues = [];

  for (const entry of entries) {
    const doi = entry.fields.doi;
    if (!doi) {
      noDoi++;
      issues.push(`[${entry.key}] No DOI — cannot validate against CrossRef`);
      continue;
    }

    // Detect placeholder DOIs
    if (/10\.0000\//.test(doi) || /example/i.test(doi)) {
      withDoi++;
      issues.push(`[${entry.key}] Placeholder DOI: ${doi}`);
      mismatches++;
      continue;
    }

    withDoi++;
    process.stdout.write(`  Checking ${entry.key}...`);

    const cr = await queryCrossRef(doi);
    if (!cr) {
      unreachable++;
      console.log(' could not reach CrossRef');
      issues.push(`[${entry.key}] DOI ${doi} — CrossRef lookup failed`);
      continue;
    }

    validated++;
    const titleOk = titlesMatch(entry.fields.title, cr.title);
    const yearOk = yearsMatch(entry.fields.year, cr.year);

    if (titleOk && yearOk) {
      console.log(' OK');
    } else {
      mismatches++;
      console.log(' MISMATCH');
      if (!titleOk) {
        issues.push(`[${entry.key}] Title mismatch:\n    bib:     "${entry.fields.title}"\n    crossref: "${cr.title}"`);
      }
      if (!yearOk) {
        issues.push(`[${entry.key}] Year mismatch: bib=${entry.fields.year}, crossref=${cr.year}`);
      }
    }
  }

  // Summary
  console.log('\n--- Summary ---');
  console.log(`Total entries:   ${entries.length}`);
  console.log(`With DOI:        ${withDoi}`);
  console.log(`Without DOI:     ${noDoi}`);
  console.log(`Validated (OK):  ${validated - mismatches}`);
  console.log(`Mismatches:      ${mismatches}`);
  console.log(`Unreachable:     ${unreachable}`);

  if (issues.length > 0) {
    console.log('\n--- Issues ---');
    for (const issue of issues) console.log(issue);
  }

  if (mismatches > 0) process.exit(1);
}

main().catch((err) => {
  console.error('Error:', err.message);
  process.exit(1);
});
