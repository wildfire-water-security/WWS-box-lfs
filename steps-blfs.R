## Code to Maintain Large Files with Box LFS 
#remotes::install_github("wildfire-water-security/WWS-box-lfs", subdir="blfs")
#install.packages("git2r")

library(blfs)
library(git2r)
library(gitcreds)

#USER 1: start tracking files with Box LFS, push to repo  
  new_repo_blfs(size = 0.0001) 

  #stage, commit, and push
  add(path=c("./box-lfs/*", "readme.md", ".gitignore"))
  commit(message="intialize Box LFS")
  cred <- cred_user_pass(gitcreds_get()$username, gitcreds_get()$password)
  push(cred=cred)

#USER 2: clone repo 
  clone_repo_blfs()

#USER 2: once we've made changes, we want to push and see if we need to upload any files to box 
  #here we haven't made changes so it runs silently, we're good to push any other changes normally
    push_repo_blfs(size=0.0001)

  #now lets change one of the text files being tracked, it tells us to upload changed file  
    cat("\ntesting file changes", file="example-files/large-file1.txt", append=TRUE) #change file
    push_repo_blfs(size=0.0001)

  #now we can push our file changes (the boxtracker will tell others there's a new file to get)
    commit(message="testing file change", all=TRUE)
    cred <- cred_user_pass(gitcreds_get()$username, gitcreds_get()$password)
    push(cred=cred)

#USER 1: starting to work on project pull changes 
    pull(cred=cred) #pull changes from github
    pull_repo_blfs()
    