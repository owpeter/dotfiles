{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
  
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      Vundle-vim
      nerdtree
      # youcompleteme
      vim-monokai
      vim-airline
      vim-airline-themes
      vim-markdown
      vim-cpp-enhanced-highlight
      vim-signify
      ale
      gruvbox
      rainbow
    ];

    extraConfig = ''
      ${builtins.readFile ../../files/editor/vimrc}
    '';
  };
}