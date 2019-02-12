{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores 
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_AL
 * OpenAL headers
 ***********************************************************************************************************************
}

Unit TERRA_AL;
{$I terra.inc}

Interface

{$IFDEF WINDOWS}{$UNDEF ANDROID}{$ENDIF}

Uses TERRA_Utils
     {$IFDEF WINDOWS},Windows
     {$ELSE}
{$IFNDEF ANDROID}
     ,DynLibs
{$ENDIF}
     {$ENDIF};

Type
{$IFDEF WINDOWS}
  TLibHandle=THandle;
{$ENDIF}

{$IFDEF ANDROID}
  TLibHandle=Integer;
{$ENDIF}

  PALCdevice=Pointer;
  PALCcontext=Pointer;

Const
{$IFDEF WINDOWS}
  OpenALLibName='OpenAL32.dll';
{$ENDIF}

{$IFDEF ANDROID}
  OpenALLibName='libopenal.so';
{$ELSE}
{$IFDEF LINUX}
  OpenALLibName='libopenal.so.1';
{$ENDIF}
{$ENDIF}

{$IFDEF MACOS}
  OpenALLibName='/System/Library/Frameworks/OpenAL.framework/OpenAL';
{$ENDIF}

{$IFDEF IPHONE}
  OpenALLibName='/System/Library/Frameworks/OpenAL.framework/OpenAL';
{$ENDIF}

Const
  //bad value
  AL_INVALID                                = -1;

  AL_NONE                                   = 0;

  //Boolean False.
  AL_FALSE                                  = 0;

  //Boolean True.
  AL_TRUE                                   = 1;

  //Indicate the type of AL_SOURCE.
  //Sources can be spatialized
  AL_SOURCE_TYPE                            = $200;

  //Indicate source has absolute coordinates.
  AL_SOURCE_ABSOLUTE                       = $201;

  //Indicate Source has relative coordinates.
  AL_SOURCE_RELATIVE                       = $202;

  //Directional source, inner cone angle, in degrees.
  //Range:    [0-360]
  //Default:  360
  AL_CONE_INNER_ANGLE                      = $1001;

  //Directional source, outer cone angle, in degrees.
  //Range:    [0-360]
  //Default:  360
  AL_CONE_OUTER_ANGLE                       = $1002;

  //Specify the pitch to be applied, either at source,
  //or on mixer results, at listener.
  //Range:   [0.5-2.0]
  //Default: 1.0
  AL_PITCH                                  =$1003;

  //Specify the current location in three dimensional space.
  //OpenAL, like OpenGL, uses a right handed coordinate system,
  //where in a frontal default view X (thumb) points right,
  //Y points up (index finger), and Z points towards the
  //viewer/camera (middle finger).
  //To switch from a left handed coordinate system, flip the
  //sign on the Z coordinate.
  //Listener position is always in the world coordinate system.
  AL_POSITION                               =$1004;

  //Specify the current direction.
  AL_DIRECTION                              =$1005;

  // Specify the current velocity in three dimensional space.
  AL_VELOCITY                               =$1006;

  //Indicate whether source is looping.
  //Type: ALboolean?
  //Range:   [AL_TRUE, AL_FALSE]
  //Default: FALSE.
  AL_LOOPING                                =$1007;

  //Indicate the buffer to provide sound samples.
  //Type: ALuint.
  //Range: any valid Buffer id.
  AL_BUFFER                                 =$1009;

  //Indicate the gain (volume amplification) applied.
  //Type:   ALfloat.
  //Range:  ]0.0-  ]
  //A value of 1.0 means un-attenuated/unchanged.
  //Each division by 2 equals an attenuation of -6dB.
  //Each multiplicaton with 2 equals an amplification of +6dB.
  //A value of 0.0 is meaningless with respect to a logarithmic
  //scale; it is interpreted as zero volume - the channel
  //is effectively disabled.
  AL_GAIN                                   =$100A;

  //Indicate minimum source attenuation
  //Type: ALfloat
  //Range:  [0.0 - 1.0]
  //Logarthmic
  AL_MIN_GAIN                               =$100D;

  //Indicate maximum source attenuation
  //Type: ALfloat
  //Range:  [0.0 - 1.0]
  //Logarthmic
  AL_MAX_GAIN                               =$100E;

  //Indicate listener orientation.
  //at/up
  AL_ORIENTATION                            =$100F;

  //Specify the channel mask. (Creative)
  //Type:	 ALuint
  //Range:	 [0 - 255]
  AL_CHANNEL_MASK                           =$3000;

  //Source state information.
  AL_SOURCE_STATE                           =$1010;
  AL_INITIAL                                =$1011;
  AL_PLAYING                                =$1012;
  AL_PAUSED                                 =$1013;
  AL_STOPPED                                =$1014;

  //Buffer Queue params
  AL_BUFFERS_QUEUED                         =$1015;
  AL_BUFFERS_PROCESSED                      =$1016;

  //Sound samples: format specifier.
  AL_FORMAT_MONO8                           =$1100;
  AL_FORMAT_MONO16                          =$1101;
  AL_FORMAT_STEREO8                         =$1102;
  AL_FORMAT_STEREO16                        =$1103;

  //source specific reference distance
  //Type: ALfloat
  //Range:  0.0 - +inf
  //At 0.0, no distance attenuation occurs.  Default is
  //1.0.
  AL_REFERENCE_DISTANCE                     =$1020;

  //source specific rolloff factor
  //Type: ALfloat
  //Range:  0.0 - +inf
  AL_ROLLOFF_FACTOR                         =$1021;

  //Directional source, outer cone gain.
  //Default:  0.0
  //Range:    [0.0 - 1.0]
  //Logarithmic
  AL_CONE_OUTER_GAIN                        =$1022;

  //Indicate distance above which sources are not
  //attenuated using the inverse clamped distance model.
  //Default: +inf
  //Type: ALfloat
  //Range:  0.0 - +inf
  AL_MAX_DISTANCE                           =$1023;

  //Sound samples: frequency, in units of Hertz [Hz].
  //This is the number of samples per second. Half of the
  //sample frequency marks the maximum significant
  //frequency component.
  AL_FREQUENCY                              =$2001;
  AL_BITS                                   =$2002;
  AL_CHANNELS                               =$2003;
  AL_SIZE                                   =$2004;
  AL_DATA                                   =$2005;

  //Buffer state.
  //Not supported for public use (yet).
  AL_UNUSED                                 =$2010;
  AL_PENDING                                =$2011;
  AL_PROCESSED                              =$2012;

  //Errors: No Error.
  AL_NO_ERROR                               =AL_FALSE;

  //Invalid Name paramater passed to AL call.
  AL_INVALID_NAME                           =$A001;

  //Invalid parameter passed to AL call.
  AL_ILLEGAL_ENUM                           =$A002;
  AL_INVALID_ENUM                           =$A002;

  //Invalid enum parameter value.
  AL_INVALID_VALUE                          =$A003;

  //Illegal call.
  AL_ILLEGAL_COMMAND                        =$A004;
  AL_INVALID_OPERATION                      =$A004;

  //No mojo.
  AL_OUT_OF_MEMORY                          =$A005;

  // Context strings: Vendor Name.
  AL_VENDOR                                 =$B001;
  AL_VERSION                                =$B002;
  AL_GraphicsManager                               =$B003;
  AL_EXTENSIONS                             =$B004;

  // Global tweakage.

  // Doppler scale.  Default 1.0
  AL_DOPPLER_FACTOR                         =$C000;

  // Tweaks speed of propagation.
  AL_DOPPLER_VELOCITY                       =$C001;

  // Distance models
  //
  // used in conjunction with DistanceModel
  //
  // implicit: NONE, which disances distance attenuation.
  AL_DISTANCE_MODEL                         =$D000;
  AL_INVERSE_DISTANCE                       =$D001;
  AL_INVERSE_DISTANCE_CLAMPED               =$D002;
  AL_LINEAR_DISTANCE                        =$D003;
  AL_LINEAR_DISTANCE_CLAMPED                =$D004;
  AL_EXPONENT_DISTANCE                      =$D005;
  AL_EXPONENT_DISTANCE_CLAMPED              =$D006;

  //bad value
  ALC_INVALID                              =0;

  //Boolean False.
  ALC_FALSE                                =0;

  //Boolean True.
  ALC_TRUE                                 =1;

  //followed by <int> Hz
  ALC_FREQUENCY                            =$1007;

  //followed by <int> Hz
  ALC_REFRESH                              =$1008;

  //followed by AL_TRUE, AL_FALSE
  ALC_SYNC                                 =$1009;

  //errors

  //No error
  ALC_NO_ERROR                             =ALC_FALSE;

  //No device
  ALC_INVALID_DEVICE                       =$A001;

  //invalid context ID
  ALC_INVALID_CONTEXT                      =$A002;

  //bad enum
  ALC_INVALID_ENUM                         =$A003;

  //bad value
  ALC_INVALID_VALUE                        =$A004;

  //Out of memory.
  ALC_OUT_OF_MEMORY                        =$A005;

  //The Specifier string for default device
  ALC_DEFAULT_DEVICE_SPECIFIER             =$1004;
  ALC_DEVICE_SPECIFIER                     =$1005;
  ALC_EXTENSIONS                           =$1006;

  ALC_CAPTURE_DEVICE_SPECIFIER		        = $310;
  ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER    = $311;
  ALC_CAPTURE_SAMPLES			                = $312;

  ALC_MAJOR_VERSION                        =$1000;
  ALC_MINOR_VERSION                        =$1001;

  ALC_ATTRIBUTES_SIZE                      =$1002;
  ALC_ALL_ATTRIBUTES                       =$1003;

  AL_REVERB_DENSITY                        = $0001;
  AL_REVERB_DIFFUSION                      = $0002;
  AL_REVERB_GAIN                           = $0003;
  AL_REVERB_GAINHF                         = $0004;
  AL_REVERB_DECAY_TIME                     = $0005;
  AL_REVERB_DECAY_HFRATIO                  = $0006;
  AL_REVERB_REFLECTIONS_GAIN               = $0007;
  AL_REVERB_REFLECTIONS_DELAY              = $0008;
  AL_REVERB_LATE_REVERB_GAIN               = $0009;
  AL_REVERB_LATE_REVERB_DELAY              = $000A;
  AL_REVERB_AIR_ABSORPTION_GAINHF          = $000B;
  AL_REVERB_ROOM_ROLLOFF_FACTOR            = $000C;
  AL_REVERB_DECAY_HFLIMIT                  = $000D;

  //Source definitions to be used with alSource functions.
  //These values must be unique and not conflict with other
  //al source values.
  AL_DIRECT_FILTER                         =$20005;
  AL_AUXILIARY_SEND_FILTER                 =$20006;
  AL_AIR_ABSORPTION_FACTOR                 =$20007;
  AL_ROOM_ROLLOFF_FACTOR                   =$20008;
  AL_CONE_OUTER_GAINHF                     =$20009;
  AL_DIRECT_FILTER_GAINHF_AUTO             =$2000A;
  AL_AUXILIARY_SEND_FILTER_GAIN_AUTO       =$2000B;
  AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO     =$2000C;

  // Filter type definitions to be used with AL_FILTER_TYPE.
  AL_FILTER_NULL                           =$0000;  // Can also be used as a Filter Object ID
  AL_FILTER_LOWPASS                        =$0001;
  AL_FILTER_HIGHPASS                       =$0002;
  AL_FILTER_BANDPASS                       =$0003;

  //Auxiliary Slot object definitions to be used with alAuxiliaryEffectSlot functions.
  AL_EFFECTSLOT_EFFECT                     = $0001;
  AL_EFFECTSLOT_GAIN                       = $0002;
  AL_EFFECTSLOT_AUXILIARY_SEND_AUTO        = $0003;

  //Value to be used as an Auxiliary Slot ID to disable a source send..
  AL_EFFECTSLOT_NULL                       = $0000;

  //Effect type definitions to be used with AL_EFFECT_TYPE.
  AL_EFFECT_NULL                           = $0000;  // Can also be used as an Effect Object ID
  AL_EFFECT_REVERB                         = $0001;
  AL_EFFECT_CHORUS                         = $0002;
  AL_EFFECT_DISTORTION                     = $0003;
  AL_EFFECT_ECHO                           = $0004;
  AL_EFFECT_FLANGER                        = $0005;
  AL_EFFECT_FREQUENCY_SHIFTER              = $0006;
  AL_EFFECT_VOCAL_MORPHER                  = $0007;
  AL_EFFECT_PITCH_SHIFTER                  = $0008;
  AL_EFFECT_RING_MODULATOR                 = $0009;
  AL_EFFECT_AUTOWAH                        = $000A;
  AL_EFFECT_COMPRESSOR                     = $000B;
  AL_EFFECT_EQUALIZER                      = $000C;

  //Effect type
  AL_EFFECT_FIRST_PARAMETER                = $0000;
  AL_EFFECT_LAST_PARAMETER                 = $8000;
  AL_EFFECT_TYPE                           = $8001;

  //Effect type definitions to be used with AL_EFFECT_TYPE.
  AL_EFFECT_EAXREVERB                      = $8000;

Var
  //GraphicsManager State management.
  alEnable: Procedure(capability: Integer); CDecl;
  alDisable: Procedure(capability: Integer); CDecl;
  alIsEnabled: Function(capability: Integer):Boolean; CDecl;

  //State retrieval.
  alGetBooleanv: Procedure(param: Integer; data: PBoolean); CDecl;
  alGetIntegerv: Procedure(param: Integer; data: PInteger); CDecl;
  alGetFloatv: Procedure(param: Integer; data: PSingle); CDecl;
  alGetDoublev: Procedure(param: Integer; data: PDouble); CDecl;
  alGetString: Function(param: Integer): PAnsiChar; CDecl;

  //State retrieval.through return value ( for compatibility )
  alGetBoolean: Function(param: Integer): Boolean; CDecl;
  alGetInteger: Function(param: Integer): Integer; CDecl;
  alGetFloat: Function(param: Integer): Single; CDecl;
  alGetDouble: Function(param: Integer): Double; CDecl;

  //ERROR support.

  //Obtain the most recent error generated in the AL state machine.
  alGetError: Function:Integer; CDecl;

  //EXTENSION support.

  // Verify is extension is avaliable
  alIsExtensionPresent: Function(fname: PAnsiChar): Boolean; CDecl;

  { Obtain the address of a Function (usually an extension)
    with the name fname. All addresses are context-independent.
  }
  alGetProcAddress: Function(fname: PAnsiChar): Pointer; CDecl;

  //Obtain the integer value of an enumeration (usually an extension) with the name ename.
  alGetEnumValue: Function(ename: PAnsiChar): Integer; CDecl;

  //LISTENER
  { Listener is the sample position for a given context.
    The multi-channel (usually stereo) output stream generated
    by the mixer is parametrized by this Listener object:
    its position and velocity relative to Sources, within
    occluder and reflector geometry.
  }
  //Listener Environment:  default 0.
  alListeneri: Procedure(param: Integer; value: Integer); CDecl;

  //Listener Gain:  default 1.0f.
  alListenerf: Procedure(param: Integer; value: Single); CDecl;

  //Listener Position.
  //Listener Velocity.
  alListener3f: Procedure(param: Integer; f1: Single; f2: Single; f3: Single); CDecl;

  //Listener Position:        array [0..2] of TSingle
  //Listener Velocity:        array [0..2] of TSingle
  //Listener Orientation:     array [0..5] of TSingle  forward and up vector.
  alListenerfv: Procedure(param:Integer; values: PSingle); CDecl;

  //Retrieve listener information
  alGetListeneriv: Procedure(param:Integer; values: PInteger); CDecl;
  alGetListenerfv: Procedure(param:Integer; values: PSingle); CDecl;

  //SOURCE
  { Source objects are by default localized. Sources
    take the PCM data provided in the specified Buffer,
    apply Source-specific modifications, and then
    submit them to be mixed according to spatial
    arrangement etc.
  }
  //Create Source objects.
  alGenSources: Procedure(n:Cardinal; sources: PCardinal); CDecl;

  //Delete Source objects.
  alDeleteSources: Procedure(n:Cardinal; sources: PCardinal); CDecl;

  //Verify a handle is a valid Source.
  alIsSource: Function(id: Cardinal):Boolean; CDecl;

  //Set an integer parameter for a Source object.
  alSourcei: Procedure(source: Cardinal; param:Integer; value: Integer); CDecl;
  //Set a 3 integer parameter for a Source object.
  alSource3i: Procedure(source: Cardinal; param:Integer; v1, v2, v3: Integer); CDecl;
  //Set a float parameter for a Source object.
  alSourcef: Procedure(source: Cardinal; param:Integer; value: Single); CDecl;
  //Set a 3 float parameter for a Source object.
  alSource3f: Procedure(source: Cardinal; param:Integer; v1: Single; v2: Single; v3: Single); CDecl;
  //Set a float vector parameter for a Source object.
  alSourcefv: Procedure(source: Cardinal; param:Integer; values: PSingle); CDecl;

  //Get an integer scalar parameter for a Source object.
  alGetSourcei: Procedure(source:Cardinal; param:Integer; value: PInteger); CDecl;
  //Get a float scalar parameter for a Source object.
  alGetSourcef: Procedure(source:Cardinal; param:Integer; value: PSingle); CDecl;
  //Get three float scalar parameter for a Source object.
  alGetSource3f: Procedure(source:Cardinal; param:Integer; v1: PSingle; v2: PSingle; v3: PSingle); CDecl;
  //Get a float vector parameter for a Source object.
  alGetSourcefv: Procedure(source:Cardinal; param:Integer; values: PSingle); CDecl;

  //Activate a source, start replay.
  alSourcePlay: Procedure(source:Cardinal); CDecl;

  //Pause a source,
  //temporarily remove it from the mixer list.
  alSourcePause: Procedure(source:Cardinal); CDecl;

  //Stop a source,
  { temporarily remove it from the mixer list,
    and reset its internal state to pre-Play.
    To remove a Source completely, it has to be
    deleted following Stop, or before Play.
  }
  alSourceStop: Procedure(source:Cardinal); CDecl;


  //Rewind a souce.
  { Stopped paused and playing sources,
    resets the offset into the PCM data and sets state to AL_INITIAL.
  }
  alSourceRewind: Procedure(source:Cardinal); CDecl;

  //vector forms of those Functions we all love
  alSourcePlayv: Procedure(n:Cardinal; sources: PCardinal); CDecl;
  alSourceStopv: Procedure(n:Cardinal; sources: PCardinal); CDecl;
  alSourceRewindv: Procedure(n:Cardinal; sources: PCardinal); CDecl;
  alSourcePausev: Procedure(n:Cardinal; sources: PCardinal); CDecl;

  //BUFFER
  { Buffer objects are storage space for sample data.
    Buffers are referred to by Sources. There can be more than
    one Source using the same Buffer data. If Buffers have
    to be duplicated on a per-Source basis, the driver has to
    take care of allocation, copying, and deallocation as well
    as propagating buffer data changes.
  }

  //Buffer object generation.
  alGenBuffers: Procedure(n:Cardinal; buffers: PCardinal); CDecl;
  alDeleteBuffers: Procedure(n:Cardinal; buffers: PCardinal); CDecl;
  alIsBuffer: Function(buffer:Cardinal):Boolean; CDecl;
  //Specify the data to be filled into a buffer.
  alBufferData: Procedure(buffer:Cardinal; format:Integer; data: Pointer; size, freq:Cardinal); CDecl;
  //read parameter for an buffer object
  alGetBufferi: Procedure(buffer:Cardinal; param:Integer; value: PInteger); CDecl;
  alGetBufferf: Procedure(buffer:Cardinal; param:Integer; value: PSingle); CDecl;

  //Queue stuff
  alSourceQueueBuffers: Procedure(source:Cardinal; n:Cardinal; buffers: PCardinal); CDecl;
  alSourceUnqueueBuffers: Procedure(source:Cardinal; n:Cardinal; buffers: PCardinal); CDecl;

  //Knobs and dials
  alDistanceModel: Procedure(value:Integer); CDecl;
  alDopplerFactor: Procedure(value:Single); CDecl;
  alDopplerVelocity: Procedure(value:Single); CDecl;

  //alc
  alcCreateContext: Function(device: PALCdevice; attrlist: PInteger): PALCcontext; CDecl;

  //There is no current context, as we can mix
  //several active contexts. But al* calls
  //only affect the current context.
  alcMakeContextCurrent: Function(context: PALCcontext): Integer; CDecl;

  //Perform processing on a synced context, non-op on a asynchronous
  //context.
  alcProcessContext: Procedure(context: PALCcontext); CDecl;

  //Suspend processing on an asynchronous context, non-op on a
  //synced context.
  alcSuspendContext: Procedure(context: PALCcontext); CDecl;

  alcDestroyContext: Procedure(context: PALCcontext); CDecl;

  alcGetError: Function(device: PALCdevice):Integer; CDecl;

  alcGetCurrentContext: Function: PALCcontext; CDecl;

  alcOpenDevice: Function(deviceName: PAnsiChar): PALCdevice; CDecl;
  alcCloseDevice: Procedure(device: PALCdevice); CDecl;

  alcIsExtensionPresent: Function(device: PALCdevice; extName: PAnsiChar): Boolean; CDecl;
  alcGetProcAddress: Function(device: PALCdevice; funcName: PAnsiChar):Pointer; CDecl;
  alcGetEnumValue: Function(device: PALCdevice; enumName: PAnsiChar):Integer; CDecl;

  alcGetContextsDevice: Function(context: PALCcontext): PALCdevice; CDecl;

  //Query Functions
  alcGetString: Function(device: PALCdevice; param: Integer): PAnsiChar; CDecl;
  alcGetIntegerv: Procedure(device: PALCdevice; param:Integer; size: Integer; data: PInteger); CDecl;

  // AL_EXT_capture functions
  alcCaptureOpenDevice: Function(Const deviceName:PAnsiChar; frequency:Cardinal; format, buffersize:Integer):PALCdevice; CDecl;
  alcCaptureCloseDevice: Procedure(device:PALCdevice); CDecl;
  alcCaptureStart: Procedure(device:PALCdevice); CDecl;
  alcCaptureStop: Procedure (device:PALCdevice); CDecl;
  alcCaptureSamples: Procedure (device:PALCdevice; Buffer:Pointer; Samples:Integer); CDecl;

  // EFX
  alGenEffects: Procedure(n:Integer; effects:PCardinal); CDecl;
  alDeleteEffects: Procedure(N:Integer; effects:PCardinal); CDecl;
  alIsEffect:Function(effect:Cardinal):Boolean; CDecl;
  alEffecti: Procedure(effect:Cardinal; param:Cardinal; iValue:Integer); CDecl;
  alEffectiv: Procedure(effect:Cardinal; param:Cardinal; piValues:Integer); CDecl;
  alEffectf: Procedure(effect:Cardinal; param:Cardinal; flValue:Single); CDecl;
  alEffectfv: Procedure(effect:Cardinal; param:Cardinal; pflValues:PSingle); CDecl;
  alGetEffecti: Procedure(effect:Cardinal; param:Cardinal; piValue:PInteger); CDecl;
  alGetEffectiv: Procedure(effect:Cardinal; param:Cardinal; piValues:PInteger); CDecl;
  alGetEffectf: Procedure(effect:Cardinal; param:Cardinal; pflValue:PSingle); CDecl;
  alGetEffectfv: Procedure(effect:Cardinal; param:Cardinal; pflValues:PSingle); CDecl;

  alGenAuxiliaryEffectSlots: Procedure(n:Integer; effectslots:PCardinal); CDecl;
  alDeleteAuxiliaryEffectSlots: Procedure(N:Integer; effectslots:PCardinal); CDecl;
  alIsAuxiliaryEffectSlot: Procedure(effectslot:Cardinal); CDecl;
  alAuxiliaryEffectSloti: Procedure(effectslot:Cardinal; param:Cardinal; iValue:Integer); CDecl;
  alAuxiliaryEffectSlotiv: Procedure(effectslot:Cardinal; param:Cardinal; piValues:PInteger); CDecl;
  alAuxiliaryEffectSlotf: Procedure(effectslot:Cardinal; param:Cardinal; flValue:Single); CDecl;
  alAuxiliaryEffectSlotfv: Procedure(effectslot:Cardinal; param:Cardinal; pflValues:PSingle); CDecl;
  alGetAuxiliaryEffectSloti: Procedure(effectslot:Cardinal; param:Cardinal; piValue:PInteger); CDecl;
  alGetAuxiliaryEffectSlotiv: Procedure(effectslot:Cardinal; param:Cardinal; piValues:PInteger); CDecl;
  alGetAuxiliaryEffectSlotf: Procedure(effectslot:Cardinal; param:Cardinal; pflValue:PSingle); CDecl;
  alGetAuxiliaryEffectSlotfv: Procedure(effectslot:Cardinal; param:Cardinal; pflValues:PSingle); CDecl;

Var
  alEffectsAvaliable:Boolean = False;

Procedure LoadOpenAL;
Procedure InitOpenAL;
Procedure FreeOpenAL;

Var
  OpenALHandle:TLibHandle=0;

Implementation
Uses TERRA_Log, TERRA_ALstub;

Function alGetProcedure(Proc:PAnsiChar):Pointer;
Begin
  {$IFDEF DISABLE_OPENAL}
  Result := Nil;
  {$ELSE}
  //Log(logDebug, 'AL','Testing proc: '+Proc);

  If (Assigned(alGetProcAddress)) Then
  Begin
    Result := alGetProcAddress(Proc);
    //Log(logDebug, 'AL','Got '+HexStr(Cardinal(Proc)));

    If Assigned(Result) Then
      Exit;
  End;

  Result := GetProcAddress(OpenALHandle, Proc);
  If Assigned(Result) Then
    Exit;

  {$ENDIF}
  Log(logWarning,'AL',Proc+' not avaliable.');
End;

Procedure InitOpenAL;
Begin
  If OpenALHandle=0 Then
    Exit;

  alEnable := alGetProcedure('alEnable');
  alDisable := alGetProcedure('alDisable');
  alIsEnabled := alGetProcedure('alIsEnabled');
  alGetBooleanv := alGetProcedure('alGetBooleanv');
  alGetIntegerv := alGetProcedure('alGetIntegerv');
  alGetFloatv := alGetProcedure('alGetFloatv');
  alGetDoublev := alGetProcedure('alGetDoublev');
  alGetString := alGetProcedure('alGetString');
  alGetBoolean := alGetProcedure('alGetBoolean');
  alGetInteger := alGetProcedure('alGetInteger');
  alGetFloat := alGetProcedure('alGetFloat');
  alGetDouble := alGetProcedure('alGetDouble');
  alGetError := alGetProcedure('alGetError');
  alIsExtensionPresent := alGetProcedure('alIsExtensionPresent');
  alGetEnumValue := alGetProcedure('alGetEnumValue');
  alListeneri := alGetProcedure('alListeneri');
  alListenerf := alGetProcedure('alListenerf');
  alListener3f := alGetProcedure('alListener3f');
  alListenerfv := alGetProcedure('alListenerfv');
  alGetListeneriv := alGetProcedure('alGetListeneriv');
  alGetListenerfv := alGetProcedure('alGetListenerfv');
  alGenSources := alGetProcedure('alGenSources');
  alDeleteSources := alGetProcedure('alDeleteSources');
  alIsSource := alGetProcedure('alIsSource');
  alSourcei := alGetProcedure('alSourcei');
  alSource3i := alGetProcedure('alSource3i');;
  alSourcef := alGetProcedure('alSourcef');
  alSource3f := alGetProcedure('alSource3f');
  alSourcefv := alGetProcedure('alSourcefv');
  alGetSourcei := alGetProcedure('alGetSourcei');
  alGetSourcef := alGetProcedure('alGetSourcef');
  alGetSource3f := alGetProcedure('alGetSource3f');
  alGetSourcefv := alGetProcedure('alGetSourcefv');
  alSourcePlay := alGetProcedure('alSourcePlay');
  alSourcePause :=alGetProcedure('alSourcePause');
  alSourceStop := alGetProcedure('alSourceStop');
  alSourceRewind := alGetProcedure('alSourceRewind');
  alSourcePlayv := alGetProcedure('alSourcePlayv');
  alSourceStopv := alGetProcedure('alSourceStopv');
  alSourceRewindv := alGetProcedure('alSourceRewindv');
  alSourcePausev := alGetProcedure('alSourcePausev');
  alGenBuffers := alGetProcedure('alGenBuffers');
  alDeleteBuffers := alGetProcedure('alDeleteBuffers');
  alIsBuffer := alGetProcedure('alIsBuffer');
  alBufferData := alGetProcedure('alBufferData');
  alGetBufferi := alGetProcedure('alGetBufferi');
  alGetBufferf := alGetProcedure('alGetBufferf');
  alSourceQueueBuffers := alGetProcedure('alSourceQueueBuffers');
  alSourceUnqueueBuffers := alGetProcedure('alSourceUnqueueBuffers');
  Assert(Assigned(alSourceUnqueueBuffers));
  alDistanceModel := alGetProcedure('alDistanceModel');
  alDopplerFactor := alGetProcedure('alDopplerFactor');
  alDopplerVelocity := alGetProcedure('alDopplerVelocity');

  alGenEffects := alGetProcedure('alGenEffects');
  If Assigned(alGenEffects) Then
  Begin
    alDeleteEffects := alGetProcedure('alDeleteEffects');
    alIsEffect := alGetProcedure('alIsEffect');
    alEffecti := alGetProcedure('alEffecti');
    alEffectiv := alGetProcedure('alEffectiv');
    alEffectf := alGetProcedure('alEffectf');
    alEffectfv := alGetProcedure('alEffectfv');
    alGetEffecti := alGetProcedure('alGetEffecti');
    alGetEffectiv := alGetProcedure('alGetEffectiv');
    alGetEffectf := alGetProcedure('alGetEffectf');
    alGetEffectfv := alGetProcedure('alGetEffectfv');

    alGenAuxiliaryEffectSlots := alGetProcedure('alGenAuxiliaryEffectSlots');
    alDeleteAuxiliaryEffectSlots := alGetProcedure('alDeleteAuxiliaryEffectSlots');
    alIsAuxiliaryEffectSlot := alGetProcedure('alIsAuxiliaryEffectSlot');
    alAuxiliaryEffectSloti := alGetProcedure('alAuxiliaryEffectSloti');
    alAuxiliaryEffectSlotiv := alGetProcedure('alAuxiliaryEffectSlotiv');
    alAuxiliaryEffectSlotf := alGetProcedure('alAuxiliaryEffectSlotf');
    alAuxiliaryEffectSlotfv := alGetProcedure('alAuxiliaryEffectSlotfv');
    alGetAuxiliaryEffectSloti := alGetProcedure('alGetAuxiliaryEffectSloti');
    alGetAuxiliaryEffectSlotiv := alGetProcedure('alGetAuxiliaryEffectSlotiv');
    alGetAuxiliaryEffectSlotf := alGetProcedure('alGetAuxiliaryEffectSlotf');
    alGetAuxiliaryEffectSlotfv := alGetProcedure('alGetAuxiliaryEffectSlotfv');

    alEffectsAvaliable := True;
  End Else
    alEffectsAvaliable := False;

  // capture extensions
  If alIsExtensionPresent('AL_EXT_capture') Then
  Begin
    alcCaptureOpenDevice:=alGetProcedure('alcCaptureOpenDevice');
    alcCaptureCloseDevice:=alGetProcedure('alcCaptureCloseDevice');
    alcCaptureStart:=alGetProcedure('alcCaptureStart');
    alcCaptureStop:=alGetProcedure('alcCaptureStop');
    alcCaptureSamples:=alGetProcedure('alcCaptureSamples');
  End Else
    Log(logWarning,'AL', 'Sound capture not avaliable.');
End;

Procedure LoadOpenAL;
Begin
  If OpenALHandle<>0 Then
    Exit;

  {$IFDEF DISABLE_OPENAL}
  Log(logWarning,'AL','OpenAL library not avaliable.');
  LoadALStubs;
  {$ELSE}

  //  OpenALHandle := 0;
  {$IFDEF WINDOWS}
  OpenALHandle := LoadLibraryA(PAnsiChar(OpenALLibName));
  {$ELSE}
  OpenALHandle := LoadLibrary(PAnsiChar(OpenALLibName));
  {$ENDIF}

  If OpenALHandle=0 Then
  Begin
    Log(logWarning,'AL','OpenAL library not avaliable.');
    LoadALStubs;
    Exit;
  End;

  alGetProcAddress := GetProcAddress(OpenALHandle, 'alGetProcAddress');

  alcGetProcAddress := alGetProcedure('alcGetProcAddress');
  alcCreateContext := alGetProcedure('alcCreateContext');
  alcMakeContextCurrent := alGetProcedure('alcMakeContextCurrent');
  alcProcessContext := alGetProcedure('alcProcessContext');
  alcSuspendContext := alGetProcedure('alcSuspendContext');
  alcDestroyContext := alGetProcedure('alcDestroyContext');
  alcGetError := alGetProcedure('alcGetError');
  alcGetCurrentContext := alGetProcedure('alcGetCurrentContext');
  alcOpenDevice := alGetProcedure('alcOpenDevice');
  alcCloseDevice := alGetProcedure('alcCloseDevice');
  alcIsExtensionPresent := alGetProcedure('alcIsExtensionPresent');
  alcGetEnumValue := alGetProcedure('alcGetEnumValue');
  alcGetContextsDevice := alGetProcedure('alcGetContextsDevice');
  alcGetString := alGetProcedure('alcGetString');
  alcGetIntegerv := alGetProcedure('alcGetIntegerv');

  Log(logDebug,'AL','OpenAL initialized.');
  {$ENDIF}
End;

Procedure FreeOpenAL;
Begin
  {$IFNDEF DISABLE_OPENAL}
  If OpenALHandle<>0 Then
    FreeLibrary(OpenALHandle);

  {$ENDIF}
  OpenALHandle := 0;
End;

End.
