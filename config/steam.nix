# gaming.nix
#
# Drop-in NixOS module for running Trackmania 2020 (and Windows games in
# general) via Steam + Proton. Tested target: NixOS 25.11 / unstable, x86_64.
#
# Usage:
#   1. Place this file alongside your configuration.nix.
#   2. Add it to your imports list:
#        imports = [ ./hardware-configuration.nix ./gaming.nix ];
#   3. sudo nixos-rebuild switch && reboot
#
# What it gives you:
#   - Zen kernel with NTSync enabled (kernel-level Windows synchronization
#     primitives, big perf/correctness win for Wine/Proton)
#   - Steam + GE-Proton (declaratively pinned, no protonup needed)
#   - GameMode (CPU governor / IO niceness tweaks while a game is running)
#   - Gamescope (Valve's micro-compositor; useful for fixed res / FSR / HDR)
#   - 32-bit graphics libs (Steam runtime + some Proton bits still need them)
#   - protontricks (for installing Openplanet, vcrun, etc. into the prefix)
#   - MangoHud (FPS/frametime overlay)
#
# After rebooting, verify:
#   uname -r                  # should show a *-zen* kernel
#   ls -l /dev/ntsync         # should exist, mode crw-rw-rw-
#   lsmod | grep ntsync       # should show the module loaded
#
# Then in Steam:
#   Settings -> Compatibility -> Enable Steam Play for all other titles
#   Set "Run other titles with" to GE-Proton (latest), or per-game via
#   right-click -> Properties -> Compatibility.
#
# Black main-library window workaround (Niri/XWayland + Mesa Intel):
#   Settings -> Interface -> turn OFF "GPU Accelerated Rendering in Web Views".
#   Symptom: login/chat/popups paint, only the CEF main view is black. Cause
#   is Chromium GPU compositing failing under XWayland; the toggle keeps
#   hardware GL for games and only disables it for the Steam UI. Persists
#   in ~/.local/share/Steam/, so this only matters on a fresh Steam config.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  ###########################################################################
  # Kernel: NTSync + Intel iGPU stability for gaming
  ###########################################################################
  # NTSync replaces esync/fsync in Wine/Proton with kernel-level Windows
  # synchronization primitives — large stability and perf win for games.
  # Stock mainline kernel 6.10+ ships it as a module (CONFIG_NTSYNC=m), so
  # we just need to load it.
  boot.kernelModules = [ "ntsync" ];

  # Intel Alder Lake (Iris Xe, PCI 8086:46A6) ships in modern kernels with
  # both `i915` (legacy, stable) and `xe` (new, still maturing) modules
  # autoloaded. They fight over the same device and the conflict manifests
  # as `i915 GPU HANG` under heavy DXVK workloads (e.g. Trackmania at high
  # MSAA). For Alder Lake in 2026, i915 is the stable choice — keep it and
  # prevent xe from binding.
  boot.blacklistedKernelModules = [ "xe" ];
  boot.kernelParams = [
    "xe.force_probe=!46a6" # tell xe to NOT bind this device
    "i915.enable_guc=3" # enable GuC submission + HuC firmware load
  ];

  # ALTERNATIVE (uncomment if you want to stay on linuxPackages_latest /
  # mainline instead of Zen). This will force a *local* kernel rebuild on
  # every kernel bump (no binary cache), so expect the first nixos-rebuild
  # after enabling this to take a while.
  #
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPatches = [{
  #   name = "enable-ntsync";
  #   patch = null;
  #   structuredExtraConfig = with lib.kernel; {
  #     NTSYNC = module;
  #   };
  # }];

  ###########################################################################
  # Allow unfree (Steam, GE-Proton, Steam runtime are unfree)
  ###########################################################################
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
      "proton-ge-bin"
    ];

  ###########################################################################
  # Graphics stack
  ###########################################################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit GL/Vulkan for Steam runtime
    extraPackages = with pkgs; [
      # VDPAU shims — not needed on Intel iGPU (NVIDIA-stack / legacy VDPAU apps)
      # libva-vdpau-driver
      # libvdpau-va-gl
      # Intel iGPU video acceleration (Iris Xe / Gen12+)
      intel-media-driver
      vpl-gpu-rt
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      # 32-bit VDPAU shims — Steam/Proton don't exercise these on Intel
      # libva-vdpau-driver
      # libvdpau-va-gl
    ];
  };

  ###########################################################################
  # Steam
  ###########################################################################
  programs.steam = {
    enable = true;

    # Open ports for Remote Play (harmless if you don't use it).
    remotePlay.openFirewall = true;

    # Declaratively make GE-Proton available in Steam's compatibility tool
    # dropdown. No need for ProtonUp-Qt unless you want a GUI to swap
    # specific GE versions.
    extraCompatPackages = [ pkgs.proton-ge-bin ];

    # Workaround for nixpkgs#389142: Steam runs games inside an FHS sandbox
    # and won't see libgamemode.so unless we inject it into the wrapper.
    package = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          gamemode
          # Some games / launchers also pull these in:
          keyutils
          libkrb5
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libxcursor
          libxi
          libxinerama
          libxscrnsaver
        ];
    };
  };

  ###########################################################################
  # GameMode (Feral)
  ###########################################################################
  # Use it via Steam launch options: gamemoderun %command%
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        # Inhibit the screensaver while gaming
        inhibit_screensaver = 1;
      };
      # If you have a discrete GPU later, you can add a [gpu] section here.
    };
  };

  ###########################################################################
  # Gamescope (optional, useful for fixed resolution / FSR / HDR)
  ###########################################################################
  # Use via Steam launch options, e.g.:
  #   gamemoderun gamescope -W 1920 -H 1080 -r 144 -f -- %command%
  # The -F fsr flag enables AMD FSR upscaling, useful on iGPUs:
  #   gamescope -W 1920 -H 1080 -F fsr -w 1280 -h 720 -- %command%
  programs.gamescope = {
    enable = true;
    capSysNice = false; # avoid conflict with gamemode renicing
  };

  ###########################################################################
  # Useful gaming utilities on PATH
  ###########################################################################
  environment.systemPackages = with pkgs; [
    mangohud # FPS / frametime / temp overlay (MANGOHUD=1 %command%)
    protontricks # Required for Openplanet install + per-prefix tweaks
    protonup-qt # Optional GUI for managing extra GE-Proton versions
    winetricks # Useful when poking around prefixes manually

    # Optional: keep Lutris around as an alternative install path
    # (e.g. native Ubisoft Connect without Steam in the loop).
    # lutris

    # Optional: vulkan tools for sanity checks
    vulkan-tools # provides `vulkaninfo`, useful: `vulkaninfo | head -n 30`
  ];

  ###########################################################################
  # Sensible per-user / system-wide gaming env defaults
  ###########################################################################
  environment.sessionVariables = {
    # Persistent shader caches across runs (Mesa)
    MESA_SHADER_CACHE_DIR = "$HOME/.cache/mesa_shader_cache";
    # Larger DXVK shader cache
    DXVK_STATE_CACHE_PATH = "$HOME/.cache/dxvk";
  };

  ###########################################################################
  # Misc niceties
  ###########################################################################
  # Some games rely on more file descriptors than the default soft limit.
  systemd.settings.Manager = {
    DefaultLimitNOFILE = 1048576;
  };
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];
}
