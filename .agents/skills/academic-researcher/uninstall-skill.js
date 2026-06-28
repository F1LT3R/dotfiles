#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

const packageDir = __dirname;
const configPath = path.join(packageDir, '.claude-skill.json');

let config;
try {
  config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
} catch (e) {
  console.error('Failed to load .claude-skill.json:', e.message);
  process.exit(1);
}

const skillName = config.name;
const platforms = config.platforms || {};

function getHomeDir() {
  return os.homedir();
}

function getProjectRoot() {
  if (process.env.INIT_CWD && fs.existsSync(process.env.INIT_CWD)) {
    return process.env.INIT_CWD;
  }

  let current = process.cwd();
  while (current !== path.parse(current).root) {
    if (
      fs.existsSync(path.join(current, 'package.json')) ||
      fs.existsSync(path.join(current, '.git'))
    ) {
      return current;
    }
    current = path.dirname(current);
  }
  return process.cwd();
}

function resolveUninstallScope() {
  const args = new Set(process.argv.slice(2));
  if (args.has('--global')) return 'global';
  if (args.has('--project')) return 'project';
  if (args.has('--skip')) return 'none';

  const envScope = (process.env.SKILL_UNINSTALL_SCOPE || '').trim().toLowerCase();
  if (envScope === 'global' || envScope === 'project') return envScope;
  if (envScope === 'none' || envScope === 'skip') return 'none';

  const npmGlobal =
    process.env.npm_config_global === 'true' || process.env.npm_config_location === 'global';
  if (npmGlobal) return 'global';

  // Avoid surprising deletes when removed as a local project dependency.
  const invokedByNpm = Boolean(process.env.npm_lifecycle_event);
  if (invokedByNpm) return 'none';

  // Manual invocation defaults to a project uninstall.
  return 'project';
}

function rmrf(p) {
  if (typeof fs.rmSync === 'function') {
    fs.rmSync(p, { recursive: true, force: true });
    return;
  }

  // Node < 14.14 fallback.
  fs.rmdirSync(p, { recursive: true });
}

function removeDir(dir) {
  if (fs.existsSync(dir)) {
    rmrf(dir);
    return true;
  }
  return false;
}

function uninstallFromPlatform(platformName, scope, globalPath, projectPath) {
  let targetDir;
  if (scope === 'global') {
    targetDir = globalPath.replace('~', getHomeDir());
  } else {
    targetDir = path.join(getProjectRoot(), projectPath);
  }
  
  const skillDir = path.join(targetDir, skillName);
  
  console.log(`Uninstalling from ${platformName} (${scope}): ${skillDir}`);
  
  try {
    if (removeDir(skillDir)) {
      console.log(`✓ ${platformName}: Uninstalled successfully`);
    } else {
      console.log(`○ ${platformName}: Skill not found, skipping`);
    }
  } catch (error) {
    console.error(`✗ ${platformName}: Failed to uninstall - ${error.message}`);
  }
}

console.log(`\n🗑️  Uninstalling skill: ${skillName}\n`);

const platformsToUninstall = ['claude-code', 'opencode', 'codex', 'gemini-cli', 'cursor', 'windsurf'];
const scope = resolveUninstallScope();

if (scope === 'none') {
  console.log('Skipping automatic uninstall (set SKILL_UNINSTALL_SCOPE=project|global or pass --project/--global).');
  process.exit(0);
}

for (const platform of platformsToUninstall) {
  if (platforms[platform]) {
    const platformConfig = platforms[platform];
    if (platformConfig.global) {
      uninstallFromPlatform(platform, scope, platformConfig.global, platformConfig.project);
    }
  }
}

console.log(`\n✅ Skill "${skillName}" uninstalled successfully!\n`);
