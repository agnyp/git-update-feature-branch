module GitInterface

  def checkout_branch(branch)
    exec_git "checkout #{branch}", "#{branch} not known. aborting ..."
  end

  def exec_git(command, error_text = "Error ...")
    out=exec_git!(command);!suc=$?.success?
    unless suc
      puts error_text
      exit 1
    end
    out
  end

  def exec_git!(command)
    `git #{command}`
  end

end
