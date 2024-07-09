const fs = require('fs');
const path = require('path')

const v8_path = path.resolve(process.argv[2]);

function justReplace(path, from, to) {
    console.log(`patch ${path} ...`)
    const context = fs.readFileSync(path, 'utf-8').replace(from, to);
    fs.writeFileSync(path, context);
}

(function() {
    justReplace(path.join(v8_path, 'src/api/api.h'), 'NewArray<internal::Address>(kHandleBlockSize)', 'NewArray<internal::Address>(kHandleBlockSize + 1)')
})();
