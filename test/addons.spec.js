'use strict';

const {expect} = require('chai');
const {execFileSync, spawnSync} = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');
const solr = require('../builders/solr');

class Service {
  constructor(id, options, compose) {
    this.options = options;
    this.service = compose.services.solr;
  }
}
const Builder = solr.builder(Service, solr.config);
const build = options => new Builder('solr', {
  name: 'solr', root: directory, confDest: '/conf', data: 'solr-data', ...options,
});
let directory;

describe('Solr addons', () => {
  beforeEach(() => {
    directory = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'lando-solr-')));
    fs.mkdirSync(path.join(directory, 'plugins'));
  });
  afterEach(() => fs.rmSync(directory, {recursive: true, force: true}));

  it('enables bundled modules on Solr 9 and 10 including patch versions', () => {
    for (const version of ['9', '9.0', '9.8.1', '10', '10.0.0']) {
      const {service} = build({version, modules: ['analysis-extras', 'langid', 'analysis-extras']});
      expect(service.environment.SOLR_MODULES).to.equal('analysis-extras,langid');
    }
  });

  it('does not set SOLR_MODULES unless requested', () => {
    expect(build({version: '9'}).service.environment).not.to.have.property('SOLR_MODULES');
    expect(build({version: '9', modules: []}).service.environment.SOLR_MODULES).to.equal('');
  });

  it('rejects invalid module lists and unsupported versions', () => {
    for (const modules of ['analysis-extras', null, [false], [''], ['analysis-extras,langid']]) {
      expect(() => build({version: '9', modules})).to.throw('list of module names');
    }
    for (const version of ['8.11', '7', 'custom']) {
      expect(() => build({version, modules: []})).to.throw('require Solr 9 or 10');
      expect(() => build({version, plugins: 'plugins'})).to.throw('require Solr 9 or 10');
    }
  });

  it('stages plugins read-only outside the Solr installation and persisted data', () => {
    const {service} = build({version: '9', plugins: './plugins'});
    expect(service.volumes).to.include(`${path.join(directory, 'plugins')}:/lando-solr-plugins:ro`);
    expect(service.volumes).to.include('/conf/install-plugins.sh:/install-solr-plugins.sh:ro');
    expect(service.environment.LANDO_SOLR_PLUGINS_DIR).to.equal('/lando-solr-plugins');
    expect(service.volumes.some(volume => volume.includes('WEB-INF/lib'))).to.equal(false);
  });

  it('rejects missing, non-directory, absolute, and escaping plugin paths', () => {
    fs.writeFileSync(path.join(directory, 'file'), 'not a directory');
    fs.symlinkSync(os.tmpdir(), path.join(directory, 'outside'), 'junction');
    for (const plugins of ['missing', 'file', 'outside', '..', '', false, ['/plugins'], '/plugins']) {
      expect(() => build({version: '10', plugins})).to.throw(/Solr plugins/);
    }
  });

  (process.platform === 'win32' ? describe.skip : describe)('plugin installation', () => {
    let source;
    let home;
    let env;
    const script = path.resolve(__dirname, '../config/install-plugins.sh');
    const install = () => execFileSync('bash', [script], {env});
    beforeEach(() => {
      source = path.join(directory, 'plugins');
      home = path.join(directory, 'data');
      fs.mkdirSync(path.join(home, 'lib'), {recursive: true});
      env = {...process.env, LANDO_SOLR_DATADIR: home, LANDO_SOLR_PLUGINS_DIR: source};
    });

    it('copies JARs and dependencies without changing the source or existing libraries', () => {
      fs.writeFileSync(path.join(source, 'custom plugin.jar'), 'plugin');
      fs.writeFileSync(path.join(source, 'dependency.jar'), 'dependency');
      fs.writeFileSync(path.join(source, 'README'), 'ignored');
      fs.mkdirSync(path.join(source, 'nested'));
      fs.writeFileSync(path.join(home, 'lib', 'existing.jar'), 'existing');
      install();
      expect(fs.readdirSync(path.join(home, 'lib')).sort())
        .to.deep.equal(['custom plugin.jar', 'dependency.jar', 'existing.jar']);
      expect(fs.readFileSync(path.join(source, 'custom plugin.jar'), 'utf8')).to.equal('plugin');
    });

    it('replaces changed JARs and removes deleted JARs on restart', () => {
      fs.writeFileSync(path.join(source, 'plugin.jar'), 'old');
      fs.writeFileSync(path.join(source, 'removed.jar'), 'old');
      install();
      fs.writeFileSync(path.join(source, 'plugin.jar'), 'new');
      fs.unlinkSync(path.join(source, 'removed.jar'));
      install();
      expect(fs.readFileSync(path.join(home, 'lib', 'plugin.jar'), 'utf8')).to.equal('new');
      expect(fs.readdirSync(path.join(home, 'lib'))).to.deep.equal(['plugin.jar']);
    });

    it('cleans up managed JARs when the plugins option is removed', () => {
      fs.writeFileSync(path.join(source, 'plugin.jar'), 'plugin');
      fs.writeFileSync(path.join(home, 'lib', 'existing.jar'), 'existing');
      install();
      delete env.LANDO_SOLR_PLUGINS_DIR;
      install();
      expect(fs.readdirSync(path.join(home, 'lib'))).to.deep.equal(['existing.jar']);
    });

    it('fails on conflicting filenames without overwriting existing libraries', () => {
      fs.writeFileSync(path.join(source, 'existing.jar'), 'replacement');
      fs.writeFileSync(path.join(home, 'lib', 'existing.jar'), 'original');
      const result = spawnSync('bash', [script], {env, encoding: 'utf8'});
      expect(result.status).to.equal(1);
      expect(result.stderr).to.include('conflicts with an existing library');
      expect(fs.readFileSync(path.join(home, 'lib', 'existing.jar'), 'utf8')).to.equal('original');
    });

    it('fails if the staged directory disappears', () => {
      env.LANDO_SOLR_PLUGINS_DIR = path.join(directory, 'missing');
      const result = spawnSync('bash', [script], {env, encoding: 'utf8'});
      expect(result.status).to.equal(1);
      expect(result.stderr).to.include('plugins directory is missing');
    });
  });
});
