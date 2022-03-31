package libraw

import "core:mem"
import "core:c"

when ODIN_OS == .Windows {
    foreign import "libraw.lib"
}

LibRaw_progress :: enum i64 {
    LIBRAW_PROGRESS_START = 0,
    LIBRAW_PROGRESS_OPEN = 1,
    LIBRAW_PROGRESS_IDENTIFY = 1 << 1,
    LIBRAW_PROGRESS_SIZE_ADJUST = 1 << 2,
    LIBRAW_PROGRESS_LOAD_RAW = 1 << 3,
    LIBRAW_PROGRESS_RAW2_IMAGE = 1 << 4,
    LIBRAW_PROGRESS_REMOVE_ZEROES = 1 << 5,
    LIBRAW_PROGRESS_BAD_PIXELS = 1 << 6,
    LIBRAW_PROGRESS_DARK_FRAME = 1 << 7,
    LIBRAW_PROGRESS_FOVEON_INTERPOLATE = 1 << 8,
    LIBRAW_PROGRESS_SCALE_COLORS = 1 << 9,
    LIBRAW_PROGRESS_PRE_INTERPOLATE = 1 << 10,
    LIBRAW_PROGRESS_INTERPOLATE = 1 << 11,
    LIBRAW_PROGRESS_MIX_GREEN = 1 << 12,
    LIBRAW_PROGRESS_MEDIAN_FILTER = 1 << 13,
    LIBRAW_PROGRESS_HIGHLIGHTS = 1 << 14,
    LIBRAW_PROGRESS_FUJI_ROTATE = 1 << 15,
    LIBRAW_PROGRESS_FLIP = 1 << 16,
    LIBRAW_PROGRESS_APPLY_PROFILE = 1 << 17,
    LIBRAW_PROGRESS_CONVERT_RGB = 1 << 18,
    LIBRAW_PROGRESS_STRETCH = 1 << 19,
    /* reserved */
    LIBRAW_PROGRESS_STAGE20 = 1 << 20,
    LIBRAW_PROGRESS_STAGE21 = 1 << 21,
    LIBRAW_PROGRESS_STAGE22 = 1 << 22,
    LIBRAW_PROGRESS_STAGE23 = 1 << 23,
    LIBRAW_PROGRESS_STAGE24 = 1 << 24,
    LIBRAW_PROGRESS_STAGE25 = 1 << 25,
    LIBRAW_PROGRESS_STAGE26 = 1 << 26,
    LIBRAW_PROGRESS_STAGE27 = 1 << 27,

    LIBRAW_PROGRESS_THUMB_LOAD = 1 << 28,
    LIBRAW_PROGRESS_TRESERVED1 = 1 << 29,
    LIBRAW_PROGRESS_TRESERVED2 = 1 << 30,
    LIBRAW_PROGRESS_TRESERVED3 = 1 << 31,
};

LIBRAW_PROGRESS_THUMB_MASK :: 0x0fffffff;

LibRaw_thumbnail_formats :: enum i32 {
    LIBRAW_THUMBNAIL_UNKNOWN = 0,
    LIBRAW_THUMBNAIL_JPEG = 1,
    LIBRAW_THUMBNAIL_BITMAP = 2,
    LIBRAW_THUMBNAIL_BITMAP16 = 3,
    LIBRAW_THUMBNAIL_LAYER = 4,
    LIBRAW_THUMBNAIL_ROLLEI = 5,
};

LibRaw_image_formats :: enum i32
{
  LIBRAW_IMAGE_JPEG = 1,
  LIBRAW_IMAGE_BITMAP = 2,
};

memory_callback :: proc "contextless" (data: rawptr, file: cstring, whereV: cstring);
exif_parser_callback :: proc "contextless" (ccontext: rawptr, tag, type, len: c.int, ord: c.uint, ifp: rawptr);
data_callback :: proc "contextless" (data: rawptr, file: cstring, offset: c.int);
progress_callback :: proc "contextless" (data: rawptr, stage: LibRaw_progress, iteration, expected: c.int) -> c.int;

libraw_data_t :: struct {
    image : ^[4]c.ushort,
    sizes: libraw_image_sizes_t,
    idata: libraw_iparams_t,
    lens: libraw_lensinfo_t,
    makernotes: libraw_makernotes_t,
    shootinginfo: libraw_shootinginfo_t,
    params: libraw_output_params_t,
    progress_flags: c.uint,
    process_warnings: c.uint,
    color: libraw_colordata_t,
    other: libraw_imgother_t,
    thumbnail: libraw_thumbnail_t,
    rawdata: libraw_rawdata_t,
    parent_class: rawptr,
};

libraw_image_sizes_t :: struct {
    raw_height: c.ushort, 
    raw_width: c.ushort, 
    height: c.ushort, 
    width: c.ushort, 
    top_margin: c.ushort, 
    left_margin: c.ushort,
    iheight: c.ushort, 
    iwidth: c.ushort,
    raw_pitch: c.uint,
    pixel_aspect: c.double,
    flip: c.int,
    mask: [8][4]c.int,
    raw_crop: libraw_raw_crop_t,
};

libraw_raw_crop_t :: struct {
    cleft: c.ushort,
    ctop: c.ushort,
    cwidth: c.ushort,
    cheight: c.ushort,
};

libraw_iparams_t :: struct {
    guard: [4]c.char,
    make: [64]c.char,
    model: [64]c.char,
    software: [64]c.char,
    raw_count: c.uint,
    dng_version: c.uint,
    is_foveon: c.uint,
    colors: c.int,
    filters: c.uint,
    xtrans: [6][6]c.char,
    xtrans_abs: [6][6]c.char,
    cdesc: [5]c.char,
    xmplen: c.uint,
    xmpdata: cstring,
};

libraw_lensinfo_t :: struct {
    MinFocal: c.float, 
    MaxFocal: c.float, 
    MaxAp4MinFocal: c.float, 
    MaxAp4MaxFocal: c.float, 
    EXIF_MaxAp: c.float,
    LensMake: [128]c.char, 
    Lens: [128]c.char, 
    LensSerial: [128]c.char, 
    InternalLensSerial: [128]c.char,
    FocalLengthIn35mmFormat: c.ushort,
    nikon: libraw_nikonlens_t,
    dng: libraw_dnglens_t,
    makernotes: libraw_makernotes_lens_t,
};

libraw_nikonlens_t :: struct {
    NikonEffectiveMaxAp: c.float,
    NikonLensIDNumber: c.uchar, 
    NikonLensFStops: c.uchar, 
    NikonMCUVersion: c.uchar, 
    NikonLensType: c.uchar,
};

libraw_dnglens_t :: struct {
    MinFocal: c.float, 
    MaxFocal: c.float, 
    MaxAp4MinFocal: c.float, 
    MaxAp4MaxFocal: c.float,
};

libraw_makernotes_lens_t :: struct {
    LensID: c.ulonglong,
    Lens: [128]c.char,
    LensFormat: c.ushort, /* to characterize the image circle the lens covers */
    LensMount: c.ushort,  /* 'male', lens itself */
    CamID: c.ulonglong,
    CameraFormat: c.ushort, /* some of the sensor formats */
    CameraMount: c.ushort,  /* 'female', body throat */
    body: [64]c.char,
    FocalType: c.short, /* -1/0 is unknown; 1 is fixed focal; 2 is zoom */
    LensFeatures_pre: [16]c.char, 
    LensFeatures_suf: [16]c.char,
    MinFocal: c.float, 
    MaxFocal: c.float,
    MaxAp4MinFocal: c.float, 
    MaxAp4MaxFocal: c.float, 
    MinAp4MinFocal: c.float, 
    MinAp4MaxFocal: c.float,
    MaxAp: c.float, 
    MinAp: c.float,
    CurFocal: c.float, 
    CurAp: c.float,
    MaxAp4CurFocal: c.float, 
    MinAp4CurFocal: c.float,
    MinFocusDistance: c.float,
    FocusRangeIndex: c.float,
    LensFStops: c.float,
    TeleconverterID: c.ulonglong,
    Teleconverter: [128]c.char,
    AdapterID: c.ulonglong,
    Adapter: [128]c.char,
    AttachmentID: c.ulonglong,
    Attachment: [128]c.char,
    CanonFocalUnits: c.ushort,
    FocalLengthIn35mmFormat: c.float,
};

libraw_makernotes_t :: struct {
    canon: libraw_canon_makernotes_t,
    nikon: libraw_nikon_makernotes_t,
    hasselblad: libraw_hasselblad_makernotes_t,
    fuji: libraw_fuji_info_t,
    olympus: libraw_olympus_makernotes_t,
    sony: libraw_sony_info_t,
    kodak: libraw_kodak_makernotes_t,
    panasonic: libraw_panasonic_makernotes_t,
    pentax: libraw_pentax_makernotes_t,
};

libraw_canon_makernotes_t :: struct {
    CanonColorDataVer: c.int,
    CanonColorDataSubVer: c.int,
    SpecularWhiteLevel: c.int,
    NormalWhiteLevel: c.int,
    ChannelBlackLevel: [4]c.int,
    AverageBlackLevel: c.int,
    /* multishot */
    multishot: [4]c.uint,
    /* metering */
    MeteringMode: c.ushort,
    SpotMeteringMode: c.short,
    FlashMeteringMode: c.uchar,
    FlashExposureLock: c.short,
    ExposureMode: c.short,
    AESetting: c.short,
    HighlightTonePriority: c.uchar,
    /* stabilization */
    ImageStabilization: c.short,
    /* focus */
    FocusMode: c.short,
    AFPoint: c.short,
    FocusContinuous: c.short,
    AFPointsInFocus30D: c.short,
    AFPointsInFocus1D: [8]c.uchar,
    AFPointsInFocus5D: c.ushort, /* bytes in reverse*/
                              /* AFInfo */
    AFAreaMode: c.ushort,
    NumAFPoints: c.ushort,
    ValidAFPoints: c.ushort,
    AFImageWidth: c.ushort,
    AFImageHeight: c.ushort,
    AFAreaWidths: [61]c.short,    /* cycle to NumAFPoints */
    AFAreaHeights: [61]c.short,    /* --''--               */
    AFAreaXPositions: [61]c.short, /* --''--               */
    AFAreaYPositions: [61]c.short, /* --''--               */
    AFPointsInFocus: [4]c.short,  /* cycle to floor((NumAFPoints+15)/16) */
    AFPointsSelected: [4]c.short,  /* --''--               */
    PrimaryAFPoint: c.ushort,
    /* flash */
    FlashMode: c.short,
    FlashActivity: c.short,
    FlashBits: c.short,
    ManualFlashOutput: c.short,
    FlashOutput: c.short,
    FlashGuideNumber: c.short,
    /* drive */
    ContinuousDrive: c.short,
    /* sensor */
    SensorWidth: c.short,
    SensorHeight: c.short,
    SensorLeftBorder: c.short,
    SensorTopBorder: c.short,
    SensorRightBorder: c.short,
    SensorBottomBorder: c.short,
    BlackMaskLeftBorder: c.short,
    BlackMaskTopBorder: c.short,
    BlackMaskRightBorder: c.short,
    BlackMaskBottomBorder: c.short,
    AFMicroAdjMode: c.int,
    AFMicroAdjValue: c.float,
};

libraw_nikon_makernotes_t :: struct {
    ExposureBracketValue: c.double,
    ActiveDLighting: c.ushort,
    ShootingMode: c.ushort,
    /* stabilization */
    ImageStabilization: [7]c.uchar,
    VibrationReduction: c.uchar,
    VRMode: c.uchar,
    /* focus */
    FocusMode: [7]c.char,
    AFPoint: c.uchar,
    AFPointsInFocus: c.ushort,
    ContrastDetectAF: c.uchar,
    AFAreaMode: c.uchar,
    PhaseDetectAF: c.uchar,
    PrimaryAFPoint: c.uchar,
    AFPointsUsed: [29]c.uchar,
    AFImageWidth: c.ushort,
    AFImageHeight: c.ushort,
    AFAreaXPposition: c.ushort,
    AFAreaYPosition: c.ushort,
    AFAreaWidth: c.ushort,
    AFAreaHeight: c.ushort,
    ContrastDetectAFInFocus: c.uchar,
    /* flash */
    FlashSetting: [13]c.char,
    FlashType: [20]c.char,
    FlashExposureCompensation: [4]c.uchar,
    ExternalFlashExposureComp: [4]c.uchar,
    FlashExposureBracketValue: [4]c.uchar,
    FlashMode: c.uchar,
    FlashExposureCompensation2: c.schar,
    FlashExposureCompensation3: c.schar,
    FlashExposureCompensation4: c.schar,
    FlashSource: c.uchar,
    FlashFirmware: [2]c.uchar,
    ExternalFlashFlags: c.uchar,
    FlashControlCommanderMode: c.uchar,
    FlashOutputAndCompensation: c.uchar,
    FlashFocalLength: c.uchar,
    FlashGNDistance: c.uchar,
    FlashGroupControlMode: [4]c.uchar,
    FlashGroupOutputAndCompensation: [4]c.uchar,
    FlashColorFilter: c.uchar,
    NEFCompression: c.ushort,
    ExposureMode: c.int,
    nMEshots: c.int,
    MEgainOn: c.int,
    ME_WB: [4]c.double,
    AFFineTune: c.uchar,
    AFFineTuneIndex: c.uchar,
    AFFineTuneAdj: c.schar,
};

libraw_hasselblad_makernotes_t :: struct {
    BaseISO: c.int,
    Gain: c.double,
};

libraw_fuji_info_t :: struct {
    FujiExpoMidPointShift: c.float,
    FujiDynamicRange: c.ushort,
    FujiFilmMode: c.ushort,
    FujiDynamicRangeSetting: c.ushort,
    FujiDevelopmentDynamicRange: c.ushort,
    FujiAutoDynamicRange: c.ushort,
    FocusMode: c.ushort,
    AFMode: c.ushort,
    FocusPixel: [2]c.ushort,
    ImageStabilization: [3]c.ushort,
    FlashMode: c.ushort,
    WB_Preset: c.ushort,
    ShutterType: c.ushort,
    ExrMode: c.ushort,
    Macro: c.ushort,
    Rating: c.uint,
    FrameRate: c.ushort,
    FrameWidth: c.ushort,
    FrameHeight: c.ushort,
};

libraw_olympus_makernotes_t :: struct {
    OlympusCropID: c.int,
    OlympusFrame: [4]c.ushort, /* upper left XY, lower right XY */
    OlympusSensorCalibration: [2]c.int,
    FocusMode: [2]c.ushort,
    AutoFocus: c.ushort,
    AFPoint: c.ushort,
    AFAreas: [64]c.uint,
    AFPointSelected: [5]c.double,
    AFResult: c.ushort,
    ImageStabilization: c.uint,
    ColorSpace: c.ushort,
    AFFineTune: c.uchar,
    AFFineTuneAdj: [3]c.short,
};

libraw_sony_info_t :: struct { 
    SonyCameraType: c.ushort,
    Sony0x9400_version: c.uchar, /* 0 if not found/deciphered, 0xa, 0xb, 0xc following exiftool convention */
    Sony0x9400_ReleaseMode2: c.uchar,
    Sony0x9400_SequenceImageNumber: c.uint,
    Sony0x9400_SequenceLength1: c.uchar,
    Sony0x9400_SequenceFileNumber: c.uint,
    Sony0x9400_SequenceLength2: c.uchar,
    raw_crop: libraw_raw_crop_t,
    AFMicroAdjValue: c.schar,
    AFMicroAdjOn: c.schar,
    AFMicroAdjRegisteredLenses: c.uchar,
    group2010: c.ushort,
    real_iso_offset: c.ushort,
    firmware: c.float,
    ImageCount3_offset: c.ushort,
    ImageCount3: c.uint,
    ElectronicFrontCurtainShutter: c.uint,
    MeteringMode2: c.ushort,
    SonyDateTime: [20]c.char,
    TimeStamp: [6]c.uchar,
    ShotNumberSincePowerUp: c.uint,
};

libraw_kodak_makernotes_t :: struct {
    BlackLevelTop: c.ushort,
    BlackLevelBottom: c.ushort,
    offset_left: c.short, 
    offset_top: c.short, /* KDC files, negative values or zeros */
    clipBlack: c.ushort, 
    clipWhite: c.ushort,   /* valid for P712, P850, P880 */
    romm_camDaylight: [3][3]c.float,
    romm_camTungsten: [3][3]c.float,
    romm_camFluorescent: [3][3]c.float,
    romm_camFlash: [3][3]c.float,
    romm_camCustom: [3][3]c.float,
    romm_camAuto: [3][3]c.float,
};

libraw_panasonic_makernotes_t :: struct {
    /* Compression:
    34826 (Panasonic RAW 2): LEICA DIGILUX 2;
    34828 (Panasonic RAW 3): LEICA D-LUX 3; LEICA V-LUX 1; Panasonic DMC-LX1; Panasonic DMC-LX2; Panasonic DMC-FZ30; Panasonic DMC-FZ50;
    34830 (not in exiftool): LEICA DIGILUX 3; Panasonic DMC-L1;
    34316 (Panasonic RAW 1): others (LEICA, Panasonic, YUNEEC);
    */
    Compression: c.ushort,
    BlackLevelDim: c.ushort,
    BlackLevel: [8]c.float,
};

libraw_pentax_makernotes_t :: struct {
    FocusMode: c.ushort,
    AFPointSelected: c.ushort,
    AFPointsInFocus: c.uint,
    FocusPosition: c.ushort,
    DriveMode: [4]c.uchar,
    AFAdjustment: c.short,
    /*    uchar AFPointMode;     */
    /*    uchar SRResult;        */
    /*    uchar ShakeReduction;  */
};



libraw_shootinginfo_t :: struct {
    DriveMode: c.short,
    FocusMode: c.short,
    MeteringMode: c.short,
    AFPoint: c.short,
    ExposureMode: c.short,
    ImageStabilization: c.short,
    BodySerial: [64]c.char,
    InternalBodySerial: [64]c.char, /* this may be PCB or sensor serial, depends on make/model*/
};

libraw_output_params_t :: struct {
    greybox: [4]c.uint,   /* -A  x1 y1 x2 y2 */
    cropbox: [4]c.uint,   /* -B x1 y1 x2 y2 */
    aber: [4]c.double,        /* -C */
    gamm: [6]c.double,        /* -g */
    user_mul: [4]c.float,     /* -r mul0 mul1 mul2 mul3 */
    shot_select: c.uint,  /* -s */
    bright: c.float,          /* -b */
    threshold: c.float,       /*  -n */
    half_size: c.int,         /* -h */
    four_color_rgb: c.int,    /* -f */
    highlight: c.int,        /* -H */
    use_auto_wb: c.int,       /* -a */
    use_camera_wb: c.int,    /* -w */
    use_camera_matrix: c.int, /* +M/-M */
    output_color: c.int,      /* -o */
    output_profile: cstring,  /* -o */
    camera_profile: cstring,  /* -p */
    bad_pixels: cstring,      /* -P */
    dark_frame: cstring,      /* -K */
    output_bps: c.int,        /* -4 */
    output_tiff: c.int,      /* -T */
    user_flip: c.int,         /* -t */
    user_qual: c.int,         /* -q */
    user_black: c.int,        /* -k */
    user_cblack: [4]c.int,
    user_sat: c.int, /* -S */

    med_passes: c.int, /* -m */
    auto_bright_thr: c.float,
    adjust_maximum_thr: c.float,
    no_auto_bright: c.int,  /* -W */
    use_fuji_rotate: c.int, /* -j */
    green_matching: c.int,
    /* DCB parameters */
    dcb_iterations: c.int,
    dcb_enhance_fl: c.int,
    fbdd_noiserd: c.int,
    exp_correc: c.int,
    exp_shift: c.float,
    exp_preser: c.float,
    /* Raw speed */
    use_rawspeed: c.int,
    /* DNG SDK */
    use_dngsdk: c.int,
    /* Disable Auto-scale */
    no_auto_scale: c.int,
    /* Disable intepolation */
    no_interpolation: c.int,
    /*  int x3f_flags; */
    /* Sony ARW2 digging mode */
    /* int sony_arw2_options; */
    raw_processing_options: c.uint,
    sony_arw2_posterization_thr: c.int,
    /* Nikon Coolscan */
    coolscan_nef_gamma: c.float,
    p4shot_order: [5]c.char,
    /* Custom camera list */
    custom_camera_strings: ^cstring,
};

libraw_colordata_t :: struct {
    curve: [0x10000]c.ushort,
    cblack: [4102]c.uint,
    black: c.uint,
    data_maximum: c.uint,
    maximum: c.uint,
    linear_max: [4]c.long,
    fmaximum: c.float,
    fnorm: c.float,
    white: [8][8]c.ushort,
    cam_mul: [4]c.float,
    pre_mul: [4]c.float,
    cmatrix: [3][4]c.float,
    ccm: [3][4]c.float,
    rgb_cam: [3][4]c.float,
    cam_xyz: [4][3]c.float,
    phase_one_data: ph1_t, // ???????
    flash_used: c.float,
    canon_ev: c.float,
    model2: [64]c.char,
    UniqueCameraModel: [64]c.char,
    LocalizedCameraModel: [64]c.char,
    profile: rawptr,
    profile_length: c.uint,
    black_stat: [8]c.uint,
    dng_color: [2]libraw_dng_color_t,
    dng_levels: libraw_dng_levels_t,
    baseline_exposure: c.float,
    WB_Coeffs: [256][4]c.int,    /* R, G1, B, G2 coeffs */
    WBCT_Coeffs: [64][5]c.float, /* CCT, than R, G1, B, G2 coeffs */
    P1_color: [2]libraw_P1_color_t,
};

ph1_t :: struct {
    format: c.int, 
    key_off: c.int, 
    tag_21a: c.int,
    t_black: c.int, 
    split_col: c.int, 
    black_col: c.int, 
    split_row: c.int, 
    black_row: c.int,
    tag_210: c.float,
};

libraw_dng_color_t :: struct {
    parsedfields: c.uint,
    illuminant: c.ushort,
    calibration: [4][4]c.float,
    colormatrix: [4][3]c.float,
    forwardmatrix: [3][4]c.float,
};

libraw_dng_levels_t :: struct {
    parsedfields: c.uint,
    dng_cblack: [4102]c.uint,
    dng_black: c.uint,
    dng_whitelevel: [4]c.uint,
    default_crop: [4]c.uint, /* Origin and size */
    preview_colorspace: c.uint,
    analogbalance: [4]c.float,
};

libraw_P1_color_t :: struct {
    romm_cam: [9]c.float,
};

libraw_imgother_t :: struct {
    iso_speed: c.float,
    shutter: c.float,
    aperture: c.float,
    focal_len: c.float,
    timestamp: c.long, //TODO: time_t
    shot_order: c.uint,
    gpsdata: [32]c.uint,
    parsed_gps: libraw_gps_info_t,
    desc: [512]c.char, 
    artist: [64]c.char,
    FlashEC: c.float,
    FlashGN: c.float,
    CameraTemperature: c.float,
    SensorTemperature: c.float,
    SensorTemperature2: c.float,
    LensTemperature: c.float,
    AmbientTemperature: c.float,
    BatteryTemperature: c.float,
    exifAmbientTemperature: c.float,
    exifHumidity: c.float,
    exifPressure: c.float,
    exifWaterDepth: c.float,
    exifAcceleration: c.float,
    exifCameraElevationAngle: c.float,
    real_ISO: c.float,
};

libraw_gps_info_t :: struct {
    latitude: [3]c.float,     /* Deg,min,sec */
    longtitude: [3]c.float,   /* Deg,min,sec */
    gpstimestamp: [3]c.float, /* Deg,min,sec */
    altitude: c.float,
    altref: c.char, 
    latref: c.char, 
    longref: c.char, 
    gpsstatus: c.char,
    gpsparsed: c.char,
};

libraw_thumbnail_t :: struct {
    tformat: LibRaw_thumbnail_formats,
    twidth: c.ushort, 
    theight: c.ushort,
    tlength: c.uint,
    tcolors: c.int,
    thumb: cstring,
};

libraw_rawdata_t :: struct {
    raw_alloc: rawptr,
    raw_image: ^c.ushort,
    color4_image: ^[4]c.ushort,
    color3_image: ^[3]c.ushort,
    float_image: ^c.float,
    float3_image: ^[3]c.float,
    float4_image: ^[4]c.float,
    ph1_cblack: ^[2]c.short,
    ph1_rblack: ^[2]c.short,
    iparams: libraw_iparams_t,
    sizes: libraw_image_sizes_t,
    ioparams: libraw_internal_output_params_t,
    color: libraw_colordata_t,
};

libraw_internal_output_params_t :: struct {
    mix_green: c.uint,
    raw_color: c.uint,
    zero_is_bad: c.uint,
    shrink: c.ushort,
    fuji_width: c.ushort,
};

libraw_decoder_info_t :: struct {
    decoder_name: cstring,
    decoder_flags: c.uint,
};

libraw_processed_image_t :: struct {
    type: LibRaw_image_formats,
    height, width, colors, bits: c.ushort,
    data_size: c.uint,
    data: [1]c.uchar,
};

@(default_calling_convention="c")
foreign libraw {

    @(link_name="libraw_init")
    init :: proc(flags: u16) -> ^libraw_data_t ---;

    @(link_name="libraw_close")
    close :: proc(libraw_data: ^libraw_data_t) ---;

    @(link_name="libraw_version")
    version :: proc() -> cstring ---;

    @(link_name="libraw_versionNumber")
    version_number :: proc() -> c.int ---;

    @(link_name="libraw_cameraCount")
    camera_count :: proc() -> c.int ---;

    @(link_name="libraw_cameraList")
    libraw_cameraList :: proc() -> ^cstring ---;

    @(link_name="libraw_strerror")
    strerror :: proc(c.int) -> cstring ---;

    @(link_name="libraw_strprogress")
    strprogress :: proc(LibRaw_progress) -> cstring ---;

    @(link_name="libraw_capabilities")
    capabilities :: proc() -> c.uint ---;

    @(link_name="libraw_open_file")
    open_file :: proc(libraw_data: ^libraw_data_t, filename: cstring) -> c.int ---;

    @(link_name="libraw_open_file_ex")
    open_file_ex :: proc(libraw_data: ^libraw_data_t, filename: cstring, max_buff_sz: c.longlong) -> c.int ---;
    
    @(link_name="libraw_open_wfile")
    open_wfile :: proc(libraw_data: ^libraw_data_t, filename: c.wchar_t) -> c.int ---;

    @(link_name="libraw_open_wfile_ex")
    open_wfile_ex :: proc(libraw_data: ^libraw_data_t, filename: c.wchar_t, max_buff_sz: c.longlong) -> c.int ---;
    
    @(link_name="libraw_open_buffer")
    open_buffer :: proc(libraw_data: ^libraw_data_t, buffer: rawptr, size: c.ulonglong) -> c.int ---;

    @(link_name="libraw_unpack")
    unpack :: proc(libraw_data: ^libraw_data_t) -> c.int ---;

    @(link_name="libraw_unpack_thumb")
    unpack_thumb :: proc(libraw_data: ^libraw_data_t) -> c.int ---;

    @(link_name="libraw_recycle_datastream")
    recycle_datastream :: proc(libraw_data: ^libraw_data_t) ---;
    
    @(link_name="libraw_recycle")
    recycle :: proc(libraw_data: ^libraw_data_t) ---;
    
    @(link_name="libraw_subtract_black")
    subtract_black :: proc(libraw_data: ^libraw_data_t) ---;
    
    @(link_name="libraw_raw2image")
    raw2image :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_free_image")
    free_image :: proc(libraw_data: ^libraw_data_t) ---;
    
    @(link_name="libraw_set_memerror_handler")
    set_memerror_handler :: proc(libraw_data: ^libraw_data_t, callback: memory_callback, datap: rawptr) ---;

    @(link_name="libraw_set_exifparser_handler")
    set_exifparser_handler :: proc(libraw_data: ^libraw_data_t, callback: exif_parser_callback, datap: rawptr) ---;

    @(link_name="libraw_set_dataerror_handler")
    set_dataerror_handler :: proc(libraw_data: ^libraw_data_t, callback: data_callback, datap: rawptr) ---;

    @(link_name="libraw_set_progress_handler")
    set_progress_handler :: proc(libraw_data: ^libraw_data_t, callback: progress_callback, datap: rawptr) ---;

    @(link_name="libraw_unpack_function_name")
    unpack_function_name :: proc(libraw_data: ^libraw_data_t) -> cstring ---;

    @(link_name="libraw_get_decoder_info")
    get_decoder_info :: proc(libraw_data: ^libraw_data_t, decoder_info: ^libraw_decoder_info_t) -> c.int ---;

    @(link_name="libraw_COLOR")
    color :: proc(libraw_data: ^libraw_data_t, row, col: c.int) -> c.int ---;

    @(link_name="libraw_adjust_sizes_info_only")
    adjust_sizes_info_only :: proc(libraw_data: ^libraw_data_t) -> cstring ---;

    @(link_name="libraw_dcraw_ppm_tiff_writer")
    dcraw_ppm_tiff_writer :: proc(libraw_data: ^libraw_data_t, filename: cstring) -> c.int ---;
    
    @(link_name="libraw_dcraw_thumb_writer")
    dcraw_thumb_writer :: proc(libraw_data: ^libraw_data_t, filename: cstring) -> c.int ---;

    @(link_name="libraw_dcraw_process")
    dcraw_process :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_dcraw_make_mem_image")
    dcraw_make_mem_image :: proc(libraw_data: ^libraw_data_t, error_code: ^c.int) -> ^libraw_processed_image_t ---;

    @(link_name="libraw_dcraw_make_mem_thumb")
    dcraw_make_mem_thumb :: proc(libraw_data: ^libraw_data_t, error_code: ^c.int) -> ^libraw_processed_image_t ---;

    @(link_name="libraw_dcraw_clear_mem")
    dcraw_clear_mem :: proc(libraw_data: ^libraw_data_t) ---;

    @(link_name="libraw_set_demosaic")
    set_demosaic :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;
    
    @(link_name="libraw_set_output_color")
    set_output_color :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;

    @(link_name="libraw_set_user_mul")
    set_user_mul :: proc(libraw_data: ^libraw_data_t, index: c.int, value: c.float) ---;

    @(link_name="libraw_set_output_bps")
    set_output_bps :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;
    
    @(link_name="libraw_set_gamma")
    set_gamma :: proc(libraw_data: ^libraw_data_t, index: c.int, value: c.float) ---;

    @(link_name="libraw_set_no_auto_bright")
    set_no_auto_bright :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;

    @(link_name="libraw_set_bright")
    set_bright :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;

    @(link_name="libraw_set_highlight")
    set_highlight :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;

    @(link_name="libraw_set_fbdd_noiserd")
    set_fbdd_noiserd :: proc(libraw_data: ^libraw_data_t, value: c.int) ---;
    
    @(link_name="libraw_get_raw_height")
    get_raw_height :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_get_raw_width")
    get_raw_width :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_get_iheight")
    get_iheight :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_get_iwidth")
    get_iwidth :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_get_cam_mul")
    get_cam_mul :: proc(libraw_data: ^libraw_data_t, index: c.int) -> c.float ---;
    
    @(link_name="libraw_get_pre_mul")
    get_pre_mul :: proc(libraw_data: ^libraw_data_t, index: c.int) -> c.float ---;
    
    @(link_name="libraw_get_rgb_cam")
    get_rgb_cam :: proc(libraw_data: ^libraw_data_t, index1: c.int, index2: c.int) -> c.float ---;
    
    @(link_name="libraw_get_color_maximum")
    get_color_maximum :: proc(libraw_data: ^libraw_data_t) -> c.int ---;
    
    @(link_name="libraw_get_iparams")
    get_iparams :: proc(libraw_data: ^libraw_data_t) -> ^libraw_iparams_t ---;
    
    @(link_name="libraw_get_lensinfo")
    get_lensinfo :: proc(libraw_data: ^libraw_data_t) -> ^libraw_lensinfo_t ---;
    
    @(link_name="libraw_get_imgother")
    get_imgother :: proc(libraw_data: ^libraw_data_t) -> ^libraw_imgother_t ---;

}

camera_list :: proc() -> []cstring {
    librawList := libraw_cameraList();
    cameraCount := camera_count();
    cameraList := mem.slice_ptr(librawList, cast(int)cameraCount); 
    return cameraList;
}