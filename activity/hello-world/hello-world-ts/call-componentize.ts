import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve, delimiter } from 'node:path';
import { componentize,type ComponentizeOptions } from '@bytecodealliance/componentize-js';
import { execSync } from 'node:child_process';
import { env, platform } from 'node:process';

// let wizerBin;
// try {
//   const isWin = platform === 'win32';
//   const cmd = isWin ? 'where wizer' : 'which wizer';
//   if (!env.PATH) throw new Error("No PATH in env");
//   // Filter out node_modules/.bin from PATH
//   const filteredPath = env.PATH.split(delimiter)
//     .filter(p => !p.includes('node_modules/.bin'))
//     .join(delimiter);
//   wizerBin = execSync(cmd, {
//     encoding: 'utf-8',
//     env: { ...env, PATH: filteredPath }
//   }).split('\n')[0]!.trim();
//   console.debug("Using wizer", wizerBin);
// } catch {
//   console.debug("Using bundled wizer");
// }

const packageJson = await readFile(new URL('./package.json', import.meta.url)).then(x => JSON.parse(x.toString()));

const options: ComponentizeOptions = {
  sourcePath: resolve('bundle/index.bundled.js'),
  witPath: resolve('wit'),
  disableFeatures: packageJson.componentMeta.disableFeatures,
  //wizerBin: wizerBin!,
}

const { component } = await componentize(options);
const pkgName = packageJson.name;

await mkdir('dist', { recursive: true });
await writeFile(`dist/${pkgName}.wasm`, component);
