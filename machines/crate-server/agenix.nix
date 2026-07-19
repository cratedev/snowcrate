{inputs, ...}: {
  imports = [(import ../agenix.nix "server")];

  age.secrets.unraidDeployKey = {
    file = "${inputs.mysecrets}/secrets/server/unraid_deploy_key.age";
    path = "/persist/etc/unraid_deploy_key";
    mode = "400";
    owner = "matt";
    group = "users";
  };
}
