// src/index.ts
import { getEnvironment } from "wasi:cli/environment@0.2.3";
var greeter = {
  greet(name) {
    const env = new Map(getEnvironment());
    const greeting = env.get("GREETING") || "Hello";
    if (!name || name.trim() === "") {
      throw "Name cannot be empty";
    }
    console.log(`Greeting ${name} with "${greeting}"`);
    return `${greeting}, ${name}!`;
  }
};
export {
  greeter
};
