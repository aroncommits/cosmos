{ pkgs, ... }: {
  home.packages = with pkgs; [ git-extras ];

  programs.git = {
    enable = true;

    # TODO read from a config file
    userName = "Aron Nash";
    userEmail = "commit@arona.sh";

    signing = {
      signByDefault = true;
      # defining it ismportant for tools like pass.
      # TODO read from a config file
      key = "hi@arona.sh";
    };

    extraConfig = {
      init = {
        # Set default branch name to main, to shut the client up for
        # reminding you of it.
        defaultBranch = "main";
      };
      push = {
        # Automatically set the remote when pushing.
        autoSetupRemote = true;
      };
    };
  };

  # TODO allow for custom imports
}
