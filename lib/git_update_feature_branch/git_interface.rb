module GitInterface

  def checkout_branch(branch)
    `git checkout #{branch}`;err=$?.success?
    if !err
      puts "branch not known. aborting ..."
      exit 1
    end
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
