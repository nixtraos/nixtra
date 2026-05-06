{
  pkgs,
  createCommand,
  ...
}:

let
  without-bg = pkgs.python3Packages.buildPythonPackage rec {
    pname = "withoutbg";
    version = "1.0.3";

    pyproject = true;

    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "sha256-TzGX6oxivfFG8RRq1ZQVMvcLTXTz0C2CzFtReXZCABs=";
    };

    nativeBuildInputs = with pkgs.python3Packages; [
      hatchling
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      pillow
      onnxruntime
      numpy
      requests
      click
      huggingface-hub
      tqdm
    ];

    doCheck = false;
  };

  script = # python
    ''
      import sys
      import os
      from withoutbg import WithoutBG


      def main():
          if len(sys.argv) != 3:
              print(f"Usage: {sys.argv[0]} <input> <output>", file=sys.stderr)
              sys.exit(1)

          input_path, output_path = sys.argv[1], sys.argv[2]

          if not os.path.exists(input_path):
              print(f"Error: {input_path} not found", file=sys.stderr)
              sys.exit(1)

          model = WithoutBG.opensource()
          result = model.remove_background(input_path)
          result.save(output_path)


      if __name__ == "__main__":
          main()
    '';

  derivation = pkgs.writers.writePython3Bin "ai-image-remove-background" {
    libraries = [
      without-bg
    ];
  } script;
in
createCommand {
  name = "ai-image-remove-background";
  buildInputs = [ ];
  command = "${derivation}/bin/ai-image-remove-background";
}
