	  {
  pkgs,
  lib,
  ...
}: {
  # environment.enableDebugInfo = true;
    # services.nixseparatedebuginfod.enable = true;
	environment.systemPackages = with pkgs; [man-pages man-pages-posix];
  documentation = {
    dev.enable = true;
    man.enable = true;
    info.enable = lib.mkForce false;
  };
}
