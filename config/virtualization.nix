{
  config,
  ...
}: {
virtualisation.docker = {
	enable = true;
	enableNvidia = false; # TODO:
	autoPrune.enable = true;
	# TODO: extraOptions
	enableOnBoot = false;
};
	users.users."clotodex".extraGroups = [ "docker" ];
}


