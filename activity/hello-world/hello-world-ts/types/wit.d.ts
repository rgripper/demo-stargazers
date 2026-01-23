/// <reference path="./interfaces/obelisk-log-log.d.ts" />
/// <reference path="./interfaces/stargazers-hello-world-greeter.d.ts" />
/// <reference path="./interfaces/wasi-cli-environment.d.ts" />
declare module 'root:component/root' {
  export type * as ObeliskLogLog100 from 'obelisk:log/log@1.0.0'; // import obelisk:log/log@1.0.0
  export type * as WasiCliEnvironment023 from 'wasi:cli/environment@0.2.3'; // import wasi:cli/environment@0.2.3
  export * as greeter from 'stargazers:hello-world/greeter'; // export stargazers:hello-world/greeter
}
