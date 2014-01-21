require 'ruby-progressbar'

progressbar = ProgressBar.create
50.times do
  progressbar.increment
  sleep(0.5)
end