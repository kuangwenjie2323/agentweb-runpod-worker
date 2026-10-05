# AgentWeb RunPod worker: runpod/worker-comfyui with a current ComfyUI baked in.
# The base ships ComfyUI 0.34.0, which lacks the MiniMax H3 nodes. Updating here, at build
# time, instead of in a start script saves that work on every cold start.
FROM runpod/worker-comfyui:5.10.0-base

ARG COMFYUI_REF=b0b743566f65daafc423b4fea8a2fbda94b3384a

# Update ComfyUI in place and install its requirements, keeping the shipped torch build.
RUN set -eux; cd /comfyui; \
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
        git fetch --depth 1 origin "$COMFYUI_REF"; git reset --hard FETCH_HEAD; \
    else \
        rm -rf /tmp/cu; git init -q /tmp/cu; \
        git -C /tmp/cu fetch --depth 1 https://github.com/comfyanonymous/ComfyUI "$COMFYUI_REF"; \
        git -C /tmp/cu checkout -q FETCH_HEAD; cp -a /tmp/cu/. /comfyui/; rm -rf /tmp/cu; \
    fi; \
    echo "$COMFYUI_REF" > /comfyui/.agentweb-ref; \
    uv pip freeze --python /opt/venv/bin/python | grep -E "^(torch|torchvision|torchaudio)==" > /tmp/pins.txt; \
    uv pip install --python /opt/venv/bin/python --no-cache -r /comfyui/requirements.txt -c /tmp/pins.txt; \
    rm -f /tmp/pins.txt; \
    /opt/venv/bin/python -c "import comfy_aimdo, comfy_kitchen"

# Uploads go to our R2 bucket (BUCKET_NAME, BUCKET_PREFIX) with real MIME types.
COPY patch_upload.py /tmp/patch_upload.py
RUN /opt/venv/bin/python /tmp/patch_upload.py && rm /tmp/patch_upload.py

COPY agentweb-start.sh /agentweb-start.sh
RUN chmod 755 /agentweb-start.sh
CMD ["/agentweb-start.sh"]
