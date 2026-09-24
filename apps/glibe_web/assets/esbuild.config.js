// esbuild config for Phoenix
const esbuild = require("esbuild");

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = {
  ".js": "jsx",
};

const plugins = [];

const options = {
  entryPoints: ["js/app.js"],
  bundle: true,
  target: "es2017",
  outdir: "../priv/static/assets",
  logLevel: "info",
  loader,
  plugins,
};

if (watch) {
  options.watch = {
    onRebuild(error) {
      if (error) console.error("watch build failed:", error);
      else console.log("watch build succeeded");
    },
  };
}

if (deploy) {
  options.minify = true;
}

esbuild.build(options).catch(() => process.exit(1));