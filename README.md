# My Neovim Configuration Scripts



<img width="1822" alt="68064" src="https://github.com/user-attachments/assets/6114599f-eb3d-471e-87f6-401a705eda32" />

Welcome to my Neovim configuration repository! This repository contains my custom Neovim setup, including plugins and configurations tailored for an enhanced coding experience.

## Repository Structure

This repository is organized as follows:

- **Plugin Configuration Files:** Each plugin has its own Lua configuration file for modularity and ease of maintenance.
- **Main Directory:** Contains all the plugin-specific configuration files.

## Plugins Included

Here is a list of the plugins I am using, along with their purposes:

| Plugin Name                    | Description                                                                                   |
|--------------------------------|-----------------------------------------------------------------------------------------------|
| **Alpha**                      | Welcome screen for Neovim.                                                                   |
| **Catppuccin**                 | A beautiful color theme for Neovim.                                                          |
| **Completions**                | Asynchronous two-stage chain completion with LSP support.                                    |
| **Git Stuff**                  | Configuration for Git integration.                                                           |
| **Gitsigns**                   | Perform Git operations directly within the editor.                                           |
| **LSP Config**                 | Portable package manager to set up LSP servers easily.                                       |
| **Mini Map**                   | Displays an overview of buffer text in a minimap.                                            |
| **Neo Tree**                   | A file explorer plugin for Neovim.                                                          |
| **None LS**                    | Bridges the gap between LSP and non-LSP tools.                                               |
| **Nvim Tmux Navigation**       | Enables seamless navigation between Neovim and Tmux panes.                                   |
| **Oil**                        | A file explorer plugin that lets you edit files directly like a text buffer.                |
| **Swagger Preview**            | Provides live preview functionality for Swagger/OpenAPI files.                              |
| **Telescope**                  | Overrides Neovim's default UI with a highly customizable fuzzy finder interface.             |
| **Treesitter**                 | Provides advanced syntax highlighting and code understanding capabilities.                   |
| **Vim Test**                   | A versatile testing plugin that allows running tests directly from the editor.               |

## Installation

To use this configuration, follow these steps:

1. Clone this repository:

```
git clone https://github.com/Dinujaya-Sandaruwan/my-neovim-configuration-scripts.git ~/.config/nvim
```

3. Install [Neovim](https://neovim.io/) if you haven't already.

4. Install [lazy.nvim](https://github.com/folke/lazy.nvim) as your plugin manager:
- Open Neovim and run:
  ```
  git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/lazy/lazy.nvim
  ```

4. Launch Neovim, and lazy.nvim will automatically detect the plugins listed in your configuration files.

5. Run the following command to install all plugins:


## How to Use

- Launch Neovim, and you'll be greeted with the Alpha welcome screen.
- Start coding with features like Git integration, LSP support, file exploration, and more!

## Contribution

Feel free to fork this repository and customize it further to suit your needs! If you have any suggestions or improvements, feel free to open an issue or submit a pull request.


