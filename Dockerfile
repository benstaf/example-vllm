FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

CMD ["bash", "-lc", "echo BOOT_OK && sleep 3600"]

