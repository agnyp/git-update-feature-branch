module GitInterface

  def checkout_branch(branch)
    exec_git "git checkout #{branch}", "#{branch} not known. aborting ..."
  end

  def exec_git(command, error_text = "Error ...")
    out=`#{command}`;!suc=$?.success?
    unless suc
      puts error_text
      exit 1
    end
    out
  end

end
