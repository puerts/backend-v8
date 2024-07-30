const fs = require('fs');
const path = require('path')

const v8_path = path.resolve(process.argv[2]);
const v8_version = process.argv[3];
const target_cpu = (process.argv[4] == 'arm' ? 'arm' : 'arm64');

function addV8CC() {
    const filepath = path.join(v8_path, 'BUILD.gn')
    console.log(`add ${target_cpu} v8cc to ${filepath} ...`);
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
    
    const v8_initializers_start = context.indexOf('v8_source_set("v8_initializers") {');
    const v8_initializers_end = context.indexOf('v8_source_set("v8_init") {');
    const v8_compiler_sources_start = context.indexOf('v8_compiler_sources = [');
    const v8_compiler_sources_end = context.indexOf('if (v8_enable_webassembly) {', v8_compiler_sources_start);
    const v8_base_without_compiler_start = context.indexOf('v8_source_set("v8_base_without_compiler") {');
    const v8_base_without_compiler_end = context.indexOf('group("v8_base") {');
    
    let new_context = context.slice(0, v8_initializers_start);
    new_context += `v8_cross_cpu = "${target_cpu}"\n\n`
    new_context += context.slice(v8_initializers_start, v8_initializers_end).replace(/v8_current_cpu/g, 'v8_cross_cpu');
    if (v8_version != "9.4.146.24" && v8_compiler_sources_start > 0) {
        new_context += context.slice(v8_initializers_end, v8_compiler_sources_start);
        new_context += context.slice(v8_compiler_sources_start, v8_compiler_sources_end).replace(/v8_current_cpu/g, 'v8_cross_cpu');
        new_context += context.slice(v8_compiler_sources_end, v8_base_without_compiler_start);
    } else {
        new_context += context.slice(v8_initializers_end, v8_base_without_compiler_start);
    }
    new_context += context.slice(v8_base_without_compiler_start, v8_base_without_compiler_end).replace(/v8_current_cpu/g, 'v8_cross_cpu');
    new_context += context.slice(v8_base_without_compiler_end);
    new_context += v8cc_target;
    new_context = new_context.replace(/V8_TARGET_ARCH_X64|V8_TARGET_ARCH_IA32/g, target_cpu == 'arm' ? 'V8_TARGET_ARCH_ARM' : 'V8_TARGET_ARCH_ARM64');

    fs.writeFileSync(filepath, new_context);
    
    fs.copyFileSync(path.join(__dirname, 'v8cc.cc'), path.join(v8_path, 'src/snapshot/v8cc.cc'));
}

(function() {
    addV8CC();
})();
