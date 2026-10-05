# agentweb-runpod-worker

The RunPod serverless image behind AgentWeb's "RunPod GPU" video workflow (MiniMax H3 / FastH3).

It is `runpod/worker-comfyui:5.10.0-base` with:

- ComfyUI updated to a pinned commit (`COMFYUI_REF` in the Dockerfile), because the base
  ships ComfyUI 0.34.0, which lacks the MiniMax H3 and sparse-attention nodes;
- the runpod upload helper patched to write into the bucket and key prefix given by the
  template's `BUCKET_NAME` / `BUCKET_PREFIX`, with real MIME types;
- a start script that points ComfyUI at the endpoint's host-cached model snapshot.

Doing the update at build time instead of on every worker start shortens cold starts.
No credentials are part of the image; RunPod passes them as template environment variables.

GitHub Actions builds and pushes `ghcr.io/kuangwenjie2323/agentweb-runpod-worker` on every
push to `main` (tags `latest` and the commit SHA). To move ComfyUI forward, change
`COMFYUI_REF` and push.
