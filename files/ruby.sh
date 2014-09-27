# add local gem bin for system ruby
PATH="`ruby -e 'print Gem.user_dir'`/bin:$PATH"
# same, but for bundler
export GEM_HOME=$(ruby -e 'print Gem.user_dir')
