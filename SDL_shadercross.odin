package sdl_shadercross

import "core:c"
import sdl "vendor:sdl3"

MAJOR_VERSION :: 3
MINOR_VERSION :: 0
MICRO_VERSION :: 0

// TODO: Other OS support
foreign import sdl_shadercross "SDL3_shadercross.lib"

ShaderStage :: enum {
	VERTEX,
	FRAGMENT,
	COMPUTE,
}

GraphicsShaderMetadata :: struct {
	num_samplers:         sdl.Uint32,		/**< The number of samplers defined in the shader. */
	num_storage_textures: sdl.Uint32,		/**< The number of storage textures defined in the shader. */
	num_storage_buffers:  sdl.Uint32,		/**< The number of storage buffers defined in the shader. */
	num_uniform_buffers:  sdl.Uint32,		/**< The number of uniform buffers defined in the shader. */
	props:                sdl.PropertiesID,	/**< A properties ID for extensions. This is allocated and freed by the caller, and should be 0 if no extensions are needed. */
}

ComputePipelineMetadata :: struct {
	num_samplers:                   sdl.Uint32,			/**< The number of samplers defined in the shader. */
	num_readonly_storage_textures:  sdl.Uint32,			/**< The number of readonly storage textures defined in the shader. */
	num_readonly_storage_buffers:   sdl.Uint32, 		/**< The number of readonly storage buffers defined in the shader. */
	num_readwrite_storage_textures: sdl.Uint32, 		/**< The number of read-write storage textures defined in the shader. */
	num_readwrite_storage_buffers:  sdl.Uint32, 		/**< The number of read-write storage buffers defined in the shader. */
	num_uniform_buffers:            sdl.Uint32, 		/**< The number of uniform buffers defined in the shader. */
	threadcount_x:                  sdl.Uint32, 		/**< The number of threads in the X dimension. */
	threadcount_y:                  sdl.Uint32, 		/**< The number of threads in the Y dimension. */
	threadcount_z:                  sdl.Uint32, 		/**< The number of threads in the Z dimension. */
	props:                          sdl.PropertiesID,	/**< A properties ID for extensions. This is allocated and freed by the caller, and should be 0 if no extensions are needed. */
}

SPIRV_Info :: struct {
	bytecode:      [^]sdl.Uint8,		/**< The SPIRV bytecode. */
	bytecode_size: c.size_t,			/**< The length of the SPIRV bytecode. */
	entrypoint:    cstring,				/**< The entry point function name for the shader in UTF-8. */
	shader_stage:  ShaderStage,			/**< The shader stage to transpile the shader with. */
	enable_debug:  c.bool,				/**< Allows debug info to be emitted when relevant. Can be useful for graphics debuggers like RenderDoc. */
	name:          cstring,				/**< A UTF-8 name to associate with the shader. Optional, can be NULL. */
	props:         sdl.PropertiesID,	/**< A properties ID for extensions. Should be 0 if no extensions are needed. */
}

PROP_SPIRV_PSSL_COMPATIBILITY :: "SDL.shadercross.spirv.pssl.compatibility"

PROP_SPIRV_MSL_VERSION :: "SDL.shadercross.spirv.msl.version"

HLSL_Define :: struct {
	name:  cstring,	/**< The define name. */
	value: cstring,	/**< An optional value for the define. Can be NULL. */
}

HLSL_Info :: struct {
	source:       [^]sdl.Uint8,		/**< The HLSL source code for the shader. */
	entrypoint:   cstring,			/**< The entry point function name for the shader in UTF-8. */
	include_dir:  cstring,			/**< The include directory for shader code. Optional, can be NULL. */
	defines:      [^]HLSL_Define,	/**< An array of defines. Optional, can be NULL. If not NULL, must be terminated with a fully NULL define struct. */
	shader_stage: ShaderStage,		/**< The shader stage to compile the shader with. */
	enable_debug: c.bool,			/**< Allows debug info to be emitted when relevant. Can be useful for graphics debuggers like RenderDoc. */
	name:         cstring,			/**< A UTF-8 name to associate with the shader. Optional, can be NULL. */
	props:        sdl.PropertiesID,	/**< A properties ID for extensions. Should be 0 if no extensions are needed. */
}

@(default_calling_convention = "c", link_prefix = "SDL_ShaderCross_")
foreign sdl_shadercross {
	/**
	* Initializes SDL_shadercross
	*
	* \threadsafety This should only be called once, from a single thread.
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
	* \param info a struct describing the shader to transpile.
	* \returns an SDL_malloc'd string containing MSL code.
	*/
	TranspileMSLFromSPIRV :: proc(info: ^SPIRV_Info) -> rawptr ---

	/**
	* Transpile to HLSL code from SPIRV code.
	*
	* You must SDL_free the returned string once you are done with it.
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
	* Compile an SDL GPU shader from SPIRV code.
	*
	* \param device the SDL GPU device.
	* \param info a struct describing the shader to transpile.
	* \param metadata a pointer filled in with shader metadata.
	* \returns a compiled SDL_GPUShader
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileGraphicsShaderFromSPIRV :: proc(device: ^sdl.GPUDevice, info: ^SPIRV_Info, metadata: ^GraphicsShaderMetadata) -> ^sdl.GPUShader ---

	/**
	* Compile an SDL GPU compute pipeline from SPIRV code.
	*
	* \param device the SDL GPU device.
	* \param info a struct describing the shader to transpile.
	* \param metadata a pointer filled in with compute pipeline metadata.
	* \returns a compiled SDL_GPUComputePipeline
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileComputePipelineFromSPIRV :: proc(device: ^sdl.GPUDevice, info: ^SPIRV_Info, metadata: ^ComputePipelineMetadata) -> ^sdl.GPUComputePipeline ---

	/**
	* Reflect graphics shader info from SPIRV code.
	*
	* \param bytecode the SPIRV bytecode.
	* \param bytecode_size the length of the SPIRV bytecode.
	* \param metadata a pointer filled in with shader metadata.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	ReflectGraphicsSPIRV :: proc(bytecode: [^]c.uint8_t, bytecode_size: c.size_t, metadata: ^GraphicsShaderMetadata) -> c.bool ---

	/**
	* Reflect compute pipeline info from SPIRV code.
	*
	* \param bytecode the SPIRV bytecode.
	* \param bytecode_size the length of the SPIRV bytecode.
	* \param metadata a pointer filled in with compute pipeline metadata.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	ReflectComputeSPIRV :: proc(bytecode: [^]c.uint8_t, bytecode_size: c.size_t, metadata: ^ComputePipelineMetadata) -> c.bool ---

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
	* \param info a struct describing the shader to transpile.
	* \param size filled in with the bytecode buffer size.
	* \returns an SDL_malloc'd buffer containing SPIRV bytecode.
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileSPIRVFromHLSL :: proc(info: ^HLSL_Info, size: ^c.size_t) -> rawptr ---

	/**
	* Compile an SDL GPU shader from HLSL code.
	*
	* \param device the SDL GPU device.
	* \param info a struct describing the shader to transpile.
	* \param metadata a pointer filled in with shader metadata.
	* \returns a compiled SDL_GPUShader
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileGraphicsShaderFromHLSL :: proc(device: ^sdl.GPUDevice, info: ^HLSL_Info, metadata: ^GraphicsShaderMetadata) -> ^sdl.GPUShader ---

	/**
	* Compile an SDL GPU compute pipeline from code.
	*
	* \param device the SDL GPU device.
	* \param info a struct describing the shader to transpile.
	* \param metadata a pointer filled in with compute pipeline metadata.
	* \returns a compiled SDL_GPUComputePipeline
	*
	* \threadsafety It is safe to call this function from any thread.
	*/
	CompileComputePipelineFromHLSL :: proc(device: ^sdl.GPUDevice, info: ^HLSL_Info, metadata: ^ComputePipelineMetadata) -> ^sdl.GPUComputePipeline ---
}
