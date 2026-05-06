{
  pkgs,
  createCommand,
  ...
}:

createCommand {
  name = "ai-image-upscale";
  buildInputs = with pkgs; [ upscayl-ncnn ];
  command = # bash
    ''
      #!/usr/bin/env bash

      if [ "$#" -ne 2 ]; then
          echo "Usage: $0 <input_path> <output_path>" >&2
          exit 1
      fi

      INPUT_FILE="$1"
      OUTPUT_FILE="$2"

      MODEL_PATH="${pkgs.upscayl-ncnn}/share/models"

      if ! command -v upscayl-bin &> /dev/null; then
          echo "Error: upscayl-ncnn not found in PATH." >&2
          exit 1
      fi

      upscayl-bin -i "$INPUT_FILE" -o "$OUTPUT_FILE" -n real-esrgan-x4plus -m "$MODEL_PATH"

      RESULT=$?

      if [ $RESULT -eq 0 ]; then
          exit 0
      else
          echo "Error: Upscaling failed with exit code $RESULT" >&2
          exit $RESULT
      fi
    '';

}
