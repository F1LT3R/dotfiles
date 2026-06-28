#!/usr/bin/env node

/*
  Keep per-platform skill copies in sync with the canonical root files.
  Platforms in this repo discover skills from:
    .claude/skills/<name>/
    .codex/skills/<name>/
    .opencode/skills/<name>/
    .gemini/skills/<name>/
    .cursor/skills/<name>/
    .windsurf/skills/<name>/
*/

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const skillName = 'academic-researcher';

const platforms = ['.claude', '.opencode', '.codex', '.gemini', '.cursor', '.windsurf'];

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function copyFile(src, dest) {
  ensureDir(path.dirname(dest));
  fs.copyFileSync(src, dest);
}

function copyDir(src, dest) {
  const stat = fs.statSync(src);
  if (!stat.isDirectory()) {
    throw new Error(`copyDir expected directory: ${src}`);
  }

  ensureDir(dest);
  for (const entry of fs.readdirSync(src)) {
    const srcPath = path.join(src, entry);
    const destPath = path.join(dest, entry);
    const s = fs.statSync(srcPath);
    if (s.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      copyFile(srcPath, destPath);
    }
  }
}

function rmrf(p) {
  if (typeof fs.rmSync === 'function') {
    fs.rmSync(p, { recursive: true, force: true });
    return;
  }

  // Node < 14.14 fallback.
  fs.rmdirSync(p, { recursive: true });
}

function rmIfExists(p) {
  if (!fs.existsSync(p)) return;
  rmrf(p);
}

const srcSkillMd = path.join(repoRoot, 'SKILL.md');
const srcReferences = path.join(repoRoot, 'references');
const srcExamples = path.join(repoRoot, 'examples');

for (const platform of platforms) {
  const destSkillDir = path.join(repoRoot, platform, 'skills', skillName);
  ensureDir(destSkillDir);

  copyFile(srcSkillMd, path.join(destSkillDir, 'SKILL.md'));

  rmIfExists(path.join(destSkillDir, 'references'));
  copyDir(srcReferences, path.join(destSkillDir, 'references'));

  rmIfExists(path.join(destSkillDir, 'examples'));
  copyDir(srcExamples, path.join(destSkillDir, 'examples'));

  console.log(`Synced ${platform}/skills/${skillName}`);
}
