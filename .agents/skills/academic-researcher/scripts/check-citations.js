#!/usr/bin/env node

/*
  Simple citation-key check for LaTeX templates:
  - Extracts citation keys used in .tex files under references/templates/
  - Verifies all keys exist in references/templates/references.bib
  - Reports unused bib entries as warnings
*/

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const templatesDir = path.join(repoRoot, 'references', 'templates');
const bibPath = path.join(templatesDir, 'references.bib');

function listFilesRecursive(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir)) {
    const p = path.join(dir, entry);
    const st = fs.statSync(p);
    if (st.isDirectory()) out.push(...listFilesRecursive(p));
    else out.push(p);
  }
  return out;
}

function extractBibKeys(bibContent) {
  const keys = new Set();
  const re = /@\w+\s*\{\s*([^,\s]+)\s*,/g;
  let m;
  while ((m = re.exec(bibContent)) !== null) {
    keys.add(m[1]);
  }
  return keys;
}

function extractCiteKeys(texContent) {
  const keys = new Set();
  const re =
    /\\(?:textcite|parencite|autocite|cite|citet|citep|citeauthor|citeyear)\*?\s*(?:\[[^\]]*\]\s*)*\{([^}]*)\}/g;
  let m;
  while ((m = re.exec(texContent)) !== null) {
    const raw = m[1];
    for (const k of raw.split(',')) {
      const key = k.trim();
      if (key) keys.add(key);
    }
  }
  return keys;
}

function rel(p) {
  return path.relative(repoRoot, p);
}

const bibContent = fs.readFileSync(bibPath, 'utf8');
const bibKeys = extractBibKeys(bibContent);

const texFiles = listFilesRecursive(templatesDir).filter((p) => p.endsWith('.tex'));
let ok = true;

const allCiteKeys = new Set();

for (const texFile of texFiles) {
  const tex = fs.readFileSync(texFile, 'utf8');
  const citeKeys = extractCiteKeys(tex);

  for (const k of citeKeys) {
    allCiteKeys.add(k);
  }

  const missing = [...citeKeys].filter((k) => !bibKeys.has(k)).sort();
  if (missing.length > 0) {
    ok = false;
    console.error(`Missing keys in ${rel(texFile)}: ${missing.join(', ')}`);
  }
}

// Reverse check: report unused bib entries
const unusedKeys = [...bibKeys].filter((k) => !allCiteKeys.has(k)).sort();
if (unusedKeys.length > 0) {
  console.warn(`Warning: unused bib entries in ${rel(bibPath)}: ${unusedKeys.join(', ')}`);
}

if (!ok) {
  process.exit(1);
}

console.log(
  `Checked ${texFiles.length} .tex files, ${allCiteKeys.size} citation keys, ${bibKeys.size} bib entries (${unusedKeys.length} unused)`
);
