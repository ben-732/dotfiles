return { 
  {
    "ahmedkhalf/project.nvim",
      config = function ()
        require('project_nvim').setup({
          manual_mode = false,
          silent_chdir = true,
          scope_chdir = 'global',
        })

        pcall(function() 
          require("telescope").load_extension("projects") 
        end)
      end
    }
}
