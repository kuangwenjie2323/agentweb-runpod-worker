#!/usr/bin/env bash
# Point ComfyUI at the endpoint's host-cached Hugging Face model snapshot, then start the worker.
SNAP=$(ls -d /runpod-volume/huggingface-cache/hub/models--*/snapshots/*/ 2>/dev/null | head -n 1)
printf "agentweb:\n  base_path: %s\n  diffusion_models: diffusion_models\n  text_encoders: text_encoders\n  vae: vae\n  loras: loras\n" "$SNAP" > /comfyui/extra_model_paths.yaml
echo "agentweb-start: comfyui $(cat /comfyui/.agentweb-ref 2>/dev/null) models at $SNAP"
exec /start.sh
