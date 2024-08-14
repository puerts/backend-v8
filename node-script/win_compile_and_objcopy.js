const { execSync } = require('child_process');

const args = process.argv.slice(2);
const compileCommand = args.map(arg => arg.indexOf(' ') > 0 ? `"${arg}"` : arg).join(' ');

try {
  // 执行编译命令
  //console.log(`CXX_SYMBOL_RENAME: ${compileCommand}`);
  execSync(compileCommand, { stdio: 'inherit' });

  // 提取输出文件名
  const outFileMatch = compileCommand.match(/\/Fo(\S+)/);
  if (outFileMatch) {
    const outFile = outFileMatch[1];
    if (outFile.startsWith('"') && outFile.endsWith('"')) {
      outFile = outFile.slice(1, -1);
    }
    //console.log(`Output file: ${outFile}`);

    // 执行 llvm-objcopy 命令
    const objcopyCommand = `llvm-objcopy --redefine-sym="??2@YAPEAX_K@Z=__puerts_wrap__Znwm" --redefine-sym="??3@YAXPEAX@Z=__puerts_wrap__ZdlPv" --redefine-sym="??_U@YAPEAX_K@Z=__puerts_wrap__Znam" --redefine-sym="??_V@YAXPEAX@Z=__puerts_wrap__ZdaPv" --redefine-sym="??2@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnwmRKSt9nothrow_t" --redefine-sym="??_U@YAPEAX_KAEBUnothrow_t@std@@@Z=__puerts_wrap__ZnamRKSt9nothrow_t" --redefine-sym="??_V@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdaPvRKSt9nothrow_t" --redefine-sym="??_V@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvSt11align_val_t" --redefine-sym="??_V@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdaPvSt11align_val_tRKSt9nothrow_t" --redefine-sym="??_V@YAXPEAX_K@Z=__puerts_wrap__ZdaPvm" --redefine-sym="??_V@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdaPvmSt11align_val_t" --redefine-sym="??3@YAXPEAXAEBUnothrow_t@std@@@Z=__puerts_wrap__ZdlPvRKSt9nothrow_t" --redefine-sym="??3@YAXPEAXW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvSt11align_val_t" --redefine-sym="??3@YAXPEAXW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZdlPvSt11align_val_tRKSt9nothrow_t" --redefine-sym="??3@YAXPEAX_K@Z=__puerts_wrap__ZdlPvm" --redefine-sym="??3@YAXPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZdlPvmSt11align_val_t" --redefine-sym="??_U@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnamSt11align_val_t" --redefine-sym="??_U@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnamSt11align_val_tRKSt9nothrow_t" --redefine-sym="??2@YAPEAX_KW4align_val_t@std@@@Z=__puerts_wrap__ZnwmSt11align_val_t" --redefine-sym="??2@YAPEAX_KW4align_val_t@std@@AEBUnothrow_t@1@@Z=__puerts_wrap__ZnwmSt11align_val_tRKSt9nothrow_t" "${outFile}"`;
    //console.log(`Executing: ${objcopyCommand}`);
    execSync(objcopyCommand, { stdio: 'inherit' });
  } else {
    console.error('Failed to extract output file name.');
    process.exit(1);
  }
} catch (error) {
  console.error('Error during compilation or objcopy:', error);
  process.exit(1);
}