FROM woodrex/rocm612-torch24-gfx803

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y -f && \
    apt-get install -y --no-install-recommends \
    git \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

RUN python3 -m pip install --no-cache-dir -r requirements.txt

EXPOSE 8188

# Use --preview-lofi or --lowvram if using gfx803 (optional but recommended for older AMD cards)
CMD ["python3", "main.py", "--listen", "0.0.0.0"]
