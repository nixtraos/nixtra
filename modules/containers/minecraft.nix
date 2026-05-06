{ config, pkgs, ... }:

{
  # Define the container
  containers.minecraftClient = {
    autoStart = true; # Automatically start the container
    config =
      { pkgs }:
      {
        # Installing necessary dependencies
        environment.systemPackages = with pkgs; [
          openjdk # Java runtime for Minecraft
          xorg.xauth # For graphical apps
          libGL # OpenGL support
          libX11 # X11 client libraries
          xorg.xserver # X server for GUI support
          prismlauncher # The Minecraft launcher
        ];

        # Create a user for the container (optional)
        users.users.minecraft = {
          isNormalUser = true;
        };

        networking.firewall.enable = true;

        # Optional: Set up a volume for Minecraft data (e.g., save worlds, mods, etc.)
        # volumes = [
        #   "/home/minecraft:/mnt/minecraft"  # Uncomment to use a volume for the data
        # ];

        # Access to the display server (X11) from the container
        # Ensure your host machine is running an X server (if you're using X11)
        # You may also want to configure this to match your actual environment setup
        # environment.variables.XAUTHORITY = "/home/minecraft/.Xauthority";
        # environment.variables.DISPLAY = ":0";  # Adjust if necessary based on your setup
      };
  };

  # Optionally, ensure the container has the right permissions to interact with your X server
  # This can help the Minecraft client access the graphical environment from the container
  security.pam.services.xserver = {
    enable = true;
  };
}
