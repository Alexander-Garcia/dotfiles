-- SET VIM OPTIONS BELOW
local set = vim.opt

-- spaces
set.expandtab = true
set.shiftwidth = 2
set.softtabstop = 2
set.tabstop = 2
set.numberwidth = 4

-- completion
set.completeopt = 'menuone,noselect'

-- sign here
set.signcolumn = 'yes'

-- search and rescue
set.ignorecase = true
set.smartcase = true
set.showmatch = true
set.incsearch = true

-- dont
set.backup = false
set.writebackup = false
set.history = 10000
set.hidden = true

-- line numbers
set.number = true

-- try again
set.undofile = true

-- ignore
set.wildignore = '*/node_modules/*,*/elm-stuff/*'

-- Leader
vim.g.mapleader = ','

-- cursor lines
set.cursorline = true

-- paste
set.pastetoggle = '<F2>'
set.clipboard = 'unnamed'

-- reggie
set.re = 0

-- colors
set.termguicolors = true
set.background = 'dark'

local maps = {
  i = {
    ['<C-c>'] = '<Esc>',
  },
  n = {
    [':'] = ';',
    [';'] = ':',
    ['<leader>a'] = '<cmd>Telescope live_grep<cr>',
    ['<leader>e'] = '<cmd>TroubleToggle workspace_diagnostics<cr>',
    ['<C-n>'] = '<cmd>NvimTreeToggle<cr>',
    ['<C-p>'] = '<cmd>Telescope find_files<cr>',
    ['<leader>b'] = '<cmd>Telescope buffers<cr>',
    ['Y'] = 'yy',
    ['j'] = 'gj',
    ['k'] = 'gk',
    ['[d'] = '<cmd>lua vim.lsp.buf.goto_prev()<cr>',
    [']d'] = '<cmd>lua vim.lsp.buf.goto_next()<cr>',
    ['gd'] = '<cmd>lua vim.lsp.buf.definition()<cr>',
    ['gr'] = '<cmd>lua vim.lsp.buf.references()<cr>',
    ['K'] = '<cmd>lua vim.lsp.buf.hover()<cr>',
    },
  }

  for mode, mappings in pairs(maps) do
    for keys, mapping in pairs(mappings) do
      vim.api.nvim_set_keymap(mode, keys, mapping, { noremap = true })
    end
  end



local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
  -- My plugins here

  -- Packer
  use 'wbthomason/packer.nvim'


  -- theme
  use "EdenEast/nightfox.nvim"
  require('nightfox').setup({
  options = {
    styles = {
      comments = "italic",
      keywords = "italic",
      types = "italic",
    }
  }
})
vim.cmd("colorscheme nightfox")

  -- plug for using jupyter notebook in neovim
  use 'untitled-ai/jupyter_ascending.vim'



  -- colorizer for showing colors when using hex and rgb stuff
  use {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end
  }

  -- Git
  use 'tpope/vim-fugitive'
  use 'airblade/vim-gitgutter'

   -- Finder
  use {
    'nvim-telescope/telescope.nvim',
    run = 'vim.cmd[[TSUpdate]]',
    requires = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = {
            '.git',
            'node_modules',
          },
        }
      }
    end
  }

  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    config = function()
      require('telescope').load_extension('fzf')
    end
  }


  -- File browser
  use {
    'kyazdani42/nvim-tree.lua',
    config = function()
      require('nvim-tree').setup {
        renderer = {
          icons = {
            show = {
              file = true,
              folder_arrow = true,
              folder = true,
              git = false,
            },
          },
          special_files = {
            'Makefile',
            'Cargo.toml',
            'README.md',
            'readme.md',
          },
        },
      }
    end
  }

  -- Comment stuff out
  use 'tpope/vim-commentary'

  -- markdown preview
  use {'iamcco/markdown-preview.nvim'}


-- LSP
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local nvim_lsp = require('lspconfig')
      local servers = {
        'bashls',
        'cssls',
        'dockerls',
        'html',
        'ocamlls',
        'pyright',
        'svelte',
        'tsserver',
        'vimls',
      }

      for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {}
      end

      nvim_lsp.eslint.setup {
        handlers = {
          ['window/showMessageRequest'] = function(_, result, params) return result end
        }
      }
    end
  }

  -- Treesitter syntax
  use {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufRead',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = 'all',
        ignore_install = {'phpdoc'},
        highlight = {
          enable = true,
          use_languagetree = true,
        },
      }
    end
  }

   -- Status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    config = function()
      -- Get character under cursor
      local get_hex = function()
        local hex = vim.api.nvim_exec([[
          ascii
        ]], true)
        if hex == nil then
          return 'nil'
        end

        hex = hex:match(',  Hex ([^,]+)')
        if hex == nil then
          return 'nil'
        end

        return '0x' .. hex
      end

      require('lualine').setup {
        options = {
          icons_enabled = true,
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          theme = 'dracula',
        },
        sections = {
          lualine_b = {
            'branch',
            'diff'
          },
          lualine_y = {
            {
              'diagnostics',
              sources = {
                'nvim_diagnostic'
              },
              symbols = {
                error = ' ',
                warn = ' ',
                info = ' '
              },
              color_error = '#ea51b2',
              color_warn = '#00f769',
              color_info = '#a1efe4',
            },
            get_hex,
          },
        },
      }
    end
  }

  -- Icons
  use {
    'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {
        default = true,
        override = {
          ['.conkyrc'] = {
            icon = '',
            color = '#6d8086',
            name = 'Conkyrc'
          },
          ['.xinitrc'] = {
            icon = '',
            color = '#6d8086',
            name = 'Xinitrc'
          },
          ['.Xresources'] = {
            icon = '',
            color = '#6d8086',
            name = 'XResources',
          },
        }
      }
    end
  }


   -- Diagnostics
  use {
    'folke/trouble.nvim',
    config = function()
      require('trouble').setup {}
    end
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)


