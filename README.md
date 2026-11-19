# MIUI Camera for POCO F9 Ultra (songyuan)

Ported from [lolipuru/device_xiaomi_myron-miuicamera](https://github.com/lolipuru/device_xiaomi_myron-miuicamera)
(Redmi K90 Pro Max / POCO F8 Ultra). Both are sm8850 and both ship MIUI V816,
so the AIDL, shims and sepolicy transfer unchanged.

Inherited automatically by `lineage_songyuan.mk` once the blobs exist:

    device/xiaomi/songyuan-miuicamera/extract-files.py <stock dump>

## APK patches

`patches-client-name/` holds the patch applied to the current APK.
`patches-myron-reference/` keeps myron's originals for reference. The upstream
`patches/` directory is retained for reference; its 0004 gallery patch targets a
different R8 mapping and is not applied to this APK.

| patch | myron path | songyuan | state |
| :-- | :-- | :-- | :-- |
| 0001 mod_device is global | `smali_classes4/z7/c.smali` | `smali_classes2/Td/c.smali` | **ported** |
| 0002 obfuscated resources | `smali_classes4/x8/a.smali` | `smali_classes2/Se/a.smali` | **ported** |
| 0003 stub jcodec MP4 | `smali_classes6/vj/e.smali` | `smali_classes6/lr/e.smali` | not needed; runs clean here |
| 0004 NAL length prefix | `smali/vb/e.smali` | `smali_classes5/Ki/f.smali` | **ported** as our 0003 |
| 0005 icon revert | `res/mipmap-anydpi-v26/ets.xml` | n/a, cosmetic | skipped |
| cupid 0002-0004 third-party galleries | `smali/d/d/a/r4.smali` | `smali/I1/f1.smali`, `Camera.smali` | **ported** as our 0004 |

0002 needed one extra change: `ResourcesCompat` is R8-renamed to `W/f$a` here,
so the fallback calls that directly.

0001 remapped cleanly: `Td/c` keeps the same static field `m`, set from the same
`ro.product.mod_device` / `"_global"` `String.contains` check, at the same hunk
offset as myron's. Without it the app calls into HyperOS Security Center for its
permissions dialog.

## Verified working

Photo and 1080p HEVC video both capture cleanly with only 0001 and 0002:

- stills: 5.9 MB JPEG with EXIF, via the full MiAlgo pipeline
- video: well-formed mp42 container, `hvc1` video + audio track, muxer closes clean
- no provider crash, no jcodec/NAL/muxer errors in the recording log

4K and 8K need myron's 0004 (our 0003). On Android 15+ the app asks the HEVC
encoder for NAL length-prefixed output at those sizes. AOSP's MPEG4Writer then
finds no parameter sets ("Missing codec specific data") and drops the video
track, leaving an audio-only file.

The thumbnail is pinned to `com.miui.gallery`. Without it the app falls back to
a plain ACTION_VIEW, which asks for an app every time per MIME type. Our 0004
(myron's older cupid patches) sends `android.provider.action.REVIEW` instead,
so Google Photos opens in its camera review pager. The provider hunk of cupid
0002 is not ported.

Capture needs more than this tree: 28 camera blobs under `odm/etc/camera` and
`odm/lib/rfsa` were missing from the main device tree's `proprietary-files.txt`.
Without `xiaomi/quickviewsnapshot.json` in particular, `libmialgoengine` gets a
null pipeline and the camera provider segfaults in `PipelineInfo::operator=` on
every shutter press.

## Current OS4 extraction path

The extracted OS4 APK is installed from `product/priv-app/MiuiCamera/MiuiCamera.apk` and is currently a raw stock blob before fixups. `extract-files.py` applies only `patches-client-name/` (the Xiaomi client-name bridge). Upstream's `patches/0004-Support-third-party-galleries.patch` targets a different R8 mapping and is retained for reference but not applied to this OS4.0.7.0 APK. The historical patches targeting an earlier R8 mapping (`Td/c`, `Se/a`, `Ki/f`) are preserved under `patches-myron-reference/`.

The old `0001` global-device workaround is intentionally not re-applied: `ro.product.mod_device=songyuan` plus `SecurityCenterStub` already covers that permission-flow behavior. The APK-only camera bridge is separate: it fills `com.xiaomi.sessionparams.clientName` with `com.android.camera` on the session-parameter builders used by `n9/B0` and `pa/g0`. It deliberately does not invent a `MiStreamUsecase` value; the stock HAL metadata defines value `2` only for `VID_HDR`, so existing app-provided usecase values are left untouched.
