self: super: 
{
  emacs = super.lib.overrideDerivation super.emacs (attrs: {
    version = "26.2";
    src = self.fetchurl {
      url = "mirror://gnu/emacs/${attrs.name}.tar.xz";
      sha256 = "13n5m60i47k96mpv5pp6km2ph9rv2m5lmbpzj929v02vpsfyc70m";
    };
    patches = [ ./1.patch ];
  });
}
