const fs = require('fs');
const path = require('path')

const v8_path = path.resolve(process.argv[2]);
const v8_version = process.argv[3];

function justReplace(path, from, to) {
    console.log(`patch ${path} ...`);
    const context = fs.readFileSync(path, 'utf-8').replace(from, to);
    fs.writeFileSync(path, context);
}

function addV8CC(v8_path) {
    const filepath = path.join(v8_path, 'BUILD.gn')
    console.log(`add v8cc to ${filepath} ...`);
    let context = fs.readFileSync(filepath, 'utf-8');
    
    let v8cc_target = `
  v8_executable("v8cc") {
    visibility = [ ":*" ]  # Only targets in this file can depend on this.

    sources = [
      "src/snapshot/embedded/embedded-empty.cc",
      "src/snapshot/v8cc.cc",
      "src/snapshot/snapshot-empty.cc",
    ]

    if (v8_control_flow_integrity) {
      sources += [ "src/deoptimizer/deoptimizer-cfi-empty.cc" ]
    }

    configs = [ ":internal_config" ]

    deps = [
      ":v8_base_without_compiler",
      ":v8_compiler_for_mksnapshot",
      ":v8_init",
      ":v8_libbase",
      ":v8_libplatform",
      ":v8_maybe_icu",
      ":v8_shared_internal_headers",
      ":v8_tracing",
      "//build/win:default_exe_manifest",
    ]
  }
    `;
    context = context.replace('deps = [ ":mksnapshot($v8_snapshot_toolchain)" ]', 'deps = [ ":mksnapshot($v8_snapshot_toolchain)", ":v8cc($v8_snapshot_toolchain)" ]');
    let insert_pos = context.indexOf('v8_executable("mksnapshot") {');
    fs.writeFileSync(filepath, context.slice(0, insert_pos) + v8cc_target + context.slice(insert_pos));
    
    fs.copyFileSync(path.join(__dirname, 'v8cc.cc'), path.join(v8_path, 'src/snapshot/v8cc.cc'));
}

(function() {
    addV8CC(v8_path);
    justReplace(path.join(v8_path, 'src/api/api.h'), 'NewArray<internal::Address>(kHandleBlockSize)', 'NewArray<internal::Address>(kHandleBlockSize + 1)');
})();
