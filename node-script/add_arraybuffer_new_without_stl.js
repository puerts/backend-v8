const fs = require('fs');
const path = require('path');

let v8_h_path = process.argv[2] + '/include/v8.h';
let v8_h_context = fs.readFileSync(v8_h_path, 'utf-8');

let v8_h_insert_pos = v8_h_context.lastIndexOf('#endif');

let v8_h_insert_code = `

#define HAS_ARRAYBUFFER_NEW_WITHOUT_STL 1
#define V8_HAS_WRAP_API_WITHOUT_STL 1

namespace v8
{
// do not new two ArrayBuffer with the same data and length
V8_EXPORT Local<ArrayBuffer> ArrayBuffer_New_Without_Stl(Isolate* isolate, 
      void* data, size_t byte_length, v8::BackingStore::DeleterCallback deleter,
      void* deleter_data);
V8_EXPORT Local<ArrayBuffer> ArrayBuffer_New_Without_Stl(Isolate* isolate, 
      void* data, size_t byte_length);
V8_EXPORT void* ArrayBuffer_Get_Data(Local<ArrayBuffer> array_buffer, size_t &byte_length);
V8_EXPORT void* ArrayBuffer_Get_Data(Local<ArrayBuffer> array_buffer);

V8_EXPORT Local<Module> Module_CreateSyntheticModule_Without_Stl(
      Isolate* isolate, Local<String> module_name,
      Local<String>* export_names, size_t export_names_length,
      v8::Module::SyntheticModuleEvaluationSteps evaluation_steps);

}
`;

fs.writeFileSync(v8_h_path, v8_h_context.slice(0, v8_h_insert_pos) + v8_h_insert_code + v8_h_context.slice(v8_h_insert_pos));


let api_cc_path = process.argv[2] + '/src/api/api.cc';

let api_cc_insert_code = `
#include "include/v8-version.h"
namespace v8
{
V8_EXPORT Local<ArrayBuffer> ArrayBuffer_New_Without_Stl(Isolate* isolate, 
      void* data, size_t byte_length, BackingStore::DeleterCallback deleter,
      void* deleter_data)
{
    auto Backing = ArrayBuffer::NewBackingStore(
            data, byte_length,deleter,
            deleter_data);
    return ArrayBuffer::New(isolate, std::move(Backing));
}

V8_EXPORT Local<ArrayBuffer> ArrayBuffer_New_Without_Stl(Isolate* isolate, 
      void* data, size_t byte_length)
{
#if V8_MAJOR_VERSION < 9
  CHECK_IMPLIES(byte_length != 0, data != nullptr);
  CHECK_LE(byte_length, i::JSArrayBuffer::kMaxByteLength);
  i::Isolate* i_isolate = reinterpret_cast<i::Isolate*>(isolate);

  std::shared_ptr<i::BackingStore> backing_store = LookupOrCreateBackingStore(
      i_isolate, data, byte_length, i::SharedFlag::kNotShared, ArrayBufferCreationMode::kExternalized);

  i::Handle<i::JSArrayBuffer> obj =
      i_isolate->factory()->NewJSArrayBuffer(std::move(backing_store));
  obj->set_is_external(true);
  return Utils::ToLocal(obj);
#else
  auto Backing = ArrayBuffer::NewBackingStore(
          data, byte_length, BackingStore::EmptyDeleter, nullptr);
  return ArrayBuffer::New(isolate, std::move(Backing));
#endif
}

V8_EXPORT void* ArrayBuffer_Get_Data(Local<ArrayBuffer> array_buffer, size_t &byte_length)
{
    byte_length = array_buffer->GetBackingStore()->ByteLength();
    return array_buffer->GetBackingStore()->Data();
}
V8_EXPORT void* ArrayBuffer_Get_Data(Local<ArrayBuffer> array_buffer)
{
    return array_buffer->GetBackingStore()->Data();
}

V8_EXPORT Local<Module> Module_CreateSyntheticModule_Without_Stl(
    Isolate* v8_isolate, Local<String> module_name,
    Local<String>* export_names, size_t export_names_length,
    v8::Module::SyntheticModuleEvaluationSteps evaluation_steps) {
  std::vector<Local<String>> vec(export_names, export_names + export_names_length);
  return v8::Module::CreateSyntheticModule(v8_isolate, module_name, vec, evaluation_steps);
}
}

`

const api_cc_content = fs.readFileSync(api_cc_path, 'utf-8');

const api_cc_insert_pos = api_cc_content.lastIndexOf('#include "src/api/api-macros-undef.h"');

fs.writeFileSync(api_cc_path, api_cc_content.slice(0, api_cc_insert_pos) + api_cc_insert_code + api_cc_content.slice(api_cc_insert_pos));

const v8_inspector_h_path = path.join(process.argv[2], 'include/v8-inspector.h');

const v8_inspector_h_insert_code = `
namespace v8_inspector {

V8_EXPORT v8_inspector::V8Inspector* V8Inspector_Create_Without_Stl(v8::Isolate*, v8_inspector::V8InspectorClient*);

V8_EXPORT void V8Inspector_Destroy_Without_Stl(v8_inspector::V8Inspector*);

}

`;

const v8_inspector_h_content = fs.readFileSync(v8_inspector_h_path, 'utf-8');

const v8_inspector_h_insert_pos = v8_inspector_h_content.lastIndexOf('#endif');

fs.writeFileSync(v8_inspector_h_path, v8_inspector_h_content.slice(0, v8_inspector_h_insert_pos) + v8_inspector_h_insert_code + v8_inspector_h_content.slice(v8_inspector_h_insert_pos));

const v8_inspector_impl_cc_path = path.join(process.argv[2], 'src/inspector/v8-inspector-impl.cc');

const v8_inspector_impl_cc_insert_code = `
namespace v8_inspector {

V8_EXPORT V8Inspector* V8Inspector_Create_Without_Stl(v8::Isolate* isolate, V8InspectorClient* client) {
    return new V8InspectorImpl(isolate, client);
}

V8_EXPORT void V8Inspector_Destroy_Without_Stl(V8Inspector* inspector) {
    delete inspector;
}
    
}

`;

fs.writeFileSync(v8_inspector_impl_cc_path, fs.readFileSync(v8_inspector_impl_cc_path, 'utf-8') + v8_inspector_impl_cc_insert_code);


const default_platform_cc_path = path.join(process.argv[2], 'src/libplatform/default-platform.cc');

const default_platform_cc_insert_code = `
#include "include/v8-version.h"
namespace v8 {
namespace platform {

v8::Platform* NewDefaultPlatform_Without_Stl(
    int thread_pool_size, IdleTaskSupport idle_task_support,
    InProcessStackDumping in_process_stack_dumping,
    v8::TracingController* tracing_controller
#if V8_MAJOR_VERSION > 10
    ,PriorityMode priority_mode
#endif
	) {
  return NewDefaultPlatform(thread_pool_size, idle_task_support, in_process_stack_dumping, std::unique_ptr<v8::TracingController>(tracing_controller)
#if V8_MAJOR_VERSION > 10
      , priority_mode
#endif
	  ).release();
}
#if V8_MAJOR_VERSION > 8
v8::Platform* NewSingleThreadedDefaultPlatform_Without_Stl(
    IdleTaskSupport idle_task_support,
    InProcessStackDumping in_process_stack_dumping,
    v8::TracingController* tracing_controller) {
  return NewSingleThreadedDefaultPlatform(idle_task_support, in_process_stack_dumping, std::unique_ptr<v8::TracingController>(tracing_controller)).release();
}
#endif

void DeletePlatform_Without_Stl(v8::Platform* platform) {
    delete platform;
}
}  // namespace platform
}  // namespace v8

`;

fs.writeFileSync(default_platform_cc_path, fs.readFileSync(default_platform_cc_path, 'utf-8') + default_platform_cc_insert_code);


const libplatform_h_path = path.join(process.argv[2], 'include/libplatform/libplatform.h');

const libplatform_h_content = fs.readFileSync(libplatform_h_path, 'utf-8');

let libplatform_h_insert_pos = libplatform_h_content.lastIndexOf('#endif');


let v8_version = process.argv[3];

let libplatform_h_insert_code;

let major_versoin = parseInt(v8_version.split('.')[0]);

if (major_versoin > 10) {
    libplatform_h_insert_code = `
    namespace v8 {
    namespace platform {


    V8_PLATFORM_EXPORT v8::Platform* NewDefaultPlatform_Without_Stl(
        int thread_pool_size = 0,
        IdleTaskSupport idle_task_support = IdleTaskSupport::kDisabled,
        InProcessStackDumping in_process_stack_dumping =
            InProcessStackDumping::kDisabled,
        v8::TracingController* tracing_controller = nullptr, 
        PriorityMode priority_mode = PriorityMode::kDontApply
        );

    V8_PLATFORM_EXPORT v8::Platform*
    NewSingleThreadedDefaultPlatform_Without_Stl(
        IdleTaskSupport idle_task_support = IdleTaskSupport::kDisabled,
        InProcessStackDumping in_process_stack_dumping =
            InProcessStackDumping::kDisabled,
        v8::TracingController* tracing_controller = nullptr);

    V8_PLATFORM_EXPORT void DeletePlatform_Without_Stl(v8::Platform*);

    }  // namespace platform
    }  // namespace v8

    `;
} else if (major_versoin == 8) {
    libplatform_h_insert_code = `
    namespace v8 {
    namespace platform {


    V8_PLATFORM_EXPORT v8::Platform* NewDefaultPlatform_Without_Stl(
        int thread_pool_size = 0,
        IdleTaskSupport idle_task_support = IdleTaskSupport::kDisabled,
        InProcessStackDumping in_process_stack_dumping =
            InProcessStackDumping::kDisabled,
        v8::TracingController* tracing_controller = nullptr
        );

    V8_PLATFORM_EXPORT void DeletePlatform_Without_Stl(v8::Platform*);

    }  // namespace platform
    }  // namespace v8

    `;
} else {
    libplatform_h_insert_code = `
    namespace v8 {
    namespace platform {


    V8_PLATFORM_EXPORT v8::Platform* NewDefaultPlatform_Without_Stl(
        int thread_pool_size = 0,
        IdleTaskSupport idle_task_support = IdleTaskSupport::kDisabled,
        InProcessStackDumping in_process_stack_dumping =
            InProcessStackDumping::kDisabled,
        v8::TracingController* tracing_controller = nullptr
        );

    V8_PLATFORM_EXPORT v8::Platform*
    NewSingleThreadedDefaultPlatform_Without_Stl(
        IdleTaskSupport idle_task_support = IdleTaskSupport::kDisabled,
        InProcessStackDumping in_process_stack_dumping =
            InProcessStackDumping::kDisabled,
        v8::TracingController* tracing_controller = nullptr);

    V8_PLATFORM_EXPORT void DeletePlatform_Without_Stl(v8::Platform*);

    }  // namespace platform
    }  // namespace v8

    `;
}

console.log(libplatform_h_insert_code);

fs.writeFileSync(libplatform_h_path, libplatform_h_content.slice(0, libplatform_h_insert_pos) + libplatform_h_insert_code + libplatform_h_content.slice(libplatform_h_insert_pos));

