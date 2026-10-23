{ myvars, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = myvars.userfullname;
        email = myvars.useremail;
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Delta (syntax-highlighted side-by-side git diffs)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      dark = true;
    };
  };
}
