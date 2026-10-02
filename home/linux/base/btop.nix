{ ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "catppuccin_mocha";
      theme_background = false;
      truecolor = true;
      force_tty = false;
      presets = "cpu:1:default,mem:0:default,proc:1:default,net:0:default";
      graph_symbol = "braille";
      shown_boxes = "proc cpu mem net";
      update_ms = 1500;
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = true;
      proc_mem_bytes = true;
    };
  };
}
