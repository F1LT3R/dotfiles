const path = require('path');

// This package is primarily a content + installer package. Exporting these paths
// makes it easier for integrators to locate the canonical skill files.
module.exports = {
  name: 'academic-researcher',
  skillMdPath: path.join(__dirname, 'SKILL.md'),
  referencesDir: path.join(__dirname, 'references'),
  examplesDir: path.join(__dirname, 'examples'),
};

