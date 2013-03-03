task :deploy do
  desc "push code to github and heroku"

  `git checkout master`
  `git merge development`
  `rake create_version`
  `git push origin master`
  `git push heroku master`
  `git checkout development`
end
