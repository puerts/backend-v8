const fs = require('fs');
const path = require('path')

const v8_path = path.resolve(process.argv[2]);
const v8_version = process.argv[3];
const wrap_new = process.argv[4] === "with_new_wrap";

function justReplace(path, from, to) {
    console.log(`patch ${path} ...`);
    const context = fs.readFileSync(path, 'utf-8').replace(from, to);
    fs.writeFileSync(path, context);
}

function addV8CC() {
    const filepath = path.join(v8_path, 'BUILD.gn')
    console.log(`add v8cc to ${filepath} ...`);
    let context = fs.readFileSync(filepath, 'utf-8');
    
    let v8cc_target = `
  v8_executable("v8cc") {
    visibility = [ ":*" ]  # Only targets in this file can depend on this.

    sources = [
      "src/snapshot/v8cc.cc",
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
      ":v8_turboshaft",
      "//build/win:default_exe_manifest",
      ":v8_snapshot",
    ]
  }
    `;
    if (v8_version == "9.4.146.24") {
        v8cc_target = v8cc_target.replace('":v8_turboshaft",', '');
    }
    console.log(v8cc_target);
    //context = context.replace('deps = [ ":mksnapshot($v8_snapshot_toolchain)" ]', 'deps = [ ":mksnapshot($v8_snapshot_toolchain)", ":v8cc($v8_snapshot_toolchain)" ]');
    const v8cc_target_insert_pos = context.indexOf('v8_executable("mksnapshot") {');
    context = context.slice(0, v8cc_target_insert_pos) + v8cc_target + context.slice(v8cc_target_insert_pos);
    const wee8_pos = context.indexOf('v8_static_library("wee8")');
    const ref_pos = context.indexOf('":v8_snapshot",', wee8_pos) + '":v8_snapshot"'.length + 1;
    fs.writeFileSync(filepath, context.slice(0, ref_pos) + '\n      ":v8cc($v8_snapshot_toolchain)",' + context.slice(ref_pos));
    
    fs.copyFileSync(path.join(__dirname, 'v8cc.cc'), path.join(v8_path, 'src/snapshot/v8cc.cc'));
}

(function() {
    addV8CC();
    if (!wrap_new) {
        justReplace(path.join(v8_path, 'src/api/api.h'), 'NewArray<internal::Address>(kHandleBlockSize)', 'NewArray<internal::Address>(kHandleBlockSize + 1)');
    } else {
        console.log("wrap_new is set, skip path kHandleBlockSize");
        const replacePath = path.join(v8_path, 'buildtools/third_party/libc++/BUILD.gn');
        if (v8_version == "9.4.146.24") {
            justReplace(replacePath, '\"trunk/src/vector.cpp\",', '\"trunk/src/vector.cpp\",\n    \"trunk/src/wrap_symbols.cc\",');
            fs.copyFileSync(path.join(__dirname, 'wrap_symbols.cc'), path.join(v8_path, 'buildtools/third_party/libc++/trunk/src/wrap_symbols.cc'));
        } else if (v8_version == "10.6.194") {
            justReplace(replacePath, '\"trunk/src/verbose_abort.cpp\",', '\"trunk/src/verbose_abort.cpp\",\n    \"trunk/src/wrap_symbols.cc\",');
            fs.copyFileSync(path.join(__dirname, 'wrap_symbols.cc'), path.join(v8_path, 'buildtools/third_party/libc++/trunk/src/wrap_symbols.cc'));
        } else if (v8_version == "11.8.172") {
            justReplace(replacePath, '\"//third_party/libc++/src/src/verbose_abort.cpp\",', '\"//third_party/libc++/src/src/verbose_abort.cpp\",\n    \"//third_party/libc++/src/src/wrap_symbols.cc\",');
            fs.copyFileSync(path.join(__dirname, 'wrap_symbols.cc'), path.join(v8_path, 'third_party/libc++/src/src/wrap_symbols.cc'));
        } else {
            throw new Error(`not support version:${v8_version}`);
        }
    }
})();
