"""Make runpod's S3 upload write into our bucket and key prefix, with real MIME types.

BUCKET_NAME and BUCKET_PREFIX come from the RunPod template at run time. The build fails
if upstream rp_upload changed, so a silent no-op patch never ships."""
import pathlib

import runpod.serverless.utils.rp_upload as module

path = pathlib.Path(module.__file__)
text = path.read_text()
required = [
    ('bucket = bucket_name if bucket_name else time.strftime("%m-%y")',
     'bucket = bucket_name or os.environ.get("BUCKET_NAME") or time.strftime("%m-%y")'),
    ('content_type = "image/" + file_extension.lstrip(".")',
     'import mimetypes; content_type = mimetypes.guess_type(image_location)[0] or "application/octet-stream"'),
]
# Both the upload and its presigned link must use the prefixed key.
keys = [
    ('Key=f"{job_id}/', 'Key=f"{os.environ.get(\'BUCKET_PREFIX\', \'\')}{job_id}/'),
    ('"Key": f"{job_id}/', '"Key": f"{os.environ.get(\'BUCKET_PREFIX\', \'\')}{job_id}/'),
]
for old, new in required:
    if old not in text:
        raise SystemExit(f"rp_upload changed upstream; review the patch: {old!r}")
    text = text.replace(old, new)
if not any(old in text for old, _ in keys):
    raise SystemExit("rp_upload changed upstream; no object key to prefix")
for old, new in keys:
    text = text.replace(old, new)
path.write_text(text)
print("rp_upload patched:", text.count("BUCKET_NAME"), "bucket,", text.count("BUCKET_PREFIX"), "prefix uses")
