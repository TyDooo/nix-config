{
  lib,
  writeShellApplication,
  rsync,
  ...
}:
(writeShellApplication {
  name = "mover";
  runtimeInputs = [rsync];
  text = builtins.readFile ./mover.sh;
})
// {
  meta = with lib; {
    licenses = licenses.mit;
    platforms = platforms.all;
  };
}
