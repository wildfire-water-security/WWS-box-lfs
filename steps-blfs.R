## Code to Maintain Large Files with Box LFS: testing scenarios to ensure it works as expected
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

#USER 1: starting to work on project again so pull changes, get new copy of file 
    pull(cred=cred) #pull changes from github
    pull_repo_blfs() 
    
    #do some work, maybe not on the file 
    push_repo_blfs(size=0.0001) #runs silently as it should 
    
#USER 1 and 2: 
    #what happens if both try to make changes before pulling changes? 
    cat("\ntesting file changes:user 1", file="example-files/large-file1.txt", append=TRUE) #change file
    push_repo_blfs(size=0.0001)
    
    #what happens if both try to make changes before pulling changes? 
    cat("\ntesting file changes:user 2", file="example-files/large-file1.txt", append=TRUE) #change file
    push_repo_blfs(size=0.0001)
    
    commit(message="testing file change", all=TRUE)
    cred <- cred_user_pass(gitcreds_get()$username, gitcreds_get()$password)
    push(cred=cred) 
    
    #get merge commit error and need to resolve manually 

#USER 1: 
    #what happens if both try to make changes and don't push, then pull -> get warned to upload files
    cat("\ntesting file changes:user 1, no push", file="example-files/large-file1.txt", append=TRUE) #change file
    pull(cred=cred) #pull changes from github
    pull_repo_blfs()
    
  