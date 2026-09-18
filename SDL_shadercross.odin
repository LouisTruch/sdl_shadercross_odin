package sdl_shadercross

import "core:c"
import sdl "vendor:sdl3"

MAJOR_VERSION :: 3
MINOR_VERSION :: 0
MICRO_VERSION :: 0

// TODO: Other OS support
foreign import sdl_shadercross "SDL3_shadercross.lib"

IOVarType :: enum c.int {
	UNKNOWN,
	INT8,
	UINT8,
	INT16,
	UINT16,
	INT32,
	UINT32,
	INT64,
	UINT64,
	FLOAT16,
	FLOAT32,
	FLOAT64,
}

ShaderStage :: enum c.int {
	VERTEX,
	FRAGMENT,
	COMPUTE,
}

IOVarMetadata :: struct {
	name:        cstring, /**< The UTF-8 name of the variable. */
	location:    sdl.Uint32, /**< The location of the variable. */
	vector_type: IOVarType, /**< The vector type of the variable. */
	vector_size: sdl.Uint32, /**< The number of components in the vector type of the variable. */
}

GraphicsShaderResourceInfo :: struct {
	num_samplers:         sdl.Uint32, /**< The number of samplers defined in the shader. */
	num_storage_textures: sdl.Uint32, /**< The number of storage textures defined in the shader. */
	num_storage_buffers:  sdl.Uint32, /**< The number of storage buffers defined in the shader. */
	num_uniform_buffers:  sdl.Uint32, /**< The number of uniform buffers defined in the shader. */
}

GraphicsShaderMetadata :: struct {
	resource_info: GraphicsShaderResourceInfo, /**< Sub-struct containing the resource info of the shader. */
	num_inputs:    sdl.Uint32, /**< The number of inputs defined in the shader. */
	inputs:        [^]IOVarMetadata, /**< The inputs defined in the shader. */
	num_outputs:   sdl.Uint32, /**< The number of outputs defined in the shader. */
	outputs:       [^]IOVarMetadata, /**< The outputs defined in the shader. */
}

ComputePipelineMetadata :: struct {
	num_samplers:                   sdl.Uint32, /**< The number of samplers defined in the shader. */
	num_readonly_storage_textures:  sdl.Uint32, /**< The number of readonly storage textures defined in the shader. */
	num_readonly_storage_buffers:   sdl.Uint32, /**< The number of readonly storage buffers defined in the shader. */
	num_readwrite_storage_textures: sdl.Uint32, /**< The number of read-write storage textures defined in the shader. */
	num_readwrite_storage_buffers:  sdl.Uint32, /**< The number of read-write storage buffers defined in the shader. */
	num_uniform_buffers:            sdl.Uint32, /**< The number of uniform buffers defined in the shader. */
	threadcount_x:                  sdl.Uint32, /**< The number of threads in the X dimension. */
	threadcount_y:                  sdl.Uint32, /**< The number of threads in the Y dimension. */
	threadcount_z:                  sdl.Uint32, /**< The number of threads in the Z dimension. */
}

SPIRV_Info :: struct {
	bytecode:      [^]sdl.Uint8, /**< The SPIRV bytecode. */
	bytecode_size: c.size_t, /**< The length of the SPIRV bytecode. */
	entrypoint:    cstring, /**< The entry point function name for the shader in UTF-8. */
	shader_stage:  ShaderStage, /**< The shader stage to transpile the shader with. */
	props:         sdl.PropertiesID, /**< A properties ID for extensions. Should be 0 if no extensions are needed. */
}

PROP_SHADER_DEBUG_ENABLE_BOOLEAN :: "SDL_shadercross.spirv.debug.enable"
PROP_SHADER_DEBUG_NAME_STRING :: "SDL_shadercross.spirv.debug.name"
PROP_SHADER_CULL_UNUSED_BINDINGS_BOOLEAN :: "SDL_shadercross.spirv.cull_unused_bindings"

PROP_SPIRV_PSSL_COMPATIBILITY_BOOLEAN :: "SDL_shadercross.spirv.pssl.compatibility"
PROP_SPIRV_MSL_VERSION_STRING :: "SDL_shadercross.spirv.msl.version"
PROP_HLSL_SKIP_SPIRV_ROUNDTRIP_BOOLEAN :: "SDL_shadercross.hlsl.skip_spirv_roundtrip"

HLSL_Define :: struct {
	name:  cstring, /**< The define name. */
	value: cstring, /**< An optional value for the define. Can be NULL. */
}

HLSL_Info :: struct {
	source:       cstring, /**< The HLSL source code for the shader. */
	entrypoint:   cstring, /**< The entry point function name for the shader in UTF-8. */
	include_dir:  cstring, /**< The include directory for shader code. Optional, can be NULL. */
	defines:      [^]HLSL_Define, /**< An array of defines. Optional, can be NULL. If not NULL, must be terminated with a fully NULL define struct. */
	shader_stage: ShaderStage, /**< The shader stage to compile the shader with. */
	props:        sdl.PropertiesID, /**< A properties ID for extensions. Should be 0 if no extensions are needed. */
}

@(default_calling_convention = "c", link_prefix = "SDL_ShaderCross_")
foreign sdl_shadercross {
	/**
	* Initializes SDL_shadercross
	*
	* \threadsafety This should only be called once, from a single thread.
	* \returns true on success, false otherwise.
	*/
	Init :: proc() -> c.bool ---

	/**
	* De-initializes SDL_shadercross
	*
	* \threadsafety This should only be called once, from a single thread.
	*/
	Quit :: proc() ---

	/**
	* Get the supported shader formats that SPIRV cross-compilation can output
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	GetSPIRVShaderFormats :: proc() -> sdl.GPUShaderFormat ---

	/**
	* Transpile to MSL code from SPIRV code.
	*
	* You must SDL_free the returned string once you are done with it.
	*
	* These are the optional properties that can be used:
	*
	* - `PROP_SPIRV_MSL_VERSION_STRING`: specifies the MSL version that should be emitted. Defaults to 1.2.0.
	*
	* \param info a struct describing the shader to transpile.
	* \returns an SDL_malloc'd string containing MSL code.
	*/
	TranspileMSLFromSPIRV :: proc(info: ^SPIRV_Info) -> rawptr ---

	/**
	* Transpile to HLSL code from SPIRV code.
	*
	* You must SDL_free the returned string once you are done with it.
	*
	* These are the optional properties that can be used:
	*
	* - `PROP_SPIRV_PSSL_COMPATIBILITY_BOOLEAN`: generates PSSL-compatible shader.
	*
	* \param info a struct describing the shader to transpile.
	* \returns an SDL_malloc'd string containing HLSL code.
	*/
	TranspileHLSLFromSPIRV :: proc(info: ^SPIRV_Info) -> rawptr ---

	/**
	* Compile DXBC bytecode from SPIRV code.
	*
	* You must SDL_free the returned buffer once you are done with it.
	*
	* \param info a struct describing the shader to transpile.
	* \param size filled in with the bytecode buffer size.
	* \returns an SDL_malloc'd buffer containing DXBC bytecode.
	*/
	CompileDXBCFromSPIRV :: proc(info: ^SPIRV_Info, size: ^c.size_t) -> rawptr ---

	/**
	* Compile DXIL bytecode from SPIRV code.
	*
	* You must SDL_free the returned buffer once you are done with it.
	*
	* \param info a struct describing the shader to transpile.
	* \param size filled in with the bytecode buffer size.
	* \returns an SDL_malloc'd buffer containing DXIL bytecode.
	*/
	CompileDXILFromSPIRV :: proc(info: ^SPIRV_Info, size: ^c.size_t) -> rawptr ---

	/**
	* Compile an SDL GPU shader from SPIRV code. If your shader source is HLSL,
	* you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL().
	*
	* \param device the SDL GPU device.
	* \param info a struct describing the shader to transpile.
	* \param resource_info a struct describing resource info of the shader. Can be obtained from ReflectGraphicsSPIRV().
	* \param props a properties object filled in with extra shader metadata.
	* \returns a compiled SDL_GPUShader.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileGraphicsShaderFromSPIRV :: proc(device: ^sdl.GPUDevice, info: ^SPIRV_Info, resource_info: ^GraphicsShaderResourceInfo, props: sdl.PropertiesID) -> ^sdl.GPUShader ---

	/**
	* Compile an SDL GPU compute pipeline from SPIRV code. If your shader source is HLSL,
	* you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL().
	*
	* \param device the SDL GPU device.
	* \param info a struct describing the shader to transpile.
	* \param metadata a struct describing shader metadata. Can be obtained from ReflectComputeSPIRV().
	* \param props a properties object filled in with extra shader metadata.
	* \returns a compiled SDL_GPUComputePipeline.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileComputePipelineFromSPIRV :: proc(device: ^sdl.GPUDevice, info: ^SPIRV_Info, metadata: ^ComputePipelineMetadata, props: sdl.PropertiesID) -> ^sdl.GPUComputePipeline ---

	/**
	* Reflect graphics shader info from SPIRV code. If your shader source is HLSL,
	* you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL().
	* The returned struct must be freed with SDL_free() when you are done with the metadata.
	*
	* \param bytecode the SPIRV bytecode.
	* \param bytecode_size the length of the SPIRV bytecode.
	* \param props a properties object filled in with extra shader metadata, provided by the user.
	* \returns A metadata struct on success, NULL otherwise.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	ReflectGraphicsSPIRV :: proc(bytecode: [^]sdl.Uint8, bytecode_size: c.size_t, props: sdl.PropertiesID) -> ^GraphicsShaderMetadata ---

	/**
	* Reflect compute pipeline info from SPIRV code. If your shader source is HLSL,
	* you should obtain SPIR-V bytecode from CompileSPIRVFromHLSL().
	* The returned struct must be freed with SDL_free() when you are done with the metadata.
	*
	* \param bytecode the SPIRV bytecode.
	* \param bytecode_size the length of the SPIRV bytecode.
	* \param props a properties object filled in with extra shader metadata, provided by the user.
	* \returns A metadata struct on success, NULL otherwise.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	ReflectComputeSPIRV :: proc(bytecode: [^]sdl.Uint8, bytecode_size: c.size_t, props: sdl.PropertiesID) -> ^ComputePipelineMetadata ---

	/**
	* Get the supported shader formats that HLSL cross-compilation can output
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	GetHLSLShaderFormats :: proc() -> sdl.GPUShaderFormat ---

	/**
	* Compile to DXBC bytecode from HLSL code via a SPIRV-Cross round trip.
	*
	* You must SDL_free the returned buffer once you are done with it.
	*
	* These are the optional properties that can be used:
	*
	* - `PROP_SHADER_DEBUG_ENABLE_BOOLEAN`: allows debug info to be emitted when relevant. Should only be used with debugging tools like Renderdoc.
	* - `PROP_SHADER_DEBUG_NAME_STRING`: a UTF-8 name to be used with the shader. Relevant for use with debugging tools like Renderdoc.
	* - `PROP_SHADER_CULL_UNUSED_BINDINGS_BOOLEAN`: When true, indicates that the compiler should cull unused shader resources. This behavior is disabled by default.
	* - `PROP_HLSL_SKIP_SPIRV_ROUNDTRIP_BOOLEAN`: When true, the SPIRV roundtrip is skipped. This behavior is disabled by default. Do not use this property if your shader uses Structured Buffers.
	*
	* \param info a struct describing the shader to transpile.
	* \param size filled in with the bytecode buffer size.
	* \returns an SDL_malloc'd buffer containing DXBC bytecode.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileDXBCFromHLSL :: proc(info: ^HLSL_Info, size: ^c.size_t) -> rawptr ---

	/**
	* Compile to DXIL bytecode from HLSL code via a SPIRV-Cross round trip.
	*
	* You must SDL_free the returned buffer once you are done with it.
	*
	* These are the optional properties that can be used:
	*
	* - `PROP_SHADER_DEBUG_ENABLE_BOOLEAN`: allows debug info to be emitted when relevant. Should only be used with debugging tools like Renderdoc.
	* - `PROP_SHADER_DEBUG_NAME_STRING`: a UTF-8 name to be used with the shader. Relevant for use with debugging tools like Renderdoc.
	* - `PROP_SHADER_CULL_UNUSED_BINDINGS_BOOLEAN`: when true, indicates that the compiler should cull unused shader resources. This behavior is disabled by default.
	* - `PROP_HLSL_SKIP_SPIRV_ROUNDTRIP_BOOLEAN`: when true, the SPIRV roundtrip is skipped. This behavior is disabled by default. Do not use this property if your shader uses Structured Buffers.
	*
	* \param info a struct describing the shader to transpile.
	* \param size filled in with the bytecode buffer size.
	* \returns an SDL_malloc'd buffer containing DXIL bytecode.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileDXILFromHLSL :: proc(info: ^HLSL_Info, size: ^c.size_t) -> rawptr ---

	/**
	* Compile to SPIRV bytecode from HLSL code.
	*
	* You must SDL_free the returned buffer once you are done with it.
	*
	* These are the optional properties that can be used:
	*
	* - `PROP_SHADER_DEBUG_ENABLE_BOOLEAN`: allows debug info to be emitted when relevant. Should only be used with debugging tools like Renderdoc.
	* - `PROP_SHADER_DEBUG_NAME_STRING`: a UTF-8 name to be used with the shader. Relevant for use with debugging tools like Renderdoc.
	* - `PROP_SHADER_CULL_UNUSED_BINDINGS_BOOLEAN`: when true, indicates that the compiler should cull unused shader resources. This behavior is disabled by default.
	*
	* \param info a struct describing the shader to transpile.
	* \param size filled in with the bytecode buffer size.
	* \returns an SDL_malloc'd buffer containing SPIRV bytecode.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileSPIRVFromHLSL :: proc(info: ^HLSL_Info, size: ^c.size_t) -> rawptr ---
}